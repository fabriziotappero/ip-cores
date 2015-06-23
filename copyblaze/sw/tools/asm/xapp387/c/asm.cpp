/*******************************************************
assembler for picoblaze microcontroller

  v1.0 - developement started 8/5/2002
       - predefined instructions are identical with picoblaze VHDL code
	   - this program parse the assembly code and generates

	   - .bin file, program word in hex format
	   - .fmt file, formated assembly file
	   - .mcs file, intel mcs-86 format file for programming
	   - .vhd file, rom vhdl module for simulation
	   - .log file, program report

*******************************************************/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <math.h>
#include <time.h>

/* declare all instructions */
/* same as picoblaze VHDL code */

/* program control group */
char *jump_id = "11010";
char *call_id = "11011";
char *return_id = "10010";

/* logical group */
char *load_k_to_x_id = "00000";
char *load_y_to_x_id = "01000";
char *and_k_to_x_id = "00001";
char *and_y_to_x_id = "01001";
char *or_k_to_x_id = "00010";
char *or_y_to_x_id = "01010";
char *xor_k_to_x_id = "00011";
char *xor_y_to_x_id = "01011";

/* arithmetic group */
char *add_k_to_x_id = "00100";
char *add_y_to_x_id = "01100";
char *addcy_k_to_x_id = "00101";
char *addcy_y_to_x_id = "01101";
char *sub_k_to_x_id = "00110";
char *sub_y_to_x_id = "01110";
char *subcy_k_to_x_id = "00111";
char *subcy_y_to_x_id = "01111";

/* shift and rotate */
char *shift_rotate_id = "10100";
/* shift decoding
instruction(3) - shift left/right
bit2 bit1 bit0
1    1    0    - SR0/SL0; 6
1    1    1    - SR1/Sl1; 7
0    1    0    - SRX/SLX; 2
0    0    0    - SRA/SLA; 0
1    0    0    - RR /RL ; 4
*/
#define SR0_SL0 6
#define SR1_SL1 7
#define SRX_SLX 2
#define SRA_SLA 0
#define RR_RL 4
#define SHIFT_RIGHT 8
#define SHIFT_LEFT 0

/* flip */ /* added new instruction */
char *flip_id = "11111";


/* input/output group */
char *input_p_to_x_id = "10000";
char *input_y_to_x_id = "11000";
char *output_p_to_x_id = "10001";
char *output_y_to_x_id = "11001";

/* interrupt group */

char *interrupt_id = "11110";
char *returni_id = "10110";

/* flag */
char *zero_id = "00";
char *not_zero_id = "01";
char *carry_id = "10";
char *not_carry_id = "11";

#define MAX_LINE_COUNT 1000 /* max 1000 lines allowed */
#define PROGRAM_COUNT 256	/* total program word */

/* increase instruction_count for added new instruction */
#define instruction_count 30/* total instruction set */

#define CONSTANT_COUNT 100	/* max 100 constant can be declared */
#define REG_COUNT 8			/* max 8 namereg can be declared */


char filename[200];
FILE *ifp;
FILE *ofp;
FILE *ffp;

char linebuf[200];
int line_count = 0;
int constant_count = 0;
int reg_count = 0;
unsigned program_word[PROGRAM_COUNT]; /* program word array */

typedef struct reg {
	char *name;
	int value;
}reg_t;

reg_t reg_set[REG_COUNT]; /* namereg array */

typedef struct constant {
	char *name;
	int value;
}constant_t;

constant_t constant_set[CONSTANT_COUNT]; /* constant array */

typedef struct opcode {
	unsigned int address;
	char *label;
	char *instruction;
	char *op1;
	char *op2;
	char *comment;
}opcode_t;

opcode op[MAX_LINE_COUNT]; /* operaton array to save info for each line */

char *instruction_set[] = {
	"JUMP",		/* 0 */
	"CALL",		/* 1 */
	"RETURN",	/* 2 */
	"LOAD",		/* 3 */
	"AND",		/* 4 */
	"OR",		/* 5 */
	"XOR",		/* 6 */
	"ADD",		/* 7 */
	"ADDCY",	/* 8 */
	"SUB",		/* 9 */
	"SUBCY",	/* 10 */
	"SR0",		/* 11 */
	"SR1",		/* 12 */
	"SRX",		/* 13 */
	"SRA",		/* 14 */
	"RR",		/* 15 */
	"SL0",		/* 16 */
	"SL1",		/* 17 */
	"SLX",		/* 18 */
	"SLA",		/* 19 */
	"RL",		/* 20 */
	"INPUT",	/* 21 */
	"OUTPUT",	/* 22 */
	"RETURNI",	/* 23 */
	"ENABLE",	/* 24 */
	"DISABLE",  /* 25 */
	"CONSTANT",	/* 26 */
	"NAMEREG",	/* 27 */
	"ADDRESS",	/* 28 */
	"FLIP"};	/* 29 */ /* added new instruction */

