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
    
    int i;
    
    for(i=-960; i<-950; i++) {
        
        P0 = (unsigned char)i;
    }
    while(1);
}
