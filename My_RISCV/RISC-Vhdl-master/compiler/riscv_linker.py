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


import riscv_instr_format as iformat
import re

def token_to_reg(regstr):
	m = re.search('x([0-9]+),*', regstr)
	return int(m.groups()[0])



def pc_relative_symbol(symbol, off, symbols):
	try:
		return int(symbol, 0)
	except:
		if symbol in symbols:
			return symbols[symbol]-off #+4 ???
		else:
			print(symbol+" not in symbol table")
			raise

def token_to_int(token, base, symbols, off):
	try:
		return int(token, base)
	except:
		try: return symbols[token]
		except: 
			print("Token "+token+" could neither be converted to int nor was found in symbol table")
			raise

def link_dw(line, tokens, symbols, off):
	#DW imm32
	if len(tokens) == 2:
		try:
			imm = token_to_int(tokens[1], 0, symbols, off)
			return iformat.le_encode(imm)
		except:
			print("Unable to parse line "+str(line)+" : "+str(tokens))

	else:
		print("Missing tokens in line "+str(line)+" : "+str(tokens))
		raise

def link_lui(line, tokens, symbols, off):
	#LUI rd, imm
	if(len(tokens) == 3):
		try:
			rd = token_to_reg(tokens[1])
			imm = token_to_int(tokens[2], 0, symbols, off)
			return iformat.le_encode(iformat.compile_u(0x37, rd, imm))
		except:
			print("Unable to parse line "+str(line)+" : "+str(tokens))
	else:
		print("Missing tokens in line "+str(line)+" : "+str(tokens))
		raise
		
def link_auipc(line, tokens, symbols, off):
	#AUIPC rd, label
	if(len(tokens) == 3):
		try:
			rd = token_to_reg(tokens[1])
			imm = pc_relative_symbol(tokens[2], off, symbols)
			return iformat.le_encode(iformat.compile_u(0x17, rd, imm))
		except:
			print("Unable to parse line "+str(line)+" : "+str(tokens))
	else:
		print("Missing tokens in line "+str(line)+" : "+str(tokens))
		raise
		
def link_jal(line, tokens, symbols, off):
	#JAL rd, label
	if(len(tokens) == 3):
		try:
			rd = token_to_reg(tokens[1])
			imm = int(pc_relative_symbol(tokens[2], off, symbols) / 1)
			return iformat.le_encode(iformat.compile_u(0x6F, rd, iformat.jal_imm_split(imm)))
		except:
			print("Unable to parse line "+str(line)+" : "+str(tokens))
	else:
		print("Missing tokens in line "+str(line)+" : "+str(tokens))
		raise		
	
def link_jalr(line, tokens, symbols, off):
	#JALR rd, rs, label
	if(len(tokens) == 4):
		try:
			rd = token_to_reg(tokens[1])
			rs = token_to_reg(tokens[2])
			imm = pc_relative_symbol(tokens[3], off, symbols)
			return iformat.le_encode(iformat.compile_i(0x67, rd, 0, rs, imm))
		except:
			print("Unable to parse line "+str(line)+" : "+str(tokens))
	else:
		print("Missing tokens in line "+str(line)+" : "+str(tokens))
		raise	
		

def link_cbranch(line, tokens, symbols, off, funct3):
	#BXX rd, rs, label
	if(len(tokens) == 4):
		try:
			rs1 = token_to_reg(tokens[1])
			rs2 = token_to_reg(tokens[2])
			imm = int(pc_relative_symbol(tokens[3], off, symbols) / 1)
			imms = iformat.sb_imm_split(imm)
			return iformat.le_encode(iformat.compile_sb(0x63, imms[0], funct3, rs1, rs2, imms[1]))
		except:
			print("Unable to parse line "+str(line)+" : "+str(tokens))
	else:
		print("Missing tokens in line "+str(line)+" : "+str(tokens))
		raise
		
