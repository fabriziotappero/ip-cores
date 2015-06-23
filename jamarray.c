/****************************************************************************/
/*																			*/
/*	Module:			jamarray.c												*/
/*																			*/
/*					Copyright (C) Altera Corporation 1997					*/
/*																			*/
/*	Description:	Contains array management functions, including			*/
/*					functions for reading array initialization data in		*/
/*					compressed formats.										*/
/*																			*/
/*	Revisions:		1.1	added support for dynamic memory allocation			*/
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
#include "jamexp.h"
#include "jamsym.h"
#include "jamstack.h"
#include "jamheap.h"
#include "jamutil.h"
#include "jamcomp.h"
#include "jamarray.h"

/*
*	Table of names of Boolean data representation schemes
*/
struct JAMS_BOOL_REP_MAP
{
	JAME_BOOLEAN_REP rep;
	char string[4];
} jam_bool_rep_table[] =
{
	{ JAM_BOOL_BINARY,      "BIN" },
	{ JAM_BOOL_HEX,         "HEX" },
	{ JAM_BOOL_RUN_LENGTH,  "RLC" },
	{ JAM_BOOL_COMPRESSED,  "ACA" },
};

#define JAMC_BOOL_REP_COUNT \
  ((int) (sizeof(jam_bool_rep_table) / sizeof(jam_bool_rep_table[0])))

#define JAMC_DICTIONARY_SIZE 4096

typedef enum
{
	JAM_CONSTANT_ZEROS,
	JAM_CONSTANT_ONES,
	JAM_RANDOM

} JAME_RLC_BLOCK_TYPE;

JAM_RETURN_TYPE jam_reverse_boolean_array_bin
(
	JAMS_HEAP_RECORD *heap_record
)
{
	long *heap_data = &heap_record->data[0];
	long dimension = heap_record->dimension;
	int a, b;
	long i, j;

	for (i = 0; i < dimension / 2; ++i)
	{
		j = (dimension - 1) - i;
		a = (heap_data[i >> 5] & (1L << (i & 0x1f))) ? 1 : 0;
		b = (heap_data[j >> 5] & (1L << (j & 0x1f))) ? 1 : 0;
		if (a)
		{
			heap_data[j >> 5] |= (1L << (j & 0x1f));
		}
		else
		{
			heap_data[j >> 5] &= ~(1L << (j & 0x1f));
		}
		if (b)
		{
			heap_data[i >> 5] |= (1L << (i & 0x1f));
		}
		else
		{
			heap_data[i >> 5] &= ~(1L << (i & 0x1f));
		}
	}

	return (JAMC_SUCCESS);
}

JAM_RETURN_TYPE jam_reverse_boolean_array_hex
(
	JAMS_HEAP_RECORD *heap_record
)
{
	long *heap_data = &heap_record->data[0];
	long nibbles = (heap_record->dimension + 3) / 4;
	long a, b, i, j;

	for (i = 0; i < nibbles / 2; ++i)
	{
		j = (nibbles - 1) - i;
		a = (heap_data[i >> 3] >> ((i & 7) << 2)) & 0x0f;
		b = (heap_data[j >> 3] >> ((j & 7) << 2)) & 0x0f;
		heap_data[j >> 3] &= ~(0x0fL << ((j & 7) << 2));
		heap_data[j >> 3] |= (a << ((j & 7) << 2));
		heap_data[i >> 3] &= ~(0x0fL << ((i & 7) << 2));
		heap_data[i >> 3] |= (b << ((i & 7) << 2));
	}

	return (JAMC_SUCCESS);
}

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_extract_bool_comma_sep
(
	JAMS_HEAP_RECORD *heap_record,
	char *statement_buffer
)

/*																			*/
/*	Description:	Extracts Boolean array data from statement buffer.		*/
/*					Works on data in comma separated representation.		*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, else appropriate error code	*/
/*																			*/
/****************************************************************************/
{
	int index = 0;
	int expr_begin = 0;
	int expr_end = 0;
	char save_ch = 0;
	long address = 0L;
	long value = 0L;
	long dimension = heap_record->dimension;
	JAME_EXPRESSION_TYPE expr_type = JAM_ILLEGAL_EXPR_TYPE;
	JAM_RETURN_TYPE status = JAMC_SUCCESS;
	long *heap_data = &heap_record->data[0];

	for (address = 0L; (status == JAMC_SUCCESS) && (address < dimension);
		++address)
	{
		status = JAMC_SYNTAX_ERROR;

		while ((jam_isspace(statement_buffer[index])) &&
			(index < JAMC_MAX_STATEMENT_LENGTH))
		{
			++index;	/* skip over white space */
		}

		expr_begin = index;
		expr_end = 0;

		while ((statement_buffer[index] != JAMC_COMMA_CHAR) &&
			(statement_buffer[index] != JAMC_SEMICOLON_CHAR) &&
			(index < JAMC_MAX_STATEMENT_LENGTH))
		{
			++index;	/* skip over the expression */
		}

		if ((statement_buffer[index] == JAMC_COMMA_CHAR) ||
			(statement_buffer[index] == JAMC_SEMICOLON_CHAR))
		{
			expr_end = index;
		}

		if (expr_end > expr_begin)
		{
			save_ch = statement_buffer[expr_end];
			statement_buffer[expr_end] = JAMC_NULL_CHAR;
			status = jam_evaluate_expression(
				&statement_buffer[expr_begin], &value, &expr_type);
			statement_buffer[expr_end] = save_ch;
		}

		if ((status == JAMC_SUCCESS) &&
			((expr_type != JAM_BOOLEAN_EXPR) &&
			(expr_type != JAM_INT_OR_BOOL_EXPR)))
		{
			status = JAMC_TYPE_MISMATCH;
		}

		if (status == JAMC_SUCCESS)
		{
			if (value == 0L)
			{
				/* clear a single bit */
				heap_data[address >> 5] &=
					(~(unsigned long)(1L << (address & 0x1f)));
			}
			else if (value == 1L)
			{
				/* set a single bit */
				heap_data[address >> 5] |= (1L << (address & 0x1f));
			}
			else
			{
				status = JAMC_SYNTAX_ERROR;
			}

			if ((address < dimension) &&
				(statement_buffer[index] == JAMC_COMMA_CHAR))
			{
				++index;
			}
		}
	}

	if (status == JAMC_SUCCESS)
	{
		while ((jam_isspace(statement_buffer[index])) &&
			(index < JAMC_MAX_STATEMENT_LENGTH))
		{
			++index;	/* skip over white space */
		}

		if (statement_buffer[index] != JAMC_SEMICOLON_CHAR)
		{
			status = JAMC_SYNTAX_ERROR;
		}
	}

	return (status);
}

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_extract_bool_binary
(
	JAMS_HEAP_RECORD *heap_record,
	char *statement_buffer
)

