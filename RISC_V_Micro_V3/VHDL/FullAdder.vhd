library IEEE;
use IEEE.STD_LOGIC_1164.ALL;

entity FullAdder is
 Port ( 
    X : in STD_LOGIC;
    Y : in STD_LOGIC;
    CI : in STD_LOGIC;
    Sum : out STD_LOGIC;
    Co : out STD_LOGIC
 );
end FullAdder;

architecture gate_level of FullAdder is

begin

 Sum <= X XOR Y XOR Ci ;
 Co <= (X AND Y) OR (Ci AND X) OR (Ci AND Y) ;

end gate_level;