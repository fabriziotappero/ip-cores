/*
 * Copyright (c) 1999-2001 Tony Givargis.  Permission to copy is granted
 * provided that this header remains intact.  This software is provided
 * with no warranties.
 *
 * Version : 2.9
 */

/*---------------------------------------------------------------------------*/

#include <8051.h>

unsigned char xdata buffer[65536];

/*---------------------------------------------------------------------------*/

void main() {
    
    unsigned short i, j;
    unsigned x;
    
    buffer[255] = 255;
    for (j=1; j<10; j++){
      x = 256 * j;
      for(i=0; i<256; i++) {
          buffer[x+i] = buffer[x+i - 1] + 1;
      }
      if (buffer[x+255]!=255) {
          P1 = j;
      }
    }

    P0 = 1;

    while(1);
}
