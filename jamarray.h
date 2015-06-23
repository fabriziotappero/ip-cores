/****************************************************************************/
/*																			*/
/*	Module:			jamarray.h												*/
/*																			*/
/*					Copyright (C) Altera Corporation 1997					*/
/*																			*/
/*	Description:	Constants and function prototypes for array support		*/
/*																			*/
/****************************************************************************/

/****************************************************************************/
/*																			*/
/*	Actel version 1.1             May 2003									*/
/*																			*/
/****************************************************************************/

#ifndef INC_JAMARRAY_H
#define INC_JAMARRAY_H

/****************************************************************************/
/*																			*/
/*	Function Prototypes														*/
/*																			*/
/****************************************************************************/

JAM_RETURN_TYPE jam_read_boolean_array_data
(
	JAMS_HEAP_RECORD *heap_record,
	char *statement_buffer
);

JAM_RETURN_TYPE jam_read_integer_array_data
(
	JAMS_HEAP_RECORD *heap_record,
	char *statement_buffer
);

JAM_RETURN_TYPE jam_get_array_value
(
	JAMS_SYMBOL_RECORD *symbol_record,
	long index,
	long *value
);

#endif	/* INC_JAMARRAY_H */