int error = 0;
/*====================================== */
void free_mem(void)
{
	int i;

	for(i = 0; i < line_count; i++){
		if(op[i].comment != NULL) free(op[i].comment);
		if(op[i].label != NULL) free(op[i].label);
		if(op[i].instruction != NULL) free(op[i].instruction);
		if(op[i].op1 != NULL) free(op[i].op1);
		if(op[i].op2 != NULL) free(op[i].op2);
	}
}

/*====================================== */
void init_program_word(void)
{
	int i;

	for(i = 0; i < PROGRAM_COUNT; i++)
		program_word[i] = 0;
}

/*====================================== */
void error_out(void)
{
	free_mem();
	exit(1);
}

/*====================================== */
/* convert hex string to int, return -1 if not valid */
int htoi(char *s)
{
	int i, l, n = 0;
	char *p;

	l = strlen(s);
	for(i = 0; i < l; i++){
		p = s+l-1-i;
		if(isdigit(*p) || (*p >= 'A' && *p <= 'F')){
			if(isdigit(*p)) n += (*p - '0') * (int) pow(16 , i);
			else n += (*p - 'A' + 10) * (int) pow(16 , i);
		} else return (-1);
	}
	return(n);
}

/*====================================== */
/* Only S0 - S7 are valid */
int register_number(char *s)
{
	if(*s != 'S') return( -1 );
	if(strlen(s) != 2) return( -1 );
	if((*(s+1) >= '0') && (*(s+1) <= '7'))
		return (*(s+1) - '0');
	else return( -1 );
}

/*====================================== */
void insert_instruction(char *s, int p)
{
	int i, l;
	unsigned n = 0;

	l = strlen(s);
	for(i = 0; i < l; i++)
		if(*(s+i) == '1')
			n = n + (unsigned) pow(2, (l-i-1));

	program_word[p] = program_word[p] | (n << 11);
}

/*====================================== */
void insert_sXX(int c, int p)
{
	program_word[p] = program_word[p] | (unsigned) (c << 8);
}

/*====================================== */
void insert_sYY(int c, int p)
{
	program_word[p] = program_word[p] | (unsigned) (c << 5);
}

/*====================================== */
void insert_constant(int c, int p)
{
	program_word[p] = program_word[p] | (unsigned) (c);
}

/*====================================== */
void insert_flag(int c, int p)
{
	program_word[p] = program_word[p] | (unsigned) (c << 8);
}

/*====================================== */
int decode_flag(char *s)
{
	if(!strcmp(s, "Z")) return (4);
	else if (!strcmp(s, "NZ")) return (5);
	else if (!strcmp(s, "C")) return (6);
	else if (!strcmp(s, "NC")) return (7);
	else return (-1);
}

/*====================================== */
int find_constant(char *s)
{
	int i;

	for(i = 0; i < constant_count; i++)
		if(!strcmp(s, constant_set[i].name))
			return(constant_set[i].value);
	return(-1);
}

/*====================================== */
int find_label(char *s)
{
	int i;

	for(i = 0; i < line_count; i++)
		if(op[i].label != NULL)
			if(!strcmp(s, op[i].label))
				return(op[i].address);
	return(-1);
}
/*====================================== */
int find_namereg(char *s)
{
	int i;

	for(i = 0; i < reg_count; i++)
		if(!strcmp(s, reg_set[i].name))
			return(reg_set[i].value);
	return(-1);
}

/*====================================== */
int parse_linebuf(void)
{
	char *ptr;
	char seps[]   = " :;,\t\n";
    char *token;

	/* get comment */
	if( (ptr = strchr(linebuf, ';')) != NULL ){
		op[line_count].comment = strdup(ptr);
		*ptr = '\0';
		op[line_count].comment[strlen(op[line_count].comment)-1] = '\0';
	}

	/* get label */
	if( (ptr = strchr(linebuf, ':')) != NULL ){
		token = strtok( linebuf, seps );
		op[line_count].label = strdup(token);
		strupr(op[line_count].label);
	}

	/* get instruction */
	if (ptr == NULL)
		token = strtok( linebuf, seps );
	else token = strtok( NULL, seps);
	if (token != NULL){
		op[line_count].instruction = strdup(token);
		strupr(op[line_count].instruction);
	} else return (0);

	/* get op1 */
	token = strtok( NULL, seps);
	if (token != NULL){
		op[line_count].op1 = strdup(token);
		strupr(op[line_count].op1);
	} else return (0);

	/* get op2 */
	token = strtok( NULL, seps);
	if (token != NULL){
		op[line_count].op2 = strdup(token);
		strupr(op[line_count].op2);
	} else return (0);

	/* make sure nothing left */
	token = strtok( NULL, seps);
	if (token != NULL){
		printf("\nToo many operands in line %d\n", line_count+1);
		fprintf(ofp,"\nToo many operands in line %d\n", line_count+1);
		error++;
	}
	return (0);
}

