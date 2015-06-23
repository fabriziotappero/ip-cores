/****************************************************************************/
/*																			*/
/*	Module:			jamsym.c												*/
/*																			*/
/*					Copyright (C) Altera Corporation 1997					*/
/*																			*/
/*	Description:	Functions for maintaining symbol table, including		*/
/*					adding a synbol, searching for a symbol, and			*/
/*					modifying the value associated with a symbol			*/
/*																			*/
/*	Revisions:		1.1 added support for dynamic memory allocation, made	*/
/*					jam_symbol_table a pointer table instead of a table of	*/
/*					structures.  Actual symbols now live at the top of the	*/
/*					workspace, and grow dynamically downwards in memory.	*/
/*																			*/
/****************************************************************************/

/****************************************************************************/
/*																			*/
/*	Actel version 1.1             May 2003									*/
/*																			*/
/****************************************************************************/

#include "jamexprt.h"
#include "jamdefs.h"
#include "jamsym.h"
#include "jamheap.h"
#include "jamutil.h"

/****************************************************************************/
/*																			*/
/*	Global variables														*/
/*																			*/
/****************************************************************************/

JAMS_SYMBOL_RECORD **jam_symbol_table = NULL;

void *jam_symbol_bottom = NULL;

extern BOOL jam_checking_uses_list;

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_init_symbol_table()

/*																			*/
/*	Description:	Initializes the symbol table.  The symbol table is		*/
/*					located at the beginning of the workspace buffer.		*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, or JAMC_OUT_OF_MEMORY if the	*/
/*					size of the workspace buffer is too small to hold the	*/
/*					desired number of symbol records.						*/
/*																			*/
/****************************************************************************/
{
	int index = 0;
	JAM_RETURN_TYPE status = JAMC_SUCCESS;

	if (jam_workspace != NULL)
	{
		jam_symbol_table = (JAMS_SYMBOL_RECORD **) jam_workspace;

		jam_symbol_bottom = (void *) (((long)jam_workspace) +
			((long)jam_workspace_size));

		if (jam_workspace_size <
			(JAMC_MAX_SYMBOL_COUNT * sizeof(void *)))
		{
			status = JAMC_OUT_OF_MEMORY;
		}
	}
	else
	{
		jam_symbol_table = (JAMS_SYMBOL_RECORD **) jam_malloc(
			(JAMC_MAX_SYMBOL_COUNT * sizeof(void *)));

		if (jam_symbol_table == NULL)
		{
			status = JAMC_OUT_OF_MEMORY;
		}
	}

	if (status == JAMC_SUCCESS)
	{
		for (index = 0; index < JAMC_MAX_SYMBOL_COUNT; ++index)
		{
			jam_symbol_table[index] = NULL;
		}
	}

	return (status);
}

void jam_free_symbol_table()
{
	int hash = 0;
	JAMS_SYMBOL_RECORD *symbol_record = NULL;
	JAMS_SYMBOL_RECORD *next = NULL;

	if ((jam_symbol_table != NULL) && (jam_workspace == NULL))
	{
		for (hash = 0; hash < JAMC_MAX_SYMBOL_COUNT; ++hash)
		{
			symbol_record = jam_symbol_table[hash];
			while (symbol_record != NULL)
			{
				next = symbol_record->next;
				jam_free(symbol_record);
				symbol_record = next;
			}
		}

		jam_free(jam_symbol_table);
	}
}

/****************************************************************************/
/*																			*/

BOOL jam_check_init_list
(
	char *name,
	long *value
)

/*																			*/
/*	Description:	Compares variable name to names in initialization list	*/
/*					and, if name is found, returns the corresponding		*/
/*					initialization value for the variable.					*/
/*																			*/
/*	Returns:		TRUE if variable was found, else FALSE					*/
/*																			*/
/****************************************************************************/
{
	char r, l;
	int ch_index = 0;
	int init_entry = 0;
	char *init_string = NULL;
	long val;
	BOOL match = FALSE;
	BOOL negate = FALSE;
	BOOL status = FALSE;

	if (jam_init_list != NULL)
	{
		while ((!match) && (jam_init_list[init_entry] != NULL))
		{
			init_string = jam_init_list[init_entry];
			match = TRUE;
			ch_index = 0;
			do
			{
				r = jam_toupper(init_string[ch_index]);
				if (!jam_is_name_char(r)) r = '\0';
				l = name[ch_index];
				match = (r == l);
				++ch_index;
			}
			while (match && (r != '\0') && (l != '\0'));

			if (match)
			{
				--ch_index;
				while (jam_isspace(init_string[ch_index])) ++ch_index;
				if (init_string[ch_index] == JAMC_EQUAL_CHAR)
				{
					++ch_index;
					while (jam_isspace(init_string[ch_index])) ++ch_index;

					if (init_string[ch_index] == JAMC_MINUS_CHAR)
					{
						++ch_index;
						negate = TRUE;
					}

					if (jam_isdigit(init_string[ch_index]))
					{
						val = jam_atol(&init_string[ch_index]);

						if (negate) val = 0L - val;

						if (value != NULL) *value = val;

						status = TRUE;
					}
				}
			}
			else
			{
				++init_entry;
			}
		}
	}

	return (status);
}