/*																			*/
/*	Description:	Extracts Boolean array data from statement buffer.		*/
/*					Works on data in binary (001100100101) representation.	*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, else appropriate error code	*/
/*																			*/
/****************************************************************************/
{
	int index = 0;
	long address = 0L;
	long dimension = heap_record->dimension;
	JAM_RETURN_TYPE status = JAMC_SUCCESS;
	long *heap_data = &heap_record->data[0];

	for (address = 0L; (status == JAMC_SUCCESS) && (address < dimension);
		++address)
	{
		while ((jam_isspace(statement_buffer[index])) &&
			(index < JAMC_MAX_STATEMENT_LENGTH))
		{
			++index;	/* skip over white space */
		}

		if (statement_buffer[index] == '0')
		{
			/* clear a single bit */
			heap_data[address >> 5] &=
				(~(unsigned long)(1L << (address & 0x1f)));
		}
		else if (statement_buffer[index] == '1')
		{
			/* set a single bit */
			heap_data[address >> 5] |= (1L << (address & 0x1f));
		}
		else
		{
			status = JAMC_SYNTAX_ERROR;
		}

		++index;
	}

	if (status == JAMC_SUCCESS)
	{
		while ((jam_isspace(statement_buffer[index])) &&
			(index < JAMC_MAX_STATEMENT_LENGTH))
		{
			++index;	/* skip over white space */
		}

		if (statement_buffer[index] != JAMC_SEMICOLON_CHAR)
		{
			status = JAMC_SYNTAX_ERROR;
		}
	}

	return (status);
}

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_extract_bool_hex
(
	JAMS_HEAP_RECORD *heap_record,
	char *statement_buffer
)

/*																			*/
/*	Description:	Extracts Boolean array data from statement buffer.		*/
/*					Works on data in hexadecimal (3BA97C0F) representation.	*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, else appropriate error code	*/
/*																			*/
/****************************************************************************/
{
	int index = 0;
	int ch = 0;
	long data = 0L;
	long nibble = 0L;
	long nibbles = 0L;
	JAM_RETURN_TYPE status = JAMC_SUCCESS;
	long *heap_data = &heap_record->data[0];

	/* compute number of hex digits expected */
	nibbles = (heap_record->dimension >> 2) +
		((heap_record->dimension & 3) ? 1 : 0);

	for (nibble = 0L; (status == JAMC_SUCCESS) && (nibble < nibbles); ++nibble)
	{
		while ((jam_isspace(statement_buffer[index])) &&
			(index < JAMC_MAX_STATEMENT_LENGTH))
		{
			++index;	/* skip over white space */
		}

		ch = (int) statement_buffer[index];

		if ((ch >= 'A') && (ch <= 'F'))
		{
			data = (long) (ch + 10 - 'A');
		}
		else if ((ch >= 'a') && (ch <= 'f'))
		{
			data = (long) (ch + 10 - 'a');
		}
		else if ((ch >= '0') && (ch <= '9'))
		{
			data = (long) (ch - '0');
		}
		else
		{
			status = JAMC_SYNTAX_ERROR;
		}

		if (status == JAMC_SUCCESS)
		{
			/* modify four bits of data in the array */
			heap_data[nibble >> 3] = (heap_data[nibble >> 3] & 
				(~(unsigned long) (15L << ((nibble & 7) << 2)))) |
				(data << ((nibble & 7) << 2));
		}

		++index;
	}

	if (status == JAMC_SUCCESS)
	{
		while ((jam_isspace(statement_buffer[index])) &&
			(index < JAMC_MAX_STATEMENT_LENGTH))
		{
			++index;	/* skip over white space */
		}

		if (statement_buffer[index] != JAMC_SEMICOLON_CHAR)
		{
			status = JAMC_SYNTAX_ERROR;
		}
	}

	return (status);
}

/****************************************************************************/
/*																			*/

int jam_6bit_char(int ch)

/*																			*/
/*	Description:	Extracts numeric value from ASCII character code,		*/
/*					based on character mapping defined in JAM language		*/
/*					specification.  Numeric value is in range 0 to 63.		*/
/*					Used for RLC and ACA data representations.				*/
/*																			*/
/*	Returns:		Integer value in range 0 to 63, or -1 for error.		*/ 
/*																			*/
/****************************************************************************/
{
	int result = 0;

	if ((ch >= '0') && (ch <= '9')) result = (ch - '0');
	else if ((ch >= 'A') && (ch <= 'Z')) result = (ch + 10 - 'A');
	else if ((ch >= 'a') && (ch <= 'z')) result = (ch + 36 - 'a');
	else if (ch == '_') result = 62;
	else if (ch == '@') result = 63;
	else result = -1;	/* illegal character */

	return (result);
}

/****************************************************************************/
/*																			*/

BOOL jam_rlc_key_char
(
	int ch,
	JAME_RLC_BLOCK_TYPE *block_type,
	int *count_size
)

/*																			*/
/*	Description:	Decodes RLC block ID character.  Returns block type		*/
/*					and count size (number of count characters in the		*/
/*					block) by reference.									*/
/*																			*/
/*	Returns:		TRUE for success, FALSE if illegal block ID character	*/
/*																			*/
/****************************************************************************/
{
	BOOL status = TRUE;

	if ((ch >= 'A') && (ch <= 'E'))
	{
		*block_type = JAM_CONSTANT_ZEROS;
		*count_size = (ch + 1 - 'A');
	}
	else if ((ch >= 'I') && (ch <= 'M'))
	{
		*block_type = JAM_CONSTANT_ONES;
		*count_size = (ch + 1 - 'I');
	}
	else if ((ch >= 'Q') && (ch <= 'U'))
	{
		*block_type = JAM_RANDOM;
		*count_size = (ch + 1 - 'Q');
	}
	else
	{
		status = FALSE;
	}

	return (status);
}

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_extract_bool_run_length
(
	JAMS_HEAP_RECORD *heap_record,
	char *statement_buffer
)

