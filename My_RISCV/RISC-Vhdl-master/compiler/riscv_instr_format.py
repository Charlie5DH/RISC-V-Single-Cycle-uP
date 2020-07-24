# VHDL implementation of RISC-V-ISA
# Copyright (C) 2016 Chair of Computer Architecture
# at Technical University of Munich
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program. If not, see <http://www.gnu.org/licenses/>.


def rshift(val, n): return (val % 0x100000000) >> n

def compile_bitfield(bfrom, bto, value, base):
	""" compiles value into base as bitfield to range bfrom (inc) to bto (exc)"""
	bitlen = bto-bfrom
	mask = 0xFFFFFFFF >> (32-bitlen)
	value = value & mask
	mask = mask << bfrom
	value = value << bfrom
	base = base & (~mask)
	return base | value

def le_encode(bitfield):
	return [int(bitfield & 0xFF), int(rshift(bitfield, 8) & 0xFF), \
	int(rshift(bitfield, 16) & 0xFF), int(rshift(bitfield, 24) & 0xFF)]

def compile_r(opcode, rd, funct3, rs1, rs2, funct7):
	n = compile_bitfield(0, 7, opcode, 0)
	n = compile_bitfield(7, 12, rd, n)
	n = compile_bitfield(12, 15, funct3, n)
	n = compile_bitfield(15, 20, rs1, n)
	n = compile_bitfield(20, 25, rs2, n)
	return compile_bitfield(25, 32, funct7, n)
	
def compile_i(opcode, rd, funct3, rs1, imm_11_0):
	n = compile_bitfield(0, 7, opcode, 0)
	n = compile_bitfield(7, 12, rd, n)
	n = compile_bitfield(12, 15, funct3, n)
	n = compile_bitfield(15, 20, rs1, n)
	return compile_bitfield(20, 32, imm_11_0, n)
	
def compile_s(opcode, imm_4_0, funct3, rs1, rs2, imm_11_5):
	n = compile_bitfield(0, 7, opcode, 0)
	n = compile_bitfield(7, 12, imm_4_0, n)
	n = compile_bitfield(12, 15, funct3, n)
	n = compile_bitfield(15, 20, rs1, n)
	n = compile_bitfield(20, 25, rs2, n)
	return compile_bitfield(25, 32, imm_11_5, n)
	
def compile_u(opcode, rd, imm_31_12):
	n = compile_bitfield(0, 7, opcode, 0)
	n = compile_bitfield(7, 12, rd, n)
	return compile_bitfield(12, 32, imm_31_12, n)
	
def compile_sb(opcode, imm1, funct3, rs1, rs2, imm2):
	n = compile_bitfield(0, 7, opcode, 0)
	n = compile_bitfield(7, 12, imm1, n)
	n = compile_bitfield(12, 15, funct3, n)
	n = compile_bitfield(15, 20, rs1, n)
	n = compile_bitfield(20, 25, rs2, n)
	return compile_bitfield(25, 32, imm2, n)
	
def compile_i_s(opcode, rd, funct3, rs1, imml5, immu7):
	imm = imml5 & 0x1F
	imm = imm | ((immu7 & 0x7F) << 5)
	return compile_i(opcode, rd, funct3, rs1, imm)
	
def sb_imm_split(imm):
	imm1 = rshift(imm, 11) & 1
	imm1 = imm1 | ((rshift(imm, 1) & 0xF)<<1)
	imm2 = (rshift(imm, 5) & 0x3F)
	imm2 = imm2 | ((rshift(imm, 12) & 1)<<6)
	return (int(imm1), int(imm2))
	
def jal_imm_split(imm):
	#print(imm)
	imm_o = int(imm) #original immediate value
	bit_19_to_12 = rshift(imm_o & 0xFFFFF, 12)
	imm = compile_bitfield(0, 8, bit_19_to_12, 0)
	bit_11 = rshift(imm_o & 0x800, 11)
	imm = compile_bitfield(8, 9, bit_11, imm)
	bit_10_to_1 = rshift(imm_o & 0x7FF, 1)
	imm = compile_bitfield(9, 19, bit_10_to_1, imm)
	bit_20 = rshift(imm_o & 0x100000, 20)
	#print(bit_20)
	imm = compile_bitfield(19, 20, bit_20, imm)
	#print(imm)
	return imm
