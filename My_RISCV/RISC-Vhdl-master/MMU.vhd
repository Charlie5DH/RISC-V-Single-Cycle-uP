-- VHDL implementation of RISC-V-ISA
-- Copyright (C) 2016 Chair of Computer Architecture
-- at Technical University of Munich
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see <http://www.gnu.org/licenses/>.


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity MMU is
port (
		--Clocking and reset ports
		reset_in : in std_logic;
		clk_in : in std_logic;
		clk90_in : in std_logic;

		--Ports connected to CPU
		data_out: out std_logic_vector(31 downto 0);
		data_in: in std_logic_vector(31 downto 0);
		addr_in: in std_logic_vector(31 downto 0);
		cmd_in: in std_logic_vector(2 downto 0);
		work_in : in std_logic;
		ack_out : out std_logic;
		
		--Ports connected to DRR2_RAM_CORE
		init_done : in std_logic;
		command_register : out std_logic_vector(2 downto 0);
		input_adress : out std_logic_vector(24 downto 0);
		input_data : out std_logic_vector(31 downto 0);
		output_data : in std_logic_vector(31 downto 0);
		cmd_ack : in std_logic;
		data_valid : in std_logic;
		burst_done : out std_logic;
		auto_ref_req : in std_logic;
		
		char_out: out std_logic_vector(7 downto 0);	
		char_addr_in : in std_logic_vector( 10 downto 0);
		
		pins_in  : in  std_logic_vector(31 downto 0);
		pins_out : out std_logic_vector(15 downto 0);
		
		mmu_state_out : out std_logic_vector(31 downto 0);
		ddr2_cntrl_state_out : out std_logic_vector(31 downto 0)
	);
end MMU;




