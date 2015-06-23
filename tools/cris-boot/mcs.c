/* $Id: mcs.c,v 1.1.1.1 2006-02-04 03:35:01 freza Exp $ */

#include <sys/types.h>
#include <errno.h>
#include <stdio.h>
#include <stdlib.h>

static int
decode_byte(FILE *file, u_int8_t *dst)
{
	int c;

	if ((c = fgetc(file)) == EOF)
		return EINVAL;

	if (c >= '0' && c <= '9')
		*dst = (c - '0') << 4;
	else if (c >= 'a' && c <= 'f')
		*dst = ((c - 'a') + 10) << 4;
	else if (c >= 'A' && c <= 'F')
		*dst = ((c - 'A') + 10) << 4;
	else
		return EINVAL;

	if ((c = fgetc(file)) == EOF)
		return EINVAL;

	if (c >= '0' && c <= '9')
		*dst |= (c - '0');
	else if (c >= 'a' && c <= 'f')
		*dst |= ((c - 'a') + 10);
	else if (c >= 'A' && c <= 'F')
		*dst |= ((c - 'A') + 10);
	else
		return EINVAL;

	return 0;
}

#define decode_uint8(dst) 	\
	do { 								\
		if (decode_byte(file, &(dst)) < 0) 			\
			goto __error; 					\
	} while (0)

#define decode_uint16(dst) 	\
	do { 								\
		if (decode_byte(file, &x) < 0) 				\
			goto __error; 					\
		(dst) = x << 8; 					\
									\
		if (decode_byte(file, &x) < 0) 				\
			goto __error; 					\
		(dst) |= x; 						\
	} while (0)

int
mcsdecode(FILE *file, u_int8_t **data, size_t *num)
{
	u_int16_t 	lsb, msb;
	u_int8_t 	bytes, type, x, val;
	int 		ret;

	*data 	= NULL;
	ret 	= EINVAL;
	*num 	= 0;
	lsb 	= 0;
	msb 	= 0;

	/*
	 * Every line begins with ':'.
	 */
	if (fgetc(file) != ':')
		return EINVAL;

	for(;;) {
		decode_uint8(bytes);	/* Line length */
		decode_uint16(lsb);	/* Address LSB */
		decode_uint8(type);	/* Record type */

		switch (type) {
		case 0x00:
			/*
			 * Data item.
			 */
			break;
		case 0x01: 
			/*
			 * Last record.
			 */
			return 0;
		case 0x04:
			/*
			 * Address MSB.
			 */
			decode_uint16(msb);
			bytes -= 2;
			break;
		}

		*data = (u_int8_t *) realloc(*data, *num + bytes);
		if (*data == NULL) {
			ret = ENOMEM;
			goto __error;
		}

		/*
		 * Sanity check
		 */
		if (((((u_int32_t)msb) << 16) | lsb) != *num)
			goto __error;

		while (bytes-- > 0) {
			/*
			 * Read a byte of data.
			 */
			decode_uint8(val);
			(*data)[*num] = val;
			(*num)++;
		}

#if 0
		/*
		 * Each line has a CRC.
		 */
		decode_uint8(crc);
#endif

		/*
		 * Skip newline (may be DOS-ish).
		 */
		do {
			x = fgetc(file);
		} while (x != ':');
	}

	/* Bail out if we failed. */
__error:
      	if (*data != NULL) {
      		free(*data);
	      	*data = NULL;
	}

	*num = 0;
      	return ret;
}
