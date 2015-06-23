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

void main() {
    
    unsigned char x=45, y=11;
    
    while( x != y ) {
        
        if( x > y ) {
            
            x -= y;
            P0 = x;
        }
        else {
            
            y -= x;
            P1 = y;
        }
    }
    if(x == 1 && y == 1) {
       P2 = 0xAA; // Pass Signature
       P3 = 0xAA;
    } else {
       P2 = 0x55; // Failure signature
       P3 = 0x1;
    }
    while(1);
}
