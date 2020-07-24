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


.entry
	lui x3, 0x40000
	lui x2, 0x00001 //init sp
	addi x2, x2, 0x800
	lui x4, 0x30000 //ioram
	
.flush_pram_loop

	lbu x5, x5, 1
	andi x5, x5, 0x80 //switch(3)
	bne x5, x0, pram_start //switch is pressed, pram start
	
	//wait for valid data
	lbu x5, x4, 5
	andi x5, x5, 1
	bne x5, x0, flush_pram_loop //data is not valid
	
	lbu x5, x4, 4 //uart data
	sb x3, x5, 0
	addi x3, x3, 1 //next byte
	
	//wait for data to become invalid
	.wait_for_new_data
		
		lbu x5, x5, 1
		andi x5, x5, 0x80 //switch(3)
		bne x5, x0, pram_start //switch is pressed, pram start
	
		lbu x5, x4, 5
		andi x5, x5, 1
		beq x5, x0, flush_pram_loop
		
		jal x0, wait_for_new_data

.pram_start
	lui x1, 0x40000
	jalr x0, x1, 0
	
.bios_error
	jal x0, bios_error