/*====================================== */
/* syntax test and assign addresses */
void test_instructions(void)
{
	int i, j, k;
	int address = 0;

	for(i = 0; i < line_count; i++){
		if(op[i].instruction != NULL){
			for(j = 0; j < instruction_count; j++)
				if(!stricmp(op[i].instruction, instruction_set[j]))
					break;
			if(j >= instruction_count){
				printf("Unknown instruction - %s found on line %d\n",op[i].instruction, i+1);
				fprintf(ofp,"Unknown instruction - %s found on line %d\n",op[i].instruction, i+1);
				error++;
			}
			switch (j)
			{
				case 0: /* JUMP */
				case 1: /* CALL */
					if(op[i].op2 != NULL){
						if(decode_flag(op[i].op1) == -1){
							printf("ERROR - Invalid operand %s on line %d\n", op[i].op1, i+1);
							fprintf(ofp,"ERROR - Invalid operand %s on line %d\n", op[i].op1, i+1);
							error++;
						}
					} else if(op[i].op1 == NULL){
						printf("ERROR - Missing operand for %s on line %d\n",op[i].instruction, i+1);
						fprintf(ofp,"ERROR - Missing operand for %s on line %d\n",op[i].instruction, i+1);
						error++;
					}
					break;
				case 2: /* RETURN */
					if(op[i].op2 != NULL){
						printf("ERROR - Too many Operands for %s\n on line %d", op[i].instruction, i+1);
						fprintf(ofp,"ERROR - Too many Operands for %s\n on line %d", op[i].instruction, i+1);
						error++;
					} else if (op[i].op1 != NULL){
						if(decode_flag(op[i].op1) == -1){
							printf("ERROR - Invalid operand %s on line %d\n", op[i].op1, i+1);
							fprintf(ofp,"ERROR - Invalid operand %s on line %d\n", op[i].op1, i+1);
							error++;
						}
					}
					break;
				case 3: /* LOAD */
				case 4: /* AND */
				case 5: /* OR */
				case 6: /* XOR */
				case 7: /* ADD */
				case 8: /* ADDCY */
				case 9: /* SUB */
				case 10: /* SUBCY */
					if((op[i].op1 == NULL) || (op[i].op2 == NULL)){
						printf("ERROR - Missing operand for %s on line %d\n",op[i].instruction, i+1);
						fprintf(ofp,"ERROR - Missing operand for %s on line %d\n",op[i].instruction, i+1);
						error++;
					}
					break;
				case 11: /* SR0 */
				case 12: /* SR1 */
				case 13: /* SRX */
				case 14: /* SRA */
				case 15: /* RR */
				case 16: /* SL0 */
				case 17: /* SL1 */
				case 18: /* SLX */
				case 19: /* SLA */
				case 20: /* RL */
				case 29: /* FLIP */ /* added new instruction, same syntax with shift/rotate */
					if(op[i].op2 != NULL){
						printf("ERROR - Too many Operands for %s on line %d\n", op[i].instruction, i+1);
						fprintf(ofp,"ERROR - Too many Operands for %s on line %d\n", op[i].instruction, i+1);
						error++;
					} else if(op[i].op1 == NULL){
						printf("ERROR - Missing operand for %s on line %d\n", op[i].instruction, i+1);
						fprintf(ofp,"ERROR - Missing operand for %s on line %d\n", op[i].instruction, i+1);
						error++;
					}
					break;
				case 21: /* INPUT */
				case 22: /* OUTPUT */
					if((op[i].op1 == NULL) || (op[i].op2 == NULL)){
						printf("ERROR - Missing operand for %s on line %d\n",op[i].instruction, i+1);
						fprintf(ofp,"ERROR - Missing operand for %s on line %d\n",op[i].instruction, i+1);
						error++;
					}					break;
				case 23: /* RETURNI */
					if(op[i].op2 != NULL){
						printf("ERROR - Too many Operands for RETURNI on line %d\n", i+1);
						fprintf(ofp,"ERROR - Too many Operands for RETURNI on line %d\n", i+1);
						error++;
					} else if(op[i].op1 == NULL){
						printf("ERROR - Missing operand for RETURNI on line %d\n", i+1);
						fprintf(ofp,"ERROR - Missing operand for RETURNI on line %d\n", i+1);
						error++;
					} else if(strcmp(op[i].op1,"ENABLE") && strcmp(op[i].op1,"DISABLE")){
						printf("ERROR - Invalid operand on line %d, only ENABLE/DISABLE allowed\n", i+1);
						fprintf(ofp,"ERROR - Invalid operand on line %d, only ENABLE/DISABLE allowed\n", i+1);
						error++;
					}
					break;
				case 24: /* ENABLE */
				case 25: /* DISABLE */
					if(op[i].op2 != NULL){
						printf("ERROR - Too many Operands for ENABLE/DISABLE on line %d\n", i+1);
						fprintf(ofp,"ERROR - Too many Operands for ENABLE/DISABLE on line %d\n", i+1);
						error++;
					} else if(op[i].op1 == NULL){
						printf("ERROR - Missing operand for %s on line %d\n", op[i].instruction, i+1);
						fprintf(ofp,"ERROR - Missing operand for %s on line %d\n", op[i].instruction, i+1);
						error++;
					} else if(strcmp(op[i].op1,"INTERRUPT")){
						printf("ERROR - Invalid operand on line %d, only INTERRUPT allowed\n", i+1);
						fprintf(ofp,"ERROR - Invalid operand on line %d, only INTERRUPT allowed\n", i+1);
						error++;
					}
					break;
				case 26: /* CONSTANT */
					if((op[i].op1 == NULL) || (op[i].op2 == NULL)){
						printf("ERROR - Missing operand for CONSTANT on line %d\n", i+1);
						fprintf(ofp,"ERROR - Missing operand for CONSTANT on line %d\n", i+1);
						error++;
					} else if(htoi(op[i].op1) != -1) {
						printf("ERROR - Invalid operand %s for CONSTANT on line %d\n", op[i].op1, i+1);
						fprintf(ofp,"ERROR - Invalid operand %s for CONSTANT on line %d\n", op[i].op1, i+1);
						error++;
					} else if(htoi(op[i].op2) == -1){
						printf("ERROR - Invalid operand %s for CONSTANT on line %d\n", op[i].op2, i+1);
						fprintf(ofp,"ERROR - Invalid operand %s for CONSTANT on line %d\n", op[i].op2, i+1);
						error++;
					} else {
						if(constant_count >= CONSTANT_COUNT){
							printf("ERROR - Too many CONSTANT declared\n");
							fprintf(ofp,"ERROR - Too many CONSTANT declared\n");
							error++;
						}
						for(k = 0; k < constant_count; k++)
							if(!strcmp(constant_set[k].name, op[i].op1)){
								printf("ERROR - Duplicate CONSTANT name %s found\n", op[i].op1);
								fprintf(ofp,"ERROR - Duplicate CONSTANT name %s found\n", op[i].op1);
								error++;
							}
						constant_set[constant_count].name = op[i].op1;
						constant_set[constant_count].value = htoi(op[i].op2);
						if(constant_set[constant_count].value >= PROGRAM_COUNT){
							printf("ERROR - Invalid operand %s for CONSTANT on line %d\n", op[i].op2, i+1);
							fprintf(ofp,"ERROR - Invalid operand %s for CONSTANT on line %d\n", op[i].op2, i+1);
							error++;
						}
						constant_count++;
					}
					break;
				case 27: /* NAMEREG */
					if((op[i].op1 == NULL) || (op[i].op2 == NULL)){
						printf("ERROR - Missing operand for NAMEREG on line %d\n", i+1);
						fprintf(ofp,"ERROR - Missing operand for NAMEREG on line %d\n", i+1);
						error++;
					} else if(htoi(op[i].op2) != -1){
						printf("ERROR - Invalid operand %s for NAMEREG on line %d\n", op[i].op2, i+1);
						fprintf(ofp,"ERROR - Invalid operand %s for NAMEREG on line %d\n", op[i].op2, i+1);
						error++;
					} else if(register_number(op[i].op1) == -1){
						printf("ERROR - Invalid operand %s for NAMEREG on line %d\n", op[i].op1, i+1);
						fprintf(ofp,"ERROR - Invalid operand %s for NAMEREG on line %d\n", op[i].op1, i+1);
						error++;
					} else {
						if(reg_count >= REG_COUNT){
							printf("ERROR - Too many NAMEREG declared\n");
							fprintf(ofp,"ERROR - Too many NAMEREG declared\n");
							error++;
						}
						for(k = 0; k < reg_count; k++)
							if(!strcmp(reg_set[k].name, op[i].op2)){
								printf("ERROR - Duplicate NAMEREG name %s found\n", op[i].op2);
								fprintf(ofp,"ERROR - Duplicate NAMEREG name %s found\n", op[i].op2);
								error++;
							}
						reg_set[reg_count].name = op[i].op2;
						reg_set[reg_count].value = register_number(op[i].op1);
						reg_count++;
					}
					break;
				case 28: /* ADDRESS */
					//assign op1 to address
					if(op[i].op2 != NULL){
						printf("ERROR - Too many Operands for ADDRESS directive on line %d\n", i+1);
						fprintf(ofp,"ERROR - Too many Operands for ADDRESS directive on line %d\n", i+1);
						error++;
					} else if(op[i].op1 == NULL){
						printf("ERROR - Missing operand for ADDRESS directive on line %d\n", i+1);
						fprintf(ofp,"ERROR - Missing operand for ADDRESS directive on line %d\n", i+1);
						error++;
					} else {
						address = htoi(op[i].op1);
						if((address == -1) || (address >= PROGRAM_COUNT)){
							printf("ERROR - Invalid ADDRESS directive on line %d\n", i+1);
							fprintf(ofp,"ERROR - Invalid ADDRESS directive on line %d\n", i+1);
							error++;
						}
					}
					break;
			}
			op[i].address = address;
			/* add (j > 28) for FLIP instruction, - added new instruction */
			if((j < 26) ||(j > 28)) address ++;
		} else op[i].address = address; /* This is a comment line*/
	}
}

