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


LUI x28, 0x20000

ADDI x1, x1, 65
SB x28, x1, 0
ADDI x1, x1, 5
SB x28, x1, 2


LB x4, x28, 0
LB x5, x28, 2


