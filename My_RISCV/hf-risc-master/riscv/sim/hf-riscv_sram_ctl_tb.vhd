library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_unsigned.all;
use std.textio.all;
use ieee.numeric_std.all;

entity tb is
	generic(
		address_width: integer := 16;
		memory_file : string := "code.txt";
		log_file: string := "out.txt";
		uart_support : string := "no"
	);
end tb;

architecture tb of tb is
	signal clock_in, reset, stall_cpu, data, stall, stall_sig: std_logic := '0';
	signal uart_read, uart_write: std_logic;
	signal boot_enable_n, ram_enable_n, irq_cpu, irq_ack_cpu, exception_cpu, burst, data_b_cpu, data_h_cpu, data_access_cpu, ram_dly: std_logic;
	signal address, data_read, data_write, data_read_boot, data_read_ram, data_read_sram, irq_vector_cpu, address_cpu, data_in_cpu, data_out_cpu: std_logic_vector(31 downto 0);
	signal ext_irq: std_logic_vector(7 downto 0);
	signal data_we, data_w_n_ram, data_w_cpu: std_logic_vector(3 downto 0);
	signal wr, rd, stall_dly, stall_dly2, stall_sram, spi_cs, spi_clk, spi_mosi, spi_miso, hold_n: std_logic := '0';
