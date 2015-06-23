/*
 * Copyright (c) 1999-2001 Tony Givargis.  Permission to copy is granted
 * provided that this header remains intact.  This software is provided
 * with no warranties.
 *
 * Version : 2.9
 */

/*---------------------------------------------------------------------------*/

unsigned char xdata buffer[2048];

/*---------------------------------------------------------------------------*/

void main() {
    
    unsigned short i;
    
    buffer[0] = 1;
    for(i=1; i<2048; i++) {
        
        buffer[i] = buffer[i - 1] + 1;
    }
    
    while(1);
}
