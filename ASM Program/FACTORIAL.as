.text
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



