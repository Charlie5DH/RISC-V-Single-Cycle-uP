-------------------------------------------------------------------------------
-- Title      : Testbench for design "DataPath"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : DataPath_tb.vhd
-- Author     :   <Carlos@DESKTOP-7LHO1A2>
-- Company    : 
-- Created    : 2019-05-29
-- Last update: 2019-05-29
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2019 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-05-29  1.0      Carlos	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity DataPath_tb is

end entity DataPath_tb;

-------------------------------------------------------------------------------

architecture arch_Datapath of DataPath_tb is

  -- component ports
  signal clk       : std_logic  := '0';
  signal rst       : std_logic  := '0';
  signal step      : std_logic  := '0';
  signal clk_man   : std_logic  := '1';

  constant clk_period : time := 50 ns;

begin  -- architecture arch_Datapath

  -- component instantiation
  DUT: entity work.DataPath
    port map (
      clk       => clk,
      rst       => rst,
      step      => step,
      clk_man   => clk_man
      );

  clk_generation : process
  begin
    clk <= '0';
    wait for clk_period/2;
    clk <= '1';
    wait for clk_period/2;
  end process ; -- clk_generation

  -- waveform generation
  WaveGen_Proc: process
  begin
    wait for clk_period;
    rst <= '1';
    step <= not step;

  end process WaveGen_Proc;

end architecture arch_Datapath;

-------------------------------------------------------------------------------

configuration DataPath_tb_arch_Datapath_cfg of DataPath_tb is
  for arch_Datapath
  end for;
end DataPath_tb_arch_Datapath_cfg;

-------------------------------------------------------------------------------
