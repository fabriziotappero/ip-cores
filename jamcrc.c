/****************************************************************************/
/*																			*/
/*	Module:			jamcrc.c												*/
/*																			*/
/*					Copyright (C) Altera Corporation 1997					*/
/*																			*/
/*	Description:	Functions to calculate Cyclic Redundancy Check codes	*/
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

void jam_crc_init(unsigned short *shift_register)

/*																			*/
/*	Description:	This function initializes CRC shift register.  It must	*/
/*					be called before jam_crc_update(). 						*/
/*																			*/
/*	Returns:		Nothing													*/
/*																			*/
/****************************************************************************/
{
	*shift_register = 0xffff;	/* start with all ones in shift reg */
}

/****************************************************************************/
/*																			*/

void jam_crc_update
(
	unsigned short *shift_register,
	int data
)

/*																			*/
/*	Description:	This function updates crc shift register by shifting	*/
/*					in the new data bits.  Must be called for each bytes in */
/*					the order that they appear in the data stream.			*/
/*																			*/
/*	Returns:		Nothing													*/
/*																			*/
/****************************************************************************/
{
	int bit, feedback;
	unsigned short shift_register_copy;

	shift_register_copy = *shift_register;	/* copy it to local variable */

	for (bit = 0; bit < 8; bit++)	/* compute for each bit */
	{
		feedback = (data ^ shift_register_copy) & 0x01;
		shift_register_copy >>= 1;	/* shift the shift register */
		if (feedback)
		{
			shift_register_copy ^= 0x8408;	/* invert selected bits */
		}
		data >>= 1;		/* get the next bit of input_byte */
	}

	*shift_register = shift_register_copy;
}

/****************************************************************************/
/*																			*/

unsigned short jam_get_crc_value(unsigned short *shift_register)

/*																			*/
/*	Description:	The content of the shift_register is the CRC of all		*/
/*					bytes passed to jam_crc_update() since the last call	*/
/*					to jam_crc_init().										*/
/*																			*/
/*	Returns:		CRC value from shift register.							*/
/*																			*/
/***************************************************************************/
{
	/* CRC is complement of shift register */
	return((unsigned short)~(*shift_register));
}

int jam_hexchar(int ch)
{
	int value;

	if (jam_isdigit((char) ch)) value = (ch - '0');
	else value = (jam_toupper((char) ch) - 'A') + 10;

	return (value);
}

/****************************************************************************/
/*																			*/

JAM_RETURN_TYPE jam_check_crc
(
	char *program,
	long program_size,
	unsigned short *expected_crc,
	unsigned short *actual_crc
)

