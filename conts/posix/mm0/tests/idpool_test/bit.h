#ifndef __LIB_BIT_H__
#define __LIB_BIT_H__

/* Minimum excess needed for word alignment */
#define SZ_WORD				sizeof(unsigned int)
#define WORD_BITS			32
#define WORD_BITS_LOG2			5
#define BITWISE_GETWORD(x)	((x) >> WORD_BITS_LOG2) /* Divide by 32 */
#define	BITWISE_GETBIT(x)	(1 << ((x) % WORD_BITS))


typedef unsigned int u32;

unsigned int __clz(unsigned int bitvector);
int find_and_set_first_free_bit(u32 *word, unsigned int lastbit);
int check_and_clear_bit(u32 *word, int bit);

int check_and_clear_contig_bits(u32 *word, int first, int nbits);

int find_and_set_first_free_contig_bits(u32 *word,  unsigned int limit,
					int nbits);
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

#endif /* __LIB_BIT_H__ */
