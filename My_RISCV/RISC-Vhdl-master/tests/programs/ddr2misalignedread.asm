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

LW x4, x1, 16
LW x5, x1, 20
LW x6, x1, 24
LW x7, x1, 28

LW x8, x1, 17
LW x9, x1, 21
LH x10, x1, 25
LB x11, x1, 29