/*																			*/
/*	Description:	This function reads the entire input stream and			*/
/*					computes the CRC of everything up to the CRC statement	*/
/*					itself (and the preceding new-line, if applicable).		*/
/*					Carriage return characters (0x0d) which are followed	*/
/*					by new-line characters (0x0a) are ignored, so the CRC	*/
/*					will not change when the file is converted from MS-DOS	*/
/*					text format (with CR-LF) to UNIX text format (only LF)	*/
/*					and visa-versa.											*/
/*																			*/
/*	Returns:		JAMC_SUCCESS for success, else appropriate error code	*/
/*																			*/
/****************************************************************************/
{
	BOOL comment = FALSE;
	BOOL quoted_string = FALSE;
	BOOL in_statement = FALSE;
	BOOL in_instruction = FALSE;
	BOOL found_expected_crc = FALSE;
	int ch = 0;
	long position = 0L;
	long left_quote_position = -1L;
	unsigned short crc_shift_register = 0;
	unsigned short crc_shift_register_backup[4] = {0};
	int ch_queue[4] = {0};
	unsigned short tmp_expected_crc = 0;
	unsigned short tmp_actual_crc = 0;
	JAM_RETURN_TYPE status = JAMC_SUCCESS;

	jam_program = program;
	jam_program_size = program_size;

	status = jam_seek(0);

	jam_crc_init(&crc_shift_register);

	while ((status == JAMC_SUCCESS) && (!found_expected_crc))
	{
		ch = jam_getc();

		if ((ch != EOF) && (ch != JAMC_RETURN_CHAR))
		{
			jam_crc_update(&crc_shift_register, ch);

			if ((!comment) && (!quoted_string))
			{
				if (ch == JAMC_COMMENT_CHAR)
				{
					/* beginning of comment */
					comment = TRUE;
				}
				else if (ch == JAMC_QUOTE_CHAR)
				{
					/* beginning of quoted string */
					quoted_string = TRUE;
					left_quote_position = position;
				}
			}

			/*
			*	Check if this is the CRC statement
			*/
			if ((!comment) && (!quoted_string) &&
				in_statement && in_instruction &&
				(jam_isspace((char) ch_queue[3])) &&
				(ch_queue[2] == 'C') &&
				(ch_queue[1] == 'R') &&
				(ch_queue[0] == 'C') &&
				(jam_isspace((char) ch)))
			{
				status = JAMC_SYNTAX_ERROR;
				crc_shift_register = crc_shift_register_backup[3];

				/* skip over any additional white space */
				do { ch = jam_getc(); } while
					((ch != EOF) && (jam_isspace((char) ch)));

				if (jam_is_hex_char((char) ch))
				{
					/* get remaining three characters of CRC */
					ch_queue[2] = jam_getc();
					ch_queue[1] = jam_getc();
					ch_queue[0] = jam_getc();

					if ((jam_is_hex_char((char) ch_queue[2])) &&
						(jam_is_hex_char((char) ch_queue[1])) &&
						(jam_is_hex_char((char) ch_queue[0])))
					{
						tmp_expected_crc = (unsigned short)
							((jam_hexchar(ch) << 12) |
							(jam_hexchar(ch_queue[2]) << 8) |
							(jam_hexchar(ch_queue[1]) << 4) |
							jam_hexchar(ch_queue[0]));

						/* skip over any additional white space */
						do { ch = jam_getc(); } while
							((ch != EOF) && (jam_isspace((char) ch)));

						if (ch == JAMC_SEMICOLON_CHAR)
						{
							status = JAMC_SUCCESS;
							found_expected_crc = TRUE;
						}
					}
				}
			}

			/* check if we are reading the instruction name */
			if ((!comment) && (!quoted_string) && (!in_statement) &&
				(jam_is_name_char((char) ch)))
			{
				in_statement = TRUE;
				in_instruction = TRUE;
			}

			/* check if we are finished reading the instruction name */
			if ((!comment) && (!quoted_string) && in_statement &&
				in_instruction && (!jam_is_name_char((char) ch)))
			{
				in_instruction = FALSE;
			}

			if ((!comment) && (!quoted_string) && in_statement &&
				(ch == JAMC_SEMICOLON_CHAR))
			{
				/* end of statement */
				in_statement = FALSE;
			}

			if (comment &&
				((ch == JAMC_NEWLINE_CHAR) || (ch == JAMC_RETURN_CHAR)))
			{
				/* end of comment */
				comment = FALSE;
			}
			else if (quoted_string && (ch == JAMC_QUOTE_CHAR) &&
				(position > left_quote_position))
			{
				/* end of quoted string */
				quoted_string = FALSE;
			}
		}

		if (ch == EOF)
		{
			/* end of file */
			status = JAMC_UNEXPECTED_END;
		}

		++position;	/* position of next character to be read */

		if (ch != JAMC_RETURN_CHAR)
		{
			ch_queue[3] = ch_queue[2];
			ch_queue[2] = ch_queue[1];
			ch_queue[1] = ch_queue[0];
			ch_queue[0] = ch;

			crc_shift_register_backup[3] = crc_shift_register_backup[2];
			crc_shift_register_backup[2] = crc_shift_register_backup[1];
			crc_shift_register_backup[1] = crc_shift_register_backup[0];
			crc_shift_register_backup[0] = crc_shift_register;
		}
	}

	tmp_actual_crc = jam_get_crc_value(&crc_shift_register);

	if (found_expected_crc && (expected_crc != NULL))
	{
		*expected_crc = tmp_expected_crc;
	}

	if (actual_crc != NULL)
	{
		*actual_crc = tmp_actual_crc;
	}

	if (found_expected_crc && (status == JAMC_SUCCESS) &&
		(tmp_expected_crc != tmp_actual_crc))
	{
		status = JAMC_CRC_ERROR;
	}

	return (status);
}
