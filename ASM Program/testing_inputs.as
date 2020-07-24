.text
addi x1, x1, 4
addi x2, x2, 0xff
addi x3, x3, 0x2
sb x2, 1(x0)
sb x3, 2(x0)
andi x2, x2, 0
andi x3, x3, 0
START:
lw x2, 0(x1)
lw x3, 4(x0)
sw x2, 1(x0)
sw x3, 2(x0)
jal x0, START
