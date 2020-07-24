--single port RAM of 16 local * 8 bits (16 registers of 8 bits)
--no chip select and no read enable cause the output goes to a mux, not a bus
--0H to 7H for output data (0H-3H and 4H-7H 32 bits register) 2reg 32 bits
--8H to FH for input operations (8H-BH and CH-FH for inputs) 2reg 32 bits

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity Data_Mem is
    port (
        clk     :in std_logic;
        rst     :in std_logic;
        writeEn :in std_logic;
        Address :in std_logic_vector(3 downto 0);
        dataIn  :in std_logic_vector(31 downto 0);
        dataOut :out std_logic_vector(31 downto 0)
    );
end entity Data_Mem;

architecture arch_Data_Mem of Data_Mem is

    type RAM is array (15 downto 0) of std_logic_vector(7 downto 0);
    signal MEM : RAM := (others => (others => '0'));
begin
    process(clk, rst)
    begin
        if rst = '0' then
            MEM <= (others => (others => '0'));
        elsif rising_edge(clk) then
            if (writeEn = '1') then
                MEM(conv_integer(Address))   <= dataIn(7 downto 0);
                MEM(conv_integer(Address+1)) <= dataIn(15 downto 8);
                MEM(conv_integer(Address+2)) <= dataIn(23 downto 16);
                MEM(conv_integer(Address+3)) <= dataIn(31 downto 24);
            end if;
    end if;
    end process;
    
    dataOut <= MEM(conv_integer(Address+3)) & MEM(conv_integer(Address+2)) &
               MEM(conv_integer(Address+1)) & MEM(conv_integer(Address)); 

end arch_Data_Mem ; -- arch_Data_Mem