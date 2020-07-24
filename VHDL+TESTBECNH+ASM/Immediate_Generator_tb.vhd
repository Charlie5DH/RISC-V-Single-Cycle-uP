-------------------------------------------------------------------------------
-- Title      : Testbench for design "Immediate_Generator"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : Immediate_Generator_tb.vhd
-- Author     :   <Carlos@DESKTOP-7LHO1A2>
-- Company    : 
-- Created    : 2019-05-28
-- Last update: 2019-05-28
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2019 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-05-28  1.0      Carlos	Created
-------------------------------------------------------------------------------

library ieee;
use ieee.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------------------------------------

entity Immediate_Generator_tb is

end entity Immediate_Generator_tb;

-------------------------------------------------------------------------------

architecture arch_Immeadiate_Generator of Immediate_Generator_tb is

  -- component ports
  signal instruction : std_logic_vector(31 downto 0) := (others => '0');
  signal immediate   : std_logic_vector(31 downto 0);

  constant period : time := 50 ns;

begin  -- architecture arch_Immeadiate_Generator

  -- component instantiation
  DUT: entity work.Immediate_Generator
    port map (
      instruction => instruction,
      immediate   => immediate);

  -- waveform generation
  WaveGen_Proc: process
  begin
    wait for period;
    instruction <= "00000000011100110000001010010011";
    wait for period;
    instruction <= "11000000010100110000001010000011";
    wait for period;
    instruction <= "01000000011100110000001010100011";
    wait for period;
    instruction <= "00001110011100110111001011100011";
    wait for period;
    instruction <= "00000000000000110111001011100111";
    wait for period;
    instruction <= "00000000011100110100001011101111";   

  end process WaveGen_Proc;
end architecture arch_Immeadiate_Generator;

-------------------------------------------------------------------------------

configuration Immediate_Generator_tb_arch_Immeadiate_Generator_cfg of Immediate_Generator_tb is
  for arch_Immeadiate_Generator
  end for;
end Immediate_Generator_tb_arch_Immeadiate_Generator_cfg;

-------------------------------------------------------------------------------
