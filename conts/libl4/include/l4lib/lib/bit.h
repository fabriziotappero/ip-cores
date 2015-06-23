#ifndef __BIT_H__
#define __BIT_H__

#include <l4lib/types.h>

unsigned int __clz(unsigned int bitvector);
int find_and_set_first_free_bit(u32 *word, unsigned int lastbit);
int find_and_set_first_free_contig_bits(u32 *word,  unsigned int limit,
					int nbits);
int check_and_clear_bit(u32 *word, int bit);
int check_and_clear_contig_bits(u32 *word, int first, int nbits);

int check_and_set_bit(u32 *word, int bit);

/* Set */
static inline void setbit(unsigned int *w, unsigned int flags)
{
	*w |= flags;
}


/* Clear */
static inline void clrbit(unsigned int *w, unsigned int flags)
{
	*w &= ~flags;
}

/* Test */
static inline int tstbit(unsigned int *w, unsigned int flags)
{
	return *w & flags;
}

/* Test and clear */
static inline int tstclr(unsigned int *w, unsigned int flags)
{
	int res = tstbit(w, flags);

	clrbit(w, flags);

	return res;
}

#endif /* __BIT_H__ */
