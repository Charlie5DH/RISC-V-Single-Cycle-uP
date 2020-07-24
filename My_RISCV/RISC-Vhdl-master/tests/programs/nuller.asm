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


LUI x1, 0x10000
ADDI x1, x1, 0x100

LUI x28, 0x20000
LUI x29, 0x03010
ADDI x29, x29, 0x204

SW x28, x29, 20


ADDI x2, x0, 0
ADDI x2, x2, 0xFFF
LUI x3, 0x80201
ADDI x3, x3, 0x008
LW x4, x1, 16
LW x5, x1, 20
LW x6, x1, 24
LW x7, x1, 28


SW x1, x0, 16

LW x8, x1, 16
LW x9, x1, 20
LW x10, x1, 24
LW x11, x1, 28


SW x1, x0, 21


LW x12, x1, 16
LW x13, x1, 20
LW x14, x1, 24
LW x15, x1, 28

SH x1, x0, 24



LW x16, x1, 16
LW x17, x1, 20
LW x18, x1, 24
LW x19, x1, 28


SH x1, x0, 27 

LW x20, x1, 16
LW x21, x1, 20
Lw x22, x1, 24
LW x23, x1, 28

SB x1, x0, 30

LW x24, x1, 16
LW x25, x1, 20
LW x26, x1, 24
LW x27, x1, 28
