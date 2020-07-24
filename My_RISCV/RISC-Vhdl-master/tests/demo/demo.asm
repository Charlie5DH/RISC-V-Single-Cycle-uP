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
	addi x2, x2, 0x400
	addi x2, x2, 0x400 //setup stack pointer
	jal x0, main

.hborder
	dw 0x2D2D2D2D
	dw 0x2D2D2D2D
	dw 0x2D2D2D2D
	dw 0x2D2D2D2D
	dw 0x2D2D2D2D
	dw 0x2D2D2D2D
	dw 0x2D2D2D2D
	dw 0x2D2D2D2D
	
.vborder
	dw 0x00007C7C
	dw 0x00000000
	dw 0x7C7C0000
	dw 0x00000000
	dw 0x00000000
	dw 0x00007C7C
	dw 0x00000000
	dw 0x7C7C0000

.cross
	dw 0x0000005C
	dw 0x2F2F2F00
	dw 0x2F5C0000
	dw 0x00000000
	dw 0x5C2F0000
	dw 0x00000000
	dw 0x0000002F
	dw 0x00005C00
	
.dot
	dw 0x2D2D2800
	dw 0x00000029
	dw 0x00000028
	dw 0x00002900
	dw 0x00000028
	dw 0x00002900
	dw 0x2D2D2800
	dw 0x00000029
	
.str_player_turn
	dw 0x65697053
	dw 0x2072656C
	dw 0x73692031
	dw 0x6D612074
	dw 0x67755A20
	dw 0x0000002E
	
.str_player_won
	dw 0x65697053
	dw 0x2072656C
	dw 0x65672031
	dw 0x6E6E6977
	dw 0x00002E74
	
	
// void setup_border(), setup borders for game into cram
.setup_border
	addi x2, x2, -8
	sw x2, x1, 0
	sw x2, x3, 4
	//setup the frames for the game
	addi x3, x0, 15
	.setup_border_loop
		blt x3, x0, end_setup_border
		//pick the right border to print (usually we pick vborder)
		lui x18, 0x40000
		addi x18, x18, vborder
		slli x27, x3, 6 //row counter * 64
		lui x19, 0x20000
		addi x19, x19, 64
		add x19, x19, x27
		addi x26, x0, 15
		beq x3, x26, phbord
		addi x26, x0, 10
		beq x3, x26, phbord
		addi x26, x0, 5
		beq x3, x26, phbord
		bne x3, x0, wboard
		.phbord
			lui x18, 0x40000
			addi x18, x18, hborder
		.wboard
		addi x20, x0, 32
		jal x1, memcpy
		addi x3, x3, -1
		jal x0, setup_border_loop
	.end_setup_border
		lw x1, x2, 0
		lw x3, x2, 4
		addi x2, x2, 8
		jalr x0, x1, 0
		
	
// void print_element (int x, int y, int element), 0=cross, !0=dot
.print_element
	addi x2, x2, -16
	sw x2, x1, 0
	sw x2, x3, 4
	sw x2, x4, 8
	sw x2, x5, 12
	
	addi x26, x0, 10
	mul x26, x26, x18 //x * 10
	addi x26, x26, 3 //x+3
	
	addi x27, x0, 5
	mul x19, x19, x27 //y * 5
	addi x19, x19, 1 //y + 1
	slli x19, x19, 6 //64 chars per line
	add x3, x19, x26    //x + 64 * y is offset
	
	addi x5, x0, 4 //cnt
	
	lui x4, 0x40000
	addi x4, x4, cross
	beq x20, x0, do_print_element
	lui x4, 0x40000
	addi x4, x4, dot
	
	.do_print_element
	beq x5, x0, end_print_element
	addi x18, x4, 0
	lui x19, 0x20000
	addi x19, x19, 64
	add x19, x19, x3
	addi x20, x0, 6
	jal x1, memcpy
	
	addi x5, x5, -1
	addi x4, x4, 8
	addi x3, x3, 64
	jal x0, do_print_element
	

	.end_print_element
	lw x1, x2, 0
	lw x3, x2, 4
	lw x4, x2, 8
	lw x5, x2, 12
	addi x2, x2, 16
	jalr x0, x1, 0
	
	