/*																			*/
/*	Description:	Extracts Boolean array data from statement buffer.		*/
/*					Works on data encoded using RLC (run-length compressed)	*/
/*					representation.											*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, else appropriate error code	*/
/*																			*/
/****************************************************************************/
{
	int index = 0;
	int index2 = 0;
	int count_index = 0;
	int count_size = 0;
	int value = 0;
	long bit = 0L;
	long count = 0L;
	long address = 0L;
	long dimension = heap_record->dimension;
	JAME_RLC_BLOCK_TYPE block_type = JAM_CONSTANT_ZEROS;
	JAM_RETURN_TYPE status = JAMC_SUCCESS;
	long *heap_data = &heap_record->data[0];

	/* remove all white space */
	while (statement_buffer[index] != JAMC_NULL_CHAR)
	{
		if (!jam_isspace(statement_buffer[index]))
		{
			statement_buffer[index2] = statement_buffer[index];
			++index2;
		}
		++index;
	}
	statement_buffer[index2] = JAMC_NULL_CHAR;

	index = 0;
	while ((status == JAMC_SUCCESS) && (address < dimension))
	{
		if (jam_rlc_key_char(statement_buffer[index], &block_type, &count_size))
		{
			++index;

			count = 0L;
			for (count_index = 0; count_index < count_size; ++count_index)
			{
				count <<= 6;
				value = jam_6bit_char(statement_buffer[index]);
				if (value == -1)
				{
					status = JAMC_SYNTAX_ERROR;
				}
				else
				{
					count |= value;
				}
				++index;
			}

			if (status == JAMC_SUCCESS)
			{
				switch (block_type)
				{
				case JAM_CONSTANT_ZEROS:
					for (bit = 0; bit < count; bit++)
					{
						/* add zeros to array */
						heap_data[address >> 5] &=
							~(unsigned long) (1L << (address & 0x1f));
						++address;
					}
					break;

				case JAM_CONSTANT_ONES:
					for (bit = 0; bit < count; bit++)
					{
						/* add ones to array */
						heap_data[address >> 5] |= (1L << (address & 0x1f));
						++address;
					}
					break;

				case JAM_RANDOM:
					for (bit = 0; bit < count; bit++)
					{
						/* add random data to array */
						value = jam_6bit_char(statement_buffer[index + (bit / 6)]);
						if (value == -1)
						{
							status = JAMC_SYNTAX_ERROR;
						}
						else if (value & (1 << (bit % 6)))
						{
							heap_data[address >> 5] |= (1L << (address & 0x1f));
						}
						else
						{
							heap_data[address >> 5] &=
								~(unsigned long) (1L << (address & 0x1f));
						}
						++address;
					}
					index = index + (int)((count / 6) + ((count % 6) ? 1 : 0));
					break;

				default:
					status = JAMC_SYNTAX_ERROR;
					break;
				}
			}
		}
		else
		{
			/* unrecognized key character */
			status = JAMC_SYNTAX_ERROR;
		}
	}

	if ((status == JAMC_SUCCESS) &&
		(statement_buffer[index] != JAMC_SEMICOLON_CHAR))
	{
		status = JAMC_SYNTAX_ERROR;
	}

	if ((status == JAMC_SUCCESS) && (address != dimension))
	{
		status = JAMC_SYNTAX_ERROR;
	}

	return (status);
}

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_extract_bool_compressed
(
	JAMS_HEAP_RECORD *heap_record,
	char *statement_buffer
)

/*																			*/
/*	Description:	Extracts Boolean array data from statement buffer.		*/
/*					Works on data encoded using ACA representation.			*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, else appropriate error code	*/
/*																			*/
/****************************************************************************/
{
	int bit = 0;
	int word = 0;
	int value = 0;
	int index = 0;
	int index2 = 0;
	long uncompressed_length = 0L;
	char *ch_data = NULL;
	long out_size = 0L;
	long address = 0L;
	long *heap_data = &heap_record->data[0];
	JAM_RETURN_TYPE status = JAMC_SUCCESS;

	/* remove all white space */
	while (statement_buffer[index] != JAMC_NULL_CHAR)
	{
		if (!jam_isspace(statement_buffer[index]))
		{
			statement_buffer[index2] = statement_buffer[index];
			++index2;
		}
		++index;
	}
	statement_buffer[index2] = JAMC_NULL_CHAR;

	/* convert 6-bit encoded characters to binary -- in the same buffer */
	index = 0;
	while ((status == JAMC_SUCCESS) &&
		(statement_buffer[index] != JAMC_NULL_CHAR) &&
		(statement_buffer[index] != JAMC_SEMICOLON_CHAR))
	{
		value = jam_6bit_char(statement_buffer[index]);
		statement_buffer[index] = 0;

		if (value == -1)
		{
			status = JAMC_SYNTAX_ERROR;
		}
		else
		{
			for (bit = 0; bit < 6; ++bit)
			{
				if (value & (1 << (bit % 6)))
				{
					statement_buffer[address >> 3] |= (1L << (address & 7));
				}
				else
				{
					statement_buffer[address >> 3] &=
						~(unsigned int) (1 << (address & 7));
				}
				++address;
			}
		}

		++index;
	}

	if ((status == JAMC_SUCCESS) &&
		(statement_buffer[index] != JAMC_SEMICOLON_CHAR))
	{
		status = JAMC_SYNTAX_ERROR;
	}

	/*
	*	We need two memory buffers:
	*
	*	in   (length of compressed bitstream)
	*	out  (length of uncompressed bitstream)
	*
	*	The statement buffer is re-used for the "in" buffer.  The "out"
	*	buffer is inside the heap record.
	*/

	if (status == JAMC_SUCCESS)
	{
		/*
		*	Uncompress the data
		*/
		out_size = (heap_record->dimension >> 3) +
			((heap_record->dimension & 7) ? 1 : 0);

		uncompressed_length = jam_uncompress(
			statement_buffer, 
			(address >> 3) + ((address & 7) ? 1 : 0),
			(char *)heap_data,
			out_size,
			jam_version);

		if (uncompressed_length != out_size)
		{
			status = JAMC_SYNTAX_ERROR;
		}
		else
		{
			/* convert data from bytes into 32-bit words */
			out_size = (heap_record->dimension >> 5) +
				((heap_record->dimension & 0x1f) ? 1 : 0);
			ch_data = (char *)heap_data;

			for (word = 0; word < out_size; ++word)
			{
				heap_data[word] =
					((((long) ch_data[(word * 4) + 3]) & 0xff) << 24L) |
					((((long) ch_data[(word * 4) + 2]) & 0xff) << 16L) |
					((((long) ch_data[(word * 4) + 1]) & 0xff) << 8L) |
					(((long) ch_data[word * 4]) & 0xff);
			}
		}
	}

	return (status);
}

/****************************************************************************/
/*																			*/

int jam_get_real_char(void)

/*																			*/
/*	Description:	Gets next character from input stream, eliminating		*/
/*					white space and comments.								*/
/*																			*/
/*	Returns:		Character code, or EOF if no characters available		*/
/*																			*/
/****************************************************************************/
{
	int ch = 0;
	BOOL comment = FALSE;
	BOOL found = FALSE;
	JAM_RETURN_TYPE status = JAMC_SUCCESS;

	while ((status == JAMC_SUCCESS) && (!found))
	{
		ch = jam_getc();

		if ((!comment) && (ch == JAMC_COMMENT_CHAR))
		{
			/* beginning of comment */
			comment = TRUE;
		}

		if (!comment)
		{
			if (!jam_isspace((char) ch))
			{
				found = TRUE;
			}
		}

		if (ch == EOF)
		{
			/* end of file */
			status = JAMC_UNEXPECTED_END;
		}

		if (comment &&
			((ch == JAMC_NEWLINE_CHAR) || (ch == JAMC_RETURN_CHAR)))
		{
			/* end of comment */
			comment = FALSE;
		}
	}

	return (ch);
}

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_read_bool_comma_sep
(
	JAMS_HEAP_RECORD *heap_record
)

