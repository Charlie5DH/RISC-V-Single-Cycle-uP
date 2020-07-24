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




ADDI x1, x0, 1
LUI x1, 0x10000 //praefix


LUI x2, 0x66666
ADDI x2, x2, 0x666

LUI x3, 0x99999
ADDI x3, x3, 0x999

LUI x4, 0x3C909
ADDI x4, x4, 0x104

SW x1, x4, 1

LUI x4, 0x2C241
ADDI x4, x4, 0x5BD

SW x1, x4, 5

LUI x4, 0xF09E2
ADDI x4, x4, 0x878

SW x1, x4, 9

LUI x4, 0x41C91
ADDI x4, x4, 0x33E
SW x1, x4, 13


LW x4, x1, 1
LW x5, x1, 5
LW x6, x1, 9
LW x7, x1, 13

SW x1, x2, 1

LW x8, x1, 1
LW x9, x1, 5
LW x10, x1, 9
LW x11, x1, 13

SW x1, x2, 6

LW x12, x1, 1
LW x13, x1, 5
LW x14, x1, 9
LW x15, x1, 13

LW x16, x1, 1
LW x17, x1, 5
LW x18, x1, 9
LW x19, x1, 13


LW x20, x1, 1
LW x21, x1, 5
LW x22, x1, 9
LW x23, x1, 13

LW x24, x1, 1
LW x25, x1, 5
LW x26, x1, 9
LW x27, x1, 13

DW 5
DW 0xA336
DW -4
DW 0xFFFFF
