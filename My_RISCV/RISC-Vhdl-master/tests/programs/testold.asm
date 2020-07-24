// VHDL implementation of RISC-V-ISA
// Copyright (C) 2016 Chair of Computer Architecture
// at Technical University of Munich
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.


	.sym0
		LUI x4, 0xF3
		AUIPC x3, sym3
	.sym1
		JAL x1, sym0
		JALR x1, x2, sym0
	.sym2
		BEQ x1, x2, sym2
		BNE x1, x2, sym2
		BLT x1, x2, sym4
		BGE x1, x2, sym2
		BLTU x1, x2, sym2
		BGEU x1, x2, sym2
	.sym3
		LB x1, x2, -4
		LH x1, x2, -8
		LW x2, x1, 34
		LBU x1, x2, 4
		LHU x3, x31, -2
		SB x1, x2, -5
		SW x1, x2, 6
		SH x2, x2, 3
	.sym4
		ADDI x13, x2, 0
		SLTI x1, x2, -4
		SLTIU x3, x4, -2
		XORI x0, x1, 33
		ANDI x2, x0, 0xFE
		SLLI x2, x1, 5
		SRLI x2, x1, 5
		SRAI x2, x1, 12
	.sym5
		ADD x1, x2, x3
		SUB x1, x2, x3
		SLL x1, x2, x3
		SLT x1, x2, x3
		SLTU x1, x2, x3
		XOR x1, x2, x3
		SRL x1, x2, x3
		SRA x1, x2, x3
		OR x1, x2, x3
		AND x1, x2, x3
		
		
	
