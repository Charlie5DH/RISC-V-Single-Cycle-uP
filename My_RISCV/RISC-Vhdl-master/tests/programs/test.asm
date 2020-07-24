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
LUI x10, 0xFFFFF
ADDI x10, x10, 0xFFF
LUI x11, 0xAAAAA
ADDI x11, x11, 0xAAA
LW x4, x1, 0x000
LW x5, x1, 0x008
LW x6, x1, 0x000
SW x1, x10, 0x000
SW x1, x11, 0x008
LW x7, x1, 0x000
LW x8, x1, 0x008
ADDI x1, x0, 0x3
ADDI x2, x0, 0x4
MUL x3, x2, x1
DIV x4, x3, x1
