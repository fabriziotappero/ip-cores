/*
 * Bit manipulation functions.
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include <l4/lib/bit.h>
#include INC_GLUE(memory.h)

/* Emulation of ARM's CLZ (count leading zeroes) instruction */
unsigned int __clz(unsigned int bitvector)
{
	unsigned int x = 0;
	while((!(bitvector & ((unsigned)1 << 31))) && (x < 32)) {
		bitvector <<= 1;
		x++;
	}
	return x;
}

int find_and_set_first_free_bit(u32 *word, unsigned int limit)
{
	int success = 0;
	int i;

	for(i = 0; i < limit; i++) {
		/* Find first unset bit */
		if (!(word[BITWISE_GETWORD(i)] & BITWISE_GETBIT(i))) {
			/* Set it */
			word[BITWISE_GETWORD(i)] |= BITWISE_GETBIT(i);
			success = 1;
			break;
		}
	}
	/* Return bit just set */
	if (success)
		return i;
	else
		return -1;
}

int check_and_clear_bit(u32 *word, int bit)
{
	/* Check that bit was set */
	if (word[BITWISE_GETWORD(bit)] & BITWISE_GETBIT(bit)) {
		word[BITWISE_GETWORD(bit)] &= ~BITWISE_GETBIT(bit);
		return 0;
	} else {
		//printf("Trying to clear already clear bit\n");
		return -1;
	}
}

int check_and_set_bit(u32 *word, int bit)
{
	/* Check that bit was clear */
	if (!(word[BITWISE_GETWORD(bit)] & BITWISE_GETBIT(bit))) {
		word[BITWISE_GETWORD(bit)] |= BITWISE_GETBIT(bit);
		return 0;
	} else {
		//printf("Trying to set already set bit\n");
		return -1;
	}
}

