-------------------------------------------------------------------------------
-- Title      : Testbench for design "Reg_File"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : Reg_File_tb.vhd
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
use IEEE.STD_LOGIC_UNSIGNED.all;
-------------------------------------------------------------------------------

entity Reg_File_tb is

end entity Reg_File_tb;

-------------------------------------------------------------------------------

architecture arch_Reg_File of Reg_File_tb is

  -- component ports
  signal clk        : std_logic;
  signal writeReg   : std_logic := '0';
  signal sourceReg1 : std_logic_vector(4 downto 0) := (others => '0');
  signal sourceReg2 : std_logic_vector(4 downto 0) := (others => '0');
  signal destinyReg : std_logic_vector(4 downto 0) := (others => '0');
  signal data       : std_logic_vector(31 downto 0) := (others => '0');
  signal readData1  : std_logic_vector(31 downto 0) := (others => '0');
  signal readData2  : std_logic_vector(31 downto 0) := (others => '0');

  constant clk_period: time := 50 ns;

begin  -- architecture arch_Reg_File

  -- component instantiation
  DUT: entity work.Reg_File
    port map (
      clk        => clk,
      writeReg   => writeReg,
      sourceReg1 => sourceReg1,
      sourceReg2 => sourceReg2,
      destinyReg => destinyReg,
      data       => data,
      readData1  => readData1,
      readData2  => readData2);

  clock_generation : process
    begin
      clk <= '0';
      wait for clk_period/2;
      clk <= '1';
      wait for clk_period/2;
    end process ; -- clock_generation

  -- waveform generation
  WaveGen_Proc: process
  begin
    wait for clk_period;
    sourceReg1  <= sourceReg1 + 1;
    sourceReg2  <= sourceReg1 + 1;
    destinyReg  <= sourceReg1 + 2;
    data        <= data + 5;
    writeReg    <= not writeReg;

  end process WaveGen_Proc;

  

end architecture arch_Reg_File;

-------------------------------------------------------------------------------

configuration Reg_File_tb_arch_Reg_File_cfg of Reg_File_tb is
  for arch_Reg_File
  end for;
end Reg_File_tb_arch_Reg_File_cfg;

-------------------------------------------------------------------------------
