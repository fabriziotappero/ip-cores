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

void main() {
    
    unsigned char x = 0xaa;
    unsigned char i;
    
    for(i=0; i<8; i++) {
        
        P0 = (x & (1<<i)) ? 1 : 0;
    }
    while(1);
}
