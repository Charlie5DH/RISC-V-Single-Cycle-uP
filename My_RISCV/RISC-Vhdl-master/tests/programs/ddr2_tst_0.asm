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


ADDI x1, x0, 0
LUI x1, 0x10000

//Load sample values for filling cells
ADDI x2, x0, -1 //Full Block
LUI x3, 0x0F0F0
ADDI x3, x3, 0x70F
ADDI x3, x3, 0x700
ADDI x3, x3, 0x100 //Full half at lower boundary

LUI x4, 0xF0F0F
ADDI x4, x4, 0xF0 //Full half at higher boundary

LUI x5, 0x55555
ADDI x5, x5, 0x555 //Alternating

LUI x6, 0x72AbE
ADDI x6, x6, 0x9F0 //Random num

LUI x7, 0xE7044
ADDI x7, x7, 0xD71 //Random num2

SW x1, x2, 0
SW x1, x4, 8
SW x1, x3, 4
SW x1, x8, 12 //intentionally disorder to check overflows

LW x10, x1, 8
LW x8, x1, 0
LW x11, x1, 12
LW x9, x1, 4 //also disordered (check if those writes work)

SW x1, x6, 0 //Aligned 32-Bit write

LW x15, x1, 12
LW x13, x1, 4
LW x12, x1, 0
LW x14, x1, 8 //random accesss

SW x1, x6, 5 //Misaligned 32-Bit write

LW x16, x1, 0
LW x19, x1, 12
LW x17, x1, 4
LW x18, x1, 8

SH x1, x7, 8 //Aligned 16-Bit write

LW x21, x1, 5
LW x20, x1, 1
LW x23, x1, 13
LW x22, x1, 9 //random access, 1 byte displacement

SH x1, x7, 11 //Misaligned 16-Bit write

LW x26, x1, 10 //Aligned
LW x27, x1, 14 //Aligned 
LB x24, x1, 2 //byte read
LH x25, x1, 6 //random access, 2 byte displacement in total, aligned hword read

SB x1, x7, 14 //Byte write

LB x28, x1, 3 //byte read
LW x31, x1, 15 
LH x29, x1, 7 //unaligned hword read
LW x30, x1, 11














