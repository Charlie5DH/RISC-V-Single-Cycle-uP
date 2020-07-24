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
  signal CLOCK_50: std_logic  := '0';
  signal rst     : std_logic;
  signal KEY    : std_logic_vector(3 downto 0); --key(0) rst, key(1) = step
  signal SW     : std_logic_vector(9 downto 0); 
  signal LEDR		: std_logic_vector (9 downto 0);
  signal HEX0		: std_logic_vector (6 downto 0);
  signal HEX1		: std_logic_vector (6 downto 0);
  signal HEX2		: std_logic_vector (6 downto 0);
  signal HEX3		: std_logic_vector (6 downto 0);
  signal HEX4		: std_logic_vector (6 downto 0);
  signal HEX5		: std_logic_vector (6 downto 0);

  constant clk_period : time := 50 ns;
  signal clk  : std_logic;

begin  -- architecture arch_Datapath

  -- component instantiation
  DUT: entity work.DataPath
    port map (
      CLOCK_50       => CLOCK_50,
      KEY       => KEY,
      SW      => SW,
      LEDR      => LEDR,
      HEX0      => HEX0,
      HEX1      => HEX1,
      HEX2      => HEX2,
      HEX3      => HEX3,
      HEX4      => HEX4,
      HEX5      => HEX5
      );

      clk <= CLOCK_50;

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
    KEY(0) <= '1';
    KEY(1) <= not KEY(1);

  end process WaveGen_Proc;

end architecture arch_Datapath;

-------------------------------------------------------------------------------

configuration DataPath_tb_arch_Datapath_cfg of DataPath_tb is
  for arch_Datapath
  end for;
end DataPath_tb_arch_Datapath_cfg;

-------------------------------------------------------------------------------