/*====================================== */
/* parse instructions and write program word */
void write_program_word(void)
{
	int i, j, reg_n;
	char *kptr, *sptr;

	for(i = 0; i < line_count; i++){
		if(op[i].instruction != NULL){
			for(j = 0; j < instruction_count; j++)
				if(!stricmp(op[i].instruction, instruction_set[j]))
					break;
			switch (j)
			{
				case 0: /* JUMP */
				case 1: /* CALL */
					if(j == 0)
						kptr = jump_id;
					else
						kptr = call_id;
					insert_instruction(kptr, op[i].address);
					if(op[i].op2 == NULL){
						if((reg_n = find_label(op[i].op1)) != -1){
							insert_constant(reg_n, op[i].address);
						} else if((reg_n = find_constant(op[i].op1)) != -1){
							insert_constant(reg_n, op[i].address);
						} else if(((reg_n = htoi(op[i].op1)) != -1) && (reg_n < PROGRAM_COUNT)){
							insert_constant(reg_n, op[i].address);
						} else {
							printf("ERROR - Invalid operand %s on line %d\n",op[i].op1, i+1);
							fprintf(ofp,"ERROR - Invalid operand %s on line %d\n",op[i].op1, i+1);
							error++;
						}
					} else {
						if(op[i].op1 != NULL){
							reg_n = decode_flag(op[i].op1);
							insert_flag(reg_n, op[i].address);
						}
						if((reg_n = find_label(op[i].op2)) != -1){
							insert_constant(reg_n, op[i].address);
						} else if((reg_n = find_constant(op[i].op2)) != -1){
							insert_constant(reg_n, op[i].address);
						} else if(((reg_n = htoi(op[i].op2)) != -1) && (reg_n < PROGRAM_COUNT)){
							insert_constant(reg_n, op[i].address);
						} else {
							printf("ERROR - Invalid operand %s on line %d\n",op[i].op2, i+1);
							fprintf(ofp,"ERROR - Invalid operand %s on line %d\n",op[i].op2, i+1);
							error++;
						}
					}
					break;
				case 2: /* RETURN */
					insert_instruction(return_id,op[i].address);
					if(op[i].op1 != NULL){
						reg_n = decode_flag(op[i].op1);
						insert_flag(reg_n, op[i].address);
					}
					break;
				case 3: /* LOAD */
				case 4: /* AND */
				case 5: /* OR */
				case 6: /* XOR */
				case 7: /* ADD */
				case 8: /* ADDCY */
				case 9: /* SUB */
				case 10: /* SUBCY */
					if(j == 3){ kptr = load_k_to_x_id; sptr = load_y_to_x_id;}
					if(j == 4){ kptr = and_k_to_x_id; sptr = and_y_to_x_id;}
					if(j == 5){ kptr = or_k_to_x_id; sptr = or_y_to_x_id;}
					if(j == 6){ kptr = xor_k_to_x_id; sptr = xor_y_to_x_id;}
					if(j == 7){ kptr = add_k_to_x_id; sptr = add_y_to_x_id;}
					if(j == 8){ kptr = addcy_k_to_x_id; sptr = addcy_y_to_x_id;}
					if(j == 9){ kptr = sub_k_to_x_id; sptr = sub_y_to_x_id;}
					if(j == 10){ kptr = subcy_k_to_x_id; sptr = subcy_y_to_x_id;}
					if((reg_n = find_namereg(op[i].op1)) != -1)
						insert_sXX(reg_n, op[i].address);
					else if((reg_n = register_number(op[i].op1)) != -1)
						insert_sXX(reg_n, op[i].address);
					else {
						printf("ERROR - Invalid operand %s on line %d\n",op[i].op1, i+1);
						fprintf(ofp,"ERROR - Invalid operand %s on line %d\n",op[i].op1, i+1);
						error++;
					}
					if((reg_n = find_constant(op[i].op2)) != -1){
						insert_constant(reg_n, op[i].address);
						insert_instruction(kptr,op[i].address);
					} else if((reg_n = find_namereg(op[i].op2)) != -1){
						insert_sYY(reg_n, op[i].address);
						insert_instruction(sptr,op[i].address);
					} else if((reg_n = register_number(op[i].op2)) != -1){
						insert_sYY(reg_n, op[i].address);
						insert_instruction(sptr,op[i].address);
					} else if(((reg_n = htoi(op[i].op2)) != -1) && (reg_n < PROGRAM_COUNT)){
						insert_constant(reg_n, op[i].address);
						insert_instruction(kptr,op[i].address);
					} else {
						printf("ERROR - Invalid operand %s on line %d\n",op[i].op2, i+1);
						fprintf(ofp,"ERROR - Invalid operand %s on line %d\n",op[i].op2, i+1);
						error++;
					}
					break;
				case 11: /* SR0 */
				case 12: /* SR1 */
				case 13: /* SRX */
				case 14: /* SRA */
				case 15: /* RR */
				case 16: /* SL0 */
				case 17: /* SL1 */
				case 18: /* SLX */
				case 19: /* SLA */
				case 20: /* RL */
					insert_instruction(shift_rotate_id,op[i].address);
					if((reg_n = find_namereg(op[i].op1)) != -1)
						insert_sXX(reg_n, op[i].address);
					else if((reg_n = register_number(op[i].op1)) != -1)
						insert_sXX(reg_n, op[i].address);
					else {
						printf("ERROR - Invalid operand %s on line %d\n",op[i].op1, i+1);
						fprintf(ofp,"ERROR - Invalid operand %s on line %d\n",op[i].op1, i+1);
						error++;
					}
					if((j >= 11) && (j <= 15)) reg_n = SHIFT_RIGHT;
					else reg_n = SHIFT_LEFT;
					if((j == 11) || (j == 16)) reg_n = reg_n + SR0_SL0;
					else if((j == 12) || (j == 17)) reg_n = reg_n + SR1_SL1;
					else if((j == 13) || (j == 18)) reg_n = reg_n + SRX_SLX;
					else if((j == 14) || (j == 19)) reg_n = reg_n + SRA_SLA;
					else if((j == 15) || (j == 20)) reg_n = reg_n + RR_RL;
					insert_constant(reg_n, op[i].address);
					break;
				case 21: /* INPUT */
					if((reg_n = find_namereg(op[i].op1)) != -1)
						insert_sXX(reg_n, op[i].address);
					else if((reg_n = register_number(op[i].op1)) != -1)
						insert_sXX(reg_n, op[i].address);
					else {
						printf("ERROR - Invalid operand %s on line %d\n",op[i].op1, i+1);
						fprintf(ofp,"ERROR - Invalid operand %s on line %d\n",op[i].op1, i+1);
						error++;
					}
					if((reg_n = find_constant(op[i].op2)) != -1){
						insert_constant(reg_n, op[i].address);
						insert_instruction(input_p_to_x_id,op[i].address);
					} else if((reg_n = find_namereg(op[i].op2)) != -1){
						insert_sYY(reg_n, op[i].address);
						insert_instruction(input_y_to_x_id,op[i].address);
					} else if((reg_n = register_number(op[i].op2)) != -1){
						insert_sYY(reg_n, op[i].address);
						insert_instruction(input_y_to_x_id,op[i].address);
					} else if(((reg_n = htoi(op[i].op2)) != -1) && (reg_n < PROGRAM_COUNT)){
						insert_constant(reg_n, op[i].address);
						insert_instruction(input_p_to_x_id,op[i].address);
					} else {
						printf("ERROR - Invalid operand %s on line %d\n",op[i].op2, i+1);
						fprintf(ofp,"ERROR - Invalid operand %s on line %d\n",op[i].op2, i+1);
						error++;
					}
					break;
				case 22: /* OUTPUT */
					if((reg_n = find_namereg(op[i].op1)) != -1)
						insert_sXX(reg_n, op[i].address);
					else if((reg_n = register_number(op[i].op1)) != -1)
						insert_sXX(reg_n, op[i].address);
					else {
						printf("ERROR - Invalid operand %s on line %d\n",op[i].op1, i+1);
						fprintf(ofp,"ERROR - Invalid operand %s on line %d\n",op[i].op1, i+1);
						error++;
					}
					if((reg_n = find_constant(op[i].op2)) != -1){
						insert_constant(reg_n, op[i].address);
						insert_instruction(output_p_to_x_id,op[i].address);
					} else if((reg_n = find_namereg(op[i].op2)) != -1){
						insert_sYY(reg_n, op[i].address);
						insert_instruction(output_y_to_x_id,op[i].address);
					} else if((reg_n = register_number(op[i].op2)) != -1){
						insert_sYY(reg_n, op[i].address);
						insert_instruction(output_y_to_x_id,op[i].address);
					} else if(((reg_n = htoi(op[i].op2)) != -1) && (reg_n < PROGRAM_COUNT)){
						insert_constant(reg_n, op[i].address);
						insert_instruction(output_p_to_x_id,op[i].address);
					} else {
						printf("ERROR - Invalid operand %s on line %d\n",op[i].op2, i+1);
						fprintf(ofp,"ERROR - Invalid operand %s on line %d\n",op[i].op2, i+1);
						error++;
					}
					break;
				case 23: /* RETURNI */
					insert_instruction(returni_id, op[i].address);
					if(!strcmp(op[i].op1, "ENABLE"))
						program_word[op[i].address]++;
					break;
				case 24: /* ENABLE */
				case 25: /* DISABLE */
					insert_instruction(interrupt_id, op[i].address);
					if(j == 24) /* ENABLE */
						program_word[op[i].address]++;
					break;
				case 26: /* CONSTANT */
				case 27: /* NAMEREG */
				case 28: /* ADDRESS */
					break;
				case 29: /* FLIP */ /* added new instruction */
					insert_instruction(flip_id, op[i].address);
					if((reg_n = find_namereg(op[i].op1)) != -1)
						insert_sXX(reg_n, op[i].address);
					else if((reg_n = register_number(op[i].op1)) != -1)
						insert_sXX(reg_n, op[i].address);
					else {
						printf("ERROR - Invalid operand %s on line %d\n",op[i].op1, i+1);
						fprintf(ofp,"ERROR - Invalid operand %s on line %d\n",op[i].op1, i+1);
						error++;
					}
					break;
			}
		}
	}
}
/*====================================== */
void write_fmt(void)
{
	char *ptr;
	int i;

	ptr = strstr(filename, ".log");
	*ptr = '\0';
	strcat(filename,".fmt");

	ffp = fopen(filename, "w");
	if (ffp == NULL){
        printf("\nCan not open fmt file\n");
		fprintf(ofp,"\nCan not open fmt file\n");
		error_out();
	}

	for(i = 0; i < line_count; i++){
		fprintf(ffp, "%3d %3X ", i+1,op[i].address);
		if(op[i].label != NULL)
			fprintf(ffp, "%-12s ", op[i].label);
		else fprintf(ffp, "%-12s ","");
		if(op[i].instruction != NULL)
			fprintf(ffp, ":%-10s ", op[i].instruction);
		if(op[i].op1 != NULL)
			fprintf(ffp, "%-12s ", op[i].op1);
		if(op[i].op2 != NULL)
			fprintf(ffp, "%-12s ", op[i].op2);
		if(op[i].comment != NULL)
			fprintf(ffp, "%s", op[i].comment);
		fprintf(ffp,"\n");
	}
	fclose(ffp);
}

