library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity multiplier1 is
    generic(size: INTEGER := 4);
    port (
        operator1   : in std_logic_vector(size-1 downto 0);
        operator2   : in std_logic_vector(size-1 downto 0);
        product     : out std_logic_vector(2*size-1 downto 0)
    );
end entity multiplier1;

architecture arch_multiplier of multiplier1 is

    type Tr is array (size-1 downto 0) of std_logic_vector(size downto 0);
    signal PP, S, C : Tr;

    procedure FA
        ( signal c, s : out std_logic;signal x,y,z: in std_logic) is
    begin
        c <= (x and y) or (x and z) or (y and z);
        s <= x xor y xor z;
    end FA;

begin
    S(0)(size) <= '0';
    row_0: for i in size-1 downto 0 generate
        S(0)(i) <= operator1(i) and operator2(0);
    end generate row_0;

    row_j : for j in 1 to size-1 generate
        S(j)(size) <= C(j)(size);
        col_i : for i in size-1 downto 0 generate
            PP(j)(i) <= operator1(i) and operator2(j);
            FA( C(j)(i+1), S(j)(i), S(j-1)(i+1), PP(j)(i), C(j)(i));
        end generate ; -- col_i
        C(j)(0) <= '0';
        product(j) <= S(j)(0);
    end generate ; -- row_j

    product(2*size-1 downto size) <= S(size -1)(size downto 1);
    product(0) <= S(0)(0);
    
end architecture arch_multiplier;