/****************************************************************************/
/*																			*/
/*	Module:			jamnote.c												*/
/*																			*/
/*					Copyright (C) Altera Corporation 1997					*/
/*																			*/
/*	Description:	Functions to extract NOTE fields from an JAM program	*/
/*																			*/
/****************************************************************************/

/****************************************************************************/
/*																			*/
/*	Actel version 1.1             May 2003									*/
/*																			*/
/****************************************************************************/

#include "jamexprt.h"
#include "jamdefs.h"
#include "jamexec.h"
#include "jamutil.h"

/****************************************************************************/
/*																			*/

BOOL jam_get_note_key
(
	char *statement_buffer,
	long *key_begin,
	long *key_end
)

/*																			*/
/*	Description:	This function finds the note key name in the statement	*/
/*					buffer and returns the start and end offsets			*/
/*																			*/
/*	Returns:		TRUE for success, FALSE if key not found				*/
/*																			*/
/****************************************************************************/
{
	int index = 0;
	BOOL quoted_string = FALSE;

	index = jam_skip_instruction_name(statement_buffer);

	/*
	*	Check if key string has quotes
	*/
	if ((statement_buffer[index] == JAMC_QUOTE_CHAR) &&
		(index < JAMC_MAX_STATEMENT_LENGTH))
	{
		quoted_string = TRUE;
		++index;
	}

	/*
	*	Mark the beginning of the key string
	*/
	*key_begin = index;

	/*
	*	Now find the end of the key string
	*/
	if (quoted_string)
	{
		/* look for matching quote */
		while ((statement_buffer[index] != JAMC_NULL_CHAR) &&
			(statement_buffer[index] != JAMC_QUOTE_CHAR) &&
			(index < JAMC_MAX_STATEMENT_LENGTH))
		{
			++index;
		}

		if (statement_buffer[index] == JAMC_QUOTE_CHAR)
		{
			*key_end = index;
		}
	}
	else
	{
		/* look for white space */
		while ((statement_buffer[index] != JAMC_NULL_CHAR) &&
			(!jam_isspace(statement_buffer[index])) &&
			(index < JAMC_MAX_STATEMENT_LENGTH))
		{
			++index;	/* skip over white space */
		}

		if (jam_isspace(statement_buffer[index]))
		{
			*key_end = index;
		}
	}

	return ((*key_end > *key_begin) ? TRUE : FALSE);
}

/****************************************************************************/
/*																			*/

BOOL jam_get_note_value
(
	char *statement_buffer,
	long *value_begin,
	long *value_end
)

/*																			*/
/*	Description:	Finds the value field of a NOTE.  Could be enclosed in	*/
/*					quotation marks, or could not be.  Must be followed by	*/
/*					a semicolon.											*/
/*																			*/
/*	Returns:		TRUE for success, FALSE for failure						*/
/*																			*/
/****************************************************************************/
{
	int index = 0;
	BOOL quoted_string = FALSE;
	BOOL status = FALSE;

	/* skip over white space */
	while ((statement_buffer[index] != JAMC_NULL_CHAR) &&
		(jam_isspace(statement_buffer[index])) &&
		(index < JAMC_MAX_STATEMENT_LENGTH))
	{
		++index;
	}

	/*
	*	Check if value string has quotes
	*/
	if ((statement_buffer[index] == JAMC_QUOTE_CHAR) &&
		(index < JAMC_MAX_STATEMENT_LENGTH))
	{
		quoted_string = TRUE;
		++index;
	}

	/*
	*	Mark the beginning of the value string
	*/
	*value_begin = index;

	/*
	*	Now find the end of the value string
	*/
	if (quoted_string)
	{
		/* look for matching quote */
		while ((statement_buffer[index] != JAMC_NULL_CHAR) &&
			(statement_buffer[index] != JAMC_QUOTE_CHAR) &&
			(index < JAMC_MAX_STATEMENT_LENGTH))
		{
			++index;
		}

		if (statement_buffer[index] == JAMC_QUOTE_CHAR)
		{
			*value_end = index;
			status = TRUE;
			++index;
		}
	}
	else
	{
		/* look for white space or semicolon */
		while ((statement_buffer[index] != JAMC_NULL_CHAR) &&
			(statement_buffer[index] != JAMC_SEMICOLON_CHAR) &&
			(!jam_isspace(statement_buffer[index])) &&
			(index < JAMC_MAX_STATEMENT_LENGTH))
		{
			++index;	/* skip over non-white space */
		}

		if ((statement_buffer[index] == JAMC_SEMICOLON_CHAR) ||
			(jam_isspace(statement_buffer[index])))
		{
			*value_end = index;
			status = TRUE;
		}
	}

	if (status)
	{
		while ((statement_buffer[index] != JAMC_NULL_CHAR) &&
			(jam_isspace(statement_buffer[index])) &&
			(index < JAMC_MAX_STATEMENT_LENGTH))
		{
			++index;	/* skip over white space */
		}

		/*
		*	Next character must be semicolon
		*/
		if (statement_buffer[index] != JAMC_SEMICOLON_CHAR)
		{
			status = FALSE;
		}
	}

	return (status);
}

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_get_note
(
	char *program,
	long program_size,
	long *offset,
	char *key,
	char *value,
	int length
)

