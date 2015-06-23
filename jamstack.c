/****************************************************************************/
/*																			*/
/*	Module:			jamstack.c												*/
/*																			*/
/*					Copyright (C) Altera Corporation 1997					*/
/*																			*/
/*	Description:	Functions for maintaining the stack						*/
/*																			*/
/*	Revisions:		1.1 added support for dynamic memory allocation			*/
/*																			*/
/****************************************************************************/

/****************************************************************************/
/*																			*/
/*	Actel version 1.1             May 2003									*/
/*																			*/
/****************************************************************************/

#include "jamexprt.h"
#include "jamdefs.h"
#include "jamutil.h"
#include "jamsym.h"
#include "jamstack.h"

JAMS_STACK_RECORD *jam_stack = 0;

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_init_stack(void)

/*																			*/
/*	Description:	Initialize the stack.  The stack is located after the	*/
/*					symbol table in the workspace buffer.					*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, else appropriate error code	*/
/*																			*/
/****************************************************************************/
{
	int index = 0;
	int size = 0;
	JAM_RETURN_TYPE return_code = JAMC_SUCCESS;
	void **symbol_table = NULL;

	if (jam_workspace != NULL)
	{
		symbol_table = (void **) jam_workspace;
		jam_stack = (JAMS_STACK_RECORD *) &symbol_table[JAMC_MAX_SYMBOL_COUNT];

		size = (JAMC_MAX_SYMBOL_COUNT * sizeof(void *)) +
			(JAMC_MAX_NESTING_DEPTH * sizeof(JAMS_STACK_RECORD));

		if (jam_workspace_size < size)
		{
			return_code = JAMC_OUT_OF_MEMORY;
		}
	}
	else
	{
		jam_stack = jam_malloc(
			JAMC_MAX_NESTING_DEPTH * sizeof(JAMS_STACK_RECORD));

		if (jam_stack == NULL)
		{
			return_code = JAMC_OUT_OF_MEMORY;
		}
	}

	if (return_code == JAMC_SUCCESS)
	{
		for (index = 0; index < JAMC_MAX_NESTING_DEPTH; ++index)
		{
			jam_stack[index].type = JAM_ILLEGAL_STACK_TYPE;
			jam_stack[index].iterator = (JAMS_SYMBOL_RECORD *) 0;
			jam_stack[index].for_position = 0L;
			jam_stack[index].stop_value = 0L;
			jam_stack[index].step_value = 0L;
			jam_stack[index].push_value = 0L;
			jam_stack[index].return_position = 0L;
		}
	}

	return (return_code);
}

void jam_free_stack(void)
{
	if ((jam_stack != NULL) && (jam_workspace == NULL))
	{
		jam_free(jam_stack);
	}
}

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_push_stack_record
(
	JAMS_STACK_RECORD *stack_record
)

/*																			*/
/*	Description:	Creates a new stack record with the specified			*/
/*					attributes.												*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, or JAMC_OUT_OF_MEMORY if		*/
/*					the stack was already full								*/
/*																			*/
/****************************************************************************/
{
	int index = 0;
	JAM_RETURN_TYPE return_code = JAMC_OUT_OF_MEMORY;

	/*
	*	Find stack top
	*/
	while ((index < JAMC_MAX_NESTING_DEPTH) &&
		(jam_stack[index].type != JAM_ILLEGAL_STACK_TYPE))
	{
		++index;
	}

	/*
	*	Add new stack record
	*/
	if ((index < JAMC_MAX_NESTING_DEPTH) &&
		(jam_stack[index].type == JAM_ILLEGAL_STACK_TYPE))
	{
		jam_stack[index].type            = stack_record->type;
		jam_stack[index].iterator        = stack_record->iterator;
		jam_stack[index].for_position    = stack_record->for_position;
		jam_stack[index].stop_value      = stack_record->stop_value;
		jam_stack[index].step_value      = stack_record->step_value;
		jam_stack[index].push_value      = stack_record->push_value;
		jam_stack[index].return_position = stack_record->return_position;

		return_code = JAMC_SUCCESS;
	}

	return (return_code);
}

