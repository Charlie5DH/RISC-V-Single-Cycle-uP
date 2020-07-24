-------------------------------------------------------------------------------
-- Title      : Testbench for design "Mux_Store"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : Mux_Store_tb.vhd
-- Author     :   <Carlos@DESKTOP-7LHO1A2>
-- Company    : 
-- Created    : 2019-05-27
-- Last update: 2019-05-27
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2019 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-05-27  1.0      Carlos	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity Mux_Store_tb is

end entity Mux_Store_tb;

-------------------------------------------------------------------------------

architecture muxStore of Mux_Store_tb is

  -- component ports
  signal muxIn0   : std_logic_vector(31 downto 0);
  signal muxIn1   : std_logic_vector(31 downto 0);
  signal selector : std_logic;
  signal muxOut   : std_logic_vector(31 downto 0);

  constant period : time := 50 ns;

begin  -- architecture muxStore

  -- component instantiation
  DUT: entity work.Mux_Store
    port map (
      muxIn0   => muxIn0,
      muxIn1   => muxIn1,
      selector => selector,
      muxOut   => muxOut);

  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here
    muxIn0    <= X"0000AF65";
    muxIn1    <= X"0000B0BA";
    selector  <= '0';
    wait for period;
    selector  <= '1';
    wait for period;

  end process WaveGen_Proc;

  

end architecture muxStore;

-------------------------------------------------------------------------------

configuration Mux_Store_tb_muxStore_cfg of Mux_Store_tb is
  for muxStore
  end for;
end Mux_Store_tb_muxStore_cfg;

-------------------------------------------------------------------------------
