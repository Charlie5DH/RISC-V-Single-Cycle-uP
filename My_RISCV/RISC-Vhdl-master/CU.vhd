-- VHDL implementation of RISC-V-ISA
-- Copyright (C) 2016 Chair of Computer Architecture
-- at Technical University of Munich
--
-- This program is free software: you can redistribute it and/or modify
-- it under the terms of the GNU General Public License as published by
-- the Free Software Foundation, either version 3 of the License, or
-- (at your option) any later version.
--
-- This program is distributed in the hope that it will be useful,
-- but WITHOUT ANY WARRANTY; without even the implied warranty of
-- MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
-- GNU General Public License for more details.
--
-- You should have received a copy of the GNU General Public License
-- along with this program. If not, see <http://www.gnu.org/licenses/>.


library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity CU is
port(
 mmu_work_out: out std_logic;
 err_out: out std_logic;
 alu_data_in: in std_logic_vector(31 downto 0);
 alu_data_out1: out std_logic_vector(31 downto 0);
 alu_work_out: out std_logic;
 alu_data_out2: out std_logic_vector(31 downto 0);
 mmu_data_in: in std_logic_vector(31 downto 0);
 rst_in: in std_logic;
 alu_adr_out: out std_logic_vector(4 downto 0);
 alu_com_out: out std_logic_vector(6 downto 0);
 clk_in: in std_logic;
 pc_out: out std_logic_vector(31 downto 0);
 ir_out: out std_logic_vector(31 downto 0);
 mmu_ack_in: in std_logic;
 mmu_com_out: out std_logic_vector(2 downto 0);
 mmu_adr_out: out std_logic_vector(31 downto 0);
 mmu_data_out: out std_logic_vector(31 downto 0)
);
end entity;

architecture CU_1 of CU is
 signal instr_ctr: std_logic_vector(63 downto 0);
 signal cycle_ctr: std_logic_vector(63 downto 0);
 signal state: std_logic_vector(3 downto 0);
 signal err: std_logic_vector(0 downto 0);
 signal time_ctr: std_logic_vector(63 downto 0);
 signal ir: std_logic_vector(29 downto 0);
 signal pc: std_logic_vector(29 downto 0);
