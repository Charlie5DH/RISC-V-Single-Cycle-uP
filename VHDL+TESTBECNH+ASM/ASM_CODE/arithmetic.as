.text
BEGIN:
addi x2, x2, 3
addi x7,x7, 4
add x1, x2, x7
sub x3, x2, x7
and x4, x7, x10
andi x5, x7, 0xf
xor x5, x6, x7
xori x5, x6, 7
or x5, x6, x7
ori x5, x6, 7
sll x5, x6, x7
srl x5, x6, x7
slt x5, x6, x7
sb x1, 1(x0)
sb x3, 2(x0)
BRANCHES:
addi x9,x0, 3
addi x8,x8, 1
bne x2,x8, BRANCHESES