/****************************************************************************/
/*																			*/

JAMS_STACK_RECORD *jam_peek_stack_record(void)

/*																			*/
/*	Description:	Finds the top of the stack								*/
/*																			*/
/*	Returns:		Pointer to the top-most stack record, or NULL if the	*/
/*					stack is empty											*/
/*																			*/
/****************************************************************************/
{
	int index = 0;
	JAMS_STACK_RECORD *top = NULL;

	/*
	*	Find stack top
	*/
	while ((index < JAMC_MAX_NESTING_DEPTH) &&
		(jam_stack[index].type != JAM_ILLEGAL_STACK_TYPE))
	{
		++index;
	}

	if ((index > 0) && (index < JAMC_MAX_NESTING_DEPTH))
	{
		top = &jam_stack[index - 1];
	}

	return (top);
}

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_pop_stack_record(void)

/*																			*/
/*	Description:	Deletes the top-most stack record from the stack		*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, or JAMC_OUT_OF_MEMORY if the	*/
/*					stack was empty											*/
/*																			*/
/****************************************************************************/
{
	int index = 0;
	JAM_RETURN_TYPE return_code = JAMC_OUT_OF_MEMORY;

	/*
	*	Find stack top
	*/
	while ((index < JAMC_MAX_NESTING_DEPTH) &&
		(jam_stack[index].type != JAM_ILLEGAL_STACK_TYPE))
	{
		++index;
	}

	/*
	*	Delete stack record
	*/
	if ((index > 0) && (index < JAMC_MAX_NESTING_DEPTH))
	{
		--index;

		jam_stack[index].type = JAM_ILLEGAL_STACK_TYPE;
		jam_stack[index].iterator = (JAMS_SYMBOL_RECORD *) 0;
		jam_stack[index].for_position = 0L;
		jam_stack[index].stop_value = 0L;
		jam_stack[index].step_value = 0L;
		jam_stack[index].push_value = 0L;
		jam_stack[index].return_position = 0L;

		return_code = JAMC_SUCCESS;
	}

	return (return_code);
}

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_push_fornext_record
(
	JAMS_SYMBOL_RECORD *iterator,
	long for_position,
	long stop_value,
	long step_value
)

/*																			*/
/*	Description:	Pushes a FOR/NEXT record onto the stack					*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, else appropriate error code	*/
/*																			*/
/****************************************************************************/
{
	JAMS_STACK_RECORD stack_record;

	stack_record.type            = JAM_STACK_FOR_NEXT;
	stack_record.iterator        = iterator;
	stack_record.for_position    = for_position;
	stack_record.stop_value      = stop_value;
	stack_record.step_value      = step_value;
	stack_record.push_value      = 0L;
	stack_record.return_position = 0L;

	return (jam_push_stack_record(&stack_record));
}

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_push_pushpop_record
(
	long value
)

/*																			*/
/*	Description:	Pushes a PUSH/POP record onto the stack					*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, else appropriate error code	*/
/*																			*/
/****************************************************************************/
{
	JAMS_STACK_RECORD stack_record;

	stack_record.type            = JAM_STACK_PUSH_POP;
	stack_record.iterator        = NULL;
	stack_record.for_position    = 0L;
	stack_record.stop_value      = 0L;
	stack_record.step_value      = 0L;
	stack_record.push_value      = value;
	stack_record.return_position = 0L;

	return (jam_push_stack_record(&stack_record));
}

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_push_callret_record
(
	long return_position
)

/*																			*/
/*	Description:	Pushes a CALL/RETURN record onto the stack				*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, else appropriate error code	*/
/*																			*/
/****************************************************************************/
{
	JAMS_STACK_RECORD stack_record;

	stack_record.type            = JAM_STACK_CALL_RETURN;
	stack_record.iterator        = NULL;
	stack_record.for_position    = 0L;
	stack_record.stop_value      = 0L;
	stack_record.step_value      = 0L;
	stack_record.push_value      = 0L;
	stack_record.return_position = return_position;

	return (jam_push_stack_record(&stack_record));
}
