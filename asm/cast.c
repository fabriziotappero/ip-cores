/*
 * Copyright (c) 1999-2001 Tony Givargis.  Permission to copy is granted
 * provided that this header remains intact.  This software is provided
 * with no warranties.
 *
 * Version : 2.9
 */

/*---------------------------------------------------------------------------*/

#include <reg51.h>

/*---------------------------------------------------------------------------*/

unsigned char cast(unsigned long l) {
    
    return (unsigned char)l;
}

/*---------------------------------------------------------------------------*/

void main() {
    
    unsigned long l = 0x01234567;
    
    P0 = cast(l >> 24);
    P1 = cast(l >> 16);
    P2 = cast(l >>  8);
    P0 = cast(l >>  0);
    
    while(1);
}
