/* -*- mode: c -*-
 * $Id: sieve.c,v 1.1.1.1 2003-02-10 04:08:54 doru Exp $
 * http://www.bagley.org/~doug/shootout/
 */

//#include <stdio.h>
//#include <stdlib.h>
#include <string.h>
//#include <sfr2313.h>
//#include <sfr8515.h>

//#define LIM 8192
#define LIM       100
#define NR_TIMES  1

void main() {
   int NUM;
   static char flags[LIM + 1];
   long i, k;
   int count;
   //char *txt1="Hello!";

   NUM=NR_TIMES;
   count=0;

   while (NUM--) {
      count = 0;
      for (i=2; i <= LIM; i++) {
         flags[i] = 0xff;
      }
      for (i=2; i <= LIM; i++) {
         if (flags[i]) {
         // remove all multiples of prime: i
         for (k=i+i; k <= LIM; k+=i) {
            flags[k] = 0xaa;
         }
         count++;
         }
      }
   }
   while (1) {
   }
   //printf("Count: %d\n", count);
}
