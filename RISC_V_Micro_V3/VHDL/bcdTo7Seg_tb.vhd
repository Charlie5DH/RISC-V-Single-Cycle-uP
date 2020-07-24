-------------------------------------------------------------------------------
-- Title      : Testbench for design "bcd_sseg_decoder"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : bcdTo7Seg_tb.vhd
-- Author     :   <Carlos@DESKTOP-7LHO1A2>
-- Company    : 
-- Created    : 2019-04-18
-- Last update: 2019-04-18
-- Platform   : 
-- Standard   : VHDL'93/02
-------------------------------------------------------------------------------
-- Description: 
-------------------------------------------------------------------------------
-- Copyright (c) 2019 
-------------------------------------------------------------------------------
-- Revisions  :
-- Date        Version  Author  Description
-- 2019-04-18  1.0      Carlos	Created
-------------------------------------------------------------------------------

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_ARITH.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-------------------------------------------------------------------------------

entity bcdTo7Seg_tb is

end entity bcdTo7Seg_tb;

-------------------------------------------------------------------------------

architecture bcd_tb of bcdTo7Seg_tb is

  -- component ports
  signal bcd_i  : STD_LOGIC_VECTOR (3 downto 0);
  signal sseg_o : STD_LOGIC_VECTOR (6 downto 0);

  -- clock
  signal Clk : std_logic := '1';

begin  -- architecture bcd_tb

  -- component instantiation
  DUT: entity work.bcdTo7Seg
    port map (
      bcd_i  => bcd_i,
      sseg_o => sseg_o);

    bcd_i <= X"0";

    bcd_i <= bcd_i + X"1" after 20 ns;
  

end architecture bcd_tb;

-------------------------------------------------------------------------------

configuration bcdTo7Seg_tb_bcd_tb_cfg of bcdTo7Seg_tb is
  for bcd_tb
  end for;
end bcdTo7Seg_tb_bcd_tb_cfg;

-------------------------------------------------------------------------------
