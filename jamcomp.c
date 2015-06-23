/****************************************************************************/
/*																			*/
/*	Module:			jamcomp.c												*/
/*																			*/
/*					Copyright (C) Altera Corporation 1997					*/
/*																			*/
/*	Description:	Contains the code for compressing and uncompressing		*/
/*					Boolean array data.										*/
/*																			*/
/*					This algorithm works by searching previous bytes in the */
/*					data that match the current data. If a match is found,	*/
/*					then the offset and length of the matching data can		*/
/*					replace the actual data in the output.					*/
/*																			*/
/****************************************************************************/

/****************************************************************************/
/*																			*/
/*	Actel version 1.1             May 2003									*/
/*																			*/
/****************************************************************************/

#include "jamexprt.h"
#include "jamdefs.h"
#include "jamcomp.h"

#define	SHORT_BITS			16
#define	CHAR_BITS			8
#define	DATA_BLOB_LENGTH	3
#define	MATCH_DATA_LENGTH	8192

/****************************************************************************/
/*																			*/

short jam_bits_required(short n)

/*																			*/
/*	Description:	Calculate the minimum number of bits required to		*/
/*					represent n.											*/
/*																			*/
/*	Returns:		Number of bits.											*/
/*																			*/
/****************************************************************************/
{
	short	result = SHORT_BITS;

	if (n == 0) result = 1;
	else
	{
		/* Look for the highest non-zero bit position */
		while ((n & (1 << (SHORT_BITS - 1))) == 0)
		{
			n = (short) (n << 1);
			--result;
		}
	}

	return (result);
}

/****************************************************************************/
/*																			*/

short jam_read_packed(char *buffer, long length, short bits)

/*																			*/
/*	Description:	Read the next value from the input array "buffer".		*/
/*					Read only "bits" bits from the array. The amount of		*/
/*					bits that have already been read from "buffer" is		*/
/*					stored internally to this function.					 	*/
/*																			*/
/*	Returns:		Up to 16 bit value. -1 if buffer overrun.				*/
/*																			*/
/****************************************************************************/
{
	short			result = -1;
	static long		index = 0L;
	static short	bits_avail = 0;
	short			shift = 0;

	/* If buffer is NULL then initialize. */
	if (buffer == NULL)
	{
		index = 0;
		bits_avail = CHAR_BITS;
	}
	else
	{
		result = 0;
		while (result != -1 && bits > 0)
		{
			result = (short) (result | (((buffer[index] >> (CHAR_BITS - bits_avail)) & (0xFF >> (CHAR_BITS - bits_avail))) << shift));

			if (bits <= bits_avail)
			{
				result = (short) (result & (0xFFFF >> (SHORT_BITS - (bits + shift))));
				bits_avail = (short) (bits_avail - bits);
				bits = 0;
			}
			else
			{
				/* Check for buffer overflow. */
				if (++index >= length) result = -1;
				else
				{
					shift = (short) (shift + bits_avail);
					bits = (short) (bits - bits_avail);
					bits_avail = CHAR_BITS;
				}
			}
		}
	}

	return (result);
}

/****************************************************************************/
/*																			*/

long jam_uncompress
(
	char *in, 
	long in_length, 
	char *out, 
	long out_length,
	int version
)

/*																			*/
/*	Description:	Uncompress data in "in" and write result to	"out".		*/
/*																			*/
/*	Returns:		Length of uncompressed data. -1 if:						*/
/*						1) out_length is too small							*/
/*						2) Internal error in the code						*/
/*						3) in doesn't contain ACA compressed data.			*/
/*																			*/
/****************************************************************************/
{
	long	i, j, data_length = 0L;
	short	offset, length;
	long	match_data_length = MATCH_DATA_LENGTH;

	if (version == 2) --match_data_length;
	
	jam_read_packed(NULL, 0, 0);
	for (i = 0; i < out_length; ++i) out[i] = 0;

	/* Read number of bytes in data. */
	for (i = 0; i < sizeof (in_length); ++i) 
	{
		data_length = data_length | ((long) jam_read_packed(in, in_length, CHAR_BITS) << (long) (i * CHAR_BITS));
	}

	if (data_length > out_length) data_length = -1L;
	else
	{
		i = 0;
		while (i < data_length)
		{
			/* A 0 bit indicates literal data. */
			if (jam_read_packed(in, in_length, 1) == 0)
			{
				for (j = 0; j < DATA_BLOB_LENGTH; ++j)
				{
					if (i < data_length)
					{
						out[i] = (char) jam_read_packed(in, in_length, CHAR_BITS);
						i++;
					}
				}
			}
			else
			{
				/* A 1 bit indicates offset/length to follow. */
				offset = jam_read_packed(in, in_length, jam_bits_required((short) (i > match_data_length ? match_data_length : i)));
				length = jam_read_packed(in, in_length, CHAR_BITS);

				for (j = 0; j < length; ++j)
				{
					if (i < data_length)
					{
						out[i] = out[i - offset];
						i++;
					}
				}
			}
		}
	}

	return (data_length);
}