begin
process(rst_in,clk_in)
begin
 if rst_in='1' then
  instr_ctr <= std_logic_vector(to_unsigned(0,instr_ctr'length));
  cycle_ctr <= std_logic_vector(to_unsigned(0,cycle_ctr'length));
  state <= "1101";
  err <= std_logic_vector(to_unsigned(0,err'length));
  time_ctr <= std_logic_vector(to_unsigned(0,time_ctr'length));
  ir <= std_logic_vector(to_unsigned(0,ir'length));
  pc <= std_logic_vector(to_unsigned(1073741800,pc'length));
  mmu_work_out <= '0';
  alu_data_out1 <= std_logic_vector(to_unsigned(0,alu_data_out1'length));
  alu_work_out <= '0';
  alu_data_out2 <= std_logic_vector(to_unsigned(0,alu_data_out2'length));
  alu_adr_out <= std_logic_vector(to_unsigned(0,alu_adr_out'length));
  alu_com_out <= std_logic_vector(to_unsigned(0,alu_com_out'length));
  mmu_com_out <= std_logic_vector(to_unsigned(0,mmu_com_out'length));
  mmu_adr_out <= std_logic_vector(to_unsigned(0,mmu_adr_out'length));
  mmu_data_out <= std_logic_vector(to_unsigned(0,mmu_data_out'length));
 elsif err="1" then

 elsif rising_edge(clk_in) then
  if state >= "1101" then
   case state is
   when "1101" =>
    if pc = std_logic_vector(to_unsigned(0,pc'length)) then
     if mmu_ack_in = '1' then
      mmu_data_out <= std_logic_vector(to_unsigned(0,mmu_data_out'length));
      mmu_adr_out  <= std_logic_vector(to_unsigned(0,mmu_adr_out'length));
      mmu_com_out  <= "0" & "00";
      mmu_work_out <= '1';
      state <= "1110";
     end if;
    else
     pc <= std_logic_vector(unsigned(pc) + 1);
    end if;
   when "1110" =>
    mmu_work_out <= '0';
    state <= "1111";
   when "1111" =>
    if mmu_ack_in='1' then
     if mmu_data_in(1 downto 0)/="11" then
      err <= "1";
     end if;
     ir(29 downto 0) <= mmu_data_in(31 downto 2);
     state <= "0000";
    end if;
   when others =>
    err <= "1";
   end case;
  else
   case ir(4 downto 0) is
-- MISC-MEM
   when "00011" =>
    case state is
    when "0000" =>
mmu_data_out <= std_logic_vector(to_unsigned(0,mmu_data_out'length));
mmu_adr_out  <= std_logic_vector(unsigned(pc) + 1) & "00";
mmu_com_out  <= "0" & "00";
mmu_work_out <= '1';
if (ir(29 downto 26) /= "0000" or ir(17 downto 5) /= "0000000000000") and ir(29 downto 5) /= "0000000000000000000100000" then
 err <= "1";
end if;
alu_data_out1 <= std_logic_vector(to_unsigned(0,alu_data_out1'length));
alu_data_out2 <= std_logic_vector(to_unsigned(0,alu_data_out2'length));
alu_adr_out   <= std_logic_vector(to_unsigned(0,alu_adr_out'length));
alu_com_out   <= "0" & "0" & "00000";
alu_work_out  <= '1';
     state <= "0001";
    when "0001" =>
     alu_work_out <= '0';
     mmu_work_out <= '0';
     state <= "0010";
    when "0010" =>
     state <= "0011";
    when "0011" =>
     if mmu_ack_in='1' then
      if mmu_data_in(1 downto 0)/="11" then
       err <= "1";
      end if;
      ir(29 downto 0) <= mmu_data_in(31 downto 2);
      instr_ctr <= std_logic_vector(unsigned(instr_ctr) + 1);
      pc <= std_logic_vector(unsigned(pc) + 1);
      state <= "0000";
     end if;
    when others =>
     err <= "1";
    end case;
-- LOAD
   when "00000" =>
    case state is
    when "0000" =>
alu_data_out1 <= std_logic_vector(resize(signed(ir(29 downto 18)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out2'length));
alu_adr_out   <= std_logic_vector(to_unsigned(0,alu_adr_out'length));
alu_com_out   <= "0" & "1" & "00000";
alu_work_out  <= '1';
     state <= "0001";
    when "0001" =>
     alu_work_out <= '0';
     state <= "0010";
    when "0010" =>
     state <= "0011";
    when "0011" =>
     state <= "0100";
    when "0100" =>
mmu_data_out <= std_logic_vector(to_unsigned(0,mmu_data_out'length));
mmu_adr_out  <= alu_data_in;
mmu_com_out  <= "0" & "00";
mmu_work_out <= '1';
     state <= "0101";
    when "0101" =>
     mmu_work_out <= '0';
     state <= "0110";
    when "0110" =>
if mmu_ack_in='1' then
case ir(12 downto 10) is
when "000" =>
alu_data_out1 <= std_logic_vector(resize(signed(mmu_data_in(7 downto 0)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(to_unsigned(0,alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "0" & "0" & "00000";
alu_work_out  <= '1';
when "001" =>
alu_data_out1 <= std_logic_vector(resize(signed(mmu_data_in(15 downto 0)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(to_unsigned(0,alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "0" & "0" & "00000";
alu_work_out  <= '1';
when "010" =>
alu_data_out1 <= mmu_data_in;
alu_data_out2 <= std_logic_vector(to_unsigned(0,alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "0" & "0" & "00000";
alu_work_out  <= '1';
when "100" =>
alu_data_out1 <= std_logic_vector(resize(unsigned(mmu_data_in(7 downto 0)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(to_unsigned(0,alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "0" & "0" & "00000";
alu_work_out  <= '1';
when "101" =>
alu_data_out1 <= std_logic_vector(resize(unsigned(mmu_data_in(15 downto 0)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(to_unsigned(0,alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "0" & "0" & "00000";
alu_work_out  <= '1';
when others =>
 err <= "1";
end case;
mmu_data_out <= std_logic_vector(to_unsigned(0,mmu_data_out'length));
mmu_adr_out  <= std_logic_vector(unsigned(pc) + 1) & "00";
mmu_com_out  <= "0" & "00";
mmu_work_out <= '1';
     state <= "0111";
end if;
    when "0111" =>
     alu_work_out <= '0';
     mmu_work_out <= '0';
     state <= "1000";
    when "1000" =>
     state <= "1001";
    when "1001" =>
     if mmu_ack_in='1' then
      if mmu_data_in(1 downto 0)/="11" then
       err <= "1";
      end if;
      ir(29 downto 0) <= mmu_data_in(31 downto 2);
      instr_ctr <= std_logic_vector(unsigned(instr_ctr) + 1);
      pc <= std_logic_vector(unsigned(pc) + 1);
      state <= "0000";
     end if;
    when others =>
     err <= "1";
    end case;
-- SYSTEM
   when "11100" =>
    case state is
    when "0000" =>
mmu_data_out <= std_logic_vector(to_unsigned(0,mmu_data_out'length));
mmu_adr_out  <= std_logic_vector(unsigned(pc) + 1) & "00";
mmu_com_out  <= "0" & "00";
mmu_work_out <= '1';
case ir(29 downto 10) is
when "11000000000000000010" =>
alu_data_out1 <= cycle_ctr(31 downto 0);
alu_data_out2 <= std_logic_vector(to_unsigned(0,alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "0" & "0" & "00000";
alu_work_out  <= '1';
when "11001000000000000010" =>
alu_data_out1 <= cycle_ctr(63 downto 32);
alu_data_out2 <= std_logic_vector(to_unsigned(0,alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "0" & "0" & "00000";
alu_work_out  <= '1';
when "11000000000100000010" =>
alu_data_out1 <= time_ctr(31 downto 0);
alu_data_out2 <= std_logic_vector(to_unsigned(0,alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "0" & "0" & "00000";
alu_work_out  <= '1';
when "11001000000100000010" =>
alu_data_out1 <= time_ctr(63 downto 32);
alu_data_out2 <= std_logic_vector(to_unsigned(0,alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "0" & "0" & "00000";
alu_work_out  <= '1';
when "11000000001000000010" =>
alu_data_out1 <= instr_ctr(31 downto 0);
alu_data_out2 <= std_logic_vector(to_unsigned(0,alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "0" & "0" & "00000";
alu_work_out  <= '1';
when "11001000001000000010" =>
alu_data_out1 <= instr_ctr(63 downto 32);
alu_data_out2 <= std_logic_vector(to_unsigned(0,alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "0" & "0" & "00000";
alu_work_out  <= '1';
when "00000000000000000000" =>
alu_data_out1 <= std_logic_vector(to_unsigned(0,alu_data_out1'length));
alu_data_out2 <= std_logic_vector(to_unsigned(0,alu_data_out2'length));
alu_adr_out   <= std_logic_vector(to_unsigned(0,alu_adr_out'length));
alu_com_out   <= "0" & "0" & "00000";
alu_work_out  <= '1';
when "00000000000000000001" =>
alu_data_out1 <= std_logic_vector(to_unsigned(0,alu_data_out1'length));
alu_data_out2 <= std_logic_vector(to_unsigned(0,alu_data_out2'length));
alu_adr_out   <= std_logic_vector(to_unsigned(0,alu_adr_out'length));
alu_com_out   <= "0" & "0" & "00000";
alu_work_out  <= '1';
when others =>
 err <= "1";
end case;
     state <= "0001";
    when "0001" =>
     alu_work_out <= '0';
     mmu_work_out <= '0';
     state <= "0010";
    when "0010" =>
     state <= "0011";
    when "0011" =>
     if mmu_ack_in='1' then
      if mmu_data_in(1 downto 0)/="11" then
       err <= "1";
      end if;
      ir(29 downto 0) <= mmu_data_in(31 downto 2);
      instr_ctr <= std_logic_vector(unsigned(instr_ctr) + 1);
      pc <= std_logic_vector(unsigned(pc) + 1);
      state <= "0000";
     end if;
    when others =>
     err <= "1";
    end case;
-- STORE
   when "01000" =>
    case state is
    when "0000" =>
alu_data_out1 <= std_logic_vector(resize(signed(ir(29 downto 23) & ir(9 downto 5)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out2'length));
alu_adr_out   <= std_logic_vector(to_unsigned(0,alu_adr_out'length));
alu_com_out   <= "0" & "1" & "00000";
alu_work_out  <= '1';
     state <= "0001";
    when "0001" =>
     alu_work_out <= '0';
     state <= "0010";
    when "0010" =>
     state <= "0011";
    when "0011" =>
     state <= "0100";
    when "0100" =>
mmu_adr_out  <= alu_data_in;
alu_data_out1 <= std_logic_vector(to_unsigned(0,alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(unsigned(ir(22 downto 18)),alu_data_out2'length));
alu_adr_out   <= std_logic_vector(to_unsigned(0,alu_adr_out'length));
alu_com_out   <= "0" & "1" & "00000";
alu_work_out  <= '1';
     state <= "0101";
    when "0101" =>
     alu_work_out <= '0';
     state <= "0110";
    when "0110" =>
     state <= "0111";
    when "0111" =>
     state <= "1000";
    when "1000" =>
case ir(12 downto 10) is
when "000" =>
mmu_data_out <= std_logic_vector(resize(unsigned(alu_data_in(7 downto 0)),mmu_data_out'length)); mmu_com_out(2 downto 0) <= "100";
when "001" =>
mmu_data_out <= std_logic_vector(resize(unsigned(alu_data_in(15 downto 0)),mmu_data_out'length)); mmu_com_out(2 downto 0) <= "101";
when "010" =>
mmu_data_out <= alu_data_in; mmu_com_out(2 downto 0) <= "111";
when others =>
 err <= "1";
end case;
mmu_work_out <= '1';
     state <= "1001";
    when "1001" =>
mmu_work_out <= '0';
     state <= "1010";
    when "1010" =>
if mmu_ack_in='1' then
mmu_data_out <= std_logic_vector(to_unsigned(0,mmu_data_out'length));
mmu_adr_out  <= std_logic_vector(unsigned(pc) + 1) & "00";
mmu_com_out  <= "0" & "00";
mmu_work_out <= '1';
     state <= "1011";
end if;
    when "1011" =>
     mmu_work_out <= '0';
     state <= "1100";
    when "1100" =>
     if mmu_ack_in='1' then
      if mmu_data_in(1 downto 0)/="11" then
       err <= "1";
      end if;
      ir(29 downto 0) <= mmu_data_in(31 downto 2);
      instr_ctr <= std_logic_vector(unsigned(instr_ctr) + 1);
      pc <= std_logic_vector(unsigned(pc) + 1);
      state <= "0000";
     end if;
    when others =>
     err <= "1";
    end case;
-- JALR
   when "11001" =>
    case state is
    when "0000" =>
if ir(12 downto 10)/="000" then
 err <= "1";
end if;
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(signed(ir(29 downto 18)),alu_data_out2'length));
alu_adr_out   <= std_logic_vector(to_unsigned(0,alu_adr_out'length));
alu_com_out   <= "1" & "0" & "00000";
alu_work_out  <= '1';
     state <= "0001";
    when "0001" =>
     alu_work_out <= '0';
     state <= "0010";
    when "0010" =>
     state <= "0011";
    when "0011" =>
     state <= "0100";
    when "0100" =>
alu_data_out1 <= std_logic_vector(unsigned(pc) + 1) & "00";
alu_data_out2 <= std_logic_vector(to_unsigned(0,alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "0" & "0" & "00000";
alu_work_out  <= '1';
if alu_data_in(1 downto 1)/="0" then
 err <= "1";
end if;
pc <= alu_data_in(31 downto 2);
mmu_data_out <= std_logic_vector(to_unsigned(0,mmu_data_out'length));
mmu_adr_out  <= alu_data_in(31 downto 1) & "0";
mmu_com_out  <= "0" & "00";
mmu_work_out <= '1';
     state <= "0101";
    when "0101" =>
     alu_work_out <= '0';
     mmu_work_out <= '0';
     state <= "0110";
    when "0110" =>
     state <= "0111";
    when "0111" =>
     if mmu_ack_in='1' then
      if mmu_data_in(1 downto 0)/="11" then
       err <= "1";
      end if;
      ir(29 downto 0) <= mmu_data_in(31 downto 2);
      instr_ctr <= std_logic_vector(unsigned(instr_ctr) + 1);
      state <= "0000";
     end if;
    when others =>
     err <= "1";
    end case;
-- BRANCH
   when "11000" =>
    case state is
    when "0000" =>
case ir(12 downto 11) is
when "00" =>
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(unsigned(ir(22 downto 18)),alu_data_out2'length));
alu_adr_out   <= std_logic_vector(to_unsigned(0,alu_adr_out'length));
alu_com_out   <= "1" & "1" & "00001";
alu_work_out  <= '1';
when "10" =>
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(unsigned(ir(22 downto 18)),alu_data_out2'length));
alu_adr_out   <= std_logic_vector(to_unsigned(0,alu_adr_out'length));
alu_com_out   <= "1" & "1" & "01000";
alu_work_out  <= '1';
when "11" =>
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(unsigned(ir(22 downto 18)),alu_data_out2'length));
alu_adr_out   <= std_logic_vector(to_unsigned(0,alu_adr_out'length));
alu_com_out   <= "1" & "1" & "01001";
alu_work_out  <= '1';
when others =>
 err <= "1";
end case;
     state <= "0001";
    when "0001" =>
     alu_work_out <= '0';
     state <= "0010";
    when "0010" =>
     state <= "0011";
    when "0011" =>
     state <= "0100";
    when "0100" =>
case ir(12 downto 12) is
when "0" =>
case ir(10 downto 10) is
when "0" =>
if unsigned(alu_data_in)=0 then
alu_data_out1 <= pc & "00";
alu_data_out2 <= std_logic_vector(resize(signed(ir(29 downto 29) & ir(5 downto 5) & ir(28 downto 23) & ir(9 downto 6) & "0"),alu_data_out2'length));
alu_adr_out   <= std_logic_vector(to_unsigned(0,alu_adr_out'length));
alu_com_out   <= "0" & "0" & "00000";
alu_work_out  <= '1';
else
alu_data_out1 <= std_logic_vector(unsigned(pc) + 1) & "00";
alu_data_out2 <= std_logic_vector(to_unsigned(0,alu_data_out2'length));
alu_adr_out   <= std_logic_vector(to_unsigned(0,alu_adr_out'length));
alu_com_out   <= "0" & "0" & "00000";
alu_work_out  <= '1';
end if;
when "1" =>
if unsigned(alu_data_in)/=0 then
alu_data_out1 <= pc & "00";
alu_data_out2 <= std_logic_vector(resize(signed(ir(29 downto 29) & ir(5 downto 5) & ir(28 downto 23) & ir(9 downto 6) & "0"),alu_data_out2'length));
alu_adr_out   <= std_logic_vector(to_unsigned(0,alu_adr_out'length));
alu_com_out   <= "0" & "0" & "00000";
alu_work_out  <= '1';
else
alu_data_out1 <= std_logic_vector(unsigned(pc) + 1) & "00";
alu_data_out2 <= std_logic_vector(to_unsigned(0,alu_data_out2'length));
alu_adr_out   <= std_logic_vector(to_unsigned(0,alu_adr_out'length));
alu_com_out   <= "0" & "0" & "00000";
alu_work_out  <= '1';
end if;
when others =>
 err <= "1";
end case;
when "1" =>
case ir(10 downto 10) is
when "0" =>
if unsigned(alu_data_in)/=0 then
alu_data_out1 <= pc & "00";
alu_data_out2 <= std_logic_vector(resize(signed(ir(29 downto 29) & ir(5 downto 5) & ir(28 downto 23) & ir(9 downto 6) & "0"),alu_data_out2'length));
alu_adr_out   <= std_logic_vector(to_unsigned(0,alu_adr_out'length));
alu_com_out   <= "0" & "0" & "00000";
alu_work_out  <= '1';
else
alu_data_out1 <= std_logic_vector(unsigned(pc) + 1) & "00";
alu_data_out2 <= std_logic_vector(to_unsigned(0,alu_data_out2'length));
alu_adr_out   <= std_logic_vector(to_unsigned(0,alu_adr_out'length));
alu_com_out   <= "0" & "0" & "00000";
alu_work_out  <= '1';
end if;
when "1" =>
if unsigned(alu_data_in)=0 then
alu_data_out1 <= pc & "00";
alu_data_out2 <= std_logic_vector(resize(signed(ir(29 downto 29) & ir(5 downto 5) & ir(28 downto 23) & ir(9 downto 6) & "0"),alu_data_out2'length));
alu_adr_out   <= std_logic_vector(to_unsigned(0,alu_adr_out'length));
alu_com_out   <= "0" & "0" & "00000";
alu_work_out  <= '1';
else
alu_data_out1 <= std_logic_vector(unsigned(pc) + 1) & "00";
alu_data_out2 <= std_logic_vector(to_unsigned(0,alu_data_out2'length));
alu_adr_out   <= std_logic_vector(to_unsigned(0,alu_adr_out'length));
alu_com_out   <= "0" & "0" & "00000";
alu_work_out  <= '1';
end if;
when others =>
 err <= "1";
end case;
when others =>
 err <= "1";
end case;
     state <= "0101";
    when "0101" =>
     alu_work_out <= '0';
     state <= "0110";
    when "0110" =>
     state <= "0111";
    when "0111" =>
     state <= "1000";
    when "1000" =>
mmu_data_out <= std_logic_vector(to_unsigned(0,mmu_data_out'length));
mmu_adr_out  <= alu_data_in;
mmu_com_out  <= "0" & "00";
mmu_work_out <= '1';
if alu_data_in(1 downto 0)/="00" then
 err <= "1";
end if;
pc <= alu_data_in(31 downto 2);
     state <= "1001";
    when "1001" =>
     mmu_work_out <= '0';
     state <= "1010";
    when "1010" =>
     state <= "1011";
    when "1011" =>
     if mmu_ack_in='1' then
      if mmu_data_in(1 downto 0)/="11" then
       err <= "1";
      end if;
      ir(29 downto 0) <= mmu_data_in(31 downto 2);
      instr_ctr <= std_logic_vector(unsigned(instr_ctr) + 1);
      state <= "0000";
     end if;
    when others =>
     err <= "1";
    end case;
-- AUPIC
   when "00101" =>
    case state is
    when "0000" =>
mmu_data_out <= std_logic_vector(to_unsigned(0,mmu_data_out'length));
mmu_adr_out  <= std_logic_vector(unsigned(pc) + 1) & "00";
mmu_com_out  <= "0" & "00";
mmu_work_out <= '1';
alu_data_out1 <= ir(29 downto 10) & "000000000000";
alu_data_out2 <= pc & "00";
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "0" & "0" & "00000";
alu_work_out  <= '1';
     state <= "0001";
    when "0001" =>
     alu_work_out <= '0';
     mmu_work_out <= '0';
     state <= "0010";
    when "0010" =>
     state <= "0011";
    when "0011" =>
     if mmu_ack_in='1' then
      if mmu_data_in(1 downto 0)/="11" then
       err <= "1";
      end if;
      ir(29 downto 0) <= mmu_data_in(31 downto 2);
      instr_ctr <= std_logic_vector(unsigned(instr_ctr) + 1);
      pc <= std_logic_vector(unsigned(pc) + 1);
      state <= "0000";
     end if;
    when others =>
     err <= "1";
    end case;
-- LUI
   when "01101" =>
    case state is
    when "0000" =>
mmu_data_out <= std_logic_vector(to_unsigned(0,mmu_data_out'length));
mmu_adr_out  <= std_logic_vector(unsigned(pc) + 1) & "00";
mmu_com_out  <= "0" & "00";
mmu_work_out <= '1';
alu_data_out1 <= ir(29 downto 10) & "000000000000";
alu_data_out2 <= std_logic_vector(to_unsigned(0,alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "0" & "0" & "00000";
alu_work_out  <= '1';
     state <= "0001";
    when "0001" =>
     alu_work_out <= '0';
     mmu_work_out <= '0';
     state <= "0010";
    when "0010" =>
     state <= "0011";
    when "0011" =>
     if mmu_ack_in='1' then
      if mmu_data_in(1 downto 0)/="11" then
       err <= "1";
      end if;
      ir(29 downto 0) <= mmu_data_in(31 downto 2);
      instr_ctr <= std_logic_vector(unsigned(instr_ctr) + 1);
      pc <= std_logic_vector(unsigned(pc) + 1);
      state <= "0000";
     end if;
    when others =>
     err <= "1";
    end case;
-- OP
   when "01100" =>
    case state is
    when "0000" =>
mmu_data_out <= std_logic_vector(to_unsigned(0,mmu_data_out'length));
mmu_adr_out  <= std_logic_vector(unsigned(pc) + 1) & "00";
mmu_com_out  <= "0" & "00";
mmu_work_out <= '1';
if ir(29 downto 23)="0000001" then
case ir(12 downto 10) is
when "000" =>
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(unsigned(ir(22 downto 18)),alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "1" & "1" & "01010";
alu_work_out  <= '1';
when "001" =>
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(unsigned(ir(22 downto 18)),alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "1" & "1" & "01011";
alu_work_out  <= '1';
when "010" =>
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(unsigned(ir(22 downto 18)),alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "1" & "1" & "01100";
alu_work_out  <= '1';
when "011" =>
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(unsigned(ir(22 downto 18)),alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "1" & "1" & "01101";
alu_work_out  <= '1';
when "100" =>
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(unsigned(ir(22 downto 18)),alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "1" & "1" & "01110";
alu_work_out  <= '1';
when "101" =>
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(unsigned(ir(22 downto 18)),alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "1" & "1" & "01111";
alu_work_out  <= '1';
when "110" =>
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(unsigned(ir(22 downto 18)),alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "1" & "1" & "10000";
alu_work_out  <= '1';
when "111" =>
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(unsigned(ir(22 downto 18)),alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "1" & "1" & "10001";
alu_work_out  <= '1';
when others =>
 err <= "1";
end case;
else
case ir(12 downto 10) is
when "000" =>
if ir(29 downto 23)="0000000" then
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(unsigned(ir(22 downto 18)),alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "1" & "1" & "00000";
alu_work_out  <= '1';
else
if ir(29 downto 23)="0100000" then
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(unsigned(ir(22 downto 18)),alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "1" & "1" & "00001";
alu_work_out  <= '1';
else
err <= "1";
end if;
end if;
when "010" =>
if ir(29 downto 23)/="0000000" then
 err <= "1";
end if;
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(unsigned(ir(22 downto 18)),alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "1" & "1" & "01000";
alu_work_out  <= '1';
when "011" =>
if ir(29 downto 23)/="0000000" then
 err <= "1";
end if;
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(unsigned(ir(22 downto 18)),alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "1" & "1" & "01001";
alu_work_out  <= '1';
when "100" =>
if ir(29 downto 23)/="0000000" then
 err <= "1";
end if;
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(unsigned(ir(22 downto 18)),alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "1" & "1" & "00100";
alu_work_out  <= '1';
when "110" =>
if ir(29 downto 23)/="0000000" then
 err <= "1";
end if;
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(unsigned(ir(22 downto 18)),alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "1" & "1" & "00011";
alu_work_out  <= '1';
when "111" =>
if ir(29 downto 23)/="0000000" then
 err <= "1";
end if;
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(unsigned(ir(22 downto 18)),alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "1" & "1" & "00010";
alu_work_out  <= '1';
when "001" =>
if ir(29 downto 23)/="0000000" then
 err <= "1";
end if;
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(unsigned(ir(22 downto 18)),alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "1" & "1" & "00101";
alu_work_out  <= '1';
when "101" =>
if ir(29 downto 23)="0000000" then
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(unsigned(ir(22 downto 18)),alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "1" & "1" & "00110";
alu_work_out  <= '1';
else
if ir(29 downto 23)="0100000" then
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(unsigned(ir(22 downto 18)),alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "1" & "1" & "00111";
alu_work_out  <= '1';
else
err <= "1";
end if;
end if;
when others =>
 err <= "1";
end case;
end if;
     state <= "0001";
    when "0001" =>
     alu_work_out <= '0';
     mmu_work_out <= '0';
     state <= "0010";
    when "0010" =>
if ir(29 downto 23)/="0000001" or ir(12 downto 12)/="1" or alu_data_in=std_logic_vector(to_unsigned(0,alu_data_in'length)) then
     state <= "0011";
end if;
    when "0011" =>
     if mmu_ack_in='1' then
      if mmu_data_in(1 downto 0)/="11" then
       err <= "1";
      end if;
      ir(29 downto 0) <= mmu_data_in(31 downto 2);
      instr_ctr <= std_logic_vector(unsigned(instr_ctr) + 1);
      pc <= std_logic_vector(unsigned(pc) + 1);
      state <= "0000";
     end if;
    when others =>
     err <= "1";
    end case;
-- OP-IMM
   when "00100" =>
    case state is
    when "0000" =>
mmu_data_out <= std_logic_vector(to_unsigned(0,mmu_data_out'length));
mmu_adr_out  <= std_logic_vector(unsigned(pc) + 1) & "00";
mmu_com_out  <= "0" & "00";
mmu_work_out <= '1';
case ir(12 downto 10) is
when "000" =>
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(signed(ir(29 downto 18)),alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "1" & "0" & "00000";
alu_work_out  <= '1';
when "010" =>
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(signed(ir(29 downto 18)),alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "1" & "0" & "01000";
alu_work_out  <= '1';
when "011" =>
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(signed(ir(29 downto 18)),alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "1" & "0" & "01001";
alu_work_out  <= '1';
when "100" =>
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(signed(ir(29 downto 18)),alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "1" & "0" & "00100";
alu_work_out  <= '1';
when "110" =>
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(signed(ir(29 downto 18)),alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "1" & "0" & "00011";
alu_work_out  <= '1';
when "111" =>
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(signed(ir(29 downto 18)),alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "1" & "0" & "00010";
alu_work_out  <= '1';
when "001" =>
if ir(29 downto 23)/="0000000" then
 err <= "1";
end if;
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(signed(ir(22 downto 18)),alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "1" & "0" & "00101";
alu_work_out  <= '1';
when "101" =>
if ir(29 downto 23)="0000000" then
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(signed(ir(22 downto 18)),alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "1" & "0" & "00110";
alu_work_out  <= '1';
else
if ir(29 downto 23)="0100000" then
alu_data_out1 <= std_logic_vector(resize(unsigned(ir(17 downto 13)),alu_data_out1'length));
alu_data_out2 <= std_logic_vector(resize(signed(ir(22 downto 18)),alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "1" & "0" & "00111";
alu_work_out  <= '1';
else
err <= "1";
end if;
end if;
when others =>
 err <= "1";
end case;
     state <= "0001";
    when "0001" =>
     alu_work_out <= '0';
     mmu_work_out <= '0';
     state <= "0010";
    when "0010" =>
     state <= "0011";
    when "0011" =>
     if mmu_ack_in='1' then
      if mmu_data_in(1 downto 0)/="11" then
       err <= "1";
      end if;
      ir(29 downto 0) <= mmu_data_in(31 downto 2);
      instr_ctr <= std_logic_vector(unsigned(instr_ctr) + 1);
      pc <= std_logic_vector(unsigned(pc) + 1);
      state <= "0000";
     end if;
    when others =>
     err <= "1";
    end case;
-- JAL
   when "11011" =>
    case state is
    when "0000" =>
alu_data_out1 <= std_logic_vector(resize(signed(ir(29 downto 29) & ir(17 downto 10) & ir(18 downto 18) & ir(28 downto 19) & "0"),alu_data_out1'length));
alu_data_out2 <= pc & "00";
alu_adr_out   <= std_logic_vector(to_unsigned(0,alu_adr_out'length));
alu_com_out   <= "0" & "0" & "00000";
alu_work_out  <= '1';
     state <= "0001";
    when "0001" =>
     alu_work_out <= '0';
     state <= "0010";
    when "0010" =>
     state <= "0011";
    when "0011" =>
     state <= "0100";
    when "0100" =>
alu_data_out1 <= std_logic_vector(unsigned(pc) + 1) & "00";
alu_data_out2 <= std_logic_vector(to_unsigned(0,alu_data_out2'length));
alu_adr_out   <= ir(9 downto 5);
alu_com_out   <= "0" & "0" & "00000";
alu_work_out  <= '1';
if alu_data_in(1 downto 0)/="00" then
 err <= "1";
end if;
pc <= alu_data_in(31 downto 2);
mmu_data_out <= std_logic_vector(to_unsigned(0,mmu_data_out'length));
mmu_adr_out  <= alu_data_in;
mmu_com_out  <= "0" & "00";
mmu_work_out <= '1';
     state <= "0101";
    when "0101" =>
     alu_work_out <= '0';
     mmu_work_out <= '0';
     state <= "0110";
    when "0110" =>
     state <= "0111";
    when "0111" =>
     if mmu_ack_in='1' then
      if mmu_data_in(1 downto 0)/="11" then
       err <= "1";
      end if;
      ir(29 downto 0) <= mmu_data_in(31 downto 2);
      instr_ctr <= std_logic_vector(unsigned(instr_ctr) + 1);
      state <= "0000";
     end if;
    when others =>
     err <= "1";
    end case;
   when others =>
    err <= "1";
   end case;
   cycle_ctr <= std_logic_vector(unsigned(cycle_ctr) + 1);
   time_ctr <= std_logic_vector(unsigned(time_ctr) + 1);
  end if;
 end if;
end process;
err_out <= err(0);
pc_out <= pc(29 downto 0) & "00";
ir_out <= ir(29 downto 0) & "11";
end architecture;
