#include "memtest.h"



void rnd_array( UBYTE * buf )
// buf points to the array of size $1C0
{

	UBYTE *src1, *src2;
	UBYTE *dst;

	UWORD loop_ctr;



	src1 = buf;
	src2 = buf+1;
	dst = buf+63;
	loop_ctr = 384;

	do
	{
		*(dst++) = *(src1++) + *(src2++);
	} while( --loop_ctr );



	dst  = buf;
	src1 = buf+384;
	loop_ctr = 63;

	do
	{
		*(dst++) = *(src1++);
	} while( --loop_ctr );
}

UWORD cmp_array(UBYTE * buf1, UBYTE * buf2)
{
	UWORD loop_ctr;

	UWORD *ptr1, *ptr2;

	ptr1 = (UWORD*)buf1;
	ptr2 = (UWORD*)buf2;

	loop_ctr = 384/2;

	do
	{
		if( *(ptr1++) != *(ptr2++) )
			return 0;
	} while( --loop_ctr );

	return 1;
}

void init_array(UBYTE * ptr)
{
	UWORD loop_ctr;

	loop_ctr = 384/2;

	do
	{
		*(ptr++) |= 0x0001;

	} while( --loop_ctr );
}


void copy_array(UBYTE * from, UBYTE * to)
{
	UWORD loop_ctr;

	loop_ctr = 384/2;

	do
	{
		*(to++) = *(from++);
	} while( --loop_ctr );
}


