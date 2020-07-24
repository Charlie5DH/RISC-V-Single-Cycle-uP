library ieee;
use ieee.std_logic_1164.all;

entity Mux_ToRegFile is
    generic(
        busWidth    :integer := 32;
        selWidth    :integer := 3
    );
	port (
        muxIn0     :in std_logic_vector(busWidth-1 downto 0);       --register
        muxIn1     :in std_logic_vector(busWidth-1 downto 0);       --LB
        muxIn2     :in std_logic_vector(busWidth-1 downto 0);       --LW
        muxIn3     :in std_logic_vector(busWidth-1 downto 0);       --PC
        muxIn4     :in std_logic_vector(busWidth-1 downto 0);       --mult
        muxIn5     :in std_logic_vector(busWidth-1 downto 0);       --PC+4
        selector   :in std_logic_vector(selWidth-1 downto 0);       --ToRegister
        muxOut     :out std_logic_vector(busWidth-1 downto 0)
	);
end Mux_ToRegFile;

architecture arch_Mux_ToRegFile of Mux_ToRegFile is

    signal selected : std_logic_vector(busWidth-1 downto 0);
    signal LB : std_logic_vector(busWidth-1 downto 0);
    signal signo : std_logic;
    
begin
    process( selector, muxIn0, muxIn1, muxIn2, muxIn3, muxIn4, muxIn5, LB )
    begin
        case selector is
            when "000" => selected <= muxIn0;
            when "001" => selected <= LB;
            when "010" => selected <= muxIn2;
            when "011" => selected <= muxIn3;
            when "100" => selected <= muxIn4;
            when "101" => selected <= muxIn5;
            when others => selected <= muxIn0;
        end case;
    end process ;
    
    signo   <= muxIn1(7);
    LB      <= (muxIn1 or X"FFFFFF00") when signo = '1' else (muxIn1 and X"000000FF");    --sign extension
	muxOut <= selected;

end arch_Mux_ToRegFile;