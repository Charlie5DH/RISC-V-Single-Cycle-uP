library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Branch_Control is
    port (
        branch      : in std_logic_vector(2 downto 0);
        signo       : in std_logic;
        zero        : in std_logic;
        PCSrc       : out std_logic
    );
end entity Branch_Control;

architecture arch_Branch_Control of Branch_Control is
    
    signal BEQ : std_logic;
    signal BNQ : std_logic;
    signal BLT : std_logic;
    signal BGT : std_logic;
    signal temp: std_logic;

begin
    process( branch, signo, zero, BEQ, BNQ, BLT, BGT )
    begin
        case branch is
            when "001" => temp <= BEQ;
            when "010" => temp <= BNQ;
            when "011" => temp <= BLT;
            when "100" => temp <= BGT;
            when "101" => temp <= '1';  --JAL
            when "110" => temp <= '1';  --JALR
            when others => temp <= '0';    
        end case;
    end process ;
    
    BEQ <= '1' when zero = '1' else '0';
    BNQ <= '1' when zero = '0' else '0';
    BLT <= '1' when signo = '1' else '0';
    BGT <= '1' when signo = '0' else '0';
    
    PCSrc <= temp;
    
end architecture arch_Branch_Control;