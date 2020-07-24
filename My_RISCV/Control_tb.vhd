-------------------------------------------------------------------------------
-- Title      : Testbench for design "Control"
-- Project    : 
-------------------------------------------------------------------------------
-- File       : Control_tb.vhd
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

entity Control_tb is

end entity Control_tb;

-------------------------------------------------------------------------------

architecture arch_Control of Control_tb is

  -- component ports
  signal opcode     : std_logic_vector(6 downto 0)  := (others => '0');
  signal funct3     : std_logic_vector(2 downto 0)  := (others => '0');
  signal funct7     : std_logic_vector(6 downto 0)  := (others => '0');
  signal jump       : std_logic;
  signal ToRegister : std_logic_vector(2 downto 0);
  signal MemWrite   : std_logic;
  signal Branch     : std_logic_vector(2 downto 0);
  signal ALUOp      : std_logic_vector(2 downto 0);
  signal StoreSel   : std_logic;
  signal ALUSrc     : std_logic;
  signal WriteReg   : std_logic;

  constant period   : time := 40 ns;

  -- clock
  --signal Clk : std_logic := '1';

begin  -- architecture arch_Control

  -- component instantiation
  DUT: entity work.Control
    port map (
      opcode     => opcode,
      funct3     => funct3,
      funct7     => funct7,
      jump       => jump,
      ToRegister => ToRegister,
      MemWrite   => MemWrite,
      Branch     => Branch,
      ALUOp      => ALUOp,
      StoreSel   => StoreSel,
      ALUSrc     => ALUSrc,
      WriteReg   => WriteReg);

  -- waveform generation
  WaveGen_Proc: process
  begin

    wait for period;
    opcode  <= "0110011";     --R-Type
    funct3  <= "000";         --
    funct7  <= "0000000";     --ADD
    wait for period;
    funct7  <= "0100000";     --SUB
    wait for period;
    funct7  <= "0100111";     --others
    wait for period;
    Rtype : for i in 0 to 6 loop  --AND,OR,XOR,SLL,SRL,SLT
      funct3 <= funct3 + 1;
      wait for period;
    end loop ; -- Rtype
    opcode  <= "0010011";     --I-Type
    funct3  <= "000";         --ADDI
    wait for period;
    funct3  <= "100";         --XORI
    wait for period;
    funct3  <= "110";         --ORI
    wait for period;
    funct3  <= "111";         --ANDI
    wait for period;
    opcode  <= "0000011";     --loads
    funct3  <= "000";         --LB
    wait for period;
    funct3  <= "010";         --LW
    wait for period;    
    opcode  <= "0100011";     --stores
    funct3  <= "000";         --SB
    wait for period;
    funct3  <= "010";         --SW
    wait for period;
    opcode  <= "1100011";     --Branches
    funct3  <= "000";         --BEQ
    wait for period;
    funct3  <= "001";         --BNQ
    wait for period;
    funct3  <= "100";         --BLT
    wait for period;
    funct3  <= "101";         --BGT
    wait for period;
    opcode  <= "1100111";     --JALR
    wait for period;
    opcode  <= "1101111";     --JAL  
    wait for period;
    opcode  <= "1111111";     --others   


  end process WaveGen_Proc;

  

end architecture arch_Control;

-------------------------------------------------------------------------------

configuration Control_tb_arch_Control_cfg of Control_tb is
  for arch_Control
  end for;
end Control_tb_arch_Control_cfg;

-------------------------------------------------------------------------------
