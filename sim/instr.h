/*
 * instr.h -- instruction encoding
 */


#ifndef _INSTR_H_
#define _INSTR_H_


#define FORMAT_N	0	/* no operands */
#define FORMAT_RH	1	/* one register and a half operand */
#define FORMAT_RHH	2	/* one register and a half operand */
				/* ATTENTION: high-order 16 bits encoded */
#define FORMAT_RRH	3	/* two registers and a half operand */
#define FORMAT_RRS	4	/* two registers and a signed half operand */
#define FORMAT_RRR	5	/* three register operands */
#define FORMAT_RRX	6	/* either FORMAT_RRR or FORMAT_RRH */
#define FORMAT_RRY	7	/* either FORMAT_RRR or FORMAT_RRS */
#define FORMAT_RRB	8	/* two registers and a 16 bit signed
				   offset operand */
#define FORMAT_J	9	/* no registers and a 26 bit signed
				   offset operand */
#define FORMAT_JR	10	/* one register operand */


#define MASK(n)		((((Word) 1) << n) - 1)
#define SIGN(n)		(((Word) 1) << (n - 1))
#define ZEXT16(x)	(((Word) (x)) & MASK(16))
#define SEXT16(x)	(((Word) (x)) & SIGN(16) ? \
			 (((Word) (x)) | ~MASK(16)) : \
			 (((Word) (x)) & MASK(16)))
#define SEXT26(x)	(((Word) (x)) & SIGN(26) ? \
			 (((Word) (x)) | ~MASK(26)) : \
			 (((Word) (x)) & MASK(26)))


#define OP_ADD		0x00
#define OP_ADDI		0x01
#define OP_SUB		0x02
#define OP_SUBI		0x03

#define OP_MUL		0x04
#define OP_MULI		0x05
#define OP_MULU		0x06
#define OP_MULUI	0x07
#define OP_DIV		0x08
#define OP_DIVI		0x09
#define OP_DIVU		0x0A
#define OP_DIVUI	0x0B
#define OP_REM		0x0C
#define OP_REMI		0x0D
#define OP_REMU		0x0E
#define OP_REMUI	0x0F

#define OP_AND		0x10
#define OP_ANDI		0x11
#define OP_OR		0x12
#define OP_ORI		0x13
#define OP_XOR		0x14
#define OP_XORI		0x15
#define OP_XNOR		0x16
#define OP_XNORI	0x17

#define OP_SLL		0x18
#define OP_SLLI		0x19
#define OP_SLR		0x1A
#define OP_SLRI		0x1B
#define OP_SAR		0x1C
#define OP_SARI		0x1D

#define OP_LDHI		0x1F

#define OP_BEQ		0x20
#define OP_BNE		0x21
#define OP_BLE		0x22
#define OP_BLEU		0x23
#define OP_BLT		0x24
#define OP_BLTU		0x25
#define OP_BGE		0x26
#define OP_BGEU		0x27
#define OP_BGT		0x28
#define OP_BGTU		0x29

#define OP_J		0x2A
#define OP_JR		0x2B
#define OP_JAL		0x2C
#define OP_JALR		0x2D

#define OP_TRAP		0x2E
#define OP_RFX		0x2F

#define OP_LDW		0x30
#define OP_LDH		0x31
#define OP_LDHU		0x32
#define OP_LDB		0x33
#define OP_LDBU		0x34

#define OP_STW		0x35
#define OP_STH		0x36
#define OP_STB		0x37

#define OP_MVFS		0x38
#define OP_MVTS		0x39
#define OP_TBS		0x3A
#define OP_TBWR		0x3B
#define OP_TBRI		0x3C
#define OP_TBWI		0x3D


typedef struct {
  char *name;
  int format;
  Byte opcode;
} Instr;


extern Instr instrTbl[];
extern Instr *instrCodeTbl[];


void initInstrTable(void);
Instr *lookupInstr(char *name);


#endif /* _INSTR_H_ */
