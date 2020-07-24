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
use ieee.numeric_std.all;

entity ASCIIUNIT is
    Port ( clk : in std_logic;
			  char_in : in  STD_LOGIC_VECTOR(7 downto 0);
           x_in : in  std_logic_vector(9 downto 0);
           y_in : in  std_logic_vector(9 downto 0);
           pixel_out : out  STD_LOGIC;
           addr_out : out  STD_LOGIC_VECTOR(10 downto 0)
			  );
end ASCIIUNIT;

architecture Behavioral of ASCIIUNIT is

Component charmap is
Port ( addr : in  STD_LOGIC_vector( 7 downto 0);
           clk : in  STD_LOGIC;
           data : out  STD_LOGIC_vector (63 downto 0)
			  );
			  
			  end component charmap;


signal curr_char : std_logic_vector(7 downto 0);
signal curr_addr: unsigned (2047 downto 0);
signal curr_bitfield : std_logic_vector(0 to 63);
signal curr_pixel : std_logic;
signal const : std_logic_vector(31 downto 0) := x"00000002";

signal temp_x : std_logic_vector(31 downto 0);


begin
pixel_out <= curr_pixel; 
curr_char <= char_in; 


process (clk)
begin

if (rising_edge (clk) ) then

	temp_x <= std_logic_vector(unsigned(x_in) + unsigned(const));
	addr_out <= std_logic_vector(unsigned(y_in(9 downto 3) & "000000") + unsigned(temp_x(9 downto 3))); -- (y/8)*64 + (temp_x)/8 ; computing address for CHARRAM
	curr_pixel <= curr_bitfield(to_integer(unsigned(x_in(2 downto 0)) + unsigned(y_in(2 downto 0)&"000"))); -- (x mod 8) + (y mod 8)*8; getting pixel out of bitfield
	

end if;


end process;


inst_charmap : CHARMAP 
port map
(
	addr => curr_char,
	clk => clk,
	data(63 downto 0) => curr_bitfield(0 to 63) -- reverting input, better readability in CHARMAP
);


end Behavioral;

