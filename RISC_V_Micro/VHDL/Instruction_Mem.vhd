library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;

entity Instruction_Mem is
    port (
        Address     :in std_logic_vector(15 downto 0);
        instruction :out std_logic_vector(31 downto 0) 
    );
end entity Instruction_Mem;

architecture arch_Instruction_Mem of Instruction_Mem is
    
    type ROM_ARRAY is array (0 to 65535) of std_logic_vector(7 downto 0);      --declaring size of memory. 128 elements of 32 bits
    constant ROM : ROM_ARRAY := (
        -----------START LABEL:
        "00000000","01110000","10000000","10010011",    --addi x1,x1,0x0       00H-03H
        "00000000","00010000","00000000","00100011",    --sb x1,0(x0)          04H-07H
        "00000000","01000001","00000001","00010011",    --addi x2, x2, 4       08H-0BH
        "00000000","00010001","10000001","10010011",    --addi x3,x3,1         0C
        "00000000","00100010","00000010","00010011",    --addi x4,x4,2         10
        "00000000","00110010","10000010","10010011",    --addi x5,x5,3         14
        ------------PICK LABEL:
        "00000000","00000001","00100000","10000011",    --lw x1, 0(x2)         18
        "00111111","11110000","11110000","10010011",    --andi x1,x1,0x00003FF
        "00000000","00110000","10001000","01100011",    --beq x1,x3, INSTRUCTIONS
        "00000100","01000000","10001110","01100011",    --beq x1,x4, BEGIN_FIBB
        "00001100","01010000","10000000","01100011",    --beq x1,x5, BEGIN_FACT
        "11111110","11011111","11110000","01101111",    --jal x0, PICK
        -------------INSTRUCTIONS LABEL:
        "00000000","01000000","00100000","10000011",
        "00000000","00010001","00000001","00010011",
        "00000000","00010001","01110001","00010011",
        "11111110","00100000","11001010","11100011",
        "00000000","00110000","10000000","10010011",
        "00000000","00010000","10000000","00100011",
        "00000000","00100011","10000011","10010011",
        "01000000","01110000","10000001","10110011",
        "00000000","00110000","00000001","00100011",
        "00000000","11110010","00000010","00010011",
        "00000000","00010010","01110010","00110011",
        "00000000","01000000","00000001","10100011",
        "00000000","00000011","01110010","10010011",
        "00000000","01110011","01000010","10110011",
        "00000000","01110011","01000010","10010011",
        "00000000","01110011","01100010","10110011",
        "00000000","01110011","01100010","10010011",
        "00000000","01110011","00010010","10110011",
        "00000000","01110011","01010010","10110011",
        "00000000","01110011","00100010","10110011",
        "00000000","00110000","10000000","00100011",
        "00000000","01010000","00000001","00100011",
        "00000000","01010001","10000001","00000011",
        "00000000","01010001","10100010","00000011",
        "00000000","00110000","00000001","00010011",
        "00000000","00010100","00000100","00010011",
        "11111110","10000001","00011100","11100011",
        "11110110","01011111","11110000","01101111",
--------------------FIBONACCI PROGRAM-------------------------------------------------------------
        "00000000","01000101","00000101","00010011",    -- addi x10,x10,4           address for load external inputs  80H
        -----------BEGIN_FIBB LABEL:                             
        "00000000","00000101","00100000","10000011",    -- lw x1,0(x10)             load the inputs to X1               84H
        "00111111","11110000","11110000","10010011",    -- andi x1,x1,0x00003FF     mask to keep only the switches      88H              
        "00000000","00000001","01110001","00010011",    -- andi x2,x2, 0x0          cleaning x2                         8CH
        "11111110","00100000","10001010","11100011",    -- beq x1,x2, BEGIN_FIBB    If the number is 0 the progrma would't start 90H
        "00000000","00000001","11110001","10010011",    -- andi x3,x3, 0x0          second                              68H-6BH
        "00000000","00000010","01110010","00010011",    -- andi x4,x4, 0x0          next                                6CH-6FH
        "00000000","00000010","11110010","10010011",    -- andi x5,x5, 0x0          cleaning previous value of C        70H-73H
        "11111111","11110010","10000010","10010011",    -- starting C = -1                                              74H-77H
        "00000000","00000011","11110011","10010011",    -- andi x7,x7, 0x0          cleaning X7                         78H-7BH
        "00000000","00100011","10000011","10010011",    -- addi x7,x7, 0x1          number 2                            7CH-7FH
        "00000000","00010001","10000001","10010011",    -- addi x3,x3, 0x1          second = 1                          80H-83H
        "00000000","00000100","01110100","00010011",    -- andi x8,x8, 0x0          cleaning register base              84H-87H
        "00000000","00110100","10000100","10010011",    -- addi x9,x9, 0x3          top register                        88H-8BH
        -----------FIBONACCI LABEL:
        "00000000","00010010","10000010","10010011",    -- addi x5,x5,1             Increase C so starts in 0 and ++ in every loop 8CH-8FH
        "00000010","01110010","11000000","01100011",    -- blt x5,x7, NEXTC         if(x5(C) < x7(2)) NEXTC             90H-93H
        "00000000","01110010","00000010","00110011",    -- add x4,x2,x3             else {next = first + second         94H-97H
        "00000000","00000001","10000001","00010011",    -- addi x2,x3,0             first = second                      98H-9BH
        "00000000","00000010","00000001","10010011",    -- addi x3,x4,0             second = next}                      9C-9FH
        -----------PRINT LABEL:
        "00000000","01000100","00000000","00100011",    -- sb x4,0(x8)              store in address                    A0H-A3H
        "00000000","00010100","00000100","00010011",    -- addi x8,x8,1             increase index in memory            A4H-A7H
        "00000000","10010100","00001000","01100011",    -- beq x8,x9, END                                               A8H-ABH
        "11111110","00010010","11000000","11100011",    -- blt x5,x1, FIBONACCI     if(C < n)                           ACH-AFH
        ------------ NEXTC LABEL:
        "00000000","00000010","10000010","00010011",    -- addi x4,x5,0x0    next = C                                   B0H-B3H
        "11111110","11011111","11110000","01101111",    -- jal x0, PRINT                                                B4H-B7H
        -------------END LABEL:
        "11110001","10011111","11110000","01101111",    -- jal x0, START
        ------------FACTORIAL PROGRAM--------------
        ------------BEGIN FACT:
        "00000000","00000010","01110010","00010011",    --andi x4, x4, 0
        "00000000","00010010","00000010","00010011",    --addi x4,x4, 1
        "00000000","00000010","11110010","10010011",    --andi x5,x5,0
        "00000000","00010010","10000010","10010011",    --addi x5,x5,1
        "00000000","00000001","01110001","00010011",    --andi x2,x2, 0
        "00000000","01000001","00000001","00010011",    --addi x2,x2, 4
        "00000000","00000001","00100000","10000011",    --lw x1, 0(x2)
        "00000000","00000001","11110001","10010011",    --andi x3,x3 0
        "00000000","00010001","10000001","10010011",    --addi x3,x3, 1
        "11111100","00000000","10001110","11100011",    --beq x1,x0, BEGIN_FACT
        ---------------FOR LABEL
        "00000010","01000001","10000001","10110011",    --mul x3,x3,x4
        "00000000","00010010","00000010","00010011",    --addi x4, x4, 1
        "11111110","00010010","01001100","11100011",    --bgt x1,x4, FOR
        "00000000","00110000","00100000","00100011",    --sw x3,0(x0)
        "00000000","00110010","10100000","00100011",    --sw x3,0(x5)
        "11101101","11011111","11110000","01101111",    --jal x0, START
        others => X"00"
    );
