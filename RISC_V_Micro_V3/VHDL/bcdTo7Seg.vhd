--active in 0
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity bcdTo7Seg is
    Port ( bcd_i : in  STD_LOGIC_VECTOR (3 downto 0);
           sseg_o : out  STD_LOGIC_VECTOR (6 downto 0)
           );
end bcdTo7Seg;

architecture Behavioral of bcdTo7Seg is

begin

bcd_to_sseg_logic: process(bcd_i)
begin
	case bcd_i is
		when x"0" =>
		sseg_o <= "1000000";
	when x"1" =>
		sseg_o <= "1111001";
	when x"2" =>
		sseg_o <= "0100100";
	when x"3" =>
		sseg_o <= "0110000";
	when x"4" =>
		sseg_o <= "0011001";
	when x"5" =>
		sseg_o <= "0010010";
	when x"6" =>
		sseg_o <= "0000010";
	when x"7" =>
		sseg_o <= "1111000";
	when x"8" =>
		sseg_o <= "0000000";
	when x"9" =>
		sseg_o <= "0010000";
	when x"A" =>
		sseg_o <= "0001000";
	when x"B" =>
		sseg_o <= "0000011";
	when x"C" =>
		sseg_o <= "1000110";
	when x"D" =>
		sseg_o <= "0100001";
	when x"E" =>
		sseg_o <= "0000110";
	when x"F" =>
		sseg_o <= "0001110";
	when others =>
		sseg_o <= "1111111";
	end case;
end process;


end Behavioral;
