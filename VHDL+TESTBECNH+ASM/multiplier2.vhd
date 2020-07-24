library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity multiplier2 is
    generic(size: INTEGER := 16);
    port (
        operator1   : in std_logic_vector(size-1 downto 0);
        operator2   : in std_logic_vector(size-1 downto 0);
        product     : out std_logic_vector(2*size-1 downto 0)
    );
end entity multiplier2;

architecture arch_multiplier of multiplier2 is

    type Tr is array (size-1 downto 0) of std_logic_vector(size downto 0);
    signal PProduct, S, C : Tr;

    component FullAdder
        Port ( 
            X : in STD_LOGIC;
            Y : in STD_LOGIC;
            CI : in STD_LOGIC;
            Sum : out STD_LOGIC;
            Co : out STD_LOGIC
        );
    end component;

begin
    
    S(0)(size) <= '0';
    row_0: for i in size-1 downto 0 generate
        S(0)(i) <= operator1(i) and operator2(0);
    end generate row_0;

    row_j : for j in 1 to size-1 generate
        S(j)(size) <= C(j)(size);
        col_i : for i in size-1 downto 0 generate
            PProduct(j)(i) <= operator1(i) and operator2(j);
            FullAdd: FullAdder port map (X => S(j-1)(i+1), Y => PProduct(j)(i), Ci => C(j)(i), Sum => S(j)(i), Co => C(j)(i+1));
        end generate ; -- col_i
        C(j)(0) <= '0';
        product(j) <= S(j)(0);
    end generate ; -- row_j

    product(2*size-1 downto size) <= S(size -1)(size downto 1);
    product(0) <= S(0)(0);
    
end architecture arch_multiplier;