/*																			*/
/*	Description:	Reads Boolean array data directly from input stream.	*/
/*					Works on data in comma separated representation.		*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, else appropriate error code	*/
/*																			*/
/****************************************************************************/
{
	int index = 0;
	int ch = 0;
	long address = 0L;
	long value = 0L;
	long dimension = heap_record->dimension;
	char expr_buffer[JAMC_MAX_STATEMENT_LENGTH + 1];
	JAME_EXPRESSION_TYPE expr_type = JAM_ILLEGAL_EXPR_TYPE;
	JAM_RETURN_TYPE status = JAMC_SUCCESS;
	long *heap_data = &heap_record->data[0];

	if (jam_seek(heap_record->position) != 0)
	{
		status = JAMC_IO_ERROR;
	}

	while ((status == JAMC_SUCCESS) && (address < dimension))
	{
		ch = jam_get_real_char();

		if (((ch == JAMC_COMMA_CHAR) && (address < (dimension - 1))) ||
			((ch == JAMC_SEMICOLON_CHAR) && (address == (dimension - 1))))
		{
			expr_buffer[index] = JAMC_NULL_CHAR;
			index = 0;

			status = jam_evaluate_expression(
				expr_buffer, &value, &expr_type);

			if ((status == JAMC_SUCCESS) &&
				((expr_type != JAM_BOOLEAN_EXPR) &&
				(expr_type != JAM_INT_OR_BOOL_EXPR)))
			{
				status = JAMC_TYPE_MISMATCH;
			}

			if (status == JAMC_SUCCESS)
			{
				if (value == 0L)
				{
					/* clear a single bit */
					heap_data[address >> 5] &=
						(~(unsigned long)(1L << (address & 0x1f)));
					++address;
				}
				else if (value == 1L)
				{
					/* set a single bit */
					heap_data[address >> 5] |= (1L << (address & 0x1f));
					++address;
				}
				else
				{
					status = JAMC_TYPE_MISMATCH;
				}
			}
		}
		else
		{
			expr_buffer[index] = (char) ch;

			if (index < JAMC_MAX_STATEMENT_LENGTH)
			{
				++index;
			}
			else
			{
				/* expression was too long */
				status = JAMC_SYNTAX_ERROR;
			}
		}

		if (ch == EOF)
		{
			/* end of file */
			status = JAMC_UNEXPECTED_END;
		}
	}

	return (status);
}

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_read_bool_binary
(
	JAMS_HEAP_RECORD *heap_record
)

/*																			*/
/*	Description:	Reads Boolean array data directly from input stream.	*/
/*					Works on data in binary (001100100101) representation.	*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, else appropriate error code	*/
/*																			*/
/****************************************************************************/
{
	int ch = 0;
	long address = 0L;
	long dimension = heap_record->dimension;
	JAM_RETURN_TYPE status = JAMC_SUCCESS;
	long *heap_data = &heap_record->data[0];

	if (jam_seek(heap_record->position) != 0)
	{
		status = JAMC_IO_ERROR;
	}

	while ((status == JAMC_SUCCESS) && (address < dimension))
	{
		ch = jam_get_real_char();

		if (ch == '0')
		{
			/* clear a single bit */
			heap_data[address >> 5] &=
				(~(unsigned long)(1L << (address & 0x1f)));
			++address;
		}
		else if (ch == '1')
		{
			/* set a single bit */
			heap_data[address >> 5] |= (1L << (address & 0x1f));
			++address;
		}
		else
		{
			status = JAMC_SYNTAX_ERROR;
		}

		if (ch == EOF)
		{
			/* end of file */
			status = JAMC_UNEXPECTED_END;
		}
	}

	if (status == JAMC_SUCCESS)
	{
		ch = jam_get_real_char();

		if (ch != JAMC_SEMICOLON_CHAR)
		{
			status = JAMC_SYNTAX_ERROR;
		}
	}

	return (status);
}

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_read_bool_hex
(
	JAMS_HEAP_RECORD *heap_record
)

/*																			*/
/*	Description:	Reads Boolean array data directly from input stream.	*/
/*					Works on data in hexadecimal (3BA97C0F) representation.	*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, else appropriate error code	*/
/*																			*/
/****************************************************************************/
{
	int ch = 0;
	long data = 0L;
	long nibble = 0L;
	long nibbles = 0L;
	JAM_RETURN_TYPE status = JAMC_SUCCESS;
	long *heap_data = &heap_record->data[0];

	/* compute number of hex digits expected */
	nibbles = (heap_record->dimension >> 2) +
		((heap_record->dimension & 3) ? 1 : 0);

	if (jam_seek(heap_record->position) != 0)
	{
		status = JAMC_IO_ERROR;
	}

	while ((status == JAMC_SUCCESS) && (nibble < nibbles))
	{
		ch = jam_get_real_char();

		if ((ch >= 'A') && (ch <= 'F'))
		{
			data = (long) (ch + 10 - 'A');
		}
		else if ((ch >= 'a') && (ch <= 'f'))
		{
			data = (long) (ch + 10 - 'a');
		}
		else if ((ch >= '0') && (ch <= '9'))
		{
			data = (long) (ch - '0');
		}
		else
		{
			status = JAMC_SYNTAX_ERROR;
		}

		if (status == JAMC_SUCCESS)
		{
			/* modify four bits of data in the array */
			heap_data[nibble >> 3] = (heap_data[nibble >> 3] & 
				(~(unsigned long) (15L << ((nibble & 7) << 2)))) |
				(data << ((nibble & 7) << 2));
			++nibble;
		}

		if (ch == EOF)
		{
			/* end of file */
			status = JAMC_UNEXPECTED_END;
		}
	}

	return (status);
}

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_read_bool_run_length
(
	JAMS_HEAP_RECORD *heap_record
)

