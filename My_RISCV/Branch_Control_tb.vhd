-------------------------------------------------------------------------------
-- Title      : Testbench for design "Branch_Control"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : Branch_Control_tb.vhd
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
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-------------------------------------------------------------------------------

entity Branch_Control_tb is

end entity Branch_Control_tb;

-------------------------------------------------------------------------------

architecture arch_Branch_Control of Branch_Control_tb is

  -- component ports
  signal branch : std_logic_vector(2 downto 0) := (others => '0');
  signal signo  : std_logic := '0';
  signal zero   : std_logic := '0';
  signal PCSrc  : std_logic;

  constant period : time := 50 ns;

begin  -- architecture arch_Branch_Control

  -- component instantiation
  DUT: entity work.Branch_Control
    port map (
      branch => branch,
      signo  => signo,
      zero   => zero,
      PCSrc  => PCSrc);

  -- waveform generation
  WaveGen_Proc: process
  begin
    wait for period;
    branch <= "100";
    signo <= '0';
    zero <= '1';
    wait for period;
    signo <= '0';
    zero <= '0';
    wait for period;
    branch <= "101";
    signo <= '0';
    zero <= '1';
    wait for period;
    signo <= '0';
    zero <= '0';
    wait for period;
    branch <= "110";
    signo <= '1';
    zero <= '0';
    wait for period;
    signo <= '0';
    zero <= '0';
    wait for period;
    branch <= "111";
    signo <= '1';
    zero <= '0';
    wait for period;
    signo <= '0';
    zero <= '0';


  end process WaveGen_Proc;

  

end architecture arch_Branch_Control;

-------------------------------------------------------------------------------

configuration Branch_Control_tb_arch_Branch_Control_cfg of Branch_Control_tb is
  for arch_Branch_Control
  end for;
end Branch_Control_tb_arch_Branch_Control_cfg;

-------------------------------------------------------------------------------
