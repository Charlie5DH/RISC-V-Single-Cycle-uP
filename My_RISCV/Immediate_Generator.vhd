library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity Immediate_Generator is
    port (
        instruction     : in std_logic_vector(31 downto 0);
        immediate       : out std_logic_vector(31 downto 0)
    );
end entity Immediate_Generator;

architecture arch_Inmmediate_Generator of Immediate_Generator is

    signal opcode : std_logic_vector(6 downto 0);
    signal temporal: std_logic_vector(31 downto 0);
    signal ItypeImmediate,StypeImmediate,SBtypeImmediate
            ,UJtypeImmediate : std_logic_vector(31 downto 0);
begin
    process( instruction, opcode, ItypeImmediate, StypeImmediate, SBtypeImmediate, UJtypeImmediate)
    begin
        case opcode is
            when ("0010011") => temporal <= ItypeImmediate;             --loads and immediate arith
            when ("0000011") => temporal <= ItypeImmediate;
            when ("0100011") => temporal <= StypeImmediate;                  --stores
            when ("1100011") => temporal <= SBtypeImmediate;                 --branches
            when ("1100111") => temporal <= ItypeImmediate;                  --JALR
            when ("1101111") => temporal <= UJtypeImmediate;                 --JAL
            when others => temporal <= (others => '0');
        end case;       
    end process ; 
    
    ItypeImmediate <= X"00000" & instruction(31 downto 20) when instruction(31) = '0' else (X"FFFFF" & instruction(31 downto 20));
    StypeImmediate <= X"00000" & ( instruction(31 downto 25) & instruction(11 downto 7) ) when instruction(31) = '0' else
                      (X"FFFFF" & ( instruction(31 downto 25) & instruction(11 downto 7) ));
    SBtypeImmediate <= X"00000" & ( instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8) )
                        when instruction(31) = '0' else
                        (X"FFFFF" & (instruction(31) & instruction(7) & instruction(30 downto 25) & instruction(11 downto 8))); --revisar
    --UtypeImmediate  <= X"000" & instruction(31 downto 12) when instruction(31) = '0' else X"FFF" & instruction(31 downto 12);
    UJtypeImmediate <= X"000" & ( instruction(31) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 21) ) when 
                        instruction(31) = '0' else
                        (X"FFF" & ( instruction(31) & instruction(19 downto 12) & instruction(20) & instruction(30 downto 21)) );

    opcode <= instruction(6 downto 0);
    immediate <= temporal;
    --antes 30 downto 25 y 11 downto 7
end architecture arch_Inmmediate_Generator;