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


--addi x30, x0, 0x7FF
"00010011","00001111","11110000","01111111",

--lui x28, 0x20000
"00110111","00001110","00000000","00100000",

--addi x29, x29, 0x001
"10010011","10001110","00011110","00000000",

--addi x28, x28, 0x001
"00010011","00001110","00011110","00000000",

--sb x28, x29, 0
"00100011","00000000","11011110","00000001",

--bne x29, x30, mar0
"11100011","10011010","11101110","11111111",

others=>(others=>'0')