begin
    instruction <= ROM(conv_integer(Address)) & ROM(conv_integer(Address + 1)) &
                   ROM(conv_integer(Address + 2)) & ROM(conv_integer(Address + 3)); 
    --instruction <= ROM(conv_integer(Address + 3)) & ROM(conv_integer(Address + 2))
      --           & ROM(conv_integer(Address + 1)) & ROM(conv_integer(Address));
 

end architecture arch_Instruction_Mem;


-- int n, first = 0, second = 1, next, c;
 
--   printf("Enter the number of terms\n");
--   scanf("%d", &n);
 
--   printf("First %d terms of Fibonacci series are:\n", n);
 
--   for (c = 0; c < n; c++)
--   {
--     if (c < 2)
--       next = c;
--     else
--     {
--       next = first + second;
--       first = second;
--       second = next;
--     }
--     printf("%d\n", next);
--   }
 
--   return 0;
-- }

--int main()
--{
    --int n, i;
    --unsigned long long factorial = 1;

    --printf("Enter an integer: ");
    --scanf("%d",&n);
    --// show error if the user enters a negative integer
    --if (n < 0)
     --   printf("Error! Factorial of a negative number doesn't exist.");

   -- else
   -- {
        --for(i=1; i<=n; ++i)
        --{
     --       factorial *= i;              // factorial = factorial*i;
       -- }
  ---      printf("Factorial of %d = %llu", n, factorial);
    --}
--
  --  return 0;
--}