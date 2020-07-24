-------------------------------------------------------------------------------
-- Title      : Testbench for design "PC"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : PC_tb.vhd
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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------------------------------------

entity PC_tb is

end entity PC_tb;

-------------------------------------------------------------------------------

architecture arch_PC of PC_tb is

  -- component ports
  signal PCIn    : std_logic_vector(31 downto 0)  := (others => '0');
  signal clk     : std_logic := '0';
  signal rst     : std_logic := '0';
  signal step    : std_logic := '1';
  signal clk_man : std_logic := '0';
  signal PCOut   : std_logic_vector(31 downto 0);

  constant clk_period : time := 50 ns;

begin  -- architecture arch_PC

  -- component instantiation
  DUT: entity work.PC
    port map (
      PCIn    => PCIn,
      clk     => clk,
      rst     => rst,
      step    => step,
      clk_man => clk_man,
      PCOut   => PCOut);

      process   --clock generation
        begin
          clk <= '0';
          wait for clk_period/2;
          clk <= '1';
          wait for clk_period/2;        
      end process ; -- 

  -- waveform generation
  WaveGen_Proc: process
  begin
    wait for clk_period;
    rst <= '1';
    clk_man <= '1';
    PCIn <= PCIn + 1;
    step <= '1';
    wait for clk_period;
    clk_man <= '0';
    step <= '0';
    PCIn <= PCIn + 1;
    wait for clk_period;
    step <= '1';
    PCIn <= PCIn + 1;
    wait for clk_period;
    step <= '0';
    PCIn <= PCIn + 1;
    wait for clk_period;
    step <= '1';
    PCIn <= PCIn + 1;
    wait for clk_period;
    step <= '0';
    PCIn <= PCIn + 1;
    clk_man <= '1';

  end process WaveGen_Proc;

end architecture arch_PC;

-------------------------------------------------------------------------------

configuration PC_tb_arch_PC_cfg of PC_tb is
  for arch_PC
  end for;
end PC_tb_arch_PC_cfg;

-------------------------------------------------------------------------------
