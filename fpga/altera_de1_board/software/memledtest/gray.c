#include "gray.h"


unsigned char bin2gray(unsigned char bin)
{
	return bin ^ (bin>>1);
}

unsigned char gray2bin(unsigned char gray)
{
	unsigned char bin;

	bin = gray ^ (gray>>1);
	bin ^= (bin>>2);
	bin ^= (bin>>4);

	return bin;
}


