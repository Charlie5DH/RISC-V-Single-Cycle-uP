# HF-RISC SoC

---
### Description

HF-RISC is a small 32-bit, in order, 3-stage pipelined MIPS / RISC-V microcontroller designed at the Embedded Systems Group (GSE) of the Faculty of Informatics, PUCRS, Brazil. All registers / memory accesses are synchronized to the rising edge of clock. The core can be easily integrated into several applications, and interfaces directly to standard synchronous memories. Pipeline stages are: 

- FETCH: Instruction memory is accessed (address is PC), data becomes available in one cycle. PC is updated.
- DECODE: An instruction is fed into the decoding / control logic and values are registered for the next stage. Pipeline stalls, as well as bubble insertion is performed in this stage.
- EXECUTE: The register file is accessed and the ALU calculates the result. Data access is performed (loads and stores) or simply the result (or pc) is written to the register file (normal operations). Branch target and its outcome are calculated.

In essence, the current pipeline arrangement is very similar to an ARM7TDMI MCU. The short pipeline and position of all functional units were design decisions that avoid the use of forwarding paths and stalls, minimizing logic complexity and CPI. This design is a compromise between performance, area and complexity. Only the absolutely *needed* MIPS-I opcodes are implemented in one version of the processor based on the MIPS ISA. This core was implemented with the C programming language in mind, so opcodes which cause overflows on integer operations (add, addi, sub) were not included for obvious reasons. The resulting ISA on the MIPS version is very similar to the RV32I base instruction set of the RISC-V architecture, being this subset conceived around 2008. Some architectural features:

- Memory is accessed in big endian mode (MIPS) and little endian mode (RISC-V).
- No unaligned loads/stores.
- No co-processor is implemented and all peripherals are memory mapped.
- Loads and stores take 3 cycles. The processor datapath is organized as a Von Neumann machine, so there is only one memory interface that is shared betweeen code and data accesses. No load delay slots are needed in code.
- Branches are performed on a single cycle (not taken) or 3 cycles (taken), including two branch delay slots. This is a side effect of the pipeline refill and memory access policy. All other instructions are single cycle. The first delay slot can be filled with an instruction (on the MIPS version), reducing the cost to 2 cycles. The second delay slot is completely useless and the instruction in this slot is discarded. No branch predictor is implemented (default branch target is 'not taken'). Minor modifications in the datapath can turn the second branch delay slot usable, but the current toolchain isn't compatible with this behavior, so a bubble is inserted.
- Interrupts are handled using memory mapped VECTOR, CAUSE, MASK, STATUS and EPC registers. The VECTOR register is used to hold the address of the default (non-vectored) interrupt handler. The CAUSE register is read only and peripheral interrupt lines are connected to this register. The MASK register is read/write and holds the interrupt mask for the CAUSE register. The interrupt STATUS register is automatically cleared on interrupts, and is set by software when returning from interrupts - this works as a global interrupt enable/disable flag. This register is read and write capable, so it can also be cleared by software. Setting this register on return from interrupts re-enables interrupts after a few cycles. The EPC register holds the program counter when the processor is interrupted (we should re-execute the last instruction (EPC-4), as it was not commited yet). EPC is a read only register, and is used to return from an interrupt using simple LW / JR instructions. As an interrupt is accepted, the processor jumps to VECTOR address where the first level of irq handling is done. A second level handler (in C) implements the interrupt priority mechanism and calls the appropriate ISR for each interrupt.
- Peripherals are integrated in a very flexible manner and have their own subsystem. Details about how peripherals are addressed and tied to interrupts is presented in the 'devices' directory.
- The core pipeline can be stalled by external logic, allowing the design to be integrated with a more complex memory system, such as DRAM controllers and caches.

A version of this core (MIPS version, along with 16KB of SRAM and 4KB of ROM for monitor/boot software) was taped out using the TSMC 180nm process. All chips worked perfectly at the specified ASIC project target speed (50MHz). The same design (using the same core and BlockRAMs for RAM/ROM instead) was validated using Xilinx FPGAs. On lower end devices the design operated at 25MHz (Spartan3E device, 38MHz synthesis, 2K LUTs). On more modern devices it operated from 50MHz to 100MHz (Zynq device, 148MHz synthesis, 1.5K LUTs). Synthesis of this design were performed for different ASIC technologies. Using a bulk TSMC180 process (SVT) Fmax is 290 MHz. On STM65 (SVT) Fmax is 1GHz. Using the modern FD-SOI 28nm process (LVT) Fmax is 1.8GHz.

One version of this core (HF-RISCV) implements the RV32I base user level instruction set of the RISC-V architecture. The core organization is basically the same as HF-RISC, including the memory map and software compatibility (a given application just has to be recompiled to the RV32I target). Improvements (compared to HF-RISC) include shorter critical path for higher clock frequency and an exception handling mechanism (traps) for unimplemented opcodes.

