-------------------------------------------------------------------------------
-- Title      : Testbench for design "Data_Mem"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : Data_Mem_tb.vhd
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

entity Data_Mem_tb is

end entity Data_Mem_tb;

-------------------------------------------------------------------------------

architecture arch_Data_Mem of Data_Mem_tb is

  -- component ports
  signal clk     : std_logic := '0';
  signal writeEn : std_logic := '0';
  signal Address : std_logic_vector(3 downto 0) := (others => '0');
  signal dataIn  : std_logic_vector(31 downto 0) := (others => '0');
  signal dataOut : std_logic_vector(31 downto 0) := (others => '0');

  constant clk_period : time := 40 ns;

  -- clock
  --signal Clk : std_logic := '1';

begin  -- architecture arch_Data_Mem

  -- component instantiation
  DUT: entity work.Data_Mem
    port map (
      clk     => clk,
      writeEn => writeEn,
      Address => Address,
      dataIn  => dataIn,
      dataOut => dataOut);

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
    dataIn <= dataIn + 2;
    Address <= Address + 1;
    writeEn <= not writeEn;
    wait for clk_period;   

  end process WaveGen_Proc;

  

end architecture arch_Data_Mem;

-------------------------------------------------------------------------------

configuration Data_Mem_tb_arch_Data_Mem_cfg of Data_Mem_tb is
  for arch_Data_Mem
  end for;
end Data_Mem_tb_arch_Data_Mem_cfg;

-------------------------------------------------------------------------------
