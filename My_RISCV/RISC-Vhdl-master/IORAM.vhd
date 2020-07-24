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

----------------------------------------------------------------------------------
-- IO RAM Interface
-- 0x0 : RO 0-7
-- 0x1 : RO 8-15
-- 0x2 : RW 0-7
-- 0x3 : RW 8-15
-- 0x4 : RO 16-23
-- 0x5 : RO 24-31
-- 0x6 : 0 (read only)
-- 0x7 : 0 (read only)

-- RO (read only) : "000000" & uart_err & uart_valid & uart_data(7 downto 0) & sw(3 downto 0) & btn(4 downto 0) & "0000000";
-- RW (read/write): "00000000" & leds(7 downto 0)



entity IORAM is

port(

		clk : in std_logic;
		rst : in std_logic;

		pin_in : in std_logic_vector(31 downto 0);
		pin_out : out std_logic_vector(15 downto 0);
		
		addr_in : in std_logic_vector(2 downto 0); --2 bit for 32 bit IO access
		data_in : in std_logic_vector(7 downto 0);
		data_out: out std_logic_vector(7 downto 0);
		write_enable : in std_logic
);

end IORAM;




architecture Behavioral of IORAM is

	signal ro_pins : std_logic_vector(31 downto 0);
	signal rw_pins : std_logic_vector(15 downto 0);

	


begin
	
	ro_pins <= pin_in;
	pin_out <= rw_pins;

	process(clk) begin
	
	
		if rising_edge(clk) then
		
			if rst = '0' then
			--No reset -> standard usage
				if write_enable = '1' then
					case addr_in is
						--when "11" => rw_pins(15 downto 8) <= data_in; zero bits
						when "010" => rw_pins(7 downto 0) <= data_in;
						when others=>NULL; --Write only allowed to adresses 2,3
					end case;
				
				else
					case addr_in is
						when "001" => data_out <= ro_pins(15 downto 8);
						when "000" => data_out <= ro_pins(7 downto 0);
						when "011" => data_out <= (others=>'0'); --rw_pins(15 downto 8); zero bits
						when "010" => data_out <= rw_pins(7 downto 0);
						when "100" => data_out <= ro_pins(23 downto 16);
						when "101" => data_out <= ro_pins(31 downto 24);
						when others =>data_out <= (others => '0');
					end case;
				end if;
					
			else
				rw_pins <= (others => '0'); --after reset the out regs are zero initialized
			
			end if;
			
		end if;
			
	end process;

end Behavioral;

