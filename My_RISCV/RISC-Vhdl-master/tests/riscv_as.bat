@echo off
python ../compiler/riscv_as.py -i %1 -o %~dpn1.out.txt
pause