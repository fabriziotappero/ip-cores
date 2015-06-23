#include "../support/support.h"
#include "../support/board.h"


void udelay(unsigned long);

void udelay(unsigned long usecs)
{
    unsigned long i;	
    unsigned long cycles = usecs / (IN_CLK / 1000000 );
    unsigned long mem_dummy;
    volatile unsigned long* ptr = &mem_dummy;

    for ( i=0; i< cycles; i++)
	    *ptr = 0xABCD;
}

