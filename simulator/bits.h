#ifndef _BITS_H_
#define _BITS_H_

#include <inttypes.h>

uint64_t bitfield(uint64_t val, int low_bit, int high_bit);
int sign_extend(uint32_t val, int len);

#endif