/****************************************************************************/
/*																			*/

int jam_hash
(
	char *name
)

/*																			*/
/*	Description:	Calcluates 'hash value' for a symbolic name.  This is	*/
/*					a pseudo-random number which is used as an offset into	*/
/*					the symbol table, as the initial position for the		*/
/*					symbol record.											*/
/*																			*/
/*	Returns:		An integer between 0 and JAMC_MAX_SYMBOL_COUNT-1		*/
/*																			*/
/****************************************************************************/
{
	int ch_index = 0;
	int hash = 0;

	while ((ch_index < JAMC_MAX_NAME_LENGTH) && (name[ch_index] != '\0'))
	{
		hash <<= 1;
		hash += (name[ch_index] & 0x1f);
		++ch_index;
	}
	if (hash < 0) hash = 0 - hash;

	return (hash % JAMC_MAX_SYMBOL_COUNT);
}

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_add_symbol
(
	JAME_SYMBOL_TYPE type,
	char *name,
	long value,
	long position
)

/*																			*/
/*	Description:	Adds a new symbol to the symbol table.  If the symbol	*/
/*					name already exists in the symbol table, it is an error	*/
/*					unless the symbol type and the position in the file		*/
/*					where the symbol was declared are identical.  This is	*/
/*					necessary to allow labels and variable declarations		*/
/*					inside loops and subroutines where they may be			*/
/*					encountered multiple times.								*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, or JAMC_REDEFINED_SYMBOL		*/
/*					if symbol was already declared elsewhere, or			*/
/*					JAMC_OUT_OF_MEMORY if symbol table is full.				*/
/*																			*/
/****************************************************************************/
{
	char r, l;
	int ch_index = 0;
	int hash = 0;
	long init_list_value = 0L;
	BOOL match = FALSE;
	BOOL identical_redeclaration = FALSE;
	JAM_RETURN_TYPE status = JAMC_SUCCESS;
	JAMS_SYMBOL_RECORD *symbol_record = NULL;
	JAMS_SYMBOL_RECORD *prev_symbol_record = NULL;

	/*
	*	Check for legal characters in name, and legal name length
	*/
	while (name[ch_index] != JAMC_NULL_CHAR)
	{
		if (!jam_is_name_char(name[ch_index++])) status = JAMC_ILLEGAL_SYMBOL;
	}

	if ((ch_index == 0) || (ch_index > JAMC_MAX_NAME_LENGTH))
	{
		status = JAMC_ILLEGAL_SYMBOL;
	}

	/*
	*	Get hash key for this name
	*/
	hash = jam_hash(name);

	/*
	*	Get pointer to first symbol record corresponding to this hash key
	*/
	symbol_record = jam_symbol_table[hash];

	/*
	*	Then check for duplicate entry in symbol table
	*/
	while ((status == JAMC_SUCCESS) && (symbol_record != NULL) &&
		(!identical_redeclaration))
	{
		match = TRUE;
		ch_index = 0;
		do
		{
			r = symbol_record->name[ch_index];
			l = name[ch_index];
			match = (r == l);
			++ch_index;
		}
		while (match && (r != '\0') && (l != '\0'));

		if (match)
		{
			/*
			*	Check if symbol was already declared identically
			*	(same name, type, and source position)
			*/
			if ((symbol_record->position == position) &&
				(jam_phase == JAM_DATA_PHASE))
			{
				if ((type == JAM_INTEGER_ARRAY_WRITABLE) &&
					(symbol_record->type == JAM_INTEGER_ARRAY_INITIALIZED))
				{
					type = JAM_INTEGER_ARRAY_INITIALIZED;
				}

				if ((type == JAM_BOOLEAN_ARRAY_WRITABLE) &&
					(symbol_record->type == JAM_BOOLEAN_ARRAY_INITIALIZED))
				{
					type = JAM_BOOLEAN_ARRAY_INITIALIZED;
				}
			}

			if ((symbol_record->type == type) &&
				(symbol_record->position == position))
			{
				/*
				*	For identical redeclaration, simply assign the value
				*/
				identical_redeclaration = TRUE;

				if (jam_version != 2)
				{
					symbol_record->value = value;
				}
				else
				{
					if ((type != JAM_PROCEDURE_BLOCK) &&
						(type != JAM_DATA_BLOCK) &&
						(jam_current_block != NULL) &&
						(jam_current_block->type == JAM_PROCEDURE_BLOCK))
					{
						symbol_record->value = value;
					}
				}
			}
			else
			{
				status = JAMC_REDEFINED_SYMBOL;
			}
		}

		prev_symbol_record = symbol_record;
		symbol_record = symbol_record->next;
	}

	/*
	*	If no duplicate entry found, add the symbol
	*/
	if ((status == JAMC_SUCCESS) && (symbol_record == NULL) &&
		(!identical_redeclaration))
	{
		/*
		*	Check initialization list -- if matching name is found,
		*	override the initialization value with the new value
		*/
		if (((type == JAM_INTEGER_SYMBOL) || (type == JAM_BOOLEAN_SYMBOL)) &&
			(jam_init_list != NULL))
		{
			if ((jam_version != 2) &&
				jam_check_init_list(name, &init_list_value))
			{
				/* value was found -- override old value */
				value = init_list_value;
			}
		}

		/*
		*	Add the symbol
		*/
		if (jam_workspace != NULL)
		{
			jam_symbol_bottom = (void *)
				(((long)jam_symbol_bottom) - sizeof(JAMS_SYMBOL_RECORD));

			symbol_record = (JAMS_SYMBOL_RECORD *) jam_symbol_bottom;

			if ((long)jam_heap_top > (long)jam_symbol_bottom)
			{
				status = JAMC_OUT_OF_MEMORY;
			}
		}
		else
		{
			symbol_record = (JAMS_SYMBOL_RECORD *)
				jam_malloc(sizeof(JAMS_SYMBOL_RECORD));

			if (symbol_record == NULL)
			{
				status = JAMC_OUT_OF_MEMORY;
			}
		}

		if (status == JAMC_SUCCESS)
		{
			symbol_record->type = type;
			symbol_record->value = value;
			symbol_record->position = position;
			symbol_record->parent = jam_current_block;
			symbol_record->next = NULL;

			if (prev_symbol_record == NULL)
			{
				jam_symbol_table[hash] = symbol_record;
			}
			else
			{
				prev_symbol_record->next = symbol_record;
			}

			ch_index = 0;
			while ((ch_index < JAMC_MAX_NAME_LENGTH) &&
				(name[ch_index] != '\0'))
			{
				symbol_record->name[ch_index] = name[ch_index];
				++ch_index;
			}
			symbol_record->name[ch_index] = '\0';
		}
	}

	return (status);
}

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_get_symbol_record
(
	char *name,
	JAMS_SYMBOL_RECORD **symbol_record
)