/*====================================== */
void write_log(void)
{
	int i;

	for(i = 0; i < line_count; i++){
		fprintf(ofp, "ADDRESS : %d\n", op[i].address);
		fprintf(ofp, "LABEL : %s\n", op[i].label);
		fprintf(ofp, "INSTRUCTION : %s\n", op[i].instruction);
		fprintf(ofp, "OP1 : %s\n", op[i].op1);
		fprintf(ofp, "OP2 : %s\n", op[i].op2);
		fprintf(ofp, "COMMENT : %s\n", op[i].comment);
	}
}

/*====================================== */
/* write program word in hex format */
void write_bin(void)
{
	int i;
	char *ptr;

	ptr = strstr(filename, ".fmt");
	*ptr = '\0';
	strcat(filename,".bin");

	ffp = fopen(filename, "w");
	if (ffp == NULL){
        printf("\nCan not open bin file\n");
		exit(1);
	}

	for(i = 0; i < PROGRAM_COUNT; i++){
		fprintf(ffp, "%3d : %04X\n", i, program_word[i]);
	}

	fclose(ffp);
}

/*====================================== */
/* write intel mcs file for programming */
void write_mcs(void)
{
	unsigned int i,j,k;
	char *ptr;
	unsigned int checksum;

	ptr = strstr(filename, ".bin");
	*ptr = '\0';
	strcat(filename,".mcs");

	ffp = fopen(filename, "w");
	if (ffp == NULL){
        printf("\nCan not open mcs file\n");
		exit(1);
	}

	fprintf(ffp, ":020000020000FC\n");
	for(i = 0; i < PROGRAM_COUNT/8; i++){
		checksum = 0;
		fprintf(ffp, ":10%04X00", i*16);
		checksum = checksum + 16 + i*16%256 + i*16/256;
		for(j = 0; j < 8; j++){
			k = i*8+j;
			fprintf(ffp,"%02X", program_word[k]%256);
			checksum = checksum + program_word[k]%256;
			fprintf(ffp,"%02X", program_word[k]/256);
			checksum = checksum + program_word[k]/256;
		}
		fprintf(ffp,"%02X\n", (256-checksum%256)%256);
	}

	fprintf(ffp, ":00000001FF\n");
	fclose(ffp);
}

