/* file:          hf_risc_sim.c
 * description:   HF-RISC simulator
 * date:          08/2015
 * author:        Sergio Johann Filho <sergio.filho@pucrs.br>
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdint.h>

#define MEM_SIZE			0x00100000
#define SRAM_BASE			0x40000000
#define EXIT_TRAP			0xe0000000

#define IRQ_VECTOR			0xf0000000
#define IRQ_CAUSE			0xf0000010
#define IRQ_MASK			0xf0000020
#define IRQ_STATUS			0xf0000030
#define IRQ_EPC				0xf0000040
#define EXTIO_IN			0xf0000080
#define EXTIO_OUT			0xf0000090
#define DEBUG_ADDR			0xf00000d0

#define S0CAUSE				0xe1000400

#define TIMERCAUSE			0xe1020400
#define TIMERCAUSE_INV			0xe1020800
#define TIMERMASK			0xe1020c00

#define TIMER0				0xe1024000
#define TIMER1				0xe1024400
#define TIMER1_PRE			0xe1024410
#define TIMER1_CTC			0xe1024420
#define TIMER1_OCR			0xe1024430

#define UARTCAUSE			0xe1030400
#define UARTCAUSE_INV			0xe1030800
#define UARTMASK			0xe1030c00

#define UART0				0xe1034000
#define UART0_DIV			0xe1034010

#define ntohs(A) ( ((A)>>8) | (((A)&0xff)<<8) )
#define htons(A) ntohs(A)
#define ntohl(A) ( ((A)>>24) | (((A)&0xff0000)>>8) | (((A)&0xff00)<<8) | ((A)<<24) )
#define htonl(A) ntohl(A)

typedef struct {
	int32_t r[32];
	int32_t pc, pc_next;
	int32_t hi, lo;
	int8_t *mem;
	int8_t j, nox_bds;
	int32_t vector, cause, mask, status, status_dly[4], epc;
	uint32_t s0cause;
	uint32_t timercause, timercause_inv, timermask;
	uint32_t timer0, timer1, timer1_pre, timer1_ctc, timer1_ocr;
	uint32_t uartcause, uartcause_inv, uartmask;
	uint32_t ins, arith, logic, shift, comp, ls, bra, taken_bra, jmp, mul, div, other;
} state;

int8_t sram[MEM_SIZE];

FILE *fptr;
int32_t log_enabled = 0;

static int32_t mem_read(state *s, int32_t size, uint32_t address){
	uint32_t value=0;
	uint32_t *ptr;

	switch (address){
		case IRQ_VECTOR:	return s->vector;
		case IRQ_CAUSE:		return s->cause;
		case IRQ_MASK:		return s->mask;
		case IRQ_STATUS:	return s->status;
		case IRQ_EPC:		return s->epc;
		case S0CAUSE:		return s->s0cause;
		case TIMERCAUSE:	return s->timercause;
		case TIMERCAUSE_INV:	return s->timercause_inv;
		case TIMERMASK:		return s->timermask;
		case TIMER0:		return s->timer0;
		case TIMER1:		return s->timer1;
		case TIMER1_PRE:	return s->timer1_pre;
		case TIMER1_CTC:	return s->timer1_ctc;
		case TIMER1_OCR:	return s->timer1_ocr;
		case UARTCAUSE:		return s->uartcause;
		case UARTCAUSE_INV:	return s->uartcause_inv;
		case UARTMASK:		return s->uartmask;
		case UART0:		return getchar();
		case UART0_DIV:		return 0;
	}
	if (address >= EXIT_TRAP) return 0;
	
	ptr = (uint32_t *)(s->mem + (address % MEM_SIZE));

	switch(size){
		case 4:
			if(address & 3){
				printf("\nunaligned access (load word) pc=0x%x addr=0x%x", s->pc, address);
				exit(1);
			}else{
				value = *(uint32_t *)ptr;
				value = ntohl(value);
			}
			break;
		case 2:
			if(address & 1){
				printf("\nunaligned access (load halfword) pc=0x%x addr=0x%x", s->pc, address);
				exit(1);
			}else{
				value = *(uint16_t *)ptr;
				value = ntohs((uint16_t)value);
			}
			break;
		case 1:
			value = *(uint8_t *)ptr;
			break;
		default:
			printf("\nerror");
	}

	return(value);
}

static void mem_write(state *s, int32_t size, uint32_t address, uint32_t value){
	uint32_t i;
	uint32_t *ptr;

	switch (address){
		case IRQ_VECTOR:	s->vector = value; return;
		case IRQ_MASK:		s->mask = value; return;
		case IRQ_STATUS:	if (value == 0){ s->status = 0; for (i = 0; i < 4; i++) s->status_dly[i] = 0; }else{ s->status_dly[3] = value; } return;
		case IRQ_EPC:		s->epc = value; return;
		case TIMERCAUSE_INV:	s->timercause_inv = value & 0xff; return;
		case TIMERMASK:		s->timermask = value & 0xff; return;
		case TIMER0:		return;
		case TIMER1:		s->timer1 = value & 0xffff; return;
		case TIMER1_PRE:	s->timer1_pre = value & 0xffff; return;
		case TIMER1_CTC:	s->timer1_ctc = value & 0xffff; return;
		case TIMER1_OCR:	s->timer1_ocr = value & 0xffff; return;
		case UARTCAUSE_INV:	s->uartcause_inv = value & 0xff; return;
		case UARTMASK:		s->uartmask = value & 0xff; return;
		case EXIT_TRAP:
			fflush(stdout);
			if (log_enabled)
				fclose(fptr);
			printf("\nend of simulation.\n");
			printf("instructions: %d\n", s->ins);
			printf("arith: %d (%f)\n", s->arith, (float)s->arith / (float)s->ins);
			printf("logic: %d (%f)\n", s->logic, (float)s->logic / (float)s->ins);
			printf("shift: %d (%f)\n", s->shift, (float)s->shift / (float)s->ins);
			printf("compare: %d (%f)\n", s->logic, (float)s->comp/ (float)s->ins);
			printf("memory: %d (%f)\n", s->ls, (float)s->ls / (float)s->ins);
			printf("branch: %d (%f) (taken: %d, %f)\n", s->bra, (float)s->bra / (float)s->ins, s->taken_bra, (float)s->taken_bra/(float)s->bra);
			printf("jump: %d (%f)\n", s->jmp, (float)s->jmp / (float)s->ins);
			printf("mul: %d (%f)\n", s->mul, (float)s->mul / (float)s->ins);
			printf("div: %d (%f)\n", s->div, (float)s->div / (float)s->ins);
			printf("other: %d (%f)\n", s->other, (float)s->other / (float)s->ins);
			exit(0);
		case DEBUG_ADDR:
			if (log_enabled)
				fprintf(fptr, "%c", (int8_t)(value & 0xff));
			return;
		case UART0:
			fprintf(stdout, "%c", (int8_t)(value & 0xff));
			return;
		case UART0_DIV:
			return;
	}
	if (address >= EXIT_TRAP) return;

	ptr = (uint32_t *)(s->mem + (address % MEM_SIZE));

	switch(size){
		case 4:
			if(address & 3){
				printf("\nunaligned access (store word) pc=0x%x addr=0x%x", s->pc, address);
				exit(1);
			}else{
				value = htonl(value);
				*(int32_t *)ptr = value;
			}
			break;
		case 2:
			if(address & 1){
				printf("\nunaligned access (store halfword) pc=0x%x addr=0x%x", s->pc, address);
				exit(1);
			}else{
				value = htons((uint16_t)value);
				*(int16_t *)ptr = (uint16_t)value;
			}
			break;
		case 1:
			*(int8_t *)ptr = (uint8_t)value;
			break;
		default:
			printf("\nerror");
	}
}

void mult_unsigned(uint32_t a, uint32_t b, uint32_t *hi, uint32_t *lo){
	uint32_t ahi, alo, bhi, blo;
	uint32_t c0, c1, c2;
	uint32_t c1_a, c1_b;

	ahi = a >> 16;
	alo = a & 0xffff;
	bhi = b >> 16;
	blo = b & 0xffff;

	c0 = alo * blo;
	c1_a = ahi * blo;
	c1_b = alo * bhi;
	c2 = ahi * bhi;

	c2 += (c1_a >> 16) + (c1_b >> 16);
	c1 = (c1_a & 0xffff) + (c1_b & 0xffff) + (c0 >> 16);
	c2 += (c1 >> 16);
	c0 = (c1 << 16) + (c0 & 0xffff);
	*hi = c2;
	*lo = c0;
}

void mult_signed(int32_t a, int32_t b, uint32_t *hi, uint32_t *lo){
	uint32_t ahi, alo, bhi, blo;
	uint32_t c0, c1, c2;
	int32_t c1_a, c1_b;

	ahi = a >> 16;
	alo = a & 0xffff;
	bhi = b >> 16;
	blo = b & 0xffff;

	c0 = alo * blo;
	c1_a = ahi * blo;
	c1_b = alo * bhi;
	c2 = ahi * bhi;

	c2 += (c1_a >> 16) + (c1_b >> 16);
	c1 = (c1_a & 0xffff) + (c1_b & 0xffff) + (c0 >> 16);
	c2 += (c1 >> 16);
	c0 = (c1 << 16) + (c0 & 0xffff);
	*hi = c2;
	*lo = c0;
}

void cycle(state *s){
	uint32_t opcode, i;
	uint32_t op, rs, rt, rd, re, func, imm, target;
	int32_t imm_shift, branch=0;
	int32_t *r = s->r;
	uint32_t *u = (uint32_t *)s->r;
	uint32_t ptr;

	if (s->status && (s->cause & s->mask) && (!s->j)){
		s->epc = s->pc + 4;
		s->pc_next = s->vector;
		s->status = 0;
		for (i = 0; i < 4; i++)
			s->status_dly[i] = 0;
		s->nox_bds = 1;
		return;
	}

	opcode = mem_read(s, 4, s->pc);
	op = (opcode >> 26) & 0x3f;
	rs = (opcode >> 21) & 0x1f;
	rt = (opcode >> 16) & 0x1f;
	rd = (opcode >> 11) & 0x1f;
	re = (opcode >> 6) & 0x1f;
	func = opcode & 0x3f;
	imm = opcode & 0xffff;
	imm_shift = (((int32_t)(int16_t)imm) << 2) - 4;
	target = (opcode << 6) >> 4;
	ptr = (int16_t)imm + r[rs];
	r[0] = 0;
	s->pc = s->pc_next;
	s->pc_next = s->pc_next + 4;
	s->status = s->status_dly[0];
	for (i = 0; i < 3; i++)
		s->status_dly[i] = s->status_dly[i+1];
	s->j = 0;
	if (s->nox_bds){
		s->nox_bds = 0;
		return;
	}

	switch (op){
		case 0x00:
			switch (func){
				case 0x00: r[rd]=r[rt]<<re; s->shift++; break;					/*SLL*/
				case 0x02: r[rd]=u[rt]>>re; s->shift++; break;					/*SRL*/
				case 0x03: r[rd]=r[rt]>>re; s->shift++; break;					/*SRA*/
				case 0x04: r[rd]=r[rt]<<r[rs]; s->shift++; break;				/*SLLV*/
				case 0x06: r[rd]=u[rt]>>r[rs]; s->shift++; break;				/*SRLV*/
				case 0x07: r[rd]=r[rt]>>r[rs]; s->shift++; break;				/*SRAV*/
				case 0x08: s->pc_next=r[rs]; s->j = 1; s->jmp++; break;				/*JR*/
				case 0x09: r[rd]=s->pc_next; s->pc_next=r[rs]; s->j = 1; s->jmp++; break;	/*JALR*/
				case 0x10: r[rd]=s->hi; s->other++; break;					/*MFHI*/
				case 0x11: s->hi=r[rs]; s->other++; break;					/*MTHI*/
				case 0x12: r[rd]=s->lo; s->other++; break;					/*MFLO*/
				case 0x13: s->lo=r[rs];	s->other++; break;					/*MTLO*/
				case 0x18: mult_signed(r[rs],r[rt],&s->hi,&s->lo); s->mul++; break;		/*MULT*/
				case 0x19: mult_unsigned(r[rs],r[rt],&s->hi,&s->lo); s->mul++; break;		/*MULTU*/
				case 0x1a:
					if (r[rt] == 0){ s->lo = 0; s->hi = 0; }
					else{ s->lo=r[rs]/r[rt]; s->hi=r[rs]%r[rt]; s->div++; break; }		/*DIV*/
				case 0x1b:
					if (u[rt] == 0){ s->lo = 0; s->hi = 0; }
					else{ s->lo=u[rs]/u[rt]; s->hi=u[rs]%u[rt]; s->div++; break; }		/*DIVU*/
				case 0x21: r[rd]=r[rs]+r[rt]; s->arith++; break;				/*ADDU*/
				case 0x23: r[rd]=r[rs]-r[rt]; s->arith++; break;				/*SUBU*/
				case 0x24: r[rd]=r[rs]&r[rt]; s->logic++; break;				/*AND*/
				case 0x25: r[rd]=r[rs]|r[rt]; s->logic++; break;				/*OR*/
				case 0x26: r[rd]=r[rs]^r[rt]; s->logic++; break;				/*XOR*/
				case 0x27: r[rd]=~(r[rs]|r[rt]); s->logic++; break;				/*NOR*/
				case 0x2a: r[rd]=r[rs]<r[rt]; s->comp++; break;					/*SLT*/
				case 0x2b: r[rd]=u[rs]<u[rt]; s->comp++; break;					/*SLTU*/
				default:
					printf("\ninvalid opcode (pc=0x%x opcode=0x%x)", s->pc - 4, opcode);
			}
			break;
		case 0x01:
			switch (rt){
				case 0x10: r[31]=s->pc_next;							/*BLTZAL*/
				case 0x00: if (r[rs]<0){ branch=r[rs]<0; } s->j = 1; s->bra++; break;		/*BLTZ*/
				case 0x11: r[31]=s->pc_next;							/*BGEZAL*/
				case 0x01: if (r[rs]>=0){ branch=r[rs]>=0; } s->j = 1; s->bra++; break;		/*BGEZ*/
				default:
					printf("\ninvalid opcode (pc=0x%x opcode=0x%x)", s->pc - 4, opcode);
			}
			break;
		case 0x03: r[31]=s->pc_next;									/*JAL*/
		case 0x02: s->pc_next=(s->pc&0xf0000000)|target; s->j = 1; s->jmp++; break;			/*J*/
		case 0x04: if (r[rs]==r[rt]){ branch=r[rs]==r[rt]; } s->j = 1; s->bra++; break;			/*BEQ*/
		case 0x05: if (r[rs]!=r[rt]){ branch=r[rs]!=r[rt]; } s->j = 1; s->bra++; break;			/*BNE*/
		case 0x06: if (r[rs]<=0){ branch=r[rs]<=0; } s->j = 1; s->bra++; break;				/*BLEZ*/
		case 0x07: if (r[rs]>0){ branch=r[rs]>0; } s->j = 1; s->bra++; break;				/*BGTZ*/
		case 0x09: u[rt]=u[rs]+(int16_t)imm; s->arith++; break;						/*ADDIU*/
		case 0x0a: r[rt]=r[rs]<(int16_t)imm; s->comp++; break;						/*SLTI*/
		case 0x0b: u[rt]=u[rs]<(uint32_t)(int16_t)imm; s->comp++; break;				/*SLTIU*/
		case 0x0c: r[rt]=r[rs]&imm; s->logic++; break;							/*ANDI*/
		case 0x0d: r[rt]=r[rs]|imm; s->logic++; break;							/*ORI*/
		case 0x0e: r[rt]=r[rs]^imm; s->logic++; break;							/*XORI*/
		case 0x0f: r[rt]=(imm<<16); s->other++; break;							/*LUI*/
		case 0x20: r[rt]=(int8_t)mem_read(s,1,ptr); s->ls++; break;					/*LB*/
		case 0x21: r[rt]=(int16_t)mem_read(s,2,ptr); s->ls++; break;					/*LH*/
		case 0x23: r[rt]=mem_read(s,4,ptr); s->ls++; break;						/*LW*/
		case 0x24: r[rt]=(uint8_t)mem_read(s,1,ptr); s->ls++; break;					/*LBU*/
		case 0x25: r[rt]=(uint16_t)mem_read(s,2,ptr); s->ls++; break;					/*LHU*/
		case 0x28: mem_write(s,1,ptr,r[rt]); s->ls++; break;						/*SB*/
		case 0x29: mem_write(s,2,ptr,r[rt]); s->ls++; break;						/*SH*/
		case 0x2b: mem_write(s,4,ptr,r[rt]); s->ls++; break;						/*SW*/
		default:
			printf("\ninvalid opcode (pc=0x%x opcode=0x%x)", s->pc - 4, opcode);
	}

	s->pc_next += branch ? imm_shift : 0;
	s->pc_next &= ~3;

	s->ins++;
	if (branch) s->taken_bra++;
	if (s->timer0 & 0x10000) {
		s->timercause |= 0x01;
	} else {
		s->timercause &= 0xfe;
	}
	if (s->timer0 & 0x40000) {
		s->timercause |= 0x02;
	} else {
		s->timercause &= 0xfd;
	}
	if (s->timer1 == s->timer1_ctc) {
		s->timer1 = 0;
		s->timercause ^= 0x4;
	}
	if (s->timer1 < s->timer1_ocr) {
		s->timercause |= 0x8;
	} else {
		s->timercause &= 0xf7;
	}
	s->s0cause = (s->timercause ^ s->timercause_inv) & s->timermask ? 0x04 : 0x00;
	s->cause = s->s0cause ? 0x01 : 0x00;

	s->timer0++;
	switch (s->timer1_pre) {
		case 1:
			if (!(s->timer0 & 3)) s->timer1++;
			break;
		case 2:
			if (!(s->timer0 & 15)) s->timer1++;
			break;
		case 3:
			if (!(s->timer0 & 63)) s->timer1++;
			break;
		case 4:
			if (!(s->timer0 & 255)) s->timer1++;
			break;
		case 5:
			if (!(s->timer0 & 1023)) s->timer1++;
			break;
		case 6:
			if (!(s->timer0 & 4095)) s->timer1++;
			break;
		case 7:
			if (!(s->timer0 & 16383)) s->timer1++;
			break;
		default:
			s->timer1++;
	}
	s->timer1 &= 0xffff;
}

int main(int argc, char *argv[]){
	state context;
	state *s;
	FILE *in;
	int bytes;

	s = &context;
	memset(s, 0, sizeof(state));
	memset(sram, 0xff, sizeof(MEM_SIZE));

	if (argc >= 2){
		in = fopen(argv[1], "rb");
		if (in == 0){
			printf("\nerror opening binary file.\n");
			return 1;
		}
		bytes = fread(&sram, 1, MEM_SIZE, in);
		fclose(in);
		if (bytes == 0){
			printf("\nerror reading binary file.\n");
			return 1;
		}
		if (argc == 3){
			fptr = fopen(argv[2], "wb");
			if (!fptr){
				printf("\nerror reading binary file.\n");
				return 1;
			}
			log_enabled = 1;
		}
	}else{
		printf("\nsyntax: hf_risc_sim [file.bin] [log_file.txt]\n");
		return 1;
	}

	memset(s, 0, sizeof(context));
	s->pc = SRAM_BASE;
	s->pc_next = s->pc + 4;
	s->mem = &sram[0];

	for(;;){
		cycle(s);
	}

	return 0;
}

