library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity Control is
    port (
        opcode      : in std_logic_vector(6 downto 0);
        funct3      : in std_logic_vector(2 downto 0);
        funct7      : in std_logic_vector(6 downto 0);
        jump        : out std_logic;
        ToRegister  : out std_logic_vector(2 downto 0);
        MemWrite    : out std_logic;
        Branch      : out std_logic_vector(2 downto 0);
        ALUOp       : out std_logic_vector(2 downto 0);
        StoreSel    : out std_logic;
        ALUSrc      : out std_logic;
        WriteReg    : out std_logic
    );
end entity Control;

architecture arch_Control of Control is

begin
    process( opcode, funct7, funct3 )
    begin
        case opcode is
            when "0110011" =>                           --R-type
                case funct3 is
                    when "000" =>
                        case funct7 is
                            when "0000000" =>               --ADD
                                jump        <= '0';
                                Branch      <= "000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= '0';
                                ALUSrc      <= '1';                                
                                ALUOp       <= "100";
                                WriteReg    <= '1';
                            when "0100000" =>               --SUB
                                jump        <= '0';
                                Branch      <= "000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= '0';
                                ALUSrc      <= '1';
                                ALUOp       <= "101";
                                WriteReg    <= '1';                            
                            when others =>                  --not included instructions
                                jump        <= '0';
                                Branch      <= "000";
                                ToRegister  <= "000";
                                MemWrite    <= '0';
                                StoreSel    <= '0';
                                ALUSrc      <= '0';
                                ALUOp       <= "000";
                                WriteReg    <= '0'; 
                        end case;
                    when "001" =>                           --SLL
                        jump        <= '0';
                        Branch      <= "000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= '0';
                        ALUSrc      <= '1';
                        ALUOp       <= "110";
                        WriteReg    <= '1';
                    when "010" =>                           --SLT
                        jump        <= '0';
                        Branch      <= "000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= '0';
                        ALUSrc      <= '1';
                        ALUOp       <= "011";
                        WriteReg    <= '1';
                    when "100" =>                           --XOR
                        jump        <= '0';
                        Branch      <= "000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= '0';
                        ALUSrc      <= '1';
                        ALUOp       <= "010";
                        WriteReg    <= '1';
                    when "101"  =>                          --SRL
                        jump        <= '0';
                        Branch      <= "000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= '0';
                        ALUSrc      <= '1';
                        ALUOp       <= "111";
                        WriteReg    <= '1';
                    when "110"  =>                          --OR
                        jump        <= '0';
                        Branch      <= "000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= '0';
                        ALUSrc      <= '1';
                        ALUOp       <= "010";
                        WriteReg    <= '1';
                    when "111"  =>                          --AND
                        jump        <= '0';
                        Branch      <= "000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= '0';
                        ALUSrc      <= '1';
                        ALUOp       <= "000";
                        WriteReg    <= '1';
                    when others =>
                        jump        <= '0';
                        Branch      <= "000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= '0';
                        ALUSrc      <= '0';
                        ALUOp       <= "000";
                        WriteReg    <= '0';
                end case;
            when "0010011" =>                       --I-type immediate arithm
                case funct3 is
                    when "000" =>                   --ADDI
                        jump        <= '0';
                        Branch      <= "000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= '0';
                        ALUSrc      <= '0';
                        ALUOp       <= "100";
                        WriteReg    <= '1';
                    when "111" =>                   --ANDI
                        jump        <= '0';
                        Branch      <= "000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= '0';
                        ALUSrc      <= '0';
                        ALUOp       <= "000";
                        WriteReg    <= '1';
                    when "100" =>                   --XORI
                        jump        <= '0';
                        Branch      <= "000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= '0';
                        ALUSrc      <= '0';
                        ALUOp       <= "010";
                        WriteReg    <= '1';
                    when "110" =>                   --ORI
                        jump        <= '0';
                        Branch      <= "000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= '0';
                        ALUSrc      <= '0';
                        ALUOp       <= "100";
                        WriteReg    <= '1';
                    when others =>
                        jump        <= '0';
                        Branch      <= "000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= '0';
                        ALUSrc      <= '0';
                        ALUOp       <= "000";
                        WriteReg    <= '0';                                      
                end case;
                when "0000011" =>                       --I-type LOADS
                case funct3 is
                    when "000" =>                   --LB
                        jump        <= '0';
                        Branch      <= "000";
                        ToRegister  <= "001";
                        MemWrite    <= '0';
                        StoreSel    <= '0';
                        ALUSrc      <= '0';
                        ALUOp       <= "100";
                        WriteReg    <= '1';
                    when "010" =>                   --LW
                        jump        <= '0';
                        Branch      <= "000";
                        ToRegister  <= "010";
                        MemWrite    <= '0';
                        StoreSel    <= '0';
                        ALUSrc      <= '0';
                        ALUOp       <= "100";
                        WriteReg    <= '1';
                    when others =>
                        jump        <= '0';
                        Branch      <= "000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= '0';
                        ALUSrc      <= '0';
                        ALUOp       <= "000";
                        WriteReg    <= '0';                                      
                end case;
                when "0100011" =>                       --Stores
                case funct3 is
                    when "000" =>                   --SB
                        jump        <= '0';
                        Branch      <= "000";
                        ToRegister  <= "000";
                        MemWrite    <= '1';
                        StoreSel    <= '1';
                        ALUSrc      <= '0';
                        ALUOp       <= "100";
                        WriteReg    <= '0';
                    when "010" =>                   --SW
                        jump        <= '0';
                        Branch      <= "000";
                        ToRegister  <= "000";
                        MemWrite    <= '1';
                        StoreSel    <= '0';
                        ALUSrc      <= '0';
                        ALUOp       <= "100";
                        WriteReg    <= '0';
                    when others =>
                        jump        <= '0';
                        Branch      <= "000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= '0';
                        ALUSrc      <= '0';
                        ALUOp       <= "000";
                        WriteReg    <= '0';                                      
                end case;
                when "1100011" =>                       --Branches
                case funct3 is
                    when "000" =>                   --BEQ
                        jump        <= '0';
                        Branch      <= "001";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= '0';
                        ALUSrc      <= '1';
                        ALUOp       <= "101";
                        WriteReg    <= '0';
                    when "001" =>                   --BNQ
                        jump        <= '0';
                        Branch      <= "010";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= '0';
                        ALUSrc      <= '1';
                        ALUOp       <= "101";
                        WriteReg    <= '0';
                    when "100" =>                  --BLT
                        jump        <= '0';
                        Branch      <= "011";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= '0';
                        ALUSrc      <= '1';
                        ALUOp       <= "101";
                        WriteReg    <= '0';
                    when "101" =>                  --BGT
                        jump        <= '0';
                        Branch      <= "100";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= '0';
                        ALUSrc      <= '1';
                        ALUOp       <= "101";
                        WriteReg    <= '0';
                    when others =>
                        jump        <= '0';
                        Branch      <= "000";
                        ToRegister  <= "000";
                        MemWrite    <= '0';
                        StoreSel    <= '0';
                        ALUSrc      <= '0';
                        ALUOp       <= "000";
                        WriteReg    <= '0';                                     
                end case;
                when "1100111" =>                  --JALR
                    jump        <= '1';
                    Branch      <= "101";
                    ToRegister  <= "011";           --PC
                    MemWrite    <= '0';
                    StoreSel    <= '0';
                    ALUSrc      <= '1';
                    ALUOp       <= "101";
                    WriteReg    <= '1';
                when "1101111" =>                  --JAL
                    jump        <= '0';
                    Branch      <= "110";
                    ToRegister  <= "101";           --PC+4
                    MemWrite    <= '0';
                    StoreSel    <= '0';
                    ALUSrc      <= '1';
                    ALUOp       <= "101";
                    WriteReg    <= '0';
                when others =>                  
                    jump        <= '0';
                    Branch      <= "000";
                    ToRegister  <= "000";           
                    MemWrite    <= '0';
                    StoreSel    <= '0';
                    ALUSrc      <= '0';
                    ALUOp       <= "000";
                    WriteReg    <= '0';
        end case;    
    end process;
end arch_Control ; -- arch_Control