/*																			*/
/*	Description:	Searches in symbol table for a symbol record with		*/
/*					matching name.											*/
/*																			*/
/*	Return:			Pointer to symbol record, or NULL if symbol not found	*/
/*																			*/
/****************************************************************************/
{
	char r, l;
	char save_ch = 0;
	int ch_index = 0;
	int hash = 0;
	int name_begin = 0;
	int name_end = 0;
	BOOL match = FALSE;
	JAMS_SYMBOL_RECORD *tmp_symbol_record = NULL;
	JAM_RETURN_TYPE status = JAMC_UNDEFINED_SYMBOL;

	/*
	*	Get hash key for this name
	*/
	hash = jam_hash(name);

	/*
	*	Get pointer to first symbol record corresponding to this hash key
	*/
	tmp_symbol_record = jam_symbol_table[hash];

	/*
	*	Search for name in symbol table
	*/
	while ((!match) && (tmp_symbol_record != NULL))
	{
		match = TRUE;
		ch_index = 0;
		do
		{
			r = tmp_symbol_record->name[ch_index];
			l = name[ch_index];
			match = (r == l);
			++ch_index;
		}
		while (match && (r != '\0') && (l != '\0'));

		if (match)
		{
			status = JAMC_SUCCESS;
		}
		else
		{
			tmp_symbol_record = tmp_symbol_record->next;
		}
	}

	/*
	*	For Jam version 2, check that symbol is in scope
	*/
	if ((status == JAMC_SUCCESS) && (jam_version == 2))
	{
		if (jam_checking_uses_list &&
			((tmp_symbol_record->type == JAM_PROCEDURE_BLOCK) ||
			(tmp_symbol_record->type == JAM_DATA_BLOCK)))
		{
			/* ignore scope rules when validating USES list */
			status = JAMC_SUCCESS;
		}
		else
		if ((tmp_symbol_record->parent != NULL) &&
			(tmp_symbol_record->parent != jam_current_block) &&
			(tmp_symbol_record != jam_current_block))
		{
			JAMS_SYMBOL_RECORD *parent = tmp_symbol_record->parent;
			JAMS_HEAP_RECORD *heap_record = NULL;
			char *parent_name = NULL;
			char *uses_list = NULL;

			status = JAMC_SCOPE_ERROR;

			/*
			*	If the symbol in question is a procedure name, check that IT
			*	itself is in the uses list, instead of looking for its parent
			*/
			if (tmp_symbol_record->type == JAM_PROCEDURE_BLOCK)
			{
				parent = tmp_symbol_record;
			}

			if (parent != NULL)
			{
				parent_name = parent->name;
			}

			if ((jam_current_block != NULL) &&
				(jam_current_block->type == JAM_PROCEDURE_BLOCK))
			{
				heap_record = (JAMS_HEAP_RECORD *) jam_current_block->value;

				if (heap_record != NULL)
				{
					uses_list = (char *) heap_record->data;
				}
			}

			if ((uses_list != NULL) && (parent_name != NULL))
			{
				name_begin = 0;
				ch_index = 0;
				while ((uses_list[ch_index] != JAMC_NULL_CHAR) &&
					(status != JAMC_SUCCESS))
				{
					name_end = 0;
					while ((uses_list[ch_index] != JAMC_NULL_CHAR) &&
						(!jam_is_name_char(uses_list[ch_index])))
					{
						++ch_index;
					}
					if (jam_is_name_char(uses_list[ch_index]))
					{
						name_begin = ch_index;
					}
					while ((uses_list[ch_index] != JAMC_NULL_CHAR) &&
						(jam_is_name_char(uses_list[ch_index])))
					{
						++ch_index;
					}
					name_end = ch_index;

					if (name_end > name_begin)
					{
						save_ch = uses_list[name_end];
						uses_list[name_end] = JAMC_NULL_CHAR;
						if (jam_strcmp(&uses_list[name_begin],
							parent_name) == 0)
						{
							/* symbol is in scope */
							status = JAMC_SUCCESS;
						}
						uses_list[name_end] = save_ch;
					}
				}
			}
		}
	}

	if (status == JAMC_SUCCESS)
	{
		if (symbol_record == NULL)
		{
			status = JAMC_INTERNAL_ERROR;
		}
		else
		{
			*symbol_record = tmp_symbol_record;
		}
	}
	return (status);
}

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_get_symbol_value
(
	JAME_SYMBOL_TYPE type,
	char *name,
	long *value
)

/*																			*/
/*	Description:	Gets the value of a symbol based on the name and		*/
/*					symbol type.											*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, else JAMC_UNDEFINED_SYMBOL	*/
/*					if symbol is not found									*/
/*																			*/
/****************************************************************************/
{
	JAM_RETURN_TYPE status = JAMC_UNDEFINED_SYMBOL;
	JAMS_SYMBOL_RECORD *symbol_record = NULL;

	status = jam_get_symbol_record(name, &symbol_record);

	if ((status == JAMC_SUCCESS) && (symbol_record != NULL))
	{
		/*
		*	If type and name match, return the value
		*/
		if (symbol_record->type == type)
		{
			if (value != NULL)
			{
				*value = symbol_record->value;
			}
			else
			{
				status = JAMC_INTERNAL_ERROR;
			}
		}
		else
		{
			status = JAMC_TYPE_MISMATCH;
		}
	}

	return (status);
}

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_set_symbol_value
(
	JAME_SYMBOL_TYPE type,
	char *name,
	long value
)

/*																			*/
/*	Description:	Assigns the value corresponding to a symbol, based on	*/
/*					the name and symbol type								*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, else JAMC_UNDEFINED_SYMBOL	*/
/*					if symbol is not found									*/
/*																			*/
/****************************************************************************/
{
	JAM_RETURN_TYPE status = JAMC_UNDEFINED_SYMBOL;
	JAMS_SYMBOL_RECORD *symbol_record = NULL;

	status = jam_get_symbol_record(name, &symbol_record);

	if ((status == JAMC_SUCCESS) && (symbol_record != NULL))
	{
		/* check for matching type... */
		if (symbol_record->type == type)
		{
			symbol_record->value = value;
		}
		else
		{
			status = JAMC_TYPE_MISMATCH;
		}
	}

	return (status);
}
