/*
 * Copyright (c) 1999-2001 Tony Givargis.  Permission to copy is granted
 * provided that this header remains intact.  This software is provided
 * with no warranties.
 *
 * Version : 2.9
 */

/*---------------------------------------------------------------------------*/

#include <8051.h>

unsigned char __xdata buffer[2048];

/*---------------------------------------------------------------------------*/

void main() {
    
    unsigned short i;
    unsigned char cErrCnt = 0;
    buffer[0] = 1;
    for(i=1; i<2048; i++) {
        
        buffer[i] = buffer[i - 1] + 1;
    }

    for(i=0; i<2048; i++) {
        /* Declaration of xram is byte not word */
        if(buffer[i] != ((i+1) & 0xFF))  {
                cErrCnt++;
                P0 = cErrCnt;
         }
    }

    if(cErrCnt !=0) {
        P2 = 0x55; // Test Fail
        P3 = cErrCnt;
 
    } else {
       P2 = 0xAA; // Test PASS
       P3 = 0xAA; // Test PASS
    }

    
    while(1);
}
