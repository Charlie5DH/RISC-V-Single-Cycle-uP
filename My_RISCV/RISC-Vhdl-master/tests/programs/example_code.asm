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



// i am a comment
ADDI x1, x0, 0xAAA
ORI  x2, x1, 0x555
ANDI x3, x2, 0xAAA
XORI x4, x3, 0x5AA
XORI x5, x4, 0x0FF // and i a am a comment
 // and i am a comment

SRAI x7, x5, 2
SRLI x8, x7, 3
SLLI x9, x8, 2  //comment as well

ADD x10, x5, x3
SUB x11, x1, x2

LUI x12, 0x2
LUI x13, 0x3
SRA x14, x11, x12
SRL x15, x11, x13
SLL x16, x11, x12
AUIPC x17, 4
DIV x18, x19, x20
MUL x21, x22, x23