// void cursor_set_active(int x, int y, int active), 0=inactive, !0=active
.cursor_set_active
	addi x26, x0, 10
	mul x26, x26, x18 //x*10
	
	addi x27, x0, 5
	mul x27, x27, x19 //y * 5
	addi x27, x27, 1 //y + 1
	slli x27, x27, 6 // 64 chars per line
	
	lui x28, 0x20000
	addi x28, x28, 64
	add x26, x26, x27 // x + y*64
	add x26, x26, x28 //prefix
	
	addi x29, x0, 4 //cnt
	
	addi x28, x0, 0x0
	beq x20, x0, do_cursor_set_active
	addi x28, x0, 0x2A
	.do_cursor_set_active
	beq x29, x0, end_cursor_set_active
		
		sb x26, x28, 2
		sb x26, x28, 9
		addi x26, x26, 64 //next line
		addi x29, x29, -1
		jal x0, do_cursor_set_active
		
	
	.end_cursor_set_active
	jalr x0, x1, 0
	
.key_release
	lui x26, 0x30000 //ioram prefix
	lh x27, x26, 0
	srli x27, x27, 7
	andi x27, x27, 0x1F //isolating buttons
	.key_release_wait
		//load new keys and check if any key was released
		lh x28, x26, 0
		srli x28, x28, 7
		andi x28, x28, 0x1F //new keys (we hope that one bit)
		addi x30, x28, 0
		xor x28, x28, x27 //all new events occur now
		and x28, x28, x27 //we only filter for events that were hold the last check
		addi x27, x30, 0
		beq x28, x0, key_release_wait //keep waiting
	addi x18, x0, 0 //return value := which button was pressed
	addi x29, x0, 1
	.key_release_shift_result
		beq x28, x29, end_key_release
		srli x28, x28, 1
		addi x18, x18, 1
		jal x0, key_release_shift_result
	.end_key_release
	jalr x0, x1, 0
	
		
.set_turn
//void set_turn(char turn) //sets the turn variable
	lui x26, 0x10000
	sb x26, x18, 0
	//LED update, Screen set String
	lui x26, 0x30000
	lui x28, 0x20000
	addi x28, x28, 0x440
	addi x27, x0, 0
	addi x29, x0, 0x31
	beq x18, x0, set_turn_set_led
	addi x27, x0, 1
	addi x29, x29, 1
	.set_turn_set_led
	sb x26, x27, 2
	sb x28, x29, 8
	jalr x0, x1, 0
	
.get_turn
//char get_turn(char turn) //gets the turn variable
	lui x26, 0x10000
	lb x18, x26, 0
	jalr x0, x1, 0

.matrix_init
//void matrix_init() initializes the matrix (3x3) = 9 bytes
	lui x26, 0x10000
	addi x27, x0, -4 //initialize with 0xFC
	sw x26, x27, 4
	sw x26, x27, 8
	sb x26, x27, 12
	jalr x0, x1, 0

.matrix_place_if_possible
//bool matrix_place_if_possible(int x, int y, int playerid) //returns weather placement was successfull
	lui x26, 0x10000
	addi x27, x0, 3
	mul x27, x19, x27 //y * 3
	add x27, x27, x18 //3y + x
	add x27, x27, x26
	lb x26, x27, 4
	addi x18, x0, 0 //placement failed
	bge x26, x0, end_matrix_can_place //singed matrix element >= 0 ->cell is used
	sb x27, x20, 4 //place
	addi x18, x0, 1 //placement sucessfull
	.end_matrix_can_place
	jalr x0, x1, 0
	
	

.main
	
	lui x3, 0x20000
	addi x3, x3, 0x440 //offset of state text
	addi x18, x0, 0
	addi x19, x3, 0
	addi x20, x0, 64 //one line
	jal x1, memfill
	
	addi x19, x3, 0
	lui x18, 0x40000
	addi x18, x18, str_player_turn
	addi x20, x0, 24
	jal x1, memcpy
	
	
	
	//Var setup
	addi x18, x0, 0 //player 0 is allowed to start
	jal x1, set_turn
	jal x1, matrix_init
	addi x3, x0, 1 //cursor x
	addi x4, x0, 1 //cursor y
	
	//UI setup
	jal x1, setup_border
	addi x18, x3, 0
	addi x19, x4, 0
	addi x20, x0, 1
	jal x1, cursor_set_active
	
