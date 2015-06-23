/*
 * Copyright (c) 1999-2001 Tony Givargis.  Permission to copy is granted
 * provided that this header remains intact.  This software is provided
 * with no warranties.
 *
 * Version : 2.9
 */

/*---------------------------------------------------------------------------*/

#include <8051.h>


char cErrCnt;

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

void print(unsigned char* buf, unsigned char *exp_buf,unsigned char n) {
    
    char i;
    
    for(i=0; i<n; i++) {
        P0 = buf[i];
        P1 = exp_buf[i];
        if(buf[i] != exp_buf[i]) {
           cErrCnt++;
        }
    }

    if(cErrCnt !=0) {
        P2 = 0x55; // Test Fail
        P3 = cErrCnt;
 
    } else {
       P2 = 0xAA; // Test PASS
       P3 = 0xAA; // Test PASS
    }


}

/*---------------------------------------------------------------------------*/

void main() {
    
    unsigned char buf[]      = { 19, 18, 14, 15, 16, 17, 13, 11, 12, 10 };
    // Sorted expected buffer
    unsigned char exp_buf[]  = { 10, 11, 12, 13, 14, 15, 16, 17, 18, 19 }; 
    cErrCnt = 0;
  
    sort(buf, 10);
    print(buf, exp_buf,10);
    while(1);
}
