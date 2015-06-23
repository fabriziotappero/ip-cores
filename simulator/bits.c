/* bits.c: various bits and pieces */

#include "bits.h"

uint64_t
bitfield(uint64_t val, int low_bit, int high_bit)
{
	return val>>low_bit & ~((~((uint64_t)0))<<(high_bit-low_bit+1));
}

int
sign_extend(uint32_t val, int len)
{
	if ((val >> (len-1)) & 1)
		return val | ((~0) << len);
	return val;
}