/*====================================== */
/* write vhdl module for simulation */
void write_vhd(void)
{
	int i, j;
	char *ptr;
	char basename[200];

	ptr = strstr(filename, ".mcs");
	*ptr = '\0';
	strcpy(basename, filename);
	strcat(filename,".vhd");

	ffp = fopen(filename, "w");
	if (ffp == NULL){
        printf("\nCan not open vhd file\n");
		exit(1);
	}

	fprintf(ffp,"library ieee;\nuse ieee.std_logic_1164.all;\n");
	fprintf(ffp,"use ieee.std_logic_unsigned.all;\n\n");

	fprintf(ffp,"entity %s is\n",basename);
	fprintf(ffp,"\tport( address : in std_logic_vector(7 downto 0);\n");
	fprintf(ffp,"\t\tclk : in std_logic;\n\t\tdout : out std_logic_vector(15 downto 0));\n\tend;\n\n");
	fprintf(ffp,"architecture v1 of %s is\n\n", basename);

	fprintf(ffp,"\tconstant ROM_WIDTH: INTEGER:= 16;\n");
	fprintf(ffp,"\tconstant ROM_LENGTH: INTEGER:= 256;\n\n");
	fprintf(ffp,"\tsubtype rom_word is std_logic_vector(ROM_WIDTH-1 downto 0);\n");
	fprintf(ffp,"\ttype rom_table is array (0 to ROM_LENGTH-1) of rom_word;\n\n");
	fprintf(ffp,"constant rom: rom_table := rom_table'(\n");
	for(i = 0; i < PROGRAM_COUNT-1; i++){
		fprintf(ffp, "\t\"");
		for(j = 15; j >= 0; j--)
			fprintf(ffp, "%d", (program_word[i]>>j) & 1); //print binary
		fprintf(ffp, "\",\n");
	}
	fprintf(ffp, "\t\"");
	for(j = 15; j >= 0; j--)
		fprintf(ffp, "%d", (program_word[i]>>j) & 1); //print binary
	fprintf(ffp, "\");\n\n");

	fprintf(ffp,"begin\n\nprocess (clk)\nbegin\n", basename);
	fprintf(ffp,"\tif clk'event and clk = '1' then\n\t\tdout <= rom(conv_integer(address));\n");
	fprintf(ffp,"\tend if;\nend process;\nend v1;\n");

	fclose(ffp);
}