.idle_loop
		jal x1, key_release
		addi x26, x0, 4 //btn 4 -> confirm
		addi x6, x18, 0 //save the released button
		beq x6, x26, request_place_element
		//one of the dir buttons was pressed -> we move the cursor and can delete the old one
		addi x18, x3, 0
		addi x19, x4, 0
		addi x20, x0, 0
		jal x1, cursor_set_active
		addi x27, x0, 3 //modulo class
		addi x26, x0, 1 //btn 1 -> north
		beq x6, x26, btn_north
		addi x26, x0, 2 //btn 2 -> south
		beq x6, x26, btn_south
		addi x26, x0, 3 //btn 3 -> west
		beq x6, x26, btn_west
		beq x6, x0, btn_east //btn 0 -> east
		//unreachable but for error handling 
		jal x0, idle_loop

.request_place_element
//request to place
	jal x1, get_turn
	addi x5, x18, 0
	addi x18, x3, 0
	addi x19, x4, 0
	addi x20, x5, 0
	jal x1, matrix_place_if_possible
	beq x18, x0, idle_loop //can not place element here
	addi x18, x3, 0
	addi x19, x4, 0
	addi x20, x5, 0
	jal x1, print_element
	xori x18, x5, 1
	jal x1, set_turn
	
	jal x0, idle_loop
	//jal x1, player_won
	blt x18, x0, idle_loop
	
	addi x3, x18, 0
	lui x18, 0x40000
	addi x18, x18, str_player_won
	lui x19, 0x20000
	addi x19, x19, 0x440
	addi x20, x0, 20
	jal x1, memcpy
	lui x19 0x20000
	addi x19, x19, 0x440
	sb x19, x3, 8
	
.btn_north
	addi x4, x4, 2 //-1 in y direction
	rem x4, x4, x27
	jal x0, cursor_update
	
.btn_south
	addi x4, x4, 1 //+1 in y direction
	rem x4, x4, x27
	jal x0, cursor_update
	
.btn_east
	addi x3, x3, 1 //+1 in x direction
	rem x3, x3, x27
	jal x0, cursor_update

.btn_west
	addi x3, x3, 2 //-1 in x direction
	rem x3, x3, x27
	
.cursor_update
	addi x18, x3, 0
	addi x19, x4, 0
	addi x20, x0, 1
	jal x1, cursor_set_active
	jal x0, idle_loop	
	
		
.player_won
	lui x26, 0x10000
	addi x27, x26, 0
	addi x28, x0, 2 //iterator
	addi x18, x0, -1 //result
	.player_won_hv_loop
		blt x28, x0, end_player_won_hv_loop
		addi x29, x0, 3 //inner iterator
		addi x30, x0, 0 //hsum
		addi x31, x0, 0 //vsum
		
		add x19, x26, x28 //vertical start index
		addi x20, x0, 3
		mul x20, x28, x20 //horizonta lstart index
		add x20, x26, x20
		
		.player_won_inner
			beq x29, x0, end_player_won_inner
			lb x21, x19, 4
			add x31, x31, x21
			lb x21, x20, 4
			add x30, x30, x21
			addi x20, x20, -1
			jal x0, player_won_inner

		.end_player_won_inner
		addi x28, x28, -1
		bge x30, x0, player_won_hsum
		blt x31, x0, player_won_hv_loop
		addi x30, x31, 0
		.player_won_hsum
		addi x19, x0, 3
		div x18, x30, x19 //when player 1 : 3 / 3 = 1, when player 0 : 0 / 3 = 0
	.end_player_won_hv_loop
	jalr x0, x1, 0
	
		
// void memcpy (void *src, void *dst, int size), bytewise memcpy		
.memcpy
	beq x20, x0, end_memcpy
	lb x26, x18, 0
	sb x19, x26, 0
	addi x18, x18, 1
	addi x19, x19, 1
	addi x20, x20, -1
	jal x0, memcpy
.end_memcpy
	jalr x0, x1, 0


//void memfill(char src, void *dst, int size), bytewise memfill
.memfill
	beq x20, x0, end_memfill
	sb x19, x18, 0
	addi x19, x19, 1
	addi x20, x20, -1
	jal x0, memfill
.end_memfill
	jalr x0, x1, 0	

	
	