def link_beq(line, tokens, symbols, off):
	#BEQ rd, rs, label
	return link_cbranch(line, tokens, symbols, off, 0)
	
def link_bne(line, tokens, symbols, off):
	#BNE rd, rs, label
	return link_cbranch(line, tokens, symbols, off, 1)
	
def link_blt(line, tokens, symbols, off):
	#BLT rd, rs, label
	return link_cbranch(line, tokens, symbols, off, 4)
	
def link_bge(line, tokens, symbols, off):
	#BGE rd, rs, label
	return link_cbranch(line, tokens, symbols, off, 5)
	
def link_bltu(line, tokens, symbols, off):
	#BLTU rd, rs, label
	return link_cbranch(line, tokens, symbols, off, 6)
	
def link_bgeu(line, tokens, symbols, off):
	#BNE rd, rs, label
	return link_cbranch(line, tokens, symbols, off, 7)
	
def link_lx(line, tokens, symbols, off, funct3):
	#lx rd, rs, imm
	if(len(tokens) == 4):
		try:
			rd = token_to_reg(tokens[1])
			rs = token_to_reg(tokens[2])
			imm = token_to_int(tokens[3], 0, symbols, off)
			return iformat.le_encode(iformat.compile_i(0x3, rd, funct3, rs, imm))
		except:
			print("Unable to parse line "+str(line)+" : "+str(tokens))
	else:
		print("Missing tokens in line "+str(line)+" : "+str(tokens))
		raise
	
def link_lb(line, tokens, symbols, off):
	#LB rd, rs, imm
	return link_lx(line, tokens, symbols, off, 0)	
	
def link_lh(line, tokens, symbols, off):
	#LH rd, rs, imm
	return link_lx(line, tokens, symbols, off, 1)	
	
def link_lw(line, tokens, symbols, off):
	#LW rd, rs, imm
	return link_lx(line, tokens, symbols, off, 2)

def link_lbu(line, tokens, symbols, off):
	#LBU rd, rs, imm
	return link_lx(line, tokens, symbols, off, 4)

def link_lhu(line, tokens, symbols, off):
	#LHU rd, rs, imm
	return link_lx(line, tokens, symbols, off, 5)

def link_sx(line, tokens, symbols, off, funct3):
	#SX rs1, rs2, imm  --writes rs2 to [rs1]
	if(len(tokens) == 4):
		try:
			rs1 = token_to_reg(tokens[1])
			rs2 = token_to_reg(tokens[2])
			imm = token_to_int(tokens[3], 0, symbols, off)
			imm1 = int(imm & 0x1F)
			imm2 = int(iformat.rshift(imm, 5) & 0x7F)
			return iformat.le_encode(iformat.compile_s(0x23, imm1, funct3, rs1, rs2, imm2))
		except:
			print("Unable to parse line "+str(line)+" : "+str(tokens))
	else:
		print("Missing tokens in line "+str(line)+" : "+str(tokens))
		raise	

def link_sb(line, tokens, symbols, off):
	#SB rd, rs, imm
	return link_sx(line, tokens, symbols, off, 0)
	
def link_sh(line, tokens, symbols, off):
	#SH rd, rs, imm
	return link_sx(line, tokens, symbols, off, 1)
	
def link_sw(line, tokens, symbols, off):
	#SW rd, rs, imm
	return link_sx(line, tokens, symbols, off, 2)
	
def link_xi(line, tokens, symbols, off, funct3):
	#XI rd, rs, imm
	if(len(tokens) == 4):
		try:
			rd = token_to_reg(tokens[1])
			rs = token_to_reg(tokens[2])
			imm = token_to_int(tokens[3], 0, symbols, off)
			return iformat.le_encode(iformat.compile_i(0x13, rd, funct3, rs, imm))
		except:
			print("Unable to parse line "+str(line)+" : "+str(tokens))
			raise
	else:
		print("Missing tokens in line "+str(line)+" : "+str(tokens))
		raise
				