begin

	process						--25Mhz system clock
	begin
		clock_in <= not clock_in;
		wait for 20 ns;
		clock_in <= not clock_in;
		wait for 20 ns;
	end process;

	reset <= '0', '1' after 5 ns, '0' after 500 ns;
	stall_sig <= stall_sram;
	ext_irq <= x"00";
	uart_read <= '1';
	boot_enable_n <= '0' when (address(31 downto 28) = "0000" and stall_cpu = '0') or reset = '1' else '1';
	ram_enable_n <= '0' when (address(31 downto 28) = "0100" and stall_cpu = '0') or reset = '1' else '1';
	rd <= '1' when (address(31 downto 28) = "0110" and data_we = "0000" and stall_dly2 = '0') else '0';
	wr <= '1' when (address(31 downto 28) = "0110" and data_we /= "0000" and stall_dly2 = '0') else '0';
	data_read <= data_read_boot when address(31 downto 28) = "0000" and ram_dly = '0' else
	data_read_sram when address(31 downto 28) = "0110" or stall_dly2 = '1' else data_read_ram;
	data_w_n_ram <= not data_we;
	hold_n <= '1';
	burst <= '0';

	process(clock_in, reset, stall_sram)
	begin
		if reset = '1' then
			ram_dly <= '0';
			stall_dly <= '0';
			stall_dly2 <= '0';
		elsif clock_in'event and clock_in = '1' then
			ram_dly <= not ram_enable_n;
			stall_dly <= stall_sram;
			stall_dly2 <= stall_dly;
		end if;
	end process;

	-- HF-RISCV core
	core: entity work.datapath
	port map(	clock => clock_in,
			reset => reset,
			stall => stall_cpu,
			irq_vector => irq_vector_cpu,
			irq => irq_cpu,
			irq_ack => irq_ack_cpu,
			exception => exception_cpu,
			address => address_cpu,
			data_in => data_in_cpu,
			data_out => data_out_cpu,
			data_w => data_w_cpu,
			data_b => data_b_cpu,
			data_h => data_h_cpu,
			data_access => data_access_cpu
	);

	-- peripherals / busmux logic
	peripherals_busmux: entity work.busmux
	generic map(
		log_file => log_file,
		uart_support => uart_support
	)
	port map(
		clock => clock_in,
		reset => reset,

		stall => stall_sig,

		stall_cpu => stall_cpu,
		irq_vector_cpu => irq_vector_cpu,
		irq_cpu => irq_cpu,
		irq_ack_cpu => irq_ack_cpu,
		exception_cpu => exception_cpu,
		address_cpu => address_cpu,
		data_in_cpu => data_in_cpu,
		data_out_cpu => data_out_cpu,
		data_w_cpu => data_w_cpu,
		data_access_cpu => data_access_cpu,

		addr_mem => address,
		data_read_mem => data_read,
		data_write_mem => data_write,
		data_we_mem => data_we,
		extio_in => ext_irq,
		extio_out => open,
		uart_read => uart_read,
		uart_write => uart_write
	);

	sram_ctrl_core: entity work.spi_sram_ctrl
	port map(	clk_i => clock_in,
			rst_i => reset,
			addr_i => address(23 downto 0),
			data_i => data_write,
			data_o => data_read_sram,
			burst_i => burst,
			bmode_i => data_b_cpu,
			hmode_i => data_h_cpu,
			wr_i => wr,
			rd_i => rd,
			data_ack_o => open,
			cpu_stall_o => stall_sram,
			spi_cs_n_o => spi_cs,
			spi_clk_o => spi_clk,
			spi_mosi_o => spi_mosi,
			spi_miso_i => spi_miso
	);

	spi_sram: entity work.M23LC1024
	port map(	SI_SIO0 => spi_mosi,
			SO_SIO1 => spi_miso,
			SCK => spi_clk,
			CS_N => spi_cs,
			SIO2 => open,
			HOLD_N_SIO3 => hold_n,
			RESET => reset
	);

	-- boot ROM
	boot0lb: entity work.boot_ram
	generic map (	memory_file => "boot.txt",
					data_width => 8,
					address_width => 12,
					bank => 0)
	port map(
		clk 	=> clock_in,
		addr 	=> address(11 downto 2),
		cs_n 	=> boot_enable_n,
		we_n	=> '1',
		data_i	=> (others => '0'),
		data_o	=> data_read_boot(7 downto 0)
	);

	boot0ub: entity work.boot_ram
	generic map (	memory_file => "boot.txt",
					data_width => 8,
					address_width => 12,
					bank => 1)
	port map(
		clk 	=> clock_in,
		addr 	=> address(11 downto 2),
		cs_n 	=> boot_enable_n,
		we_n	=> '1',
		data_i	=> (others => '0'),
		data_o	=> data_read_boot(15 downto 8)
	);

	boot1lb: entity work.boot_ram
	generic map (	memory_file => "boot.txt",
					data_width => 8,
					address_width => 12,
					bank => 2)
	port map(
		clk 	=> clock_in,
		addr 	=> address(11 downto 2),
		cs_n 	=> boot_enable_n,
		we_n	=> '1',
		data_i	=> (others => '0'),
		data_o	=> data_read_boot(23 downto 16)
	);

	boot1ub: entity work.boot_ram
	generic map (	memory_file => "boot.txt",
					data_width => 8,
					address_width => 12,
					bank => 3)
	port map(
		clk 	=> clock_in,
		addr 	=> address(11 downto 2),
		cs_n 	=> boot_enable_n,
		we_n	=> '1',
		data_i	=> (others => '0'),
		data_o	=> data_read_boot(31 downto 24)
	);

	-- RAM
	memory0lb: entity work.bram
	generic map (	memory_file => memory_file,
					data_width => 8,
					address_width => address_width,
					bank => 0)
	port map(
		clk 	=> clock_in,
		addr 	=> address(address_width -1 downto 2),
		cs_n 	=> ram_enable_n,
		we_n	=> data_w_n_ram(0),
		data_i	=> data_write(7 downto 0),
		data_o	=> data_read_ram(7 downto 0)
	);

	memory0ub: entity work.bram
	generic map (	memory_file => memory_file,
					data_width => 8,
					address_width => address_width,
					bank => 1)
	port map(
		clk 	=> clock_in,
		addr 	=> address(address_width -1 downto 2),
		cs_n 	=> ram_enable_n,
		we_n	=> data_w_n_ram(1),
		data_i	=> data_write(15 downto 8),
		data_o	=> data_read_ram(15 downto 8)
	);

	memory1lb: entity work.bram
	generic map (	memory_file => memory_file,
					data_width => 8,
					address_width => address_width,
					bank => 2)
	port map(
		clk 	=> clock_in,
		addr 	=> address(address_width -1 downto 2),
		cs_n 	=> ram_enable_n,
		we_n	=> data_w_n_ram(2),
		data_i	=> data_write(23 downto 16),
		data_o	=> data_read_ram(23 downto 16)
	);

	memory1ub: entity work.bram
	generic map (	memory_file => memory_file,
					data_width => 8,
					address_width => address_width,
					bank => 3)
	port map(
		clk 	=> clock_in,
		addr 	=> address(address_width -1 downto 2),
		cs_n 	=> ram_enable_n,
		we_n	=> data_w_n_ram(3),
		data_i	=> data_write(31 downto 24),
		data_o	=> data_read_ram(31 downto 24)
	);

	-- debug process
	debug:
	if uart_support = "no" generate
		process(clock_in, address_cpu)
			file store_file : text open write_mode is "debug.txt";
			variable hex_file_line : line;
			variable c : character;
			variable index : natural;
			variable line_length : natural := 0;
		begin
			if clock_in'event and clock_in = '1' then
				if address_cpu = x"f00000d0" and data = '0' then
					data <= '1';
					index := conv_integer(data_write(30 downto 24));
					if index /= 10 then
						c := character'val(index);
						write(hex_file_line, c);
						line_length := line_length + 1;
					end if;
					if index = 10 or line_length >= 72 then
						writeline(store_file, hex_file_line);
						line_length := 0;
					end if;
				else
					data <= '0';
				end if;
			end if;
		end process;
	end generate;

	process(clock_in, reset, address)
	begin
		if reset = '1' then
		elsif clock_in'event and clock_in = '0' then
			assert address /= x"e0000000" report "end of simulation" severity failure;
			assert (address < x"70000000") or (address >= x"f0000000") report "out of memory region" severity failure;
			assert address /= x"40000100" report "handling IRQ" severity warning;
		end if;
	end process;

end tb;

