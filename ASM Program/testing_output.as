.text
START:
addi x1, x1, 1
sw x1, 0(x0)
addi x2, x2, 1
sb x2, 1(x0)
addi x3, x3, 1
sb x3, 2(x0)
addi x4, x4, 1
sb x4, 3(x0)
jal x0, START
