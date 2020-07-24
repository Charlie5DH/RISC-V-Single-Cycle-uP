-------------------------------------------------------------------------------
-- Title      : Testbench for design "ALU_RV32"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : ALU_RV32_tb.vhd
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

library IEEE;
use IEEE.std_logic_1164.all;
use IEEE.numeric_std.all;
use ieee.std_logic_unsigned.all;

-------------------------------------------------------------------------------

entity ALU_RV32_tb is

end entity ALU_RV32_tb;

-------------------------------------------------------------------------------

architecture arch_ALU_RV32 of ALU_RV32_tb is

  -- component ports
  signal operator1 : std_logic_vector(31 downto 0) := (others => '0');
  signal operator2 : std_logic_vector(31 downto 0) := (others => '0');
  signal ALUOp     : std_logic_vector(2 downto 0) := (others => '0');
  signal result    : std_logic_vector(31 downto 0);
  signal zero      : std_logic;
  signal carryOut  : std_logic;
  signal signo     : std_logic;

  constant period  : time := 50 ns;


begin  -- architecture arch_ALU_RV32

  -- component instantiation
  DUT: entity work.ALU_RV32
    port map (
      operator1 => operator1,
      operator2 => operator2,
      ALUOp     => ALUOp,
      result    => result,
      zero      => zero,
      carryOut  => carryOut,
      signo     => signo);

  -- waveform generation
  WaveGen_Proc: process
  begin    
    wait for period;
    operator1 <= X"00000004";
    operator2 <= X"00000001";
    ALUOp     <= "000";
    wait for period;
    ALUOp     <= "001";
    wait for period;
    ALUOp     <= "010";
    wait for period;
    ALUOp     <= "011";
    wait for period;
    ALUOp     <= "100";
    wait for period;
    ALUOp     <= "101";
    wait for period;
    ALUOp     <= "101";
    operator1 <= X"00000001";
    operator2 <= X"00000004";
    wait for period;
    ALUOp     <= "101";
    operator1 <= X"00000004";
    operator2 <= X"00000004";
    wait for period;
    operator1 <= X"00000004";
    operator2 <= X"00000001";
    ALUOp     <= "110";
    wait for period;
    ALUOp     <= "111";
    wait for period;

  end process WaveGen_Proc;
end architecture arch_ALU_RV32;

-------------------------------------------------------------------------------

configuration ALU_RV32_tb_arch_ALU_RV32_cfg of ALU_RV32_tb is
  for arch_ALU_RV32
  end for;
end ALU_RV32_tb_arch_ALU_RV32_cfg;

-------------------------------------------------------------------------------
