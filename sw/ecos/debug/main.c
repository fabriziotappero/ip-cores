//
//
//

#include "LPC22xx.h"

extern void dbg_sh(void);



int main(void)
{
  // enable cs3
  PINSEL2 = 0x0f814924;
  
  // configure BCFG3
  *((unsigned int *)0xFFE0000C) = 0x20007de7;
  
  dbg_sh();

  return( -1 );
}