/*																			*/
/*	Description:	Reads Boolean array data directly from input stream.	*/
/*					Works on data encoded using RLC (run-length compressed)	*/
/*					representation.											*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, else appropriate error code	*/
/*																			*/
/****************************************************************************/
{
	int ch = 0;
	int count_index = 0;
	int count_size = 0;
	int value = 0;
	long bit = 0L;
	long count = 0L;
	long address = 0L;
	long dimension = heap_record->dimension;
	JAME_RLC_BLOCK_TYPE block_type = JAM_CONSTANT_ZEROS;
	JAM_RETURN_TYPE status = JAMC_SUCCESS;
	long *heap_data = &heap_record->data[0];

	if (jam_seek(heap_record->position) != 0)
	{
		status = JAMC_IO_ERROR;
	}

	while ((status == JAMC_SUCCESS) && (address < dimension))
	{
		if (jam_rlc_key_char(jam_get_real_char(), &block_type, &count_size))
		{
			count = 0L;
			for (count_index = 0; count_index < count_size; ++count_index)
			{
				count <<= 6;
				value = jam_6bit_char(jam_get_real_char());
				if (value == -1)
				{
					status = JAMC_SYNTAX_ERROR;
				}
				else
				{
					count += (long) value;
				}
			}

			switch (block_type)
			{
			case JAM_CONSTANT_ZEROS:
				for (bit = 0; bit < count; bit++)
				{
					/* add zeros to array */
					heap_data[address >> 5] &=
						~(unsigned long) (1L << (address & 0x1f));
					++address;
				}
				break;

			case JAM_CONSTANT_ONES:
				for (bit = 0; bit < count; bit++)
				{
					/* add ones to array */
					heap_data[address >> 5] |= (1L << (address & 0x1f));
					++address;
				}
				break;

			case JAM_RANDOM:
				for (bit = 0; bit < count; bit++)
				{
					/* add random data to array */
					if ((bit % 6) == 0)
					{
						value = jam_6bit_char(jam_get_real_char());

						if (value == -1)
						{
							status = JAMC_SYNTAX_ERROR;
						}
					}

					if (value & (1 << ((int)(bit % 6))))
					{
						heap_data[address >> 5] |= (1L << (address & 0x1f));
					}
					else
					{
						heap_data[address >> 5] &=
							~(unsigned long) (1L << (address & 0x1f));
					}
					++address;
				}
				break;

			default:
				status = JAMC_SYNTAX_ERROR;
				break;
			}
		}
		else
		{
			/* unrecognized key character */
			status = JAMC_SYNTAX_ERROR;
		}
	}

	ch = jam_get_real_char();

	if (ch == EOF)
	{
		status = JAMC_UNEXPECTED_END;
	}

	if ((status == JAMC_SUCCESS) &&
		((ch != JAMC_SEMICOLON_CHAR) || (address != dimension)))
	{
		status = JAMC_SYNTAX_ERROR;
	}

	return (status);
}

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_read_bool_compressed
(
	JAMS_HEAP_RECORD *heap_record
)

/*																			*/
/*	Description:	Reads Boolean array data directly from input stream.	*/
/*					Works on data encoded using ACA representation.			*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, else appropriate error code	*/
/*																			*/
/****************************************************************************/
{
	int ch = 0;
	int bit = 0;
	int word = 0;
	int value = 0;
	long uncompressed_length = 0L;
	char *in = NULL;
	char *ch_data = NULL;
	long in_size = 0L;
	long out_size = 0L;
	long address = 0L;
	BOOL done = FALSE;
	long *heap_data = &heap_record->data[0];
	JAM_RETURN_TYPE status = JAMC_SUCCESS;

	if (jam_seek(heap_record->position) != 0)
	{
		status = JAMC_IO_ERROR;
	}

	/*
	*	We need two memory buffers:
	*
	*	in   (length of compressed bitstream)
	*	out  (length of uncompressed bitstream)
	*
	*	The "out" buffer is inside the heap record.  The "in" buffer
	*	resides in temporary storage above the last heap record.
	*/

	out_size = (heap_record->dimension >> 3) +
		((heap_record->dimension & 7) ? 1 : 0);
	in = jam_get_temp_workspace(out_size + (out_size / 10) + 100);
	if (in == NULL)
	{
		status = JAMC_OUT_OF_MEMORY;
	}

	while ((status == JAMC_SUCCESS) && (!done))
	{
		ch = jam_get_real_char();

		if (ch == JAMC_SEMICOLON_CHAR)
		{
			done = TRUE;
		}
		else
		{
			value = jam_6bit_char(ch);

			if (value == -1)
			{
				status = JAMC_SYNTAX_ERROR;
			}
			else
			{
				for (bit = 0; bit < 6; ++bit)
				{
					if (value & (1 << (bit % 6)))
					{
						in[address >> 3] |= (1L << (address & 7));
					}
					else
					{
						in[address >> 3] &=
							~(unsigned int) (1 << (address & 7));
					}
					++address;
				}
			}
		}
	}

	if (done && (status == JAMC_SUCCESS))
	{
		/*
		*	Uncompress the data
		*/
		in_size = (address >> 3) + ((address & 7) ? 1 : 0);
		uncompressed_length = jam_uncompress(
			in, in_size, (char *)heap_data, out_size, jam_version);

		if (uncompressed_length != out_size)
		{
			status = JAMC_SYNTAX_ERROR;
		}
		else
		{
			/* convert data from bytes into 32-bit words */
			out_size = (heap_record->dimension >> 5) +
				((heap_record->dimension & 0x1f) ? 1 : 0);
			ch_data = (char *)heap_data;

			for (word = 0; word < out_size; ++word)
			{
				heap_data[word] =
					((((long) ch_data[(word * 4) + 3]) & 0xff) << 24L) |
					((((long) ch_data[(word * 4) + 2]) & 0xff) << 16L) |
					((((long) ch_data[(word * 4) + 1]) & 0xff) << 8L) |
					(((long) ch_data[word * 4]) & 0xff);
			}
		}
	}

	if (in != NULL) jam_free_temp_workspace(in);

	return (status);
}

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_read_boolean_array_data
(
	JAMS_HEAP_RECORD *heap_record,
	char *statement_buffer
)

/*																			*/
/*	Description:	Reads Boolean array initialization data.  If it is all	*/
/*					present in the statement buffer, then it is extracted	*/
/*					from the buffer.  If the array initialization data did	*/
/*					not fit into the statement buffer, it is read directly	*/
/*					from the input stream.  Five formats of Boolean array	*/
/*					initialization data are supported:  comma-separated		*/
/*					values (the default), and BIN, HEX, RLC, and ACA.		*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, else appropriate error code	*/
/*																			*/
/****************************************************************************/
{
	int index = 0;
	int ch = 0;
	int rep = 0;
	int length = 0;
	int data_offset = 0;
	long position = 0L;
	long data_position = 0L;
	BOOL done = FALSE;
	BOOL comment = FALSE;
	BOOL found_equal = FALSE;
	BOOL found_space = FALSE;
	BOOL found_keyword = FALSE;
	BOOL data_complete = FALSE;
	JAME_BOOLEAN_REP representation = JAM_ILLEGAL_REP;
	JAM_RETURN_TYPE status = JAMC_SUCCESS;

	while ((jam_isspace(statement_buffer[index])) &&
		(index < JAMC_MAX_STATEMENT_LENGTH))
	{
		++index;	/* skip over white space */
	}

	/*
	*	Figure out which data representation scheme is used
	*/
	if (jam_version == 2)
	{
		if (statement_buffer[index] == JAMC_POUND_CHAR)
		{
			representation = JAM_BOOL_BINARY;
			data_offset = index + 1;
		}
		else if (statement_buffer[index] == JAMC_DOLLAR_CHAR)
		{
			representation = JAM_BOOL_HEX;
			data_offset = index + 1;
		}
		else if (statement_buffer[index] == JAMC_AT_CHAR)
		{
			representation = JAM_BOOL_COMPRESSED;
			data_offset = index + 1;
		}
	}
	else if (jam_isdigit(statement_buffer[index]))
	{
		/*
		*	First character is digit -- assume comma separated list
		*/
		representation = JAM_BOOL_COMMA_SEP;
		data_offset = index;
	}
	else if (jam_isalpha(statement_buffer[index]))
	{
		/*
		*	Get keyword to indicate representation scheme
		*/
		for (rep = 0; (rep < JAMC_BOOL_REP_COUNT) &&
			(representation == JAM_ILLEGAL_REP); ++rep)
		{
			length = jam_strlen(jam_bool_rep_table[rep].string);

			if ((jam_strnicmp(&statement_buffer[index],
				jam_bool_rep_table[rep].string, length) == 0) &&
				jam_isspace(statement_buffer[index + length]))
			{
				representation = jam_bool_rep_table[rep].rep;
			}
		}

		data_offset = index + length;
	}

	if (representation == JAM_ILLEGAL_REP)
	{
		status = JAMC_SYNTAX_ERROR;
	}
	else
	{
		heap_record->rep = representation;
	}

	if ((status == JAMC_SUCCESS) && (jam_version == 2))
	{
		if ((representation != JAM_BOOL_BINARY) &&
			(representation != JAM_BOOL_HEX) &&
			(representation != JAM_BOOL_COMPRESSED))
		{
			/* only these three formats are supported in Jam 2.0 */
			status = JAMC_SYNTAX_ERROR;
		}
	}

	/*
	*	See if all the initialization data is present in the statement buffer
	*/
	if ((status == JAMC_SUCCESS) && !heap_record->cached)
	{
		while ((statement_buffer[index] != JAMC_NULL_CHAR) &&
			(statement_buffer[index] != JAMC_SEMICOLON_CHAR) &&
			(index < JAMC_MAX_STATEMENT_LENGTH))
		{
			++index;	/* look for semicolon */
		}

		if (statement_buffer[index] == JAMC_SEMICOLON_CHAR)
		{
			data_complete = TRUE;
		}
	}

	/*
	*	If data is not all present in the statement buffer, or if data
	*	will be cached, find the position of the data in the input file
	*/
	if ((status == JAMC_SUCCESS) && ((!data_complete) || heap_record->cached))
	{
		/*
		*	Get position offset of initialization data
		*/
		if (jam_seek(jam_current_statement_position) == 0)
		{
			position = jam_current_statement_position;
		}
		else status = JAMC_IO_ERROR;

		while ((status == JAMC_SUCCESS) && !done)
		{
			ch = jam_getc();

			if ((!comment) && (ch == JAMC_COMMENT_CHAR))
			{
				/* beginning of comment */
				comment = TRUE;
			}

			if ((!comment) && (!found_equal) && (ch == JAMC_EQUAL_CHAR))
			{
				/* found the equal sign */
				found_equal = TRUE;
			}

			if ((!comment) && found_equal && (!found_space) &&
				jam_isspace((char)ch))
			{
				/* found the space after the equal sign */
				found_space = TRUE;
			}

			if ((!comment) && found_equal && found_space)
			{
				if (representation == JAM_BOOL_COMMA_SEP)
				{
					if (jam_isdigit((char)ch))
					{
						/* found the first character of the data area */
						done = TRUE;
						data_position = position;
					}
				}
				else	/* other representations */
				{
					if ((jam_version == 2) && (!found_keyword) &&
						((ch == JAMC_POUND_CHAR) ||
						(ch == JAMC_DOLLAR_CHAR) ||
						(ch == JAMC_AT_CHAR)))
					{
						found_keyword = TRUE;
						done = TRUE;
						data_position = position + 1;
					}

					if ((jam_version != 2) && (!found_keyword) &&
						(jam_isalpha((char)ch)))
					{
						/* found the first char of the representation keyword */
						found_keyword = TRUE;
					}

					if ((jam_version != 2) && found_keyword &&
						(jam_isspace((char)ch)))
					{
						/* found the first character of the data area */
						done = TRUE;
						data_position = position;
					}
				}

			}

			if ((!comment) && (ch == JAMC_SEMICOLON_CHAR))
			{
				/* end of statement */
				done = TRUE;
			}

			if (ch == EOF)
			{
				/* end of file */
				done = TRUE;
				status = JAMC_UNEXPECTED_END;
			}

			if (comment &&
				((ch == JAMC_NEWLINE_CHAR) || (ch == JAMC_RETURN_CHAR)))
			{
				/* end of comment */
				comment = FALSE;
			}

			++position;	/* position of next character to be read */
		}

		if (status == JAMC_SUCCESS)
		{
			heap_record->position = data_position;
		}

		/*
		*	If data will not be cached, read it in from the file now.
		*/
		if ((status == JAMC_SUCCESS) && !heap_record->cached)
		{
			/*
			*	Data is present, and will not be cached.  Read it in.
			*/
			switch (representation)
			{
			case JAM_BOOL_COMMA_SEP:
				status = jam_read_bool_comma_sep(heap_record);
				break;

			case JAM_BOOL_BINARY:
				status = jam_read_bool_binary(heap_record);
				break;

			case JAM_BOOL_HEX:
				status = jam_read_bool_hex(heap_record);
				break;

			case JAM_BOOL_RUN_LENGTH:
				status = jam_read_bool_run_length(heap_record);
				break;

			case JAM_BOOL_COMPRESSED:
				status = jam_read_bool_compressed(heap_record);
				break;

			default:
				status = JAMC_INTERNAL_ERROR;
			}
		}

		/*
		*	Restore file pointer to position of next statement
		*/
		if (status == JAMC_SUCCESS)
		{
			if (jam_seek(jam_next_statement_position) == 0)
			{
				jam_current_file_position = jam_next_statement_position;
			}
			else status = JAMC_IO_ERROR;
		}
	}

	if ((status == JAMC_SUCCESS) && data_complete && !heap_record->cached)
	{
		/*
		*	Data is present, and will not be cached.  Extract it from buffer.
		*/
		switch (representation)
		{
		case JAM_BOOL_COMMA_SEP:
			status = jam_extract_bool_comma_sep(
				heap_record, &statement_buffer[data_offset]);
			break;

		case JAM_BOOL_BINARY:
			status = jam_extract_bool_binary(
				heap_record, &statement_buffer[data_offset]);
			break;

		case JAM_BOOL_HEX:
			status = jam_extract_bool_hex(
				heap_record, &statement_buffer[data_offset]);
			break;

		case JAM_BOOL_RUN_LENGTH:
			status = jam_extract_bool_run_length(
				heap_record, &statement_buffer[data_offset]);
			break;

		case JAM_BOOL_COMPRESSED:
			status = jam_extract_bool_compressed(
				heap_record, &statement_buffer[data_offset]);
			break;

		default:
			status = JAMC_INTERNAL_ERROR;
		}
	}

	/* in Jam 2.0, Boolean arrays in BIN and HEX format are reversed */
	if ((status == JAMC_SUCCESS) && (jam_version == 2) &&
		(representation == JAM_BOOL_BINARY))
	{
		status = jam_reverse_boolean_array_bin(heap_record);
	}

	if ((status == JAMC_SUCCESS) && (jam_version == 2) &&
		(representation == JAM_BOOL_HEX))
	{
		status = jam_reverse_boolean_array_hex(heap_record);
	}

	return (status);
}

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_extract_int_comma_sep
(
	JAMS_HEAP_RECORD *heap_record,
	char *statement_buffer
)

