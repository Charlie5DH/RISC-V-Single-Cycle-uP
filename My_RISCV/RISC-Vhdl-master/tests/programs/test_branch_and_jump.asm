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


.start
LUI x20,0xAAAAA
AUIPC x29,0x0
ADDI x1,x0,0x3
ADDI x2,x0,0x5
ADD x3,x0,x0
ADD x4,x0,x0
ADD x5,x0,x0
ADD x6,x0,x0
ADD x7,x0,x0
ADD x8,x0,x0
ADD x9,x0,x0
ADD x10,x0,x0
ADD x31,x0,x0
AUIPC x21,0x123
AUIPC x30,0x0
ADDI x30,x0,0x10
.loop1
BNE x3,x0,is_not_zero
ADD x3,x0,x1
ADD x4,x0,x2
ADD x5,x0,x1
ADD x6,x0,x2
SUB x7,x0,x1
SUB x8,x0,x2
SUB x9,x0,x1
SUB x10,x0,x2
.is_not_zero
BEQ x3,x4,equal
BLT x3,x4,lt1
ADD x4,x4,x2
JAL x31,end1
.lt1
ADD x3,x3,x1
.end1
BGEU x5,x6,ge1
ADD x5,x5,x1
JAL x31,end2
.ge1
ADD x6,x6,x2
.end2
BGE x7,x8,ge2
SUB x8,x8,x2
JAL x31,end3
.ge2
SUB x7,x7,x1
.end3
BLTU x9,x10,lt2
ADD x9,x9,x1
JAL x31,end4
.lt2
ADD x10,x10,x2
.end4
JALR x30,-0x10
.equal
BLT x3,x4,end5
BGE x3,x4,end6
JAL x31,end5
.end6
JALR x29,0x0
.end5