/*																			*/
/*	Description:	Gets key and value of NOTE fields in the JAM file.		*/
/*					Can be called in two modes:  if offset pointer is NULL,	*/
/*					then the function searches for note fields which match 	*/
/*					the key string provided.  If offset is not NULL, then	*/
/*					the function finds the next note field of any key,		*/
/*					starting at the offset specified by the offset pointer.	*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, else appropriate error code	*/
/*																			*/
/****************************************************************************/
{
	JAM_RETURN_TYPE status = JAMC_SUCCESS;
	char statement_buffer[JAMC_MAX_STATEMENT_LENGTH + 1];
	char label_buffer[JAMC_MAX_NAME_LENGTH + 1];
	JAME_INSTRUCTION instruction = JAM_ILLEGAL_INSTR;
	long key_begin = 0L;
	long key_end = 0L;
	long value_begin = 0L;
	long value_end = 0L;
	BOOL done = FALSE;
	char *tmp_program = jam_program;
	long tmp_program_size = jam_program_size;
	long tmp_current_file_position = jam_current_file_position;
	long tmp_current_statement_position = jam_current_statement_position;
	long tmp_next_statement_position = jam_next_statement_position;

	jam_program = program;
	jam_program_size = program_size;

	jam_current_statement_position = 0L;
	jam_next_statement_position = 0L;

	if (offset == NULL)
	{
		/*
		*	We will search for the first note with a specific key, and
		*	return only the value
		*/
		status = jam_seek(0L);
		jam_current_file_position = 0L;
	}
	else
	{
		/*
		*	We will search for the next note, regardless of the key, and
		*	return both the value and the key
		*/
		status = jam_seek(*offset);
		jam_current_file_position = *offset;
	}

	/*
	*	Get program statements and look for NOTE statements
	*/
	while ((!done) && (status == JAMC_SUCCESS))
	{
		status = jam_get_statement(statement_buffer, label_buffer);

		if (status == JAMC_SUCCESS)
		{
			instruction = jam_get_instruction(statement_buffer);

			if (instruction == JAM_NOTE_INSTR)
			{
				if (jam_get_note_key(statement_buffer, &key_begin, &key_end))
				{
					statement_buffer[key_end] = JAMC_NULL_CHAR;

					if ((offset != NULL) || (jam_stricmp(
						key, &statement_buffer[key_begin]) == 0))
					{
						if (jam_get_note_value(&statement_buffer[key_end + 1],
							&value_begin, &value_end))
						{
							done = TRUE;
							value_begin += (key_end + 1);
							value_end += (key_end + 1);
							statement_buffer[value_end] = JAMC_NULL_CHAR;

							if (offset != NULL)
							{
								*offset = jam_current_file_position;
							}
						}
						else
						{
							status = JAMC_SYNTAX_ERROR;
						}
					}
				}
				else
				{
					status = JAMC_SYNTAX_ERROR;
				}
			}
		}
	}

	/*
	*	Copy the key and value strings into buffers provided
	*/
	if (done && (status == JAMC_SUCCESS))
	{
		if (offset != NULL)
		{
			/* only copy the key string if we were looking for all NOTEs */
			jam_strncpy(
				key, &statement_buffer[key_begin], JAMC_MAX_NAME_LENGTH);
		}
		jam_strncpy(value, &statement_buffer[value_begin], length);
	}

	jam_program = tmp_program;
	jam_program_size = tmp_program_size;
	jam_current_file_position = tmp_current_file_position;
	jam_current_statement_position = tmp_current_statement_position;
	jam_next_statement_position = tmp_next_statement_position;

	return (status);
}
