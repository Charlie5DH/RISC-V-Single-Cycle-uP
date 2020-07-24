--lamps active 0
library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

entity OutputLogic is
    port (
        reset       : in std_logic;
        Reg         : in std_logic_vector(31 downto 0);
        outputSel   : in std_logic_vector(2 downto 0);
        LEDR        : out std_logic_vector(9 downto 0);
        HEX0        : out std_logic_vector(6 downto 0);
        HEX1        : out std_logic_vector(6 downto 0);
        HEX2        : out std_logic_vector(6 downto 0);
        HEX3        : out std_logic_vector(6 downto 0);
        HEX4        : out std_logic_vector(6 downto 0);
        HEX5        : out std_logic_vector(6 downto 0)
    );
end entity OutputLogic;

architecture OutputLogic_arch of OutputLogic is

    component bcdTo7Seg
        Port ( 
            bcd_i : in  STD_LOGIC_VECTOR (3 downto 0);
            sseg_o : out  STD_LOGIC_VECTOR (6 downto 0)
        );
    end component;

    signal bcd0,bcd1,bcd2,bcd3,bcd4,bcd5 : std_logic_vector(3 downto 0) := (others => '0');
    signal selecReset: std_logic_vector(2 downto 0);
    signal LEDS     : std_logic_vector(9 downto 0);

begin

    dec0: bcdTo7Seg port map (bcd_i => bcd0, sseg_o => HEX0);
    dec1: bcdTo7Seg port map (bcd_i => bcd1, sseg_o => HEX1);
    dec2: bcdTo7Seg port map (bcd_i => bcd2, sseg_o => HEX2);
    dec3: bcdTo7Seg port map (bcd_i => bcd3, sseg_o => HEX3);
    dec4: bcdTo7Seg port map (bcd_i => bcd4, sseg_o => HEX4);
    dec5: bcdTo7Seg port map (bcd_i => bcd5, sseg_o => HEX5);
    LEDR <= LEDS;

    process( selecReset )
    begin
        case selecReset is
            when "001" => 
                LEDS <= (others => '0'); bcd0 <= (others => '0');bcd1 <= (others => '0');
                bcd2 <= (others => '0');bcd3 <= (others => '0');
                bcd4 <= (others => '0');bcd5 <= (others => '0');
            when "100" => LEDS <= reg(9 downto 0);
            when "101" => 
                bcd0 <= reg(3 downto 0);
                bcd1 <= reg(7 downto 4);
            when "110" =>
                bcd2 <= reg(3 downto 0);
                bcd3 <= reg(7 downto 4);
            when "111" =>
                bcd4 <= reg(3 downto 0);
                bcd5 <= reg(7 downto 4);
            when others => NULL;
        end case;
    end process ; -- 
    
    --LEDR <= reg(9 downto 0) when (outputSel = "100" and reset = '1') else (others => '0');
    --bcd0 <= reg(3 downto 0) when (outputSel = "101" and reset = '1') else (others => '0');
    --bcd1 <= reg(7 downto 4) when (outputSel = "101" and reset = '1') else (others => '0');
    --bcd2 <= reg(3 downto 0) when (outputSel = "110" and reset = '1') else (others => '0');
    --bcd3 <= reg(7 downto 4) when (outputSel = "110" and reset = '1') else (others => '0');
    --bcd4 <= reg(3 downto 0) when (outputSel = "111" and reset = '1') else (others => '0');
    --bcd5 <= reg(7 downto 4) when (outputSel = "111" and reset = '1') else (others => '0');    
    
    selecReset <= outputSel when reset = '1' else "001";

end OutputLogic_arch ; -- OutputLogic_arch