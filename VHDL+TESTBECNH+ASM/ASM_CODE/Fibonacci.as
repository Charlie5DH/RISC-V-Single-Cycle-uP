.text
addi x10,x10,4
BEGIN:
lw x1,0(x10)
andi x1,x1,0x00003FF
andi x2,x2, 0x0
beq x1,x2, BEGIN
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

