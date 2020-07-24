library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity FastAdder is
    Generic (BITS : INTEGER);
    Port ( X, Y: in  STD_LOGIC_VECTOR (BITS-1 downto 0);
           Sum : out  STD_LOGIC_VECTOR (BITS downto 0));
end FastAdder;
 
architecture rtl of FastAdder is
begin
    Sum <= X + Y;
end rtl;