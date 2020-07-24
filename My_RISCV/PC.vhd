--PC is a register that is going to be updated with the value of the input
--every time there is a rising edge if clk_man is disable.

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity PC is
    port (
        PCIn    : in std_logic_vector(31 downto 0);
        clk     : in std_logic;
        rst     : in std_logic;
        PCOut   : out std_logic_vector(31 downto 0)
    );
end entity PC;

architecture arch_PC of PC is

begin
    process( clk, rst)
    begin
        if rst = '0' then
            PCOut <= (others => '0');
        else
            if rising_edge(clk) then        
                    PCOut <= PCIn;          --register operation
            end if;
        end if;
    end process ;
end arch_PC ; -- arch_PC