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


-- CU:  control unit
-- ALU: arithmetic logic unit
-- MMU: memory management unit
-- DU:  debug unit
-- CDU:  clock divider unit

library ieee;
use ieee.std_logic_1164.all;

entity CPU is
port(
	cpu_clk_in  : in  std_logic;
        cpu_rst_in  : in  std_logic;
	cpu_slow_in : in  std_logic;
	cpu_err_out : out std_logic;

	cpu_debug_data_out : out std_logic_vector(31 downto 0);
	cpu_debug_adr_out  : out std_logic_vector(5 downto 0);
	cpu_debug_pc_out   : out std_logic_vector(31 downto 0);
	cpu_debug_ir_out   : out std_logic_vector(31 downto 0);

	cpu_mmu_data_in  : in  std_logic_vector(31 downto 0);
	cpu_mmu_data_out : out std_logic_vector(31 downto 0);
	cpu_mmu_adr_out  : out std_logic_vector(31 downto 0);
	cpu_mmu_com_out  : out std_logic_vector(2 downto 0);
	cpu_mmu_work_out : out std_logic;
	cpu_mmu_ack_in   : in  std_logic
);
end entity;

architecture CPU_1 of CPU is
-- signals between CU and ALU
signal cu_alu_data_in   : std_logic_vector(31 downto 0);
signal cu_alu_data_out1 : std_logic_vector(31 downto 0);
signal cu_alu_data_out2 : std_logic_vector(31 downto 0);
signal cu_alu_adr_out   : std_logic_vector(4 downto 0);
signal cu_alu_com_out   : std_logic_vector(6 downto 0);
signal cu_alu_work_out  : std_logic;

-- signal from and to the CDU
signal clk_alu_cu : std_logic;
begin
CU: entity work.CU port map(	
	clk_in => clk_alu_cu,
	rst_in => cpu_rst_in,

	-- ALU
	alu_data_in   => cu_alu_data_in,
	alu_data_out1 => cu_alu_data_out1,
	alu_data_out2 => cu_alu_data_out2,
	alu_adr_out   => cu_alu_adr_out,
	alu_com_out   => cu_alu_com_out,
	alu_work_out  => cu_alu_work_out,

	-- MMU
	mmu_data_in  => cpu_mmu_data_in,
	mmu_data_out => cpu_mmu_data_out,
	mmu_adr_out  => cpu_mmu_adr_out,
	mmu_com_out  => cpu_mmu_com_out,
	mmu_work_out => cpu_mmu_work_out,
	mmu_ack_in   => cpu_mmu_ack_in,

	-- Error
	err_out => cpu_err_out,

	-- DU
	pc_out => cpu_debug_pc_out,
	ir_out => cpu_debug_ir_out
);

ALU: entity work.ALU port map(
	clk_in => clk_alu_cu,
	rst_in => cpu_rst_in,

	-- CU
	cu_data_in1 => cu_alu_data_out1,
	cu_data_in2 => cu_alu_data_out2,
	cu_adr_in   => cu_alu_adr_out,
	cu_com_in   => cu_alu_com_out,
	cu_work_in  => cu_alu_work_out,
	cu_data_out => cu_alu_data_in,

	-- DU
	debug_data_out => cpu_debug_data_out,
	debug_adr_out => cpu_debug_adr_out
);

CDU: entity work.ClockDivider port map(
	clk_in  => cpu_clk_in,
	rst_in  => cpu_rst_in,
	clk_out => clk_alu_cu,
	slow_in => cpu_slow_in
);
end architecture;

