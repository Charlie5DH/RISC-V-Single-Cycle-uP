library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_textio.all;
use ieee.std_logic_unsigned.all;

entity tb is
end tb;

architecture tb of tb is
	signal clock, reset, we, valid, spi_ssn, spi_clk_i, spi_clk_o, spi_mosi, spi_miso: std_logic := '0';
	signal input, output: std_logic_vector(7 downto 0);
	signal clk_div: std_logic_vector(2 downto 0);
begin

	reset <= '0', '1' after 5 ns, '0' after 500 ns;

	process						--25Mhz system clock
	begin
		clock <= not clock;
		wait for 20 ns;
		clock <= not clock;
		wait for 20 ns;
	end process;

	spi_ssn <= '1', '0' after 5600 ns, '1' after 10000 ns;
	we <= '0', '1' after 1002 ns, '0' after 4600 ns;
	spi_miso <= '0', '1' after 2460 ns, '0' after 3000 ns, '1' after 6050 ns, '1' after 6250 ns, '1' after 6450 ns, '1' after 6650 ns, '0' after 6850 ns, '0' after 7050 ns, '0' after 7250 ns, '0' after 7450 ns, '1' after 7650 ns, '1' after 7850 ns, '0' after 8050 ns, '0' after 8250 ns, '0' after 8450 ns, '0' after 8650 ns, '1' after 8850 ns, '1' after 9050 ns;
	spi_clk_i <= '0', '1' after 6100 ns, '0' after 6300 ns, '1' after 6500 ns, '0' after 6700 ns, '1' after 6900 ns, '0' after 7100 ns, '1' after 7300 ns, '0' after 7500 ns, '1' after 7700 ns, '0' after 7900 ns, '1' after 8100 ns, '0' after 8300 ns, '1' after 8500 ns, '0' after 8700 ns, '1' after 8900 ns, '0' after 9100 ns;
	input <= x"a1";
	clk_div <= "000";



	spi_core: entity work.spi_master_slave
	generic map(
		BYTE_SIZE => 8
	)
	port map(	clk_i => clock,
			rst_i => reset,
			data_i => input,
			data_o => output,
			data_valid_o => valid,
			wren_i => we,
			clk_div_i => clk_div,
			spi_ssn_i => spi_ssn,
			spi_clk_i => spi_clk_i,
			spi_clk_o => spi_clk_o,
			spi_do_o => spi_mosi,
			spi_di_i => spi_miso
	);

end tb;
