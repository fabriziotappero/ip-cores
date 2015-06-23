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

void sort(unsigned char* buf, unsigned char n) {
    
    unsigned char i, j, t;
    
    for(i=0; i<n; i++) {
        
        for(j=i; j<n; j++) {
            
            if( buf[i] > buf[j] ) {
                
                t = buf[i];
                buf[i] = buf[j];
                buf[j] = t;
            }
        }
    }
    P0 = 0;
}

/*---------------------------------------------------------------------------*/

void print(unsigned char* buf, unsigned char n) {
    
    char i;
    
    for(i=0; i<n; i++) {
        
        P0 = buf[i];
    }
}

/*---------------------------------------------------------------------------*/

void main() {
    
    unsigned char buf[] = { 19, 18, 17, 16, 15, 14, 13, 12, 11, 10 };
    
    sort(buf, 10);
    print(buf, 10);
    while(1);
}
