# RISC-V-Single-Cycle-uP

Design and implementation in VHDL for FPGAs of a single cycle RISC-V based architecture.

The work presents the design of a single cycle reduced version of the RISC-V architecture described by David A. Patterson and John L. Hennessy in the book, “Computer Organization and Design RISC-V Edition: The Hardware Software Interface”, Morgan Kaufmann, 2017. The design is described in VHDL (Very High-Speed Integrated Circuit Hardware Description Language) to be implemented in an FPGA (Fieldprogrammable gate array) and includes all the necessary hardware to implement some of the most common instructions in the RISC-V architecture. The functioning is tested by making use of three programs in assembly code, stored in the instruction memory, which use all the instructions and the input/output interface of the platform. Testbenches for the functionality of the design are provided.

RISC-V is a new general-purpose, open-source ISA, usable in any hardware or software without royalties. It was developed at UC Berkeley starting in 2010. Although x86 and ARM are widely available and supported, they are complex, and the licensing model is difficult for experimental and academic use, also, developing a microprocessor is a very hard and multidisciplinary task. Normally licenses can cost around $1M to $10M and the negotiation time can vary from 6 to 24 months and doesn’t even let you design your own core. RISC-V was created as the solution for this problem as one free and open ISA everyone can use.

The addition of a new open-source ISA like RISC-V to the market could lead to greater innovation via free-market competition from many more designers. Shared open core designs, which would mean shorter time to market, lower cost from reuse and fewer error. Processors becoming affordable for more devices, which helps expand the Internet of Things (IoTs).
RISC-V aims to serve all markets, including microcontrollers as well as image, graphics, and server processors. Therefor it must be consistent in across architectures, from an inorder scalar design to a heavily out-of-order design. To address this issue, RISC-V defines a guaranteed base integer instruction set of 32, 64, or 128 bits, a family of optional and predefined extensions, and a mechanism for creating variable-length extensions. The RISC-V ISA offers all the basic RISC features with a few twists that simplify the
implementation, thereby reducing die area and potentially power consumption. Compared with today’s two most popular ISAs, RISC-V offers considerable area savings, particularly
for low-end designs, and the ability to add custom extensions.

## Design Criteria
The ISA is cleanly architected to simplify implementation. The instruction encoding is highly regular and lacks complicated memory instructions. The benefit is that minimal RISC-V cores are much smaller than similar ARM or x86 cores, although the difference is not noticeable for more powerful cores.

## Requirements
- Quartus
- VHDL

## References

1) David A. Patterson, John L. Hennessy, “Computer Organization and Design RISC-V Edition: The Hardware Software Interface”, Morgan Kaufmann, 2017.
2) https://riscv.org/risc-v-foundation/
3) O’Connor, Rick. RISC-V ISA & Foundation Overview. https://content.riscv.org/wp.../1-RISC-V-ISA-Foundation-Overview-DAC2018-1.pdf
4) Kanter D. RISC-V offers simple, modular ISA. The Linley Group MICROPROCESSOR Report (March 2016). 2016 Mar.
5) https://github.com/rv8-io/rv8/blob/master/doc/pdf/riscv-instructions.pdf
6) https://rv8.io/
