#ifndef MEMTEST_H
#define MEMTEST_H

typedef unsigned char UBYTE;
typedef unsigned int  UWORD;

void rnd_array(UBYTE * buf);
UWORD cmp_array(UBYTE * buf1, UBYTE * buf2);
void init_array(UBYTE * ptr);
void copy_array(UBYTE * from, UBYTE * to);



#endif

