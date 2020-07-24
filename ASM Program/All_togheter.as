.text
START:
addi x1,x1,0xF
sb x1,0(x0)
addi x2, x2, 4
addi x3,x3,1
addi x4,x4,2
addi x5,x5,3
PICK:
lw x1, 0(x2)
andi x1,x1,0x00003FF
beq x1,x3, INSTRUCTIONS
beq x1,x4, BEGIN_FIBB
beq x1,x5, BEGIN_FACT
jal x0, PICK
INSTRUCTIONS:
addi x1,x1, 3
sb x1, 0(x1)
sub x3, x7, x5
and x5, x6, x7
andi x5, x6, 0
xor x5, x6, x7
xori x5, x6, 7 
or x5, x6, x7       
ori x5, x6, 7        
sll x5, x6, x7      
srl x5, x6, x7       
slt x5, x6, x7        
sb x3, 5(x2)         
sw x5, 3(x2)        
lb x2, 5(x3)        
lw x4, 5(x3) 
BRANCHES:
addi x2,x0, 3        
addi x8,x8,1        
bne x2,x8, BRANCHES
jal x0, START
BEGIN_FIBB:
lw x1,0(x10)
andi x1,x1,0x00003FF
andi x2,x2, 0x0
beq x1,x2, BEGIN_FIBB
andi x3,x3, 0x0
andi x4,x4, 0x0
andi x5,x5, 0x0
addi x5,x5, -1
andi x7,x7, 0x0
addi x7,x7, 0x2
addi x3,x3, 0x1
addi x1,x1, 0x5
andi x8,x8, 0x0
addi x9,x9, 0x3  
FIBONACCI:
addi x5,x5,1
blt x5,x7, NEXTC
add x4,x2,x3
addi x2,x3,0
addi x3,x4,0
PRINT:
sb x4,0(x8)
addi x8,x8,1
beq x8,x9, END
blt x5,x1, FIBONACCI
NEXTC:
addi x4,x5,0x0
jal x0, PRINT 
END:
jal x0, START
BEGIN_FACT:
andi x4, x4, 0
addi x4,x4, 1
andi x5,x5,0
addi x5,x5,1
andi x2,x2, 0
addi x2,x2, 4
lw x1, 0(x2)
andi x3,x3 0
addi x3,x3, 1
beq x1,x0, BEGIN_FACT
FOR:
mul x3,x3,x4
addi x4, x4, 1
bgt x1,x4, FOR
sw x3,0(x0)
sw x3,0(x5)
jal x0, START