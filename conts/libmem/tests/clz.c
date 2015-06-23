
#include <l4/macros.h>
#include <l4/types.h>
#include <l4/config.h>

/* Emulation of CLZ (count leading zeroes) instruction */
unsigned int __clz(unsigned int bitvector)
{
	unsigned int x = 0;
	while((!(bitvector & ((unsigned)1 << 31))) && (x < 32)) {
		bitvector <<= 1;
		x++;
	}
	return x;
}

