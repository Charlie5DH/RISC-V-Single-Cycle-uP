-------------------------------------------------------------------------------
-- Title      : Testbench for design "Mux_ToRegFile"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : Mux_ToRegFile_tb.vhd
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
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------------------------------------

entity Mux_ToRegFile_tb is

end entity Mux_ToRegFile_tb;

-------------------------------------------------------------------------------

architecture Mux_ToRegFile of Mux_ToRegFile_tb is

  -- component generics
  constant busWidth : integer := 32;
  constant selWidth : integer := 3;

  -- component ports
  signal muxIn0   : std_logic_vector(busWidth-1 downto 0);
  signal muxIn1   : std_logic_vector(busWidth-1 downto 0);
  signal muxIn2   : std_logic_vector(busWidth-1 downto 0);
  signal muxIn3   : std_logic_vector(busWidth-1 downto 0);
  signal muxIn4   : std_logic_vector(busWidth-1 downto 0);
  signal muxIn5   : std_logic_vector(busWidth-1 downto 0);
  signal muxIn6   : std_logic_vector(busWidth-1 downto 0);
  signal selector : std_logic_vector(selWidth-1 downto 0) := "000";
  signal muxOut   : std_logic_vector(busWidth-1 downto 0);

  constant period : time := 50 ns;

  -- clock
  --signal Clk : std_logic := '1';

begin  -- architecture Mux_ToRegFile

  -- component instantiation
  DUT: entity work.Mux_ToRegFile
    generic map (
      busWidth => busWidth,
      selWidth => selWidth)
    port map (
      muxIn0   => muxIn0,
      muxIn1   => muxIn1,
      muxIn2   => muxIn2,
      muxIn3   => muxIn3,
      muxIn4   => muxIn4,
      muxIn5   => muxIn5,
      muxIn6   => muxIn6,
      selector => selector,
      muxOut   => muxOut);

    muxIn0 <= X"FF00AB0D";
    muxIn1 <= X"FF00ABFF";
    muxIn2 <= X"FF000000";
    muxIn3 <= X"FFFFAB0D";
    muxIn4 <= X"FF00FF00";
    muxIn5 <= X"22CCBBAA";
    

  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here
    wait for period;
    selector <= selector + 1;

  end process WaveGen_Proc;

  

end architecture Mux_ToRegFile;

-------------------------------------------------------------------------------

configuration Mux_ToRegFile_tb_Mux_ToRegFile_cfg of Mux_ToRegFile_tb is
  for Mux_ToRegFile
  end for;
end Mux_ToRegFile_tb_Mux_ToRegFile_cfg;

-------------------------------------------------------------------------------
