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


//First we do some random stuff to create a lot of fuzz in the bram at adress 0

XORI x27, x7, 0x313
SLL x16, x11, x12
AUIPC x17, 4
DIV x18, x19, x20

.test

ADDi x1, x0, test
LUI x1, 0x00000 //praefix

ADDI x2, x0, 0x666
LUI x2, 0x66666

ADDI x3, x0, 0x999
LUI x3, 0x99999

LW x4, x1, 0
LW x5, x1, 4
LW x6, x1, 8
LW x7, x1, 12

SW x1, x2, 0

LW x8, x1, 0
LW x9, x1, 0
LW x10, x1, 0
LW x11, x1, 0

SW x1, x2, 5

LW x12, x1, 0
LW x13, x1, 0
LW x14, x1, 0
LW x15, x1, 0

SH x1, x3, 8

LW x16, x1, 0
LW x17, x1, 4
LW x18, x1, 8
LW x19, x1, 12

SH x1, x3, 11

LW x20, x1, 0
LW x21, x1, 0
LW x22, x1, 0
LW x23, x1, 0

SB x1, x3, 14

LW x24, x1, 0
LW x25, x1, 0 
LW x26, x1, 0
LW x27, x1, 0

