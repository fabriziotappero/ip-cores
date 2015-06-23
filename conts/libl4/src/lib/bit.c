/*
 * Bit manipulation functions.
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include <l4lib/lib/bit.h>
#include <stdio.h>
#include <l4/macros.h>
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

int find_and_set_first_free_contig_bits(u32 *word,  unsigned int limit,
					int nbits)
{
	int i = 0, first = 0, last = 0, found = 0;

	/* Can't allocate more than the limit */
	if (nbits > limit)
		return -1;

	/* This is a state machine that checks n contiguous free bits. */
	while (i + nbits <= limit) {
		first = i;
		last  = i;
		while (!(word[BITWISE_GETWORD(last)] & BITWISE_GETBIT(last))) {
			last++;
			i++;
			if (last == first + nbits) {
				found = 1;
				break;
			}
		}
		if (found)
			break;
		i++;
	}

	/* If found, set the bits */
	if (found) {
		for (int x = first; x < first + nbits; x++)
			word[BITWISE_GETWORD(x)] |= BITWISE_GETBIT(x);
		return first;
	} else
		return -1;
}

int check_and_clear_bit(u32 *word, int bit)
{
	/* Check that bit was set */
	if (word[BITWISE_GETWORD(bit)] & BITWISE_GETBIT(bit)) {
		word[BITWISE_GETWORD(bit)] &= ~BITWISE_GETBIT(bit);
		return 0;
	} else {
		printf("Trying to clear already clear bit\n");
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

int check_and_clear_contig_bits(u32 *word, int first, int nbits)
{
	for (int i = first; i < first + nbits; i++)
		if (check_and_clear_bit(word, i) < 0)
			return -1;
	return 0;
}

