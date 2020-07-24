library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;
 
entity HalfAdder is
  port (
    X  : in std_logic;
    Y  : in std_logic;
    Sum   : out std_logic;
    Co : out std_logic
    );
end HalfAdder;
 
architecture rtl of HalfAdder is
begin
  Sum   <= X xor Y;
  Co <= X and Y;
end rtl;