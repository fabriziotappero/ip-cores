/******************************************************************************
 * Standard Library                                                           *
 ******************************************************************************
 * Copyright (C)2011  Mathias Hörtnagl <mathias.hoertnagl@gmail.com>          *
 *                                                                            *
 * This program is free software: you can redistribute it and/or modify       *
 * it under the terms of the GNU General Public License as published by       *
 * the Free Software Foundation, either version 3 of the License, or          *
 * (at your option) any later version.                                        *
 *                                                                            *
 * This program is distributed in the hope that it will be useful,            *
 * but WITHOUT ANY WARRANTY; without even the implied warranty of             *
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the              *
 * GNU General Public License for more details.                               *
 *                                                                            *
 * You should have received a copy of the GNU General Public License          *
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.      *
 ******************************************************************************/
#include "stddef.h"
#include "stdlib.h"

/******************************************************************************
 * Timer                                                                      *
 ******************************************************************************/
/* Resets the counter. If you call reset before the counter has finished, it
   returns the count progress. */
uint pit_reset() {
   return PIT_ADDRESS[0];
}

/* Set PIT limit and start counting. */
void pit_run(uint cycles) {
   PIT_ADDRESS[0] = cycles;
}


/******************************************************************************
 * RS-232                                                                     *
 ******************************************************************************/
/* Wait for one byte of data. Return n reception. */
uchar rs232_receive() { 
   return RS232_ADDRESS[0];
}

/* Send one byte of data. */
void rs232_transmit(uchar chr) {
   RS232_ADDRESS[1] = chr;
}


/******************************************************************************
 * Memory Operations                                                          *
 ******************************************************************************/
 
void memcpy(const void *src, void *dst, uint len) {   
   for(char *s = src, *d = dst; len-- > 0; *d++ = *s++); 
}

void memset(const void *ptr, int val, uint len) {
   for(char *p = ptr; len-- > 0; *p++ = val);
}

// 
// int memcmp(const void *src, void *dst, uint len) {
   // for(char *s = src, *d = dst; len > 0; len--)
      // if(*s++ != *p++) return 1;
   // return 0;
// }


/******************************************************************************
 * String Operations                                                          *
 ******************************************************************************/
/* Returns the length of a string */
uint strlen(const uchar *str) {  
   uint c = 0;
   for(uchar *s = str; *s++; c++);
   return c;
}

/* Copys a string at location src to location dst. */
void strcpy(const uchar *src, uchar *dst) {
   for(uchar *s = src, *d = dst; *d++ = *s++; ); 
}

/* Returns a pointer to the leftmost occurence of character chr in 
   string str or NULL, if not found. */
uchar *strchr(const uchar *str, const uchar chr) {   
   for(uchar *s = str; *s; s++)
      if(*s == chr) return *s;
   return NULL;
}


/******************************************************************************
 * Number/String Conversion                                                   *
 ******************************************************************************/
 /* Convert a string containing a decimal number into a number. */
int atoi(const uchar *str) {
   
   int num = 0;
   uchar sign;
   uchar *s = str;
   
   for(; !( isdigit(*s) || (*s == '-') ) && (*s != NULL); s++);
   sign = *s++;

   for(; isdigit(*s); s++)
      num = x10(num) + (*s-'0');      
   return (sign == '-') ? -num : num;
}

/* Returns a binary representation of an integer <num>. The buffer <str> must be
   at least 35 byte wide to hold the char sequence of the form '0bn...n\0'. */
uchar* itob(int num, uchar *str) {
   
   uchar *s = str;
   uint p = 0x80000000;
   
   *s++ = '0';
   *s++ = 'b';
   //while( !(num & p) ) p >>= 1;
   while(p) {
      *s++ = (num & p) ? '1' : '0';
      p >>= 1;
   }
   *s = '\0';
   return str;
}

/* Returns a hexadecimal representation of an integer <num>. The buffer <str> 
   must be at least 11 byte wide to hold the char sequence of the form 
   '0xn...n\0'. */
uchar* itox(int num, uchar *str) {
   
   uchar *s = str;
   uchar n;
   uint p = 0xf0000000;
   
   *s++ = '0';
   *s++ = 'x';
   //while( !(num & p) ) p >>= 1;
   for(int i=28; i>=0; i-=4) {
      n = ((uint) num & p) >> i;
      if ( n <= 9 )
         *s++ = n + '0';
      else
         *s++ = n - 10 + 'a';   
      p >>= 4;
   }
   *s = '\0';
   return str;
}
  
  
/******************************************************************************
 * Nathematics                                                                *
 ******************************************************************************/
static uint x = 314159265;
/* Xorshift RNGs, George Marsaglia
   http://www.jstatsoft.org/v08/i14/paper */
uint rand() {  
  x ^= x << 13;
  x ^= x >> 17;
  x ^= x << 5;
  return x;
} 
 
/* Radix-4 Booth Multiplication Algorithm */
int mul(short a, short b) {
   
   int r = 0;
   int ai = a << 1;

   for(int i=0; i++<16; ai>>=1, b<<=1)
      switch (ai & 3) {
         case 1: r += b; break;
         case 2: r -= b; break;
      }  
   return r;
}


short div(int a, int b) {
   
   char s = 0;
   short m = 0;
   
   if(a < 0) {
      s = 1;
      a = -a;
   }  
   if(b < 0) {   
      if(s == 1) 
         s = 0;
      else
         s = 1;
         
      b = -b;
   } 
   if(b == 0) {
      return 0;
   }
   while(a > b) {
      m++;
      a = a-b;
   }   
   return m;
}
