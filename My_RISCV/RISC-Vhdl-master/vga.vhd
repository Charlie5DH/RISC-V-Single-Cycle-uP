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

entity vga is
    port(   clk     : in std_logic;
            rst     : in std_logic;

            rgb     : in std_logic_vector(11 downto 0);

            x       : out std_logic_vector(9 downto 0);
            y       : out std_logic_vector(9 downto 0);
            offs    : out std_logic;

            r        : out std_logic_vector(3 downto 0);
            g        : out std_logic_vector(3 downto 0);
            b        : out std_logic_vector(3 downto 0);
            h        : out std_logic;
            v        : out std_logic;

	reg_data_in : in std_logic_vector(31 downto 0);
	reg_adr_in  : in std_logic_vector(5 downto 0);
	pc_in       : in std_logic_vector(31 downto 0);
	ir_in       :  in std_logic_vector(31 downto 0);

	debug_on	: in std_logic; --debug : regs else ascii				
	x_out		: out std_logic_vector(9 downto 0);
	y_out		: out std_logic_vector(9 downto 0);
	pixel		: in std_logic
         );
end vga;


architecture behaviour of vga is
signal x_cnt : unsigned(9 downto 0) := (others => '0');
signal y_cnt : unsigned(9 downto 0) := (others => '0');

type regbank is array (0 to 3) of std_logic_vector(31 downto 0); -- 31 free Registers, Register 0 is always 0

type  regarray is array(0 to 16) of regbank;
signal regs : regarray;

signal offs_intX : std_logic := '0';
signal offs_intY : std_logic := '0';
signal offs_int  : std_logic;

signal reg_counterx: unsigned(5 downto 0);
signal reg_countery: unsigned(5 downto 0);
signal bit_counter: unsigned(4 downto 0);

signal currentreg: std_logic_vector(31 downto 0);

begin

offs_int <= offs_intX or offs_intY;
offs <= offs_int;

currentreg <= pc_in when reg_countery = "01010" and reg_counterx = "00001" else
              ir_in when reg_countery = "01010" and reg_counterx = "00010" else
              regs(to_integer(reg_countery))(to_integer(reg_counterx));

x_out<= std_logic_vector(x_cnt) when offs_int = '0' else
        (others => '0');
y_out <=  std_logic_vector(y_cnt) when offs_int = '0' else
        (others => '0');		  

x <=  std_logic_vector(x_cnt) when offs_int = '0' else
        (others => '0');
y <=  std_logic_vector(y_cnt) when offs_int = '0' else
        (others => '0');
			
			
			--debug_on = 0 then r,g and b = pixel -> asciimode
			--rot, wenn gerade Zeile und ungerade Spalte oder ungerade Spalte und gerade Zeile
r <=     "1111" when debug_on='0' and pixel ='1' else "0000" when debug_on = '0' and pixel ='0' else
			"1111" when offs_int = '0' and reg_counterx(0) /= reg_countery(0) and currentreg(to_integer(bit_counter)) = '1' else
			"0111" when offs_int = '0' and reg_counterx(0) /= reg_countery(0) and currentreg(to_integer(bit_counter)) = '0' else
        (others => '0');
		  
g <=     --std_logic_vector(x_cnt(8 downto 5)) when offs_int = '0' else
			"1111" when debug_on='0' and pixel = '1' else "0000" when debug_on = '0' 
			else
        (others => '0');
		  
			--blau wenn gerade Zeile und gerade Spalte oder ungerade Zeile und ungerade Spalte
b <=     "1111" when debug_on='0' and pixel ='1' else "0000" when debug_on = '0' and pixel ='0' 
else
			"1111" when offs_int = '0' and reg_counterx(0) = reg_countery(0) and currentreg(to_integer(bit_counter)) = '1' else
			"0111" when offs_int = '0' and reg_counterx(0) = reg_countery(0) and currentreg(to_integer(bit_counter)) = '0' else
        (others => '0');


sync_proc_x : process(clk, rst)
begin

    if rising_edge(clk) then

        if rst = '1' then
            x_cnt <= (others => '0');

            offs_intX <= '0';

            h <= '1';

				
        else
            x_cnt <= x_cnt + 1;
				
				
				
            case to_integer(x_cnt) is

                when 512 =>
                    offs_intX <= '1';

                when 655 =>
                    h <= '0';

                when 751 =>
                    h <= '1';

                when 799 =>
                    x_cnt <= (others => '0');
                    offs_intX <= '0';

                when others => NULL;

            end case;
        end if;
    end if;
end process;


sync_proc_y : process(clk, rst)
begin

    if rising_edge(clk) then

        if rst = '1' then
            y_cnt <= (others => '0');

            offs_intY <= '0';

            v <= '1';

        elsif x_cnt = to_unsigned(799, x_cnt'length) then
            y_cnt <= y_cnt + 1;

				
				

            case to_integer(y_cnt) is

                when 256 =>
                    offs_intY <= '1';

                when 481 =>
                    v <= '0';

                when 491 =>
                    v <= '1';

                when 520 =>
						  y_cnt <= (others => '0');
                    offs_intY <= '0';

                when others => NULL;

            end case;
        end if;
    end if;
end process;

reg_counting : process(clk, rst)
begin
if rising_edge(clk) then
	if rst='1' then
		reg_counterx <= (others => '0');
		reg_countery <= (others => '0');
		bit_counter <= (others => '0');
	else
		regs(to_integer(unsigned(reg_adr_in(5 downto 2))))(to_integer(unsigned(reg_adr_in(1 downto 0)))) <= reg_data_in;
	
		if x_cnt = 513 and y_cnt = 257 then
			reg_countery <= (others => '0');
			reg_counterx <= (others => '0');
			bit_counter <= (others => '0');
		elsif x_cnt < 513 and y_cnt = 257 then
			if x_cnt(1 downto 0) = "11" then
				bit_counter <= bit_counter + 1;
			end if;
		
		elsif x_cnt = 513 and y_cnt < 257 then
			if y_cnt(3 downto 0) = "111" then
				reg_countery <= reg_countery +1;
			end if;
			bit_counter <= (others => '0');
			reg_counterx <= (others => '0');
			
		elsif x_cnt < 513 and y_cnt < 257 then
			if x_cnt(6 downto 0) = "1111111" then
				reg_counterx <= reg_counterx +1;
				bit_counter <= (others => '0');
			else
				if x_cnt(1 downto 0) = "11" then
					bit_counter <= bit_counter + 1;
				end if;
			end if;
		
		end if;
		
		
		
	end if;
	
	
end if;

end process;

end behaviour;
