-------------------------------------------------------------------------------
-- Title      : Testbench for design "multiplier1"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : multiplier1_tb.vhd
-- Author     :   <Carlos@DESKTOP-7LHO1A2>
-- Company    : 
-- Created    : 2019-06-15
-- Last update: 2019-06-15
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2019 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-06-15  1.0      Carlos	Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------------------------------------

entity multiplier1_tb is

end entity multiplier1_tb;

-------------------------------------------------------------------------------

architecture multiplier1_tb of multiplier1_tb is

  -- component generics
  constant size : INTEGER := 16;

  -- component ports
  signal operator1  : std_logic_vector(size-1 downto 0) := (others => '0');
  signal operator2  : std_logic_vector(size-1 downto 0) := (others => '0');
  signal product    : std_logic_vector(2*size-1 downto 0);

begin  -- architecture multiplier1_tb

  -- component instantiation
  DUT: entity work.multiplier1
    generic map (
      size => size)
    port map (
      operator1 => operator1,
      operator2 => operator2,
      product => product);

  -- waveform generation
  WaveGen_Proc: process
  begin
    wait for 50 ns;
    operator1 <= operator1 + 1;
    operator2 <= operator2 + 1;

  end process WaveGen_Proc;

  

end architecture multiplier1_tb;

-------------------------------------------------------------------------------

configuration multiplier1_tb_multiplier1_tb_cfg of multiplier1_tb is
  for multiplier1_tb
  end for;
end multiplier1_tb_multiplier1_tb_cfg;

-------------------------------------------------------------------------------
