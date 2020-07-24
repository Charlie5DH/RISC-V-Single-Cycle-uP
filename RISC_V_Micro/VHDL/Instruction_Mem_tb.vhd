-------------------------------------------------------------------------------
-- Title      : Testbench for design "Instruction_Mem"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : Instruction_Mem_tb.vhd
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

entity Instruction_Mem_tb is

end entity Instruction_Mem_tb;

-------------------------------------------------------------------------------

architecture arch_Instruction_Mem of Instruction_Mem_tb is

  -- component ports
  signal Address     : std_logic_vector(7 downto 0) := (others => '0');
  signal instruction : std_logic_vector(31 downto 0);

  constant period : time := 50 ns;

begin  -- architecture arch_Instruction_Mem

  -- component instantiation
  DUT: entity work.Instruction_Mem
    port map (
      Address     => Address,
      instruction => instruction);

  -- waveform generation
  WaveGen_Proc: process
  begin
    wait for period;
    Address   <= Address + 1;

  end process WaveGen_Proc;

end architecture arch_Instruction_Mem;

-------------------------------------------------------------------------------

configuration Instruction_Mem_tb_arch_Instruction_Mem_cfg of Instruction_Mem_tb is
  for arch_Instruction_Mem
  end for;
end Instruction_Mem_tb_arch_Instruction_Mem_cfg;

-------------------------------------------------------------------------------