architecture Behavioral of MMU is

	-- CHARRAM Control --
	component CHARRAM is
	port(
		clk : in std_logic;
		rst : in std_logic;
		addr_in : in std_logic_vector(10 downto 0); --9 bit for adressing 512 32-bit cells
		data_in : in std_logic_vector(7 downto 0);
		data_out: out std_logic_vector(7 downto 0);
			
		write_enable : in std_logic;
		
		char_out: out std_logic_vector(7 downto 0);	
		char_addr_in : in std_logic_vector( 10 downto 0)
	);
	end component CHARRAM;

	-- PROGRAMRAM Control --
	component PRAM is
	Port(
			clk : in std_logic;
			rst : in std_logic;
			addr_in : in std_logic_vector(10 downto 0); --11 bit for adressing 8-bit cells
			data_in : in std_logic_vector(7 downto 0);
			data_out: out std_logic_vector(7 downto 0);
			write_enable : in std_logic
		
	);
	end component PRAM;

	-- BLOCKRAM Control --
	component BLOCKRAM is
	Port(
			clk : in std_logic;
			rst : in std_logic;
			addr_in : in std_logic_vector(10 downto 0); --11 bit for adressing 8-bit cells
			data_in : in std_logic_vector(7 downto 0);
			data_out: out std_logic_vector(7 downto 0);
			write_enable : in std_logic
		
	);
	end Component BLOCKRAM;

	-- DDR2 Control --
	COMPONENT DDR2_Control_VHDL is
	PORT (
		 		reset_in : in std_logic;
				clk_in : in std_logic;
				clk90_in : in std_logic;

				maddr   : in std_logic_vector(15 downto 0);
				mdata_i : in std_logic_vector(7 downto 0);
				data_out : out std_logic_vector(7 downto 0);
				mwe	  : in std_logic;
				mrd    : in std_logic;
				uidle : out std_logic;
				ucmd_ack : out std_logic;
				state_out : out std_logic_vector(31 downto 0);
				
				init_done : in std_logic;
				command_register : out std_logic_vector(2 downto 0);
				input_adress : out std_logic_vector(24 downto 0);
				input_data : out std_logic_vector(31 downto 0);
				output_data : in std_logic_vector(31 downto 0);
				cmd_ack : in std_logic;
				data_valid : in std_logic;
				burst_done : out std_logic;
				auto_ref_req : in std_logic
	);
	END COMPONENT DDR2_Control_VHDL;
	
	-- IO RAM --
	COMPONENT IORAM is
	Port(
	
		clk : in std_logic;
		rst : in std_logic;
	
		pin_in : in std_logic_vector(31 downto 0);
		pin_out : out std_logic_vector(15 downto 0);
		
		addr_in : in std_logic_vector(2 downto 0); --2 bit for 64 bit IO access
		data_in : in std_logic_vector(7 downto 0);
		data_out: out std_logic_vector(7 downto 0);
		write_enable : in std_logic
	);
	END COMPONENT IORAM;

	type MMU_STATE_T is (
			MMU_WAITING,
			MMU_DATA_VALID,
			MMU_READ_NEXT,
			MMU_READ_DONE,
			MMU_WRITE_NEXT,
			MMU_WRITE_DONE,
			MMU_RESET,
			MMU_IDLE
		);
	signal MMU_STATE : MMU_STATE_T := MMU_IDLE;
	
	signal read_data : std_logic_vector (31 downto 0);
	
	signal data_in_buf : std_logic_vector(31 downto 0); --Buffer for the write input data from CPU
	signal addr_in_buf : std_logic_vector(31 downto 0); --Signal to buffer an address for access cycles
	signal access_remaining : unsigned(2 downto 0); --Buffering how many accesses (r/w) are still requested
	signal write_mode : std_logic;
	
	
	--Intern signals to be conncted to asram
	signal cr_addr_in :  std_logic_vector(10 downto 0);
	signal cr_data_in : std_logic_vector(7 downto 0);
	signal cr_data_out :	std_logic_vector(7 downto 0);
	signal cr_write_enable : std_logic := '0';
	
	--Intern signals to be connected to ioram
	signal io_addr_in : std_logic_vector(2 downto 0);
	signal io_data_in : std_logic_vector(7 downto 0);
	signal io_data_out : std_logic_vector(7 downto 0);
	signal io_write_enable : std_logic := '0';
	
	--Intern signals to be conncted to bram
	signal br_data_in : std_logic_vector(7 downto 0);
	signal br_data_out : std_logic_vector(7 downto 0);
	signal br_write_enable : std_logic := '0';
	signal br_addr_in : std_logic_vector(10 downto 0);
	
	--Intern signals to be connected to pram
	signal pr_data_in : std_logic_vector(7 downto 0);
	signal pr_data_out : std_logic_vector(7 downto 0);
	signal pr_write_enable : std_logic := '0';
	signal pr_addr_in : std_logic_vector(10 downto 0);
	
	--Intern signals to be connected to ddr2sdram
	signal ddr2_addr_in : std_logic_vector(15 downto 0);
	signal ddr2_data_in : std_logic_vector(7 downto 0) := (others => '0');
	signal ddr2_data_out : std_logic_vector(7 downto 0) := (others => '0');
	signal ddr2_write_enable : std_logic := '0';
	signal ddr2_read_enable : std_logic := '0';
	signal ddr2_ready : std_logic;
	signal ddr2_ack : std_logic;
	signal ddr2_accessed : std_logic;
	
	begin
	
	
		process(clk_in) begin

			
			if rising_edge(clk_in) then
			
				if reset_in = '1' then
				
					ack_out <= '0';
					ddr2_read_enable <= '0';
					ddr2_write_enable <= '0';
					br_write_enable <= '0'; --Prevent additional data write during skipped cycle
					cr_write_enable <= '0';
					pr_write_enable <= '0';
					MMU_STATE <= MMU_RESET;
					data_out <= (others => '0');
					addr_in_buf <= (others => '0');
					
				
				else
					
				
					case MMU_STATE is
						
						when MMU_RESET =>
							mmu_state_out <= x"11111111";
							-- ensure that we can handle ddr2 requests after a reset
							if ddr2_ready = '1' then
								MMU_STATE <= MMU_IDLE;
							end if;
					
						when MMU_IDLE =>
						
							mmu_state_out <= x"22222222";
							--we wait for work_in input
							if work_in = '1' then
								data_in_buf <= data_in;
								ack_out <= '0'; --CPU has to wait until MMU has finished
								addr_in_buf <= addr_in; --Buffer the adress in any case
								
								write_mode <= cmd_in(2);
								if cmd_in(2) = '1' then
									--In read mode we always read 32-Bit as definied in CU
									case cmd_in(1 downto 0) is
									
										when "00" => access_remaining <= to_unsigned(1, access_remaining'length);
										when "01" => access_remaining <= to_unsigned(2, access_remaining'length);
										--when "10" => access_remaining <= to_unsigned(4, access_remaining'length); --prohibited
										when "11" => access_remaining <= to_unsigned(4, access_remaining'length);
										when others =>NULL;

									end case;
								else
									read_data(31 downto 0) <= (others=>'0'); --Clear the buffer (should not be required since we always read 32-bit but whatsoever)
									access_remaining <= to_unsigned(4, access_remaining'length);
								end if;
								
								--We always send a read command, since we need to prefetch for every write as well
								case addr_in(31 downto 28) is
								
									when "0000" =>
										--Prefix 0x0 : BRAM access
										br_addr_in(10 downto 0) <= addr_in(10 downto 0);
										br_write_enable <= cmd_in(2);
										br_data_in(7 downto 0) <= data_in(7 downto 0);
										ddr2_accessed <= '0';
										MMU_STATE <= MMU_WAITING;
							
									when "0001" =>
										--Prefix 0x1 : SDRAM access
										ddr2_read_enable <= (not cmd_in(2));
										ddr2_write_enable <= cmd_in(2);
										if cmd_in(2) = '1' then
											ddr2_data_in(7 downto 0) <= data_in(7 downto 0); --probably this is not neccessarily needed to be wrapped inside an if
																											 --but I want to make sure it is not storing some weird data
										end if;
										ddr2_accessed <= '1';
										ddr2_addr_in <= addr_in(15 downto 0);
										MMU_STATE <= MMU_WAITING;
									
									when "0010" =>
										--Prefix 0x2 : CRAM access
										cr_addr_in <= addr_in(10 downto 0);
										cr_data_in <= data_in(7 downto 0);
										cr_write_enable <= cmd_in(2);
										ddr2_accessed <= '0';
										MMU_STATE <= MMU_WAITING;
										
									when "0011" =>
										--Prefix 0x3 : IORAM acess
										io_addr_in <= addr_in(2 downto 0);
										io_data_in <= data_in(7 downto 0);
										io_write_enable <= cmd_in(2);
										ddr2_accessed <= '0';
										MMU_STATE <= MMU_WAITING;
										
									when "0100" =>
										--Prefix 0x4 : BRAM access
										pr_addr_in(10 downto 0) <= addr_in(10 downto 0);
										pr_write_enable <= cmd_in(2);
										pr_data_in(7 downto 0) <= data_in(7 downto 0);
										ddr2_accessed <= '0';
										MMU_STATE <= MMU_WAITING;	
										
									
									when others => NULL;
										
								end case;
							
							else
							
							
								ack_out <= '1';
							
							end if;
						
						when MMU_WAITING =>
						
							mmu_state_out <= x"33333333";
							if ddr2_ack = '1' or ddr2_accessed = '0' then
								--Remove all signals that enable access to any RAM
								ddr2_read_enable <= '0';
								ddr2_write_enable <= '0';
								br_write_enable <= '0';
								cr_write_enable <= '0';
								io_write_enable <= '0';
								pr_write_enable <= '0';
								MMU_STATE <= MMU_DATA_VALID;
								
							end if;
							
						
						when MMU_DATA_VALID =>
					
							if ddr2_ready = '1' then
		
								--RShift so far recieved data by 8 and place new recieved data on top (due to LE encoding)
								read_data(23 downto 0) <= read_data(31 downto 8);
								data_in_buf(23 downto 0) <= data_in_buf(31 downto 8);
								
								access_remaining <= access_remaining - 1;
								addr_in_buf <= std_logic_vector(unsigned(addr_in_buf(31 downto 0))+1); --Ready the next adress to read/write from
								if write_mode = '1' then
									MMU_STATE <= MMU_WRITE_NEXT;
								else
									MMU_STATE <= MMU_READ_NEXT;
								end if;
							end if;
						
						when MMU_READ_NEXT =>
							mmu_state_out <= x"44444444";
							case addr_in_buf(31 downto 28) is
							
								when "0000" => read_data (31 downto 24) <= br_data_out(7 downto 0);
								when "0001" => read_data (31 downto 24) <= ddr2_data_out(7 downto 0);
								when "0010" => read_data (31 downto 24) <= cr_data_out(7 downto 0);
								when "0011" => read_data (31 downto 24) <= io_data_out(7 downto 0);
								when "0100" => read_data (31 downto 24) <= pr_data_out(7 downto 0);
								when others => NULL;
							
							end case;
							if access_remaining = 0 then
								MMU_STATE <= MMU_READ_DONE;
							else
								
								case addr_in_buf(31 downto 28) is
								
									when "0000" => br_addr_in(10 downto 0) <= addr_in_buf(10 downto 0);
									when "0001" => ddr2_addr_in(15 downto 0) <= addr_in_buf(15 downto 0);
														ddr2_read_enable <= '1';
									when "0010" => cr_addr_in(10 downto 0) <= addr_in_buf(10 downto 0);
									when "0011" => io_addr_in(2 downto 0) <= addr_in_buf(2 downto 0);
									when "0100" => pr_addr_in(10 downto 0) <= addr_in_buf(10 downto 0);
									
									when others => NULL;
								
								end case;
								MMU_STATE <= MMU_WAITING;
								
							end if;
							
						when MMU_WRITE_NEXT =>
							mmu_state_out <= x"55555555";
							if access_remaining = 0 then
							
								MMU_STATE <= MMU_WRITE_DONE;
								
							else
							
								case addr_in_buf(31 downto 28) is
								
									when "0000" => 
										br_data_in (7 downto 0) <= data_in_buf(7 downto 0);
										br_write_enable <= '1';
										br_addr_in(10 downto 0) <= addr_in_buf(10 downto 0);
										
									when "0001" => 
										ddr2_data_in (7 downto 0) <= data_in_buf(7 downto 0);
										ddr2_write_enable <= '1';
										ddr2_addr_in(15 downto 0) <= addr_in_buf(15 downto 0);
									
									when "0010" => 
										cr_data_in(7 downto 0) <= data_in_buf(7 downto 0);
										cr_addr_in(10 downto 0) <= addr_in_buf(10 downto 0);
										cr_write_enable <= '1';
										
									when "0011" =>
										io_data_in(7 downto 0) <= data_in_buf(7 downto 0);
										io_addr_in(2 downto 0) <= addr_in_buf(2 downto 0);
										io_write_enable <= '1';
										
									when "0100" =>
										pr_data_in(7 downto 0) <= data_in_buf(7 downto 0);
										pr_addr_in(10 downto 0) <= addr_in_buf(10 downto 0);
										pr_write_enable <= '1';
									
									when others => NULL;
								
								end case;
									
								MMU_STATE <= MMU_WAITING;
							
							end if;
						
						when MMU_READ_DONE =>
							mmu_state_out <= x"66666666";
							ack_out <= '1';
							data_out <= read_data;
							MMU_STATE <= MMU_IDLE;
						
						when MMU_WRITE_DONE =>
							mmu_state_out <= x"77777777";
							ack_out <= '1';
							MMU_STATE <= MMU_IDLE;

							
						when others => mmu_state_out <= x"00000000"; NULL;
				
					end case;
				
				end if;
				
			end if;
		
		end process;
		
		--Instanciate Blockram 
		INST_BLOCKRAM : BLOCKRAM
		PORT MAP (
				clk => clk_in,
				rst => reset_in,
				addr_in => br_addr_in,
				data_in => br_data_in,
				data_out => br_data_out,
				write_enable => br_write_enable
		);
		
		--Instanciate Programram 
		INST_PRAM : PRAM
		PORT MAP (
				clk => clk_in,
				rst => reset_in,
				addr_in => pr_addr_in,
				data_in => pr_data_in,
				data_out => pr_data_out,
				write_enable => pr_write_enable
		);
		
		--Instanciate CHARRAM
		
		INST_CHARRAM : CHARRAM
		PORT MAP (
		
		clk => clk_in,
		rst => reset_in,
		addr_in(10 downto 0) => cr_addr_in(10 downto 0),		
		data_in(7 downto 0) => cr_data_in(7 downto 0),
		data_out(7 downto 0) => cr_data_out(7 downto 0),
			
		write_enable => cr_write_enable,
		char_addr_in => char_addr_in,
		char_out => char_out
		
		);
		
		
		INST_IORAM : IORAM
		PORT MAP(
		
			clk => clk_in,
			rst => reset_in,
		
			pin_in => pins_in,
			pin_out => pins_out,
			
			addr_in => io_addr_in,
			data_in => io_data_in,
			data_out => io_data_out,
			write_enable => io_write_enable
		);

		
		INST_DDR2_Control_VHDL : DDR2_Control_VHDL
		PORT MAP (
			 reset_in => reset_in,
			 clk_in => clk_in,
			 clk90_in => clk90_in,

			 maddr   => ddr2_addr_in,
			 mdata_i => ddr2_data_in,
			 data_out => ddr2_data_out,
			 mwe	  => ddr2_write_enable,
			 mrd     => ddr2_read_enable,
			 uidle => ddr2_ready,
			 ucmd_ack => ddr2_ack,
			 state_out => ddr2_cntrl_state_out,

			 -- ddr2	
			 init_done => init_done, --in
			 command_register => command_register, --out
			 input_adress => input_adress, --out
			 input_data => input_data, --out 
			 output_data => output_data, --in
			 cmd_ack => cmd_ack, --in
			 data_valid => data_valid, --in
			 burst_done => burst_done, --out
			 auto_ref_req => auto_ref_req --in
	);
	
	

end Behavioral;
	
