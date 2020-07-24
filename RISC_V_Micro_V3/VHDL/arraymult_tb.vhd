-------------------------------------------------------------------------------
-- Title      : Testbench for design "arraymult"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : arraymult_tb.vhd
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

library ieee;
use ieee.std_logic_1164.all;

-------------------------------------------------------------------------------

entity arraymult_tb is

end entity arraymult_tb;

-------------------------------------------------------------------------------

architecture arraymult_tb of arraymult_tb is

  -- component generics
  constant N : integer := 4;

  -- component ports
  signal X : STD_LOGIC_VECTOR (N-1 downto 0) := "0000";
  signal Y : STD_LOGIC_VECTOR (N-1 downto 0) := "0000";
  signal P : STD_LOGIC_VECTOR (2*N-1 downto 0);

begin  -- architecture arraymult_tb

  -- component instantiation
  DUT: entity work.arraymult
    generic map (
      N => N)
    port map (
      X => X,
      Y => Y,
      P => P);

  -- waveform generation
  WaveGen_Proc: process
  begin
    -- insert signal assignments here
    X <= X + 1;
    Y <= Y + 1;
    wait for 50 ns;

  end process WaveGen_Proc;

  

end architecture arraymult_tb;

-------------------------------------------------------------------------------

configuration arraymult_tb_arraymult_tb_cfg of arraymult_tb is
  for arraymult_tb
  end for;
end arraymult_tb_arraymult_tb_cfg;

-------------------------------------------------------------------------------
