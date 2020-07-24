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

.hexnumbers
DW 0x33323130
DW 0x37363534
DW 0x42413938
DW 0x46454443

// Arguments:
// x1 = return address
// x2 = string destination
// x10 = HEX-number to convert
// Returns:
// x2 = string destination
// x7 changed
// x8 changed
// x9 changed
.dword_to_hexstring
ADDI x7, x0, 0x020
// hexnumbers = 4
ADDI x8, x0, 4
.dword_to_hexstring1
ADDI x7, x7, 0xFFC
ADD x9, x0, x10
SRL x9, x9, x7
ANDI x9, x9, 0x00F
ADD x9, x9, x8
LB x9, x9, 0x000
SB x2, x9, 0x000
ADDI x2, x2, 0x001
BLT x0, x7, dword_to_hexstring1
SB x2, x0, 0x000
ADDI x2, x2, 0x001
JALR x0, x1, 0x000

// Arguments:
// x1 = return address
// x2 = pointer to video memory
// x10 = pointer to '\0'-terminated string
// Returns:
// x2 = pointer to video memory
// x7 changed
// x8 changed
.print_string
ADD x8, x10, x0
JAL x0, print_string2
.print_string1
SB x2, x7, 0x000
ADDI x2, x2, 0x001
ADDI x8, x8, 0x001
.print_string2
LB x7, x8, 0x000
BNE x7, x0, print_string1
JALR x0, x1, 0x000

// Arguments:
// x1 = return address
// x2 = pointer to video memory
// x3 = pointer to opcode ('\0'-terminated string)
// x4 = expected result
// x5 = calculated result
// Returns:
// x2 = pointer to video memory
// x1 changed
// x6 changed
// x10 changed
.test_op
// save x1 in x6
ADD x6, x0, x1
BEQ x4, x5, test_op1
// x1 = '-'
ADDI x1, x0, 0x02D
JAL x0, test_op2
.test_op1
// x1 = '+'
ADDI x1, x0, 0x02B
.test_op2
// print x1
SB x2, x1, 0x000
ADDI x2, x2, 0x001
// print opcode
ADD x10, x0, x3
JAL x1, print_string
// print ' '
ADDI x1, x0, 0x020
SB x2, x1, 0x000
ADDI x2, x2, 0x001
// print numbers only if test failed
BEQ x4, x5, test_op3
// print expected result
ADD x10, x0, x4
JAL x1, dword_to_hexstring
// print calculated result
ADD x10, x0, x5
JAL x1, dword_to_hexstring
.test_op3
// return
JALR x0, x6, 0x000

// Arguments:
// x1 = return address
// x2 = pointer to video memory
// Returns:
// x2 = pointer to video memory
.new_line
SRLI x2, x2, 0x6
ADDI x2, x2, 0x001
SLLI x2, x2, 0x6
JALR x0, x1, 0x000

.opcodes
DW 0x00444441

.start
// x2 = pointer to video memory
LUI x2, 0x20000
// Testing add:
//   0x048CF2D8
// + 0x758100A9
// ------------
//   0x7A0DF381
// opcodes = 196
ADDI x3, x0, 196
// falsches Ergebnis:
LUI x4, 0x7a1df
ADDI x4, x4, 0x381
// richtiges Ergebnis:
//LUI x4, 0x7a0df
//ADDI x4, x4, 0x381
LUI x31, 0x048CF
ADDI x31, x31, 0x2D8
LUI x5, 0x75810
ADDI x5, x5, 0x0A9
ADD x5, x5, x31
JAL x1, test_op


//LUI x10, 0xABCD6
//ADDI x10, x10, 0x789
//LUI x2, 0x20000
//ADDI x2, x2, 0x000
//JAL x1, dword_to_hexstring