/*																			*/
/*	Description:	Extracts integer array data from statement buffer.		*/
/*					Works on data in comma separated representation.		*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, else appropriate error code	*/
/*																			*/
/****************************************************************************/
{
	int index = 0;
	int expr_begin = 0;
	int expr_end = 0;
	char save_ch = 0;
	long address = 0L;
	long value = 0L;
	long dimension = heap_record->dimension;
	JAME_EXPRESSION_TYPE expr_type = JAM_ILLEGAL_EXPR_TYPE;
	JAM_RETURN_TYPE status = JAMC_SUCCESS;
	long *heap_data = &heap_record->data[0];

	for (address = 0L; (status == JAMC_SUCCESS) && (address < dimension);
		++address)
	{
		status = JAMC_SYNTAX_ERROR;

		while ((jam_isspace(statement_buffer[index])) &&
			(index < JAMC_MAX_STATEMENT_LENGTH))
		{
			++index;	/* skip over white space */
		}

		expr_begin = index;
		expr_end = 0;

		while ((statement_buffer[index] != JAMC_COMMA_CHAR) &&
			(statement_buffer[index] != JAMC_SEMICOLON_CHAR) &&
			(index < JAMC_MAX_STATEMENT_LENGTH))
		{
			++index;	/* skip over the expression */
		}

		if ((statement_buffer[index] == JAMC_COMMA_CHAR) ||
			(statement_buffer[index] == JAMC_SEMICOLON_CHAR))
		{
			expr_end = index;
		}

		if (expr_end > expr_begin)
		{
			save_ch = statement_buffer[expr_end];
			statement_buffer[expr_end] = JAMC_NULL_CHAR;
			status = jam_evaluate_expression(
				&statement_buffer[expr_begin], &value, &expr_type);
			statement_buffer[expr_end] = save_ch;
		}

		if ((status == JAMC_SUCCESS) &&
			((expr_type != JAM_INTEGER_EXPR) &&
			(expr_type != JAM_INT_OR_BOOL_EXPR)))
		{
			status = JAMC_TYPE_MISMATCH;
		}

		if (status == JAMC_SUCCESS)
		{
			heap_data[address] = value;

			if ((address < dimension) &&
				(statement_buffer[index] == JAMC_COMMA_CHAR))
			{
				++index;
			}
		}
	}

	if (status == JAMC_SUCCESS)
	{
		while ((jam_isspace(statement_buffer[index])) &&
			(index < JAMC_MAX_STATEMENT_LENGTH))
		{
			++index;	/* skip over white space */
		}

		if (statement_buffer[index] != JAMC_SEMICOLON_CHAR)
		{
			status = JAMC_SYNTAX_ERROR;
		}
	}

	return (status);
}

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_read_int_comma_sep
(
	JAMS_HEAP_RECORD *heap_record
)

/*																			*/
/*	Description:	Reads integer array data directly from input stream.	*/
/*					Works on data in comma separated representation.		*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, else appropriate error code	*/
/*																			*/
/****************************************************************************/
{
	int index = 0;
	int ch = 0;
	long address = 0L;
	long value = 0L;
	long dimension = heap_record->dimension;
	char expr_buffer[JAMC_MAX_STATEMENT_LENGTH + 1];
	JAME_EXPRESSION_TYPE expr_type = JAM_ILLEGAL_EXPR_TYPE;
	JAM_RETURN_TYPE status = JAMC_SUCCESS;
	long *heap_data = &heap_record->data[0];

	if (jam_seek(heap_record->position) != 0)
	{
		status = JAMC_IO_ERROR;
	}

	while ((status == JAMC_SUCCESS) && (address < dimension))
	{
		ch = jam_get_real_char();

		if (((ch == JAMC_COMMA_CHAR) && (address < (dimension - 1))) ||
			((ch == JAMC_SEMICOLON_CHAR) && (address == (dimension - 1))))
		{
			expr_buffer[index] = JAMC_NULL_CHAR;
			index = 0;

			status = jam_evaluate_expression(
				expr_buffer, &value, &expr_type);

			if ((status == JAMC_SUCCESS) &&
				((expr_type != JAM_INTEGER_EXPR) &&
				(expr_type != JAM_INT_OR_BOOL_EXPR)))
			{
				status = JAMC_TYPE_MISMATCH;
			}

			if (status == JAMC_SUCCESS)
			{
				heap_data[address] = value;
				++address;
			}
		}
		else if ((ch == JAMC_COMMA_CHAR) && (address >= (dimension - 1)))
		{
			status = JAMC_BOUNDS_ERROR;
		}
		else
		{
			expr_buffer[index] = (char) ch;

			if (index < JAMC_MAX_STATEMENT_LENGTH)
			{
				++index;
			}
			else
			{
				/* expression was too long */
				status = JAMC_SYNTAX_ERROR;
			}
		}

		if (ch == EOF)
		{
			/* end of file */
			status = JAMC_UNEXPECTED_END;
		}
	}

	return (status);
}

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_read_integer_array_data
(
	JAMS_HEAP_RECORD *heap_record,
	char *statement_buffer
)

