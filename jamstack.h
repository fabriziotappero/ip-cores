/****************************************************************************/
/*																			*/
/*	Module:			jamstack.h												*/
/*																			*/
/*					Copyright (C) Altera Corporation 1997					*/
/*																			*/
/*	Description:	Prototypes for stack management functions				*/
/*																			*/
/*	Revisions:		1.1	added jam_free_stack()								*/
/*																			*/
/****************************************************************************/

/****************************************************************************/
/*																			*/
/*	Actel version 1.1             May 2003									*/
/*																			*/
/****************************************************************************/

#ifndef INC_JAMSTACK_H
#define INC_JAMSTACK_H

/****************************************************************************/
/*																			*/
/*	Type definitions														*/
/*																			*/
/****************************************************************************/

/* types of stack records */
typedef enum
{
	JAM_ILLEGAL_STACK_TYPE = 0,
	JAM_STACK_FOR_NEXT,
	JAM_STACK_PUSH_POP,
	JAM_STACK_CALL_RETURN,
	JAM_STACK_MAX

} JAME_STACK_RECORD_TYPE;

/* stack record structure */
typedef struct
{
	JAME_STACK_RECORD_TYPE type;
	JAMS_SYMBOL_RECORD *iterator;	/* used only for FOR/NEXT */
	long for_position;				/* used only for FOR/NEXT */
	long stop_value;				/* used only for FOR/NEXT */
	long step_value;				/* used only for FOR/NEXT */
	long push_value;				/* used only for PUSH/POP */
	long return_position;			/* used only for CALL/RETURN */

} JAMS_STACK_RECORD;

/****************************************************************************/
/*																			*/
/*	Global variables														*/
/*																			*/
/****************************************************************************/

extern JAMS_STACK_RECORD *jam_stack;

/****************************************************************************/
/*																			*/
/*	Function prototypes														*/
/*																			*/
/****************************************************************************/

JAM_RETURN_TYPE jam_init_stack
(
	void
);

void jam_free_stack
(
	void
);

JAM_RETURN_TYPE jam_push_stack_record
(
	JAMS_STACK_RECORD *stack_record
);

JAMS_STACK_RECORD *jam_peek_stack_record
(
	void
);

JAM_RETURN_TYPE jam_pop_stack_record
(
	void
);

JAM_RETURN_TYPE jam_push_fornext_record
(
	JAMS_SYMBOL_RECORD *iterator,
	long for_position,
	long stop_value,
	long step_value
);

JAM_RETURN_TYPE jam_push_pushpop_record
(
	long value
);

JAM_RETURN_TYPE jam_push_callret_record
(
	long return_position
);

#endif /* INC_JAMSTACK_H */
