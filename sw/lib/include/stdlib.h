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

#ifndef _STDLIB_H
#define _STDLIB_H

/******************************************************************************
 * Timer                                                                      *
 ******************************************************************************/
 /* Porgammable Intervall Timer control loaction. */
#define PIT_ADDRESS ((volatile uint *) 0xfffff000)
 
/* Time periods in seconds and milliseconds respectivly. 
   NOTE: No hardware implementation of multiplication available! */
#define sec(x)    ( 50000000*x )
#define msec(x)   ( 50000*x )


/******************************************************************************
 * RS-232                                                                     *
 ******************************************************************************/
/* RS-232 Receiver Address. */
#define RS232_ADDRESS  ((volatile uint *) 0xffff4000)

/* Poll for valid received serial data. */
#define RS232_RCV_POLL ((ushort) 0x8000)


/* 10 times x. */
#define x10(x) ( (x << 3) + (x << 1) )


/******************************************************************************
 * Timer                                                                      *
 ******************************************************************************/
/* Resets the counter. If you call reset before the counter has finished, it
   returns the count progress. */
extern uint pit_reset();

/* Set the PIT limit and start counting. */
extern void pit_run(uint cycles);


/******************************************************************************
 * RS-232                                                                     *
 ******************************************************************************/
 /* Wait for one byte of data. Return n reception. */
extern uchar rs232_receive();

/* Send one byte of data. */
extern void rs232_transmit(uchar chr);


/******************************************************************************
 * Memory Operations                                                          *
 ******************************************************************************/
 
extern void memcpy(const void *src, void *dst, uint len);

extern void memset(const void *ptr, int val, uint len);

extern int memcmp(const void *src, void *dst, uint len);


/******************************************************************************
 * String Operations                                                          *
 ******************************************************************************/
/* Returns the length of a string */
extern uint strlen(const uchar *str);

/* Copys a string at location src to location dst. */
extern void strcpy(const uchar *src, uchar *dst);

// KMP algo
// char *strstr(const char *str, const char *pat);

/* Returns a pointer to the leftmost occurence of character chr in 
   string str or NULL, if not found. */
extern uchar *strchr(const uchar *str, const uchar chr);


/******************************************************************************
 * Number/String Conversion                                                   *
 ******************************************************************************/
/* Convert a string containing a decimal number into a number. */
extern int atoi(const uchar *str);

//extern char* itoa(int num, char *str);

/* Returns a binary representation of an integer <num>. The buffer <str> must be
   at least 35 byte wide to hold the char sequence of the form '0bn...n\0'. */
extern uchar* itob(int num, uchar *str);

/* Returns a hexadecimal representation of an integer <num>. The buffer <str> 
   must be at least 11 byte wide to hold the char sequence of the form 
   '0xn...n\0'. */
extern uchar* itox(int num, uchar *str);


/******************************************************************************
 * Nathematics                                                                *
 ******************************************************************************/
/* Xorshift RNGs, George Marsaglia
   http://www.jstatsoft.org/v08/i14/paper */
extern uint rand();
 
/* Radix-4 Booth Multiplication Algorithm */
extern int mul(short a, short b);

extern short div(int a, int b);

 
// extern void *malloc(uint size);
// extern void *calloc(uint num, uint size);
// extern void free(void *ptr);

#endif