-------------------------------------------------------------------------------
-- Title      : Testbench for design "OutputLogic"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : OutputLogic_tb.vhd
-- Author     :   <Carlos@DESKTOP-7LHO1A2>
-- Company    : 
-- Created    : 2019-06-13
-- Last update: 2019-06-13
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2019 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-06-13  1.0      Carlos	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------------------------------------

entity OutputLogic_tb is

end entity OutputLogic_tb;

-------------------------------------------------------------------------------

architecture OutputLogic_arch of OutputLogic_tb is

  -- component ports
  signal reset     : std_logic := '0';
  signal Reg       : std_logic_vector(31 downto 0) := (others => '0');
  signal outputSel : std_logic_vector(2 downto 0) := (others => '0');
  signal LEDR      : std_logic_vector(9 downto 0);
  signal HEX0      : std_logic_vector(6 downto 0);
  signal HEX1      : std_logic_vector(6 downto 0);
  signal HEX2      : std_logic_vector(6 downto 0);
  signal HEX3      : std_logic_vector(6 downto 0);
  signal HEX4      : std_logic_vector(6 downto 0);
  signal HEX5      : std_logic_vector(6 downto 0);

  constant clk_period : time := 50 ns;

begin  -- architecture OutputLogic_arch

  -- component instantiation
  DUT: entity work.OutputLogic
    port map (
      reset     => reset,
      Reg       => Reg,
      outputSel => outputSel,
      LEDR      => LEDR,
      HEX0      => HEX0,
      HEX1      => HEX1,
      HEX2      => HEX2,
      HEX3      => HEX3,
      HEX4      => HEX4,
      HEX5      => HEX5);

      reset <= '1';
  -- waveform generation
  WaveGen_Proc: process
  begin
    wait for clk_period;
    reg <= reg +1;
    outputSel <= outputSel +1;
    
  end process WaveGen_Proc;
end architecture OutputLogic_arch;

-------------------------------------------------------------------------------

configuration OutputLogic_tb_OutputLogic_arch_cfg of OutputLogic_tb is
  for OutputLogic_arch
  end for;
end OutputLogic_tb_OutputLogic_arch_cfg;

-------------------------------------------------------------------------------