def link_addi(line, tokens, symbols, off):
	#ADDI rd, rs, imm
	return link_xi(line, tokens, symbols, off, 0)
	
def link_slti(line, tokens, symbols, off):
	#SLTI rd, rs, imm
	return link_xi(line, tokens, symbols, off, 2)
	
def link_sltiu(line, tokens, symbols, off):
	#SLTIU rd, rs, imm
	return link_xi(line, tokens, symbols, off, 3)
	
def link_xori(line, tokens, symbols, off):
	#XORI rd, rs, imm
	return link_xi(line, tokens, symbols, off, 4)
	
def link_ori(line, tokens, symbols, off):
	#ORI rd, rs, imm
	return link_xi(line, tokens, symbols, off, 6)
	
def link_andi(line, tokens, symbols, off):
	#ANDI rd, rs, imm
	return link_xi(line, tokens, symbols, off, 7)
	
def link_shift(line, tokens, symbols, off, funct3, immu7):
	#XI rd, rs, imm
	if(len(tokens) == 4):
		try:
			rd = token_to_reg(tokens[1])
			rs = token_to_reg(tokens[2])
			imm = token_to_int(tokens[3], 0, symbols, off)
			return iformat.le_encode(iformat.compile_i_s(0x13, rd, funct3, rs, imm, immu7))
		except Exception as e:
			print("Unable to parse line "+str(line)+" : "+str(tokens))
	else:
		print("Missing tokens in line "+str(line)+" : "+str(tokens))
		raise	
	
def link_slli(line, tokens, symbols, off):
	#SLLI rd, rs, imm --5 bit value
	return link_shift(line, tokens, symbols, off, 1, 0)
	
def link_srli(line, tokens, symbols, off):
	#SRLI rd, rs, imm --5 bit value
	return link_shift(line, tokens, symbols, off, 5, 0)
	
def link_srai(line, tokens, symbols, off):
	#SRAI rd, rs, imm --5 bit value
	return link_shift(line, tokens, symbols, off, 5, 0x20)
	
def link_rtor(line, tokens, symbols, off, funct3, funct7):
	#XX rd, rs1, rs2
	if(len(tokens) == 4):
		try:
			rd = token_to_reg(tokens[1])
			rs1 = token_to_reg(tokens[2])
			rs2 = token_to_reg(tokens[3])
			return iformat.le_encode(iformat.compile_s(0x33, rd, funct3, rs1, rs2, funct7))
		except:
			print("Unable to parse line "+str(line)+" : "+str(tokens))
	else:
		print("Missing tokens in line "+str(line)+" : "+str(tokens))
		raise

def link_mul(line, tokens, symbol, off):
	#MUL rd, rs1, rs2
	return link_rtor(line, tokens, symbol, off, 0, 0x1)
	
def link_mulh(line, tokens, symbol, off):
	#MULH rd, rs1, rs2
	return link_rtor(line, tokens, symbol, off, 0x1, 0x1)
	
def link_mulhsu(line, tokens, symbol, off):
	#MULHSU rd, rs1, rs2
	return link_rtor(line, tokens, symbol, off, 0x2, 0x1)
	
def link_mulhu(line, tokens, symbol, off):
	#MULH rd, rs1, rs2
	return link_rtor(line, tokens, symbol, off, 0x3, 0x1)
		
def link_div(line, tokens, symbol, off):
	#DIV rd, rs1, rs2
	return link_rtor(line, tokens, symbol, off, 0x4, 0x1)
			
def link_divu(line, tokens, symbol, off):
	#DIVU rd, rs1, rs2
	return link_rtor(line, tokens, symbol, off, 0x5, 0x1)
	
def link_rem(line, tokens, symbol, off):
	#REM rd, rs1, rs2
	return link_rtor(line, tokens, symbol, off, 0x6, 0x1)
	
