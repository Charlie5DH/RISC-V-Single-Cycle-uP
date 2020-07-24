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
ADDI x1, x1, 0x20

LUI x2, 0x77777
ADDI x2, x2, 0x777

LW x4, x1, 0
LW x5, x1, 4
LW x6, x1, 8
LW x7, x1, 12

SW x1, x2, 0

LW x8, x1, 0
LW x9, x1, 4
LW x10, x1, 8
LW x11, x1, 12

SW x1, x2, 8

LW x12, x1, 0
LW x13, x1, 4
LW x14, x1, 8
LW x15, x1, 12

SW x1, x2, 4

LW x16, x1, 0
LW x17, x1, 4
LW x18, x1, 8
LW x19, x1, 12

SW x1, x2, 12

LW x20, x1, 0
LW x21, x1, 4
LW x22, x1, 8
LW x23, x1, 12
