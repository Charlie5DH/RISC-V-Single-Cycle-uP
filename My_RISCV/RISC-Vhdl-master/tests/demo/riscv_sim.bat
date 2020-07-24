@echo off
python ../../compiler/riscv_as.py -i %1 -o %~dpn1.out.txt -s %~dpn1.out.sym -b %~dpn1.out.bin
python ../../compiler/riscv_simulation.py -s %~dpn1.out.sym -b %~dpn1.out.bin
pause