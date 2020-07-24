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


JAL x0, start

// Arguments:
// x1 = return address
// x2 = pointer to video memory
// x4 = expected result
// x5 = calculated result
// Returns:
// x2 = pointer to video memory
// x1 changed
// x6 changed
// x10 changed
.test_op
BEQ x4, x5, test_op1
// x6 = '-'
ADDI x6, x0, 0x02D
JAL x0, test_op2
.test_op1
// x6 = '+'
ADDI x6, x0, 0x02B
.test_op2
// print x1
SB x2, x6, 0x000
// x6 = ','
ADDI x6, x0, 0x02C
SB x2, x6, 0x001
ADDI x2, x2, 0x002
JALR x0, x1, 0x000

.start
// x2 = pointer to video memory
LUI x2, 0x20000

// Testing SUB:
//   0x048CF2D8
// + 0x758100A9
// ------------
//   0x7A0DF381
LUI x3, 0x00444
ADDI x3, x3, 0x441
SW x2, x3, 0x000
ADDI x2, x2, 0x003
LUI x4, 0x7a0df
ADDI x4, x4, 0x381
LUI x31, 0x048CF
ADDI x31, x31, 0x2D8
LUI x5, 0x75810
ADDI x5, x5, 0x0A9
ADD x5, x5, x31
JAL x1, test_op

// Testing SUB:
//   0x3F7D3284
// - 0xB7C38281
// ------------
//   0x87B9B003
LUI x3, 0x00425
ADDI x3, x3, 0x553
SW x2, x3, 0x000
ADDI x2, x2, 0x003
LUI x4, 0x87b9b
ADDI x4, x4, 0x003
LUI x31, 0xb7c38
ADDI x31, x31, 0x281
LUI x5, 0x3F7D3
ADDI x5, x5, 0x284
SUB x5, x5, x31
JAL x1, test_op

.end
JAL x0, end
