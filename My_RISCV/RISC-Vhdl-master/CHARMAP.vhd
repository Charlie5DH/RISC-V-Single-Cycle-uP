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

entity CHARMAP is
    Port ( addr : in  STD_LOGIC_vector( 7 downto 0);
           clk : in  STD_LOGIC;
           data : out  STD_LOGIC_vector (63 downto 0)
			  );
end CHARMAP;

architecture Behavioral of CHARMAP is

type mem_t is array (0 to 255) of std_logic_vector(63 downto 0);  -- 256 cells with 64 bit
	signal cells : mem_t:= (
					
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					
					"00000000"& --Empty
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000"& 
					"00000000",
					
					"00000000"&--!
					"00011000"&
					"00011000"&
					"00011000"&
					"00011000"&
					"00000000"&
					"00011000"&
					"00000000",
						
					"00000000"&--"
					"01100110"&
					"01000100"&
					"00000000"&
					"00000000"&
					"00000000"&
					"00000000"&
					"00000000",
					
					
						
					"00000000"&--#
					"00000000"&
					"00010100"&
					"01111110"&
					"00010100"&
					"01111110"&
					"00101000"&
					"00000000",
					
					
						
					"00000000"&--$
					"00111110"&
					"01010000"&
					"00111100"&
					"00010010"&
					"01111100"&
					"00010000"&
					"00000000",
					
					
						
					"00000000"&--%
					"01110010"&
					"01010100"&
					"01111000"&
					"00011110"&
					"00101010"&
					"01001110"&
					"00000000",
					
					
						
					"00000000"&--&
					"01111100"&
					"01000000"&
					"00100100"&
					"00111000"&
					"01001000"&
					"00110100"&
					"00000000",
					
					
						
					"00000000"&--'
					"00011000"&
					"00010000"&
					"00000000"&
					"00000000"&
					"00000000"&
					"00000000"&
					"00000000",
					
					
						
					"00000000"&--(
					"00011000"&
					"00110000"&
					"00100000"&
					"00100000"&
					"00110000"&
					"00011000"&
					"00000000",
					
					
						
					"00000000"&--)
					"00011000"&
					"00001100"&
					"00000100"&
					"00000100"&
					"00001100"&
					"00011000"&
					"00000000",
					
					
						
					"00000000"&--*
					"00101010"&
					"00011100"&
					"00100010"&
					"00000000"&
					"00000000"&
					"00000000"&
					"00000000",
					
					
						
					"00000000"&--+
					"00000000"&
					"00011000"&
					"00011000"&
					"01111110"&
					"00011000"&
					"00011000"&
					"00000000",
					
					
						
					"00000000"&--�
					"00000000"&
					"00000000"&
					"00000000"&
					"00000000"&
					"00011000"&
					"00010000"&
					"00000000",
					
					
						
					"00000000"&---
					"00000000"&
					"00000000"&
					"00000000"&
					"01111110"&
					"00000000"&
					"00000000"&
					"00000000",
					
					
						
					"00000000"&--.
					"00000000"&
					"00000000"&
					"00000000"&
					"00000000"&
					"00011000"&
					"00011000"&
					"00000000",
					
					
						
					"00000000"&--/
					"00000010"&
					"00000100"&
					"00001000"&
					"00010000"&
					"00100000"&
					"01000000"&
					"00000000",
					
					"00000000"&--0
					"00111100"&
					"01100110"&
					"01101110"&
					"01110110"&
					"01100110"&
					"00111100"&
					"00000000",
					
					"00000000"&--1
					"00011000"&
					"00111000"&
					"00011000"&
					"00011000"&
					"00011000"&
					"00111100"&
					"00000000",
					
					"00000000"&--2
					"00111100"&
					"01100110"&
					"00000110"&
					"00111100"&
					"01100000"&
					"01111110"&
					"00000000",
					
					"00000000"&--3
					"00111100"&
					"00000110"&
					"00011100"&
					"00000110"&
					"01100110"&
					"00111100"&
					"00000000",
					
					"00000000"&--4
					"00001100"&
					"00011100"&
					"00111100"&
					"01101100"&
					"01111110"&
					"00001100"&
					"00000000",
					
					"00000000"&--5
					"01111100"&
					"01100000"&
					"01111100"&
					"00000110"&
					"01100110"&
					"00111100"&
					"00000000",
					
					"00000000"&--6
					"00111100"&
					"01100000"&
					"01111100"&
					"01100110"&
					"01100110"&
					"00111100"&
					"00000000",
					
					"00000000"&--7
					"01111110"&
					"01100110"&
					"00000110"&
					"00001100"&
					"00011000"&
					"00011000"&
					"00000000",
						
					"00000000"&--8
					"00111100"&
					"01100110"&
					"00111100"&
					"01100110"&
					"01100110"&
					"00111100"&
					"00000000",
						
					"00000000"&--9
					"00111100"&
					"01100110"&
					"01100110"&
					"00111110"&
					"00000110"&
					"00111100"&
					"00000000",
					
					"00000000"&--:
					"00000000"&
					"00011000"&
					"00011000"&
					"00000000"&
					"00011000"&
					"00011000"&
					"00000000",
					
					"00000000"&--;
					"00000000"&
					"00011000"&
					"00011000"&
					"00000000"&
					"00011000"&
					"00110000"&
					"00000000",
					
					"00000000"&--<
					"00000000"&
					"00001100"&
					"00010000"&
					"00100000"&
					"00010000"&
					"00001100"&
					"00000000",
					
					"00000000"&--=
					"00000000"&
					"00000000"&
					"01111110"&
					"00000000"&
					"01111110"&
					"00000000"&
					"00000000",
					
					"00000000"&-->
					"00000000"&
					"01100000"&
					"00010000"&
					"00001000"&
					"00010000"&
					"01100000"&
					"00000000",
					
					"00000000"&--?
					"01111100"&
					"00000110"&
					"00000110"&
					"00011100"&
					"00000000"&
					"00011000"&
					"00000000",
					
					"00000000"&--@
					"01111110"&
					"01000010"&
					"01011110"&
					"01011110"&
					"01000000"&
					"01111110"&
					"00000000",
					
					
					
					"00000000"& --A
					"00111100"&
					"01100110"&
					"01100110"&
					"01111110"&
					"01100110"&
					"01100110"&
					"00000000",
					
					
					"00000000"& --B
					"01111100"&
					"01100110"&
					"01111100"&
					"01100110"&
					"01100110"&
					"01111100"&
					"00000000",
					
					"00000000"& --C
					"00111100"&
					"01100110"&
					"01100000"&
					"01100000"&
					"01100110"&
					"00111100"&
					"00000000",
										
					
					"00000000"& --D
					"01111100"&
					"01100110"&
					"01100110"&
					"01100110"&
					"01100110"&
					"01111100"&
					"00000000",
					
					
					"00000000"& --E
					"01111110"&
					"01100000"&
					"01111100"&
					"01000000"&
					"01000000"&
					"01111110"&
					"00000000",
					
					
					"00000000"& --F
					"01111110"&
					"01100000"&
					"01100000"&
					"01111100"&
					"01100000"&
					"01100000"&
					"00000000",
					
					
					"00000000"& --G
					"00111100"&
					"01100110"&
					"01100000"&
					"01101110"&
					"01100110"&
					"00111110"&
					"00000000",
					
					
					"00000000"& --H
					"01100110"&
					"01100110"&
					"01111110"&
					"01100110"&
					"01100110"&
					"01100110"&
					"00000000",
					
					
					"00000000"& --I
					"00111100"&
					"00011000"&
					"00011000"&
					"00011000"&
					"00011000"&
					"00111100"&
					"00000000",
					
					
					"00000000"& --J
					"00001110"&
					"00000110"&
					"00000110"&
					"00000110"&
					"01100110"&
					"00111100"&
					"00000000",
					
					
					"00000000"& --K
					"01100110"&
					"01101100"&
					"01111000"&
					"01111000"&
					"01101100"&
					"01100110"&
					"00000000",
					
					
					"00000000"& --L
					"01100000"&
					"01100000"&
					"01100000"&
					"01100000"&
					"01100000"&
					"01111110"&
					"00000000",
					
					
					"00000000"& --M
					"01100010"&
					"01110110"&
					"01111110"&
					"01101010"&
					"01100010"&
					"01100010"&
					"00000000",
					
					
					"00000000"& --N
					"01100010"&
					"01110010"&
					"01111010"&
					"01101110"&
					"01100110"&
					"01100010"&
					"00000000",
					
					
					"00000000"& --O
					"00111100"&
					"01100110"&
					"01100110"&
					"01100110"&
					"01100110"&
					"00111100"&
					"00000000",
					
					
					"00000000"& --P
					"01111100"&
					"01100110"&
					"01100110"&
					"01111100"&
					"01100000"&
					"01100000"&
					"00000000",
					
					
					"00000000"& --Q
					"00111110"&
					"01100110"&
					"01100110"&
					"01101110"&
					"01100100"&
					"00111010"&
					"00000000",
					
					
					"00000000"& --R
					"01111100"&
					"01100110"&
					"01100110"&
					"01111100"&
					"01100110"&
					"01100110"&
					"00000000",
					
					
					"00000000"& --S
					"00111110"&
					"01100000"&
					"00111100"&
					"00000110"&
					"01100110"&
					"00111100"&
					"00000000",
					
					
					"00000000"& --T
					"01111110"&
					"00011000"&
					"00011000"&
					"00011000"&
					"00011000"&
					"00011000"&
					"00000000",
					
					"00000000"& --U
					"01100110"&
					"01100110"&
					"01100110"&
					"01100110"&
					"01100110"&
					"00111100"&
					"00000000",
					
					
					"00000000"& --V
					"01100110"&
					"01100110"&
					"01100110"&
					"01100110"&
					"00111100"&
					"00011000"&
					"00000000",
					
					
					"00000000"&--W
					"01100010"&
					"01100010"&
					"01101010"&
					"01111110"&
					"01110110"&
					"01100010"&
					"00000000",
					
					"00000000"&--X
					"01100110"&
					"01100110"&
					"00111100"&
					"00111100"&
					"01100110"&
					"01100110"&
					"00000000",
					"00000000"&--Y
					"01100110"&
					"01100110"&
					"01100110"&
					"00111100"&
					"00011000"&
					"00011000"&					
					"00000000",

					"00000000"&--Z
					"01111110"&
					"00001110"&
					"00011100"&
					"00111000"&
					"01110000"&
					"01111110"&
					"00000000",										
 
					"00000000"&--[
					"00111000"&
					"00100000"&
					"00100000"&
					"00100000"&
					"00100000"&
					"00111000"&
					"00000000",
										
					"00000000"&--\
					"01000000"&
					"00100000"&
					"00010000"&
					"00001000"&
					"00000100"&
					"00000010"&
					"00000000",
										
					"00000000"&--]
					"00001110"&
					"00000010"&
					"00000010"&
					"00000010"&
					"00000010"&
					"00001110"&
					"00000000",
										
					"00000000"&--^
					"00001000"&
					"00010100"&
					"00100010"&
					"00000000"&
					"00000000"&
					"00000000"&
					"00000000",
										
					"00000000"&--_
					"00000000"&
					"00000000"&
					"00000000"&
					"00000000"&
					"00000000"&
					"01111110"&
					"00000000",
										
					"00000000"&--`
					"00011000"&
					"00001000"&
					"00000000"&
					"00000000"&
					"00000000"&
					"00000000"&
					"00000000",
					
					
					
					
					
					"00000000"&--A
					"00111100"&
					"01100110"&
					"01100110"&
					"01111110"&
					"01100110"&
					"01100110"&
					"00000000",
					
					"00000000"&--B
					"01111100"&
					"01100110"&
					"01111100"&
					"01100110"&
					"01100110"&
					"01111100"&
					"00000000",
					
					"00000000"&--C
					"00111100"&
					"01100110"&
					"01100000"&
					"01100000"&
					"01100110"&
					"00111100"&
					"00000000",
										
					
					"00000000"&--D
					"01111100"&
					"01100110"&
					"01100110"&
					"01100110"&
					"01100110"&
					"01111100"&
					"00000000",
					
					
					"00000000"&--E
					"01111110"&
					"01100000"&
					"01111100"&
					"01000000"&
					"01000000"&
					"01111110"&
					"00000000",
					
					
					"00000000"&--F
					"01111110"&
					"01100000"&
					"01100000"&
					"01111100"&
					"01100000"&
					"01100000"&
					"00000000",
					
					
					"00000000"&--G
					"00111100"&
					"01100110"&
					"01100000"&
					"01101110"&
					"01100110"&
					"00111110"&
					"00000000",
					
					
					"00000000"&--H
					"01100110"&
					"01100110"&
					"01111110"&
					"01100110"&
					"01100110"&
					"01100110"&
					"00000000",
					
					
					"00000000"&--I
					"00111100"&
					"00011000"&
					"00011000"&
					"00011000"&
					"00011000"&
					"00111100"&
					"00000000",
					
					
					"00000000"&--J
					"00001110"&
					"00000110"&
					"00000110"&
					"00000110"&
					"01100110"&
					"00111100"&
					"00000000",
					
					
					"00000000"&--K
					"01100110"&
					"01101100"&
					"01111000"&
					"01111000"&
					"01101100"&
					"01100110"&
					"00000000",
					
					
					"00000000"&--L
					"01100000"&
					"01100000"&
					"01100000"&
					"01100000"&
					"01100000"&
					"01111110"&
					"00000000",
					
					
					"00000000"&--M
					"01100010"&
					"01110110"&
					"01111110"&
					"01101010"&
					"01100010"&
					"01100010"&
					"00000000",
					
					
					"00000000"&--N
					"01100010"&
					"01110010"&
					"01111010"&
					"01101110"&
					"01100110"&
					"01100010"&
					"00000000",
					
					
					"00000000"&--O
					"00111100"&
					"01100110"&
					"01100110"&
					"01100110"&
					"01100110"&
					"00111100"&
					"00000000",
					
					
					"00000000"&--P
					"01111100"&
					"01100110"&
					"01100110"&
					"01111100"&
					"01100000"&
					"01100000"&
					"00000000",
					
					
					"00000000"&--Q
					"00111110"&
					"01100110"&
					"01100110"&
					"01101110"&
					"01100100"&
					"00111010"&
					"00000000",
					
					
					"00000000"&--R
					"01111100"&
					"01100110"&
					"01100110"&
					"01111100"&
					"01100110"&
					"01100110"&
					"00000000",
					
					
					"00000000"&--S
					"00111110"&
					"01100000"&
					"00111100"&
					"00000110"&
					"01100110"&
					"00111100"&
					"00000000",
					
					
					"00000000"&--T
					"01111110"&
					"00011000"&
					"00011000"&
					"00011000"&
					"00011000"&
					"00011000"&
					"00000000",
					
					"00000000"&--U
					"01100110"&
					"01100110"&
					"01100110"&
					"01100110"&
					"01100110"&
					"00111100"&
					"00000000",
					
					
					"00000000"&--V
					"01100110"&
					"01100110"&
					"01100110"&
					"01100110"&
					"00111100"&
					"00011000"&
					"00000000",
					
					
					"00000000"&--W
					"01100010"&
					"01100010"&
					"01101010"&
					"01111110"&
					"01110110"&
					"01100010"&
					"00000000",
					
					"00000000"&--X
					"01100110"&
					"01100110"&
					"00111100"&
					"00111100"&
					"01100110"&
					"01100110"&
					"00000000",
					
					"00000000"&--Y
					"01100110"&
					"01100110"&
					"01100110"&
					"00111100"&
					"00011000"&
					"00011000"&
					"00000000",
					
					"00000000"&--Z
					"01111110"&
					"00001110"&
					"00011100"&
					"00111000"&
					"01110000"&
					"01111110"&
					"00000000",

										

					"00000100"&--{
					"00001000"&
					"00001000"&
					"00010000"&
					"00001000"&
					"00001000"&
					"00000100"&
					"00000000",
										

					"00001000"&--|
					"00001000"&
					"00001000"&
					"00001000"&
					"00001000"&
					"00001000"&
					"00001000"&
					"00000000",
										
		
					"00010000"&--}
					"00001000"&
					"00001000"&
					"00000100"&
					"00001000"&
					"00001000"&
					"00010000"&
					"00000000",
		
					"00000000"&--~
					"00000000"&
					"00000000"&
					"00100000"&
					"01011010"&
					"00000100"&
					"00000000"&
					"00000000",
				
					
					others=>(others=>'0')
					
					);
					
					attribute ram_style: string;
	attribute ram_style of cells : signal is "block";
begin



	process(clk) begin
	
		
		
		if rising_edge(clk) then
		
			
			
				data <= cells(to_integer(unsigned(addr))); -- always send out bitfield according to current address
			
			
		end if;
			
	end process;

end Behavioral;
