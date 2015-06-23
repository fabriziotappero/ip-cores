/****************************************************************************/
/*																			*/
/*	Module:			jamsym.h												*/
/*																			*/
/*					Copyright (C) Altera Corporation 1997					*/
/*																			*/
/*	Description:	Prototypes for symbol-table management functions		*/
/*																			*/
/*	Revisions:		1.1	added jam_free_symbol_table()						*/
/*																			*/
/****************************************************************************/

/****************************************************************************/
/*																			*/
/*	Actel version 1.1             May 2003									*/
/*																			*/
/****************************************************************************/

#ifndef INC_JAMSYM_H
#define INC_JAMSYM_H

/****************************************************************************/
/*																			*/
/*	Type definitions														*/
/*																			*/
/****************************************************************************/

/* types of symbolic names */
typedef enum
{
	JAM_ILLEGAL_SYMBOL_TYPE = 0,
	JAM_LABEL,
	JAM_INTEGER_SYMBOL,
	JAM_BOOLEAN_SYMBOL,
	JAM_INTEGER_ARRAY_WRITABLE,
	JAM_BOOLEAN_ARRAY_WRITABLE,
	JAM_INTEGER_ARRAY_INITIALIZED,
	JAM_BOOLEAN_ARRAY_INITIALIZED,
	JAM_DATA_BLOCK,
	JAM_PROCEDURE_BLOCK,
	JAM_SYMBOL_MAX

} JAME_SYMBOL_TYPE;

/* symbol record structure */
typedef struct JAMS_SYMBOL_STRUCT
{
	char name[JAMC_MAX_NAME_LENGTH + 1];
	JAME_SYMBOL_TYPE type;
	long value;
	long position;
	struct JAMS_SYMBOL_STRUCT *parent;
	struct JAMS_SYMBOL_STRUCT *next;

} JAMS_SYMBOL_RECORD;

/****************************************************************************/
/*																			*/
/*	Global variables														*/
/*																			*/
/****************************************************************************/

extern JAMS_SYMBOL_RECORD **jam_symbol_table;

extern void *jam_symbol_bottom;

extern JAMS_SYMBOL_RECORD *jam_current_block;

extern int jam_version;

/****************************************************************************/
/*																			*/
/*	Function prototypes														*/
/*																			*/
/****************************************************************************/

JAM_RETURN_TYPE jam_init_symbol_table
(
	void
);

void jam_free_symbol_table
(
	void
);

JAM_RETURN_TYPE jam_add_symbol
(
	JAME_SYMBOL_TYPE type,
	char *name,
	long value,
	long position
);

JAM_RETURN_TYPE jam_get_symbol_value
(
	JAME_SYMBOL_TYPE type,
	char *name,
	long *value
);

JAM_RETURN_TYPE jam_set_symbol_value
(
	JAME_SYMBOL_TYPE type,
	char *name,
	long value
);

JAM_RETURN_TYPE jam_get_symbol_record
(
	char *name,
	JAMS_SYMBOL_RECORD **symbol_record
);

#endif /* INC_JAMSYM_H */
