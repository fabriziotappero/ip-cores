/*
 * This source file contains C code for PPC405 cycle counter timer utilities
 * 
 * Redistributions of any form whatsoever must retain and/or include the
 * following acknowledgment, notices and disclaimer:
 *
 * This product includes software developed by Carnegie Mellon University.
 *
 * Copyright (c) 2006 by J. C. Hoe, Carnegie Mellon University
 *
 * You may not use the name "Carnegie Mellon University" or derivations
 * thereof to endorse or promote products derived from this software.
 *
 * If you modify the software you must place a notice on or within any
 * modified version provided or made available to any third party stating
 * that you have modified the software.  The notice shall include at least
 * your name, address, phone number, email address and the date and purpose
 * of the modification.
 *
 * THE SOFTWARE IS PROVIDED "AS-IS" WITHOUT ANY WARRANTY OF ANY KIND, EITHER
 * EXPRESS, IMPLIED OR STATUTORY, INCLUDING BUT NOT LIMITED TO ANY WARRANTY
 * THAT THE SOFTWARE WILL CONFORM TO SPECIFICATIONS OR BE ERROR-FREE AND ANY
 * IMPLIED WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE,
 * TITLE, OR NON-INFRINGEMENT.  IN NO EVENT SHALL CARNEGIE MELLON UNIVERSITY
 * BE LIABLE FOR ANY DAMAGES, INCLUDING BUT NOT LIMITED TO DIRECT, INDIRECT,
 * SPECIAL OR CONSEQUENTIAL DAMAGES, ARISING OUT OF, RESULTING FROM, OR IN
 * ANY WAY CONNECTED WITH THIS SOFTWARE (WHETHER OR NOT BASED UPON WARRANTY,
 * CONTRACT, TORT OR OTHERWISE).
 */

#define MHZ 300

typedef struct
{
    unsigned int upper;
    unsigned int lower;
} TIME_STAMP;

static long long ts_get_ll() {
	unsigned int upper, upper2;
	unsigned int lower;
	
	unsigned long long ans;
	unsigned int x;

	// see PPC405 programmer's manual for explanation
	do {
		asm volatile ("mftbu %[arg]" : [arg] "=r" (upper) : );
		asm volatile ("mftb %[arg]" : [arg] "=r" (lower) : );
		asm volatile ("mftbu %[arg]" : [arg] "=r" (upper2) : );
	} while (upper!=upper2);

	ans=upper;
	ans=ans<<32;
	ans|=lower;
	
	return ans;
}


static unsigned int ts_elapse_us(long long start, long long finish) {
	unsigned long long elapse=(finish-start);

	unsigned int xf=finish;
	unsigned int xs=start;

	elapse=elapse/MHZ;
	
	return elapse;
}

static unsigned int ts_elapse_ns(long long start, long long finish) {
	unsigned long long elapse=(finish-start);

	unsigned int xf=finish;
	unsigned int xs=start;

	elapse=(elapse*1000)/MHZ;
	return elapse;
	
}
