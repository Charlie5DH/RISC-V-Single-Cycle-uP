library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity ALU_RV32 is
    port (
        operator1   :in std_logic_vector(31 downto 0);
        operator2   :in std_logic_vector(31 downto 0);
        ALUOp       :in std_logic_vector(2 downto 0);
        result      :out std_logic_vector(31 downto 0);
        zero        :out std_logic;
        carryOut    :out std_logic;
        signo  		:out std_logic
    );
end entity ALU_RV32;

architecture arch_ALU_RV32 of ALU_RV32 is
    
    signal aluResult        : std_logic_vector(31 downto 0);
    signal temp_sign        : std_logic_vector(31 downto 0); 
    signal temporal         : std_logic_vector(32 downto 0);
    signal subtraction      : std_logic_vector(32 downto 0);
    signal addition         : std_logic_vector(32 downto 0);
    signal shiftNumb        : std_logic_vector(4 downto 0);
	signal shift1l, shift2l, shift4l, shift8l, shift16l : std_logic_vector(31 downto 0);
    signal shift1r, shift2r, shift4r, shift8r, shift16r : std_logic_vector(31 downto 0);

begin
    process(operator1, operator2, ALUOp, addition, subtraction, shift16l, shift16r, temp_sign)
    begin
        case(ALUOp) is
            when "000" => aluResult <= operator1 and operator2;     --AND
            when "001" => aluResult <= operator1 or operator2;      --OR
            when "010" => aluResult <= operator1 xor operator2;     --XOR    
            when "011" => aluResult <= temp_sign;                    --SLT
            when "100" => aluResult <= addition(31 downto 0);       --ADD
            when "101" => aluResult <= subtraction(31 downto 0);    --SUB
            when "110" => aluResult <= shift16l;                   --SLL
            when "111" => aluResult <= shift16r;                   --SRL
            when others => aluResult <= operator1;
        end case ;       
    end process ;
    
    shiftNumb   <= operator2(4 downto 0);                                               --it can only be left shifted 32 bits                                                           --vector to put zeros in right
	shift1l  <= operator1(30 downto 0) & '0' when shiftNumb(0) = '1' else operator1;    --shift one or no shift
	shift2l  <= shift1l(29 downto 0) & "00" when shiftNumb(1) = '1' else shift1l;       --shift two, three or no shift
	shift4l  <= shift2l(27 downto 0) & x"0" when shiftNumb(2) = '1' else shift2l;       --shift four,five,six,seven or no shift
	shift8l  <= shift4l(23 downto 0) & x"00" when shiftNumb(3) = '1' else shift4l;      --shift 8 or 9 or ... or 15 or no shift
	shift16l <= shift8l(15 downto 0) & x"0000" when shiftNumb(4) = '1' else shift8l;    --shift 16,17,...,32 or no shift
 
	shift1r  <= '0' & operator1(31 downto 1) when shiftNumb(0) = '1' else operator1;
	shift2r  <= "00" & shift1r(31 downto 2) when shiftNumb(1) = '1' else shift1r;
	shift4r  <= x"0" & shift2r(31 downto 4) when shiftNumb(2) = '1' else shift2r;
	shift8r  <= x"00" & shift4r(31 downto 8)  when shiftNumb(3) = '1' else shift4r;
	shift16r <= x"0000" & shift8r(31 downto 16) when shiftNumb(4) = '1' else shift8r;

    addition    <= ('0' & operator1) + ('0' & operator2);                   --append 0 after MSB for carry out detection
    subtraction <= ('0' & operator1) - ('0' & operator2);                   --append 0 after MSB for carry out detection
    carryOut    <= addition(32) when ALUOp = "100" else subtraction(32);    --the carry will be the MSB bit
    temp_sign   <= X"00000001" when subtraction(31) = '0' else X"00000000";   
    zero        <= '1' when aluResult = X"00000000" else '0';           --zero flag indicates if the operation is equal to 0
    signo       <= aluResult(31);                                       --the sign bit is the MSB of the result
    result      <= aluResult;

end arch_ALU_RV32 ; -- arch_ALU_RV32