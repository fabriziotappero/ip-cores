


/*  this file simulate the stream cypher function */
#include <stdlib.h>
#include <stdio.h>
#include <memory.h>
#include "misc.h"
extern void stream_cypher(int init, unsigned char *CK, unsigned char *sb, unsigned char *cb); 
int main()
{
        unsigned char ck[8];
        unsigned char sb[8];
        unsigned char sb1[8];
        unsigned char cb[8];
        READ_DATA(ck, 8*8);       
        READ_DATA(sb, 8*8);       
        READ_DATA(sb1,8*8);       
        stream_cypher(1,ck,sb,cb);
        WRITE_DATA(cb,8*8);
        stream_cypher(0,ck,sb1,cb);
        WRITE_DATA(cb,8*8);
         
        return 0;
}
