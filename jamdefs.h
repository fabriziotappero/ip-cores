/****************************************************************************/
/*																			*/
/*	Module:			jamdefs.h												*/
/*																			*/
/*					Copyright (C) Altera Corporation 1997					*/
/*																			*/
/*	Description:	Definitions of JAM constants and user-defined types		*/
/*																			*/
/*	Revisions:		1.1	added prototypes for jam_malloc and jam_free		*/
/*																			*/
/****************************************************************************/

/****************************************************************************/
/*																			*/
/*	Actel version 1.1             May 2003									*/
/*																			*/
/****************************************************************************/

#ifndef INC_JAMDEFS_H
#define INC_JAMDEFS_H

/****************************************************************************/
/*																			*/
/*	Constant definitions													*/
/*																			*/
/****************************************************************************/

#define NULL (0)
#define EOF (-1)
typedef int BOOL;
//#define BOOL int
#define TRUE 1
#define FALSE 0

/* maximum quantities of some items */
#define JAMC_MAX_SYMBOL_COUNT 1021	/* should be a prime number */
#define JAMC_MAX_NESTING_DEPTH 128

/* maximum JTAG IR and DR lengths (in bits) */
#define JAMC_MAX_JTAG_IR_PREAMBLE   256
#define JAMC_MAX_JTAG_IR_POSTAMBLE  256
#define JAMC_MAX_JTAG_IR_LENGTH     512
#define JAMC_MAX_JTAG_DR_PREAMBLE  1024
#define JAMC_MAX_JTAG_DR_POSTAMBLE 1024
#define JAMC_MAX_JTAG_DR_LENGTH    2048

/* memory needed for JTAG buffers (in bytes) */
#define JAMC_JTAG_BUFFER_SIZE   (( \
	JAMC_MAX_JTAG_IR_PREAMBLE   + \
	JAMC_MAX_JTAG_IR_POSTAMBLE  + \
	JAMC_MAX_JTAG_IR_LENGTH     + \
	JAMC_MAX_JTAG_DR_PREAMBLE   + \
	JAMC_MAX_JTAG_DR_POSTAMBLE  + \
	JAMC_MAX_JTAG_DR_LENGTH     ) / 8)

/* size (in bytes) of cache buffer for initialized arrays */
#define JAMC_ARRAY_CACHE_SIZE 1024

/* character length limits */
#define JAMC_MAX_STATEMENT_LENGTH 8192
#define JAMC_MAX_NAME_LENGTH 32
#define JAMC_MAX_INSTR_LENGTH 10

/* character codes */
#define JAMC_COMMENT_CHAR   ('\'')
#define JAMC_QUOTE_CHAR     ('\"')
#define JAMC_COLON_CHAR     (':')
#define JAMC_SEMICOLON_CHAR (';')
#define JAMC_COMMA_CHAR     (',')
#define JAMC_PERIOD_CHAR    ('.')
#define JAMC_NEWLINE_CHAR   ('\n')
#define JAMC_RETURN_CHAR    ('\r')
#define JAMC_TAB_CHAR       ('\t')
#define JAMC_SPACE_CHAR     (' ')
#define JAMC_EQUAL_CHAR     ('=')
#define JAMC_MINUS_CHAR     ('-')
#define JAMC_LPAREN_CHAR    ('(')
#define JAMC_RPAREN_CHAR    (')')
#define JAMC_LBRACKET_CHAR  ('[')
#define JAMC_RBRACKET_CHAR  (']')
#define JAMC_POUND_CHAR     ('#')
#define JAMC_DOLLAR_CHAR    ('$')
#define JAMC_AT_CHAR        ('@')
#define JAMC_NULL_CHAR      ('\0')
#define JAMC_UNDERSCORE_CHAR ('_')

/****************************************************************************/
/*																			*/
/*	Enumerated Types														*/
/*																			*/
/****************************************************************************/

/* instruction codes */
typedef enum
{
	JAM_ILLEGAL_INSTR = 0,
	JAM_ACTION_INSTR,
	JAM_BOOLEAN_INSTR,
	JAM_CALL_INSTR,
	JAM_CRC_INSTR,
	JAM_DATA_INSTR,
	JAM_DRSCAN_INSTR,
	JAM_DRSTOP_INSTR,
	JAM_ENDDATA_INSTR,
	JAM_ENDPROC_INSTR,
	JAM_EXIT_INSTR,
	JAM_EXPORT_INSTR,
	JAM_FOR_INSTR,
	JAM_FREQUENCY_INSTR,
	JAM_GOTO_INSTR,
	JAM_IF_INSTR,
	JAM_INTEGER_INSTR,
	JAM_IRSCAN_INSTR,
	JAM_IRSTOP_INSTR,
	JAM_LET_INSTR,
	JAM_NEXT_INSTR,
	JAM_NOTE_INSTR,
	JAM_PADDING_INSTR,
	JAM_POP_INSTR,
	JAM_POSTDR_INSTR,
	JAM_POSTIR_INSTR,
	JAM_PREDR_INSTR,
	JAM_PREIR_INSTR,
	JAM_PRINT_INSTR,
	JAM_PROCEDURE_INSTR,
	JAM_PUSH_INSTR,
	JAM_REM_INSTR,
	JAM_RETURN_INSTR,
	JAM_STATE_INSTR,
	JAM_TRST_INSTR,
	JAM_VECTOR_INSTR,
	JAM_VMAP_INSTR,
	JAM_WAIT_INSTR,
	JAM_INSTR_MAX

} JAME_INSTRUCTION;

/* types of expressions */
typedef enum
{
	JAM_ILLEGAL_EXPR_TYPE = 0,
	JAM_INTEGER_EXPR,
	JAM_BOOLEAN_EXPR,
	JAM_INT_OR_BOOL_EXPR,
	JAM_ARRAY_REFERENCE,
	JAM_EXPR_MAX

} JAME_EXPRESSION_TYPE;

/* phases of execution */
typedef enum
{
	JAM_UNKNOWN_PHASE = 0,
	JAM_NOTE_PHASE,
	JAM_ACTION_PHASE,
	JAM_PROCEDURE_PHASE,
	JAM_DATA_PHASE,
	JAM_PHASE_MAX

} JAME_PHASE_TYPE;

/****************************************************************************/
/*																			*/
/*	Global variables														*/
/*																			*/
/****************************************************************************/

extern char *jam_workspace;

extern long jam_workspace_size;

extern char *jam_program;

extern long jam_program_size;

extern char **jam_init_list;

extern JAME_PHASE_TYPE jam_phase;

#endif /* INC_JAMDEFS_H */
