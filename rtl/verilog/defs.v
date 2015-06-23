
`default_nettype none 

`define RN_ACCD		4'h0
`define RN_IX		4'h1
`define RN_IY		4'h2
`define RN_U		4'h3
`define RN_S		4'h4
`define RN_PC		4'h5
//`define RN_MEM16   	4'h6
//`define RN_IMM16   	4'h7
`define RN_ACCA		4'h8
`define RN_ACCB		4'h9
`define RN_CC		4'ha
`define RN_DP		4'hb
//`define RN_MEM8		4'hc
//`define	RN_IMM8		4'hd
`define	RN_INV		4'hf


// opcodes that need an ALU result
`define NOP    5'b00000
`define SEXT   5'b00001
`define ST     5'b00010
`define BIT    5'b00011

`define LD     5'b00100 // in logic8
`define AND    5'b00101 // in logic8
`define OR     5'b00110 // in logic8
`define EOR    5'b00111 // in logic8
`define ADD    5'b01000 // in arith8
`define SUB    5'b01001 // in arith8
`define ADC    5'b01010 // in arith8
`define SBC    5'b01011 // in arith8

`define LSR    5'b10000
`define LSL    5'b10001
`define ROR    5'b10010
`define ROL    5'b10011
`define ASR    5'b10100
`define NEG    5'b10101
`define COM    5'b10110
`define INC    5'b11000 // encoding of least 2 bits must be like ADD/SUB
`define DEC    5'b11001
`define DAA    5'b11010  
`define MUL    5'b11011
`define LEA    5'b11100
`define CLR    5'b11101
`define TST    5'b11110

/* Sequencer states */

`define SEQ_COLDRESET 		'h00
`define SEQ_NMI				'h01
`define SEQ_SWI				'h02
`define SEQ_IRQ				'h03
`define SEQ_FIRQ			'h04
`define SEQ_SWI2			'h05
`define SEQ_SWI3			'h06
`define SEQ_UNDEF			'h07
`define SEQ_LOADPC      	'h08
`define SEQ_FETCH 			'h09
`define SEQ_FETCH_1 		'h0a
`define SEQ_FETCH_2 		'h0b
`define SEQ_FETCH_3 		'h0c
`define SEQ_FETCH_4 		'h0d
`define SEQ_FETCH_5 		'h0e

`define SEQ_DECODE 			'h0f
`define SEQ_DECODE_P23		'h10 // x

`define SEQ_GRAL_ALU		'h11 
`define SEQ_GRAL_WBACK		'h12 
`define SEQ_CWAI_STACK		'h13 // stacks registers
`define SEQ_CWAI_WAIT		'h14 // waits for an interrupt
`define SEQ_TFREXG			'h15

`define SEQ_IND_READ_EA		'h16 // offset 8 or 16 bits
`define SEQ_IND_READ_EA_1	'h17
`define SEQ_IND_READ_EA_2	'h18 // real operand from memory indirect
`define SEQ_IND_DECODE		'h19
`define SEQ_IND_DECODE_OFS  'h1a // used to load 8 or 16 bits offset
`define SEQ_JMP_LOAD_PC		'h1b


`define SEQ_JSR_PUSH		'h1c
`define SEQ_JSR_PUSH_L		'h1d // x
`define SEQ_RTS_POP_L		'h1e // x
`define SEQ_RTS_POP_H		'h1f // x

`define SEQ_PREPUSH			'h20
`define SEQ_PREPULL			'h21
`define SEQ_PUSH_WRITE_L	'h22
`define SEQ_PUSH_WRITE_L_1	'h23
`define SEQ_PUSH_WRITE_H	'h24
`define SEQ_PUSH_WRITE_H_1	'h25
`define SEQ_SYNC			'h26

`define SEQ_PC_READ_H		'h30
`define SEQ_PC_READ_H_1		'h31
`define SEQ_PC_READ_H_2		'h32
`define SEQ_PC_READ_L		'h33
`define SEQ_PC_READ_L_1		'h34
`define SEQ_PC_READ_L_2		'h35

`define SEQ_MEM_READ_H		'h36
`define SEQ_MEM_READ_H_1	'h37
`define SEQ_MEM_READ_H_2	'h38
`define SEQ_MEM_READ_L		'h39
`define SEQ_MEM_READ_L_1	'h3a
`define SEQ_MEM_READ_L_2	'h3b
`define SEQ_MEM_WRITE_H		'h3c
`define SEQ_MEM_WRITE_H_1	'h3d
`define SEQ_MEM_WRITE_L		'h3e
`define SEQ_MEM_WRITE_L_1	'h3f

// flags used in MC6809_cpu.v
`define FLAGI regs_o_CCR[5]
`define FLAGF regs_o_CCR[6]
`define FLAGE regs_o_CCR[7]

`define DFLAGC CCR[0]
`define DFLAGV CCR[1]
`define DFLAGZ CCR[2]
`define DFLAGN CCR[3]
// some wires exist only for simulation
`define SIMULATION 1
// Adressing modes
`define NONE 		3'h0
`define IMMEDIATE   3'h1
`define INHERENT	3'h2
`define DIRECT 		3'h3
`define INDEXED		3'h4
`define EXTENDED	3'h5
`define REL8		3'h6
`define REL16		3'h7

// Address size

// memory transfer size, read or written, used for addresses 
`define MSZ_0   2'h0
`define MSZ_8	2'h1
`define MSZ_16	2'h2
// Data transfer size, to save to register, used for data from memory and to save results to memory/registers
`define DSZ_0   2'h0
`define DSZ_8	2'h1
`define DSZ_16	2'h2
/* Memory access type for input/output operands */
`define MT_NONE		3'h0
`define MT_BYTE		3'h1
`define	MT_WORD		3'h2
`define MT_QUAD		3'h3

/* alu decoder right path modifier */
`define MOD_DEFAULT 2'h0
`define MOD_ONE		2'h1
`define MOD_ZERO	2'h2
`define MOD_MINUS1	2'h3
// Memory source address
`define MEMDEST_PC	1'h0
`define MEMDEST_MH	1'h1
