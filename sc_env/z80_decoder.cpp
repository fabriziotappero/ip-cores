#include "z80_decoder.h"

char *table_r[] = { "B", "C", "D", "E", "H", "L", "(HL)", "A" };
char *table_cc[] = { "NZ", "Z", "NC", "C", "PO", "PE", "P", "M" };
char *table_rp[] = {"BC", "DE", "HL", "SP" };
char *table_rp2[] = {"BC","DE","HL","AF"};
char *table_alu[] = {"ADD A,","ADC A,","SUB","SBC A,","AND","XOR","OR","CP"};
char *table_im[] = {"0","0/1", "1", "2", "0", "0/1", "1", "2" };

void z80_decoder::op_print ()
{
	printf ("DECODE :[%04x] %s\n", op_addr, op_name);
}

void z80_decoder::decode_unpre()
{
	int x = opcode.range(7,6);
	int y = opcode.range(5,3);
	int z = opcode.range(2,0);
	
	sprintf (op_buf, "Unknown (%02x)", (int) opcode);
	op_name = op_buf;
	
	switch (x) {
		case 0 :
			switch (z) {
				case 0 :
					if (y == 0)
						op_name = "NOP";
					else if (y == 1)
						op_name = "EX AF, AF'";
					else if (y == 2) {
						op_name = "DJNZ %d";
						state = DISP;
					} else if (y == 3) {
						op_name = "JR %d";
						state = DISP;
					} else {
						sprintf (op_buf, "JR %s, %%02x", table_cc[y-4]);
						op_name = op_buf;
						state = IMM1;
					}
					break;
				case 1 :
					if (opcode.bit(3)) {
						sprintf (op_buf, "ADD HL, %s", table_rp[y>>1]);
						op_name = op_buf;
					} else {
						sprintf (op_buf, "LD %s, %%04x", table_rp[y>>1]);
						op_name = op_buf;
						state = IMM2;
					}
					break;
				case 2 :
					switch (y) {
						case 0 : op_name = "LD (BC), A"; break;
						case 1 : op_name = "LD (DE), A"; break;
						case 2 : op_name = "LD (%04x), HL"; state = IMM2; break;
						case 3 : op_name = "LD (%04x), A"; state = IMM2; break;
						case 4 : op_name = "LD A, (BC)"; break;
						case 5 : op_name = "LD A, (DE)"; break;
						case 6 : op_name = "LD HL, (%04x)"; state = IMM2; break;
						case 7 : op_name = "LD A, (%02x)"; state = IMM1; break;
					}
					break;
				case 3 :
					if (opcode.bit(3)) {
						sprintf (op_buf, "DEC %s", table_rp[opcode.range(5,4)]);
						op_name = op_buf;
					} else {
						sprintf (op_buf, "INC %s", table_rp[opcode.range(5,4)]);
						op_name = op_buf;
					}
					break;
				case 4 : 
					sprintf (op_buf, "INC %s", table_r[y]);
					op_name = op_buf;
					break;
				case 5 : 
					sprintf (op_buf, "DEC %s", table_r[y]);
					op_name = op_buf;
					break;
				case 6 : 
					sprintf (op_buf, "LD %s, %%02x", table_r[y]);
					op_name = op_buf;
					state = IMM1;
					break;
				case 7 :
					switch (y) {
						case 0 : op_name = "RLCA"; break;
						case 1 : op_name = "RRCA"; break;
						case 2 : op_name = "RLA"; break;
						case 3 : op_name = "RRA"; break;
						case 4 : op_name = "DAA"; break;
						case 5 : op_name = "CPL"; break;
						case 6 : op_name = "SCF"; break;
						case 7 : op_name = "CCF"; break;
					}
					break;
			}
		break;
		
		case 1 :
		if ((z == 6) && (y == 6)) {
			op_name = "HALT";
		} else {
			sprintf (op_buf, "LD %s, %s", table_r[y], table_r[z]);
			op_name = op_buf;
		}
		break;
		
		case 2 : // ALU
			sprintf (op_buf, "%s %s", table_alu[y], table_r[z]);
			op_name = op_buf;
		break;
		
		case 3 :
			switch (z) {
				case 0 : 
					sprintf (op_buf, "RET %s", table_cc[y]);
					op_name = op_buf;
					break;
				case 1 : // TBD, POP & opcodes
					switch (y) {
						case 0 : case 1: case 2 : case 3 :
						sprintf (op_buf, "POP %s", table_rp2[y>>1]);
						op_name = op_buf;
						break;
						case 4 : op_name = "RET"; break;
						case 5 : op_name = "EXX"; break;
						case 6 : op_name = "JP HL"; break;
						case 7 : op_name = "LD SP, HL"; break;
					}
					break;
				case 2 :
					sprintf (op_buf, "JP %s, %%04x", table_cc[y]);
					op_name = op_buf;
					state = IMM2;
					break;
				case 3 : // JP and opcodes
					switch (y) {
						case 0 : op_name = "JP %04x"; state = IMM2; break;
						case 1 : state = PRE_CB; break;
						case 2 : op_name = "OUT (%02x), A"; state = IMM1; break;
						case 3 : op_name = "IN A, (%02x)"; state = IMM1; break;
						case 4 : op_name = "EX (SP), HL"; break;
						case 5 : op_name = "EX DE, HL"; break;
						case 6 : op_name = "DI"; break;
						case 7 : op_name = "EI"; break;
						
					}
					break;
				case 4 :
					sprintf (op_buf, "CALL %s, %%04x", table_cc[y]);
					op_name = op_buf;
					state = IMM2;
					break;
				case 5 :
					switch (y) {
						case 0 :
						case 1 :
						case 2 :
						case 3 :
							sprintf (op_buf, "PUSH %s", table_rp2[y>>1]);
							op_name = op_buf;
							break;
						case 4 :
							op_name = "CALL %04x";
							state = IMM2;
							op_print();
							break;
						case 5 : state = PRE_DD; break;
						case 6 : state = PRE_ED; break;
						case 7 : state = PRE_FD; break;
					}
					break;
				case 6 :
					sprintf (op_buf, "IM %s", table_im[y]);
					op_name = op_buf;
					break;
				break;
				case 7 :
					switch (y) {
						case 0 : op_name="LD I,A"; break;
						case 1 : op_name="LD R,A"; break;
						case 2 : op_name="LD A,I"; break;
						case 3 : op_name="LD A,R"; break;
						case 4 : op_name="RRD"; break;
						case 5 : op_name="RLD"; break;
						case 6 : op_name="NOP"; break;
						case 7 : op_name="NOP"; break;
					}
				break;
			}
		break;
	}
	/*FOR x=0
z=0 	
	y=0	NOP	y=2	DJNZ d
	y=1	EX AF, AF'	y=3	JR d
			y=4..7	JR cc[y-4], d
	Relative jumps and assorted ops
z=1 	
q=0		LD rp[p], nn
q=1		ADD HL, rp[p]
	16-bit load immediate/add
z=2 	
q=0	p=0	LD (BC), A	p=2	LD (nn), HL
	p=1	LD (DE), A	p=3	LD (nn), A
q=1	p=0	LD A, (BC)	p=2	LD HL, (nn)
	p=1	LD A, (DE)	p=3	LD A, (nn)
	Indirect loading
z=3 	
q=0		INC rp[p]
q=1		DEC rp[p]
	16-bit INC/DEC
z=4 	
		INC r[y]
	8-bit INC
z=5 	
		DEC r[y]
	8-bit DEC
z=6 	
		LD r[y], n
	8-bit load immediate
z=7 	
	y=0	RLCA	y=4	DAA
	y=1	RRCA	y=5	CPL
	y=2	RLA	y=6	SCF
	y=3	RRA	y=7	CCF
	Assorted operations on accumulator/flags
	*/
	
	if (state == UNPRE) {
		//printf ("DECODE : %02x %s\n", (int) opcode, op_name);
		op_print();
	}
}

void z80_decoder::event()
{
	if ((en_decode == false) || !reset_n) return;
	
	if (!m1_n && !mreq_n && !rd_n && wait_n) {
		imm = 0;
		op_addr = (int) addr;
		switch ( (int) di.read() ) {
			case 0xCB : state = PRE_CB; break;
			case 0xDD : state = PRE_DD; break;
			case 0xED : state = PRE_ED; break;
			case 0xFD : state = PRE_FD; break;
			default :
			opcode = di;
			state = UNPRE;
			decode_unpre();
			break;
		}
	} else if (!mreq_n && !rd_n && wait_n && (state != UNPRE)) {
		switch (state) {
			case IMM2 :
				imm = ((unsigned int) di) & 0xff;
				state = IMM2B;
				break;
			case IMM2B :
				imm |= ((unsigned int) di << 8)& 0xFF00;
				sprintf (op_buf, op_name, imm);
				op_name = op_buf;
				op_print();
				break;
			case IMM1 :
				imm = ((unsigned int) di) & 0xff;
				sprintf (op_buf, op_name, imm);
				op_name = op_buf;
				op_print();
				break;
		}
	}			
}
