library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;

entity multiplier1 is
    port (
        operator1   : in std_logic_vector(15 downto 0);
        operator2   : in std_logic_vector(15 downto 0);
        rst         : in std_logic;
        clk         : in std_logic;
        product     : out std_logic_vector(31 downto 0)
    );
end entity multiplier1;

architecture arch_multiplier of multiplier1 is

begin

    
end architecture arch_multiplier;