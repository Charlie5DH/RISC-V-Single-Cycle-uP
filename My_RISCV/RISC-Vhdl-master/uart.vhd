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


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity uart is
port(
 clk   : in  std_logic;
 rst   : in  std_logic;
 rx    : in  std_logic;

 err   : out std_logic;
 valid : out std_logic;
 data  : out std_logic_vector(7 downto 0)
);
end entity;

architecture uart_1 of uart is
 signal baud_rate : unsigned(15 downto 0);
 signal cnt1      : unsigned(15 downto 0);
 signal cnt2      : unsigned(2 downto 0);
 signal reg       : std_logic_vector(7 downto 0);
 signal state     : std_logic_vector(2 downto 0);
begin

process(clk)
begin
 if rst = '1' then
  cnt1 <= x"0000";
  cnt2 <= "000";
  baud_rate <= x"1458";
  reg <= x"00";
  err <= '0';
  valid <= '0';
  data <= x"00";
  state <= "000";
 elsif rising_edge(clk) then
  case state is
  when "000" =>
   if rx = '0' then
	 valid <= '0';
    cnt1 <= x"0000";
    cnt2 <= "000";
	 state <= "001";
	end if;
  when "001" =>
   if (cnt1 & "0") >= baud_rate then
    cnt1 <= x"0000";
	 state <= "010";
	else
	 cnt1 <= cnt1 + 1;
	end if;
  when "010" =>
   if cnt1 >= baud_rate then
    cnt1 <= x"0000";
	 reg <= rx & reg(7 downto 1);
	 cnt2 <= cnt2 + 1;
	 if cnt2 = 7 then
	  state <= "011";
	 end if;
	else
	 cnt1 <= cnt1 + 1;
	end if;
  when "011" =>
   if cnt1 >= baud_rate then
    cnt1 <= x"0000";
	 if rx = '1' then
	  state <= "000";
	  data <= reg;
	  valid <= '1';
	 else
	  err <= '1';
	 end if;
	else
	 cnt1 <= cnt1 + 1;
	end if;
  when others =>
  end case;
 end if;
end process;
end architecture;
