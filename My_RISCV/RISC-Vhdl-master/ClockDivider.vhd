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

entity ClockDivider is
port(clk_in, rst_in, slow_in: in std_logic;
clk_out: out std_logic);
end ClockDivider;

architecture Behavioral of ClockDivider is

signal counter:unsigned(31 downto 0);
signal clk_sgn: std_logic;
signal mode : std_logic;
begin

clk_out <= clk_sgn when mode = '1' else clk_in;

process(clk_in, rst_in)
begin
	if rst_in = '1' then
	   mode <= slow_in;
		clk_sgn <= '0';
		counter <= (others => '0');
	elsif rising_edge(clk_in) then
		if counter >= x"195E240" then
		   mode <= slow_in;
			counter <= (others => '0');
			clk_sgn <= not clk_sgn;
		else
			counter <= counter + "1";
		end if;
	end if;
end process;






end Behavioral;

