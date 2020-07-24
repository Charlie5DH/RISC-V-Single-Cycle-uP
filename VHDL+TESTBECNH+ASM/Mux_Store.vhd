library ieee;
use ieee.std_logic_1164.all;

entity Mux_Store is
    port (
        muxIn0      :in std_logic_vector(31 downto 0);
        muxIn1      :in std_logic_vector(31 downto 0);
        selector    :in std_logic;
        muxOut      :out std_logic_vector(31 downto 0)
    );
end entity Mux_Store;

architecture arch_Mux_Store of Mux_Store is
    signal selected : std_logic_vector(31 downto 0);
begin
    process( muxIn0, muxIn1, selector )
    begin
        case selector is
            when '0' => selected <= muxIn0;
            when '1' => selected <= muxIn1;   --byte mask
            when others => selected <= muxIn0;              
        end case;
    end process ; -- 

    muxOut <= selected;
    
end architecture arch_Mux_Store;