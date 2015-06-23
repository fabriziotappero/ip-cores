/*----------------------------------------------------------------
//                                                              //
//  sprintf.c                                                   //
//                                                              //
//  This file is part of the Amber project                      //
//  http://www.opencores.org/project,amber                      //
//                                                              //
//  Description                                                 //
//  printf functions for the mini-libc library.                 //
//                                                              //
//  Author(s):                                                  //
//      - Conor Santifort, csantifort.amber@gmail.com           //
//                                                              //
//////////////////////////////////////////////////////////////////
//                                                              //
// Copyright (C) 2011 Authors and OPENCORES.ORG                 //
//                                                              //
// This source file may be used and distributed without         //
// restriction provided that this copyright statement is not    //
// removed from the file and that any derivative work contains  //
// the original copyright notice and the associated disclaimer. //
//                                                              //
// This source file is free software; you can redistribute it   //
// and/or modify it under the terms of the GNU Lesser General   //
// Public License as published by the Free Software Foundation; //
// either version 2.1 of the License, or (at your option) any   //
// later version.                                               //
//                                                              //
// This source is distributed in the hope that it will be       //
// useful, but WITHOUT ANY WARRANTY; without even the implied   //
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      //
// PURPOSE.  See the GNU Lesser General Public License for more //
// details.                                                     //
//                                                              //
// You should have received a copy of the GNU Lesser General    //
// Public License along with this source; if not, download it   //
// from http://www.opencores.org/lgpl.shtml                     //
//                                                              //
----------------------------------------------------------------*/

#include "stdio.h"

/* Defines */
#define PAD_RIGHT 1
#define PAD_ZERO  2

/* the following should be enough for 32 bit int */
#define PRINT_BUF_LEN 16


/* format and print a string, inserting variables, to dst char buffer,
   return the number of characters printed. If dst is 0, the string is
   sent to the serial output
*/
int print(char** dst, const char *format, unsigned long *varg)
{
    register int width, pad;
    register int pc = 0;
    char scr[2];

    for (; *format != 0; ++format) {
       if (*format == '%') {
          ++format;
          width = pad = 0;
          if (*format == '\0') break;
          if (*format == '%') goto out;
          if (*format == '-') {
             ++format;
             pad = PAD_RIGHT;
          }
          while (*format == '0') {
             ++format;
             pad |= PAD_ZERO;
          }
          for ( ; *format >= '0' && *format <= '9'; ++format) {
             width *= 10;
             width += *format - '0';
          }
          if( *format == 's' ) {
             register char *s = *((char **)varg++);
             pc += prints (dst, s?s:"(null)", width, pad);
             continue;
          }
          if( *format == 'd' ) {
             pc += printi (dst, *varg++, 10, 1, width, pad, 'a');
             continue;
          }
          if( *format == 'x' ) {
             pc += printi (dst, *varg++, 16, 0, width, pad, 'a');
             continue;
          }
          if( *format == 'X' ) {
             pc += printi (dst, *varg++, 16, 0, width, pad, 'A');
             continue;
          }
          if( *format == 'u' ) {
             pc += printi (dst, *varg++, 10, 0, width, pad, 'a');
             continue;
          }
          if( *format == 'c' ) {
             /* char are converted to int then pushed on the stack */
             scr[0] = *varg++;
             scr[1] = '\0';
             pc += prints (dst, scr, width, pad);
             continue;
          }
       }
       else {
       out:
          if (dst)
              *(*dst)++ = *format;
          else
              serial_putchar_(*format);
          ++pc;
       }
    }

    return pc;
}


/* Print a string - no formatting characters will be interpreted here */
int prints(char** dst, const char *string, int width, int pad)
{
    register int pc = 0, padchar = ' ';

    if (width > 0) {
       register int len = 0;
       register const char *ptr;
       for (ptr = string; *ptr; ++ptr) ++len;
       if (len >= width) width = 0;
       else width -= len;
       if (pad & PAD_ZERO) padchar = '0';
    }
    if (!(pad & PAD_RIGHT)) {
       for ( ; width > 0; --width) {
          if (dst)
              *(*dst)++ = padchar;
          else
              serial_putchar_(padchar);
          ++pc;
       }
    }
    for ( ; *string ; ++string) {
       if (dst)
          *(*dst)++ = *string;
       else
          serial_putchar_(*string);
       ++pc;
    }
    for ( ; width > 0; --width) {
       if (dst)
          *(*dst)++ = padchar;
       else
          serial_putchar_(padchar);
       ++pc;
    }

    return pc;
}


/* Printf an integer */
int printi(char** dst, int i, int b, int sg, int width, int pad, int letbase)
{
    char print_buf[PRINT_BUF_LEN];
    char *s;
    int t, neg = 0, pc = 0;
    unsigned int u = i;

    if (i == 0) {
       print_buf[0] = '0';
       print_buf[1] = '\0';
       return prints (dst, print_buf, width, pad);
    }

    if (sg && b == 10 && i < 0) {
       neg = 1;
       u = -i;
    }

    s = print_buf + PRINT_BUF_LEN-1;
    *s = '\0';

    while (u) {
       if ( b == 16 )    t = u & 0xf;                  /* hex modulous */
       else              t = u - ( _div (u, b) * b );  /* Modulous */

       if( t >= 10 )
          t += letbase - '0' - 10;
       *--s = t + '0';

    /*   u /= b;  */
       if ( b == 16)  u = u >> 4;    /* divide by 16 */
       else           u = _div(u, b);
    }

    if (neg) {
       if( width && (pad & PAD_ZERO) ) {
          if (dst)
              *(*dst)++ = '-';
          else
              serial_putchar_('-');
          ++pc;
          --width;
       }
       else {
          *--s = '-';
       }
    }

    return pc + prints (dst, s, width, pad);
}

