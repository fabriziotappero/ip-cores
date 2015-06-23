/****************************************************************************/
/*																			*/
/*	Module:			jamexprt.h												*/
/*																			*/
/*					Copyright (C) Altera Corporation 1997					*/
/*																			*/
/*	Description:	JAM Interpreter Export Header File						*/
/*																			*/
/*	Revisions:		1.1 removed error code JAMC_UNSUPPORTED FEATURE, added	*/
/*					JAMC_VECTOR_MAP_FAILED									*/
/*																			*/
/****************************************************************************/

/****************************************************************************/
/*																			*/
/*	Actel version 1.1             May 2003									*/
/*																			*/
/****************************************************************************/

#ifndef INC_JAMEXPRT_H
#define INC_JAMEXPRT_H

/****************************************************************************/
/*																			*/
/*	Return codes from most JAM functions									*/
/*																			*/
/****************************************************************************/

#define JAM_RETURN_TYPE int

#define JAMC_SUCCESS           0
#define JAMC_OUT_OF_MEMORY     1
#define JAMC_IO_ERROR          2
#define JAMC_SYNTAX_ERROR      3
#define JAMC_UNEXPECTED_END    4
#define JAMC_UNDEFINED_SYMBOL  5
#define JAMC_REDEFINED_SYMBOL  6
#define JAMC_INTEGER_OVERFLOW  7
#define JAMC_DIVIDE_BY_ZERO    8
#define JAMC_CRC_ERROR         9
#define JAMC_INTERNAL_ERROR   10
#define JAMC_BOUNDS_ERROR     11
#define JAMC_TYPE_MISMATCH    12
#define JAMC_ASSIGN_TO_CONST  13
#define JAMC_NEXT_UNEXPECTED  14
#define JAMC_POP_UNEXPECTED   15
#define JAMC_RETURN_UNEXPECTED 16
#define JAMC_ILLEGAL_SYMBOL   17
#define JAMC_VECTOR_MAP_FAILED 18
#define JAMC_USER_ABORT        19
#define JAMC_STACK_OVERFLOW    20
#define JAMC_ILLEGAL_OPCODE    21
#define JAMC_PHASE_ERROR       22
#define JAMC_SCOPE_ERROR       23
#define JAMC_ACTION_NOT_FOUND  24

//&RA
#define DEBUG 1

/****************************************************************************/
/*																			*/
/*	Function Prototypes														*/
/*																			*/
/****************************************************************************/

JAM_RETURN_TYPE jam_execute
(
	char *program,
	long program_size,
	char *workspace,
	long workspace_size,
	char *action,
	char **init_list,
	int reset_jtag,
	long *error_line,
	int *exit_code,
	int *format_version
);

JAM_RETURN_TYPE jam_get_note
(
	char *program,
	long program_size,
	long *offset,
	char *key,
	char *value,
	int length
);

JAM_RETURN_TYPE jam_check_crc
(
	char *program,
	long program_size,
	unsigned short *expected_crc,
	unsigned short *actual_crc
);

int jam_getc
(
	void
);

int jam_seek
(
	long offset
);

int jam_jtag_io
(
	int tms,
	int tdi,
	int read_tdo
);

void jam_message
(
	char *message_text
);

void jam_export_integer
(
	char *key,
	long value
);

void jam_export_boolean_array
(
	char *key,
	unsigned char *data,
	long count
);

void jam_delay
(
	long microseconds
);

int jam_vector_map
(
	int signal_count,
	char **signals
);

int jam_vector_io
(
	int signal_count,
	long *dir_vect,
	long *data_vect,
	long *capture_vect
);

int jam_set_frequency
(
	long hertz
);

void *jam_malloc
(
	unsigned int size
);

void jam_free
(
	void *ptr
);

#endif /* INC_JAMEXPRT_H */