/*																			*/
/*	Description:	Reads integer array initialization data.  If it is all	*/
/*					present in the statement buffer, then it is extracted	*/
/*					from the buffer.  If the array initialization data did	*/
/*					not fit into the statement buffer, it is read directly	*/
/*					from the input stream.  The only data representation	*/
/*					supported for integer arrays is a comma-separated list	*/
/*					of integer expressions.									*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, else appropriate error code	*/
/*																			*/
/****************************************************************************/
{
	int index = 0;
	int ch = 0;
	long position = 0L;
	long data_position = 0L;
	BOOL done = FALSE;
	BOOL comment = FALSE;
	BOOL found_equal = FALSE;
	BOOL found_space = FALSE;
	BOOL data_complete = FALSE;
	JAM_RETURN_TYPE status = JAMC_SUCCESS;

	/*
	*	See if all the initialization data is present in the statement buffer
	*/
	if ((status == JAMC_SUCCESS) && !heap_record->cached)
	{
		while ((statement_buffer[index] != JAMC_NULL_CHAR) &&
			(statement_buffer[index] != JAMC_SEMICOLON_CHAR) &&
			(index < JAMC_MAX_STATEMENT_LENGTH))
		{
			++index;	/* look for semicolon */
		}

		if (statement_buffer[index] == JAMC_SEMICOLON_CHAR)
		{
			data_complete = TRUE;
		}
	}

	/*
	*	If data is not all present in the statement buffer, or if data
	*	will be cached, find the position of the data in the input file
	*/
	if ((status == JAMC_SUCCESS) && ((!data_complete) || heap_record->cached))
	{
		/*
		*	Get position offset of initialization data
		*/
		if (jam_seek(jam_current_statement_position) == 0)
		{
			position = jam_current_statement_position;
		}
		else status = JAMC_IO_ERROR;

		while ((status == JAMC_SUCCESS) && !done)
		{
			ch = jam_getc();

			if ((!comment) && (ch == JAMC_COMMENT_CHAR))
			{
				/* beginning of comment */
				comment = TRUE;
			}

			if ((!comment) && (!found_equal) && (ch == JAMC_EQUAL_CHAR))
			{
				/* found the equal sign */
				found_equal = TRUE;
			}

			if ((!comment) && found_equal && (!found_space) &&
				jam_isspace((char)ch))
			{
				/* found the space after the equal sign */
				found_space = TRUE;
			}

			if ((!comment) && found_equal && found_space &&
				jam_isdigit((char)ch))
			{
				/* found the first character of the data area */
				done = TRUE;
				data_position = position;
			}

			if ((!comment) && (ch == JAMC_SEMICOLON_CHAR))
			{
				/* end of statement */
				done = TRUE;
			}

			if (ch == EOF)
			{
				/* end of file */
				done = TRUE;
				status = JAMC_UNEXPECTED_END;
			}

			if (comment &&
				((ch == JAMC_NEWLINE_CHAR) || (ch == JAMC_RETURN_CHAR)))
			{
				/* end of comment */
				comment = FALSE;
			}

			++position;	/* position of next character to be read */
		}

		if (status == JAMC_SUCCESS)
		{
			heap_record->position = data_position;
		}

		/*
		*	If data will not be cached, read it in from the file now.
		*/
		if ((status == JAMC_SUCCESS) && !heap_record->cached)
		{
			/*
			*	Data is present, and will not be cached.  Read it in.
			*/
			status = jam_read_int_comma_sep(heap_record);
		}

		/*
		*	Restore file pointer to position of next statement
		*/
		if (status == JAMC_SUCCESS)
		{
			if (jam_seek(jam_next_statement_position) == 0)
			{
				jam_current_file_position = jam_next_statement_position;
			}
			else status = JAMC_IO_ERROR;
		}
	}

	if ((status == JAMC_SUCCESS) && data_complete && !heap_record->cached)
	{
		/*
		*	Data is present, and will not be cached.  Extract it from buffer.
		*/
		status = jam_extract_int_comma_sep(heap_record, statement_buffer);
	}

	/*
	*	For Jam 2.0, reverse the order of the data values
	*/
	if ((status == JAMC_SUCCESS) && (jam_version == 2))
	{
		long *heap_data = &heap_record->data[0];
		long dimension = heap_record->dimension;
		long a, b, i, j;

		for (i = 0; i < dimension / 2; ++i)
		{
			j = (dimension - 1) - i;
			a = heap_data[i];
			b = heap_data[j];
			heap_data[j] = a;
			heap_data[i] = b;
		}
	}

	return (status);
}

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_get_array_value
(
	JAMS_SYMBOL_RECORD *symbol_record,
	long index,
	long *value
)

/*																			*/
/*	Description:	Gets the value of an array element.	 The value is		*/
/*					passed back by reference.								*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, else appropriate error code	*/
/*																			*/
/****************************************************************************/
{
	JAM_RETURN_TYPE status = JAMC_SUCCESS;
	JAMS_HEAP_RECORD *heap_record = NULL;
	long *heap_data = NULL;

	if ((symbol_record == NULL) ||
		((symbol_record->type != JAM_INTEGER_ARRAY_WRITABLE) &&
		(symbol_record->type != JAM_BOOLEAN_ARRAY_WRITABLE) &&
		(symbol_record->type != JAM_INTEGER_ARRAY_INITIALIZED) &&
		(symbol_record->type != JAM_BOOLEAN_ARRAY_INITIALIZED)))
	{
		status = JAMC_INTERNAL_ERROR;
	}
	else
	{
		heap_record = (JAMS_HEAP_RECORD *) symbol_record->value;

		if (heap_record == NULL)
		{
			status = JAMC_INTERNAL_ERROR;
		}

		if ((status == JAMC_SUCCESS) &&
			((index < 0) || (index >= heap_record->dimension)))
		{
			status = JAMC_BOUNDS_ERROR;
		}

		if (status == JAMC_SUCCESS)
		{
			heap_data = &heap_record->data[0];

			if ((symbol_record->type == JAM_INTEGER_ARRAY_WRITABLE) ||
				(symbol_record->type == JAM_INTEGER_ARRAY_INITIALIZED))
			{
				if (!heap_record->cached)
				{
					if (value != NULL) *value = heap_data[index];
				}
				else
				{
					/* get data from cache */

					/* cache not implemented yet! */
					status = JAMC_INTERNAL_ERROR;
				}
			}
			else if ((symbol_record->type == JAM_BOOLEAN_ARRAY_WRITABLE) ||
				(symbol_record->type == JAM_BOOLEAN_ARRAY_INITIALIZED))
			{
				if (!heap_record->cached)
				{
					*value = (heap_data[index >> 5] & (1L << (index & 0x1f)))
						? 1 : 0;
				}
				else
				{
					/* get data from cache */

					/* cache not implemented yet! */
					status = JAMC_INTERNAL_ERROR;
				}
			}
			else
			{
				status = JAMC_INTERNAL_ERROR;
			}
		}
	}

	return (status);
}