def link_remu(line, tokens, symbol, off):
	#REMU rd, rs1, rs2
	return link_rtor(line, tokens, symbol, off, 0x7, 0x1)
		
def link_add(line, tokens, symbols, off):
	#ADD rd, rs1, rs2
	return link_rtor(line, tokens, symbols, off, 0, 0)
	
def link_sub(line, tokens, symbols, off):
	#SUB rd, rs1, rs2
	return link_rtor(line, tokens, symbols, off, 0, 0x20)
	
def link_sll(line, tokens, symbols, off):
	#SLL rd, rs1, rs2
	return link_rtor(line, tokens, symbols, off, 1, 0)
	
def link_slt(line, tokens, symbols, off):
	#SLT rd, rs1, rs2
	return link_rtor(line, tokens, symbols, off, 2, 0)
	
def link_sltu(line, tokens, symbols, off):
	#SLTU rd, rs1, rs2
	return link_rtor(line, tokens, symbols, off, 3, 0)
	
def link_xor(line, tokens, symbols, off):
	#XOR rd, rs1, rs2
	return link_rtor(line, tokens, symbols, off, 4, 0)
	
def link_srl(line, tokens, symbols, off):
	#SRL rd, rs1, rs2
	return link_rtor(line, tokens, symbols, off, 5, 0)
	
def link_sra(line, tokens, symbols, off):
	#SRA rd, rs1, rs2
	return link_rtor(line, tokens, symbols, off, 5, 0x20)
	
def link_or(line, tokens, symbols, off):
	#OR rd, rs1, rs2
	return link_rtor(line, tokens, symbols, off, 6, 0)
	
def link_and(line, tokens, symbols, off):
	#AND rd, rs1, rs2
	return link_rtor(line, tokens, symbols, off, 7, 0)
	
		
inst_dict = { \
	"lui":link_lui, \
	"auipc":link_auipc, \
	"jal":link_jal, \
	"jalr":link_jalr, \
	"beq":link_beq, \
	"bne":link_bne, \
	"blt":link_blt, \
	"bge":link_bge, \
	"bltu":link_bltu, \
	"bgeu":link_bgeu, \
	"lb":link_lb, \
	"lh":link_lh, \
	"lw":link_lw, \
	"lbu":link_lb, \
	"lhu":link_lh, \
	"sb":link_sb, \
	"sh":link_sh, \
	"sw":link_sw, \
	"addi":link_addi, \
	"slti":link_slti, \
	"sltiu":link_sltiu, \
	"xori":link_xori, \
	"ori":link_ori, \
	"andi":link_andi, \
	"slli":link_slli, \
	"srli":link_srli, \
	"srai":link_srai, \
	"add":link_add, \
	"sub":link_sub, \
	"sll":link_sll, \
	"slt":link_slt, \
	"sltu":link_sltu, \
	"xor":link_xor, \
	"srl":link_srl, \
	"sra":link_sra, \
	"or":link_or, \
	"and":link_and, \
	"mul":link_mul, \
	"mulh":link_mulh, \
	"mulhsu":link_mulhsu, \
	"mulhu":link_mulhu, \
	"div":link_div, \
	"divu":link_divu, \
	"rem":link_rem, \
	"remu":link_remu, \
	"dw":link_dw, \
	"dummy":None
}

def linker(symbols, object):
	#print("Symbol table : "+str(symbols))
	bytecode = []
	comment_list = []
	for obj in object:
		
		line = obj[0]
		tokens = obj[1].split()
		off = obj[2]
		if(len(tokens)):
			tokens[0] = tokens[0].lower()
			if(tokens[0] in inst_dict):
				bytecode = bytecode + inst_dict[tokens[0]](line, tokens, symbols, off)
				comment_list.append("--"+" ".join(tokens))
			else:
				print("Unkown mnemoric "+tokens[0])
		#print("processing line "+str(line)+" : "+str(tokens))
	#print(bytecode)
	return (bytecode, comment_list)
