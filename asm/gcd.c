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
    
    unsigned char x=47, y=11;
    
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
    P2 = x;
    while(1);
}