Other advantages of this core are related to the ISA, which improves a lot (compared to MIPS) several aspects: better code density (even without the compressed code extensions), more extensible ISA, no delayed load/branches, better immediate fields encoding and nice support for relocatable code. Also, there is no need to tweak the compiler (as done on the HF-RISC) because RV32I is as simple as it gets.


### Compiler support

There are cross compiler build scripts in the tools/mips-toolchain and /tools/riscv-toolchain directories. Compilers generated by these scripts are simple (bare metal) compilers based on GCC.

*MIPS version:
Patched GNU GCC version 4.9.3. Mandatory compiler options (for bare metal) are: -mips1(**) -mpatfree -mfix-r4000 -mno-check-zero-division -msoft-float -fshort-double -ffreestanding -nostdlib -fomit-frame-pointer -G 0 -mnohwmult -mnohwdiv -ffixed-lo -ffixed-hi.

(**) "-mips2 -mno-branch-likely" can be used instead of "-mips1". The result is similar to the code generated with "-mips1", but no useless nops are inserted after loads on data hazards (load delay slots).

*RISC-V version:
Vanilla GNU GCC version 7.1.0. This is a fairly new compiler that fully supports RISC-V as a target machine. Mandatory compiler options are: -march=rv32i -mabi=ilp32 -Wall -O2 -c -ffreestanding -nostdlib -ffixed-s10 -ffixed-s11.

A complete set of flags to be used with the compiler is provided in example applications, along with a small C library and a makefile to build the applications.

### Instruction set

The following instructions from the MIPS I instruction set were implemented in the MIPS version (subset of 41 opcodes):

- Arithmetic Instructions: addiu, addu, subu
- Logic Instructions: and, andi, nor, or, ori, xor, xori
- Shift Instructions: sll, sra, srl, sllv, srav, srlv
- Comparison Instructions: slt, sltu, slti, sltiu
- Load/Store Instructions: lui, lb, lbu, lh, lhu, lw, sb, sh, sw
- Branch Instructions: beq, bne, bgez, bgezal, bgtz, blez, bltzal, bltz
- Jump Instructions: j, jal, jr, jalr

In the RISC-V version all instructions (minus the FENCE instruction) from the RV32I user level base instruction set are supported.

### Memory Map

The memory map is separated into regions.

- ROM / Flash: 0x00000000 - 0x1fffffff (512MB)
- Reserved: 0x20000000 - 0x3fffffff (512MB)
- SRAM: 0x40000000 - 0x5fffffff (512MB)
- External RAM / device: 0x60000000 - 0x9fffffff (1GB)
- External RAM / device: 0xa0000000 - 0xdfffffff (1GB)		(uncached)
- Reserved: 0xe0000000 - 0xe0ffffff (16MB)
- Peripheral (SoC segment 0): 0xe1000000 - 0xe1ffffff (16MB)		(uncached)
- Peripheral (SoC segment 1): 0xe2000000 - 0xe3ffffff (32MB)		(uncached)
- Peripheral (SoC segment 2): 0xe4000000 - 0xe7ffffff (64MB)		(uncached)
- Peripheral (SoC segment 3): 0xe8000000 - 0xefffffff (128MB)		(uncached)
- Peripheral (core): 0xf0000000 - 0xf0ffffff (16MB)		(uncached)
- Reserved: 0xf1000000 - 0xffffffff (240MB)

The core interrupt controller has some register addresses defined below.

- IRQ_VECTOR: 0xf0000000
- IRQ_CAUSE: 0xf0000010
- IRQ_MASK: 0xf0000020
- IRQ_STATUS: 0xf0000030
- IRQ_EPC: 0xf0000040
- EXTIO_IN: 0xf0000080
- EXTIO_OUT: 0xf0000090
- DEBUG: 0xf00000d0

### HF-RISC SoC

Several examples of the HF-RISC SoC are presented for FPGA implementation. A typical platform includes the CPU core (with internal peripherals), memories (RAM), boot ROM and optional external peripherals. The memory map is defined to make it easy for future improvements in the platform, such as large external RAMs, cache controllers and multiprocessor implementations.

Example prototype platforms are available for both HF-RISC and HF-RISCV cores on the 'platform' subdirectories. Different configurations of peripherals are presented on the 'devices/peripherals' and 'devices/controllers' subdirectories. Simulation testbenches and ROM images are available on the 'sim' subdirectories for each core.

### Performance

- HF-RISC: 0.96 CoreMark/MHz
- HF-RISCV: 0.84 CoreMark/MHz*

If a multiplier is used (not included in this design) the score is around 2.1 Coremark/MHz.

*HF-RISCV doesn't include the multiply/divide (M) extension (pure RV32I) and doesn't include dalayed branches as found on MIPS. This sacrifices performance a bit, but simplifies the ISA for deeper pipelines and OOO execution. Based on several experiments, the inclusion of the M module will boost the performance of this core beyond the HF-RISC version, even without branch prediction. 