/*====================================== */
int main(int argc, char **argv)
{
	char *ptr;

    if(argc != 2){
		printf("\nCommand line syntax:\n\nasm file.asm\n");
		exit(1);
	}

	strcpy(filename, argv[1]);
	ptr = strstr(filename, ".asm");
	if (ptr == NULL){
		printf("\nInvalid file type, use .asm extension\n");
		exit(1);
	}
	*ptr = '\0';
	strcat(filename,".log");

    ifp = fopen(argv[1], "r");
    if (ifp == NULL){
        printf("\nCan not open input file\n");
		exit(1);
	}

	ofp = fopen(filename, "w");
	if (ofp == NULL){
        printf("\nCan not open output file\n");
		exit(1);
	}
	fprintf(ofp, "Crypto asm logfile\n\n");

	printf("Reading input file...\n");
	fprintf(ofp,"Reading input file...\n");
	while ( fgets(linebuf, 128, ifp) != NULL ) {
		if(line_count >= MAX_LINE_COUNT){
			printf("\nInput exceed maximum line number\n");
			error_out();
		}
		parse_linebuf();
		line_count++;
	}

	init_program_word();
	printf("Testing instructions...\n");
	fprintf(ofp,"Testing instructions...\n");
	test_instructions();
	if(error > 0){
		printf("Program aborted...error count %d\n", error);
		fprintf(ofp,"Program aborted...error count %d\n", error);
		error_out();
	}
	write_program_word();
	if(error > 0){
		printf("Program aborted...error count %d\n", error);
		fprintf(ofp,"Program aborted...error count %d\n", error);
		error_out();
	}

	printf("Write output files...\n");
	fprintf(ofp,"Write output files...\n");
	write_fmt();
	write_bin();
	write_mcs();
	write_vhd();

	free_mem();
	printf("Program completed...\n");
	fprintf(ofp,"Program completed...\n");
	fclose(ifp);
	fclose(ofp);
	return(0);
}

