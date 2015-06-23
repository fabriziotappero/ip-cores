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

void fib(unsigned char* buf, unsigned char n) {
    
    unsigned char i;
    
    buf[0] = 1;
    buf[1] = 1;
    for(i=2; i<n; i++) {
        
        buf[i] = buf[i-1] + buf[i-2];
    }
}

/*---------------------------------------------------------------------------*/

void print(unsigned char* buf, unsigned char n) {
    
    unsigned char i;
    
    unsigned char exp_buf[10] = {0x1,0x1,0x2,0x3,0x5,0x8,0xd,0x15,0x22,0x37};
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
    
    unsigned char buf[10];
    cErrCnt = 0;
    
    fib(buf, 10);
    print(buf, 10);
    while(1);
}
