.text
add x1, x2, x7
addi x5, x6, 5
sub x3, x5, x7
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
sw x5, 3(x3)
lb x2, 5(x2)
lw x6, 3(x3)
BRANCHES:
addi x2,x0, 3
addi x8,x8, 1
beq x2,x8, BRANCHES