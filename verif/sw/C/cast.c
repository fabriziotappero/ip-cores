/*
 * Copyright (c) 1999-2001 Tony Givargis.  Permission to copy is granted
 * provided that this header remains intact.  This software is provided
 * with no warranties.
 *
 * Version : 2.9
 */

/*---------------------------------------------------------------------------*/

#include <8051.h>

/*---------------------------------------------------------------------------*/

unsigned char cast(unsigned long l) {
    
    return (unsigned char)l;
}

/*---------------------------------------------------------------------------*/

void main() {
    
    unsigned long l = 0x01234567;
    unsigned char cErrCnt = 0;
    P0 = cast(l >> 24);
    if(P0 != 0x01) cErrCnt ++;
    P0 = cast(l >> 16);
    if(P0 != 0x23) cErrCnt ++;
    P0 = cast(l >>  8);
    if(P0 != 0x45) cErrCnt ++;
    P0 = cast(l >>  0);
    if(P0 != 0x67) cErrCnt ++;

    if(cErrCnt !=0) {
        P2 = 0x55; // Test Fail
        P3 = cErrCnt;
 
    } else {
       P2 = 0xAA; // Test PASS
       P3 = 0xAA; // Test PASS
    }

    while(1);
}
