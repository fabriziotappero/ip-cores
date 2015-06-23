/* Support file for or32 tests.  This file should is included
   in each test. It calls main() function and add support for
   basic functions */

#ifndef SUPPORT_H
#define SUPPORT_H

#include <stdarg.h>
#include <stddef.h>
#include <limits.h>
#define OR1K 1  //ME added

//#define UART_PRINTF
#if OR1K

/* Register access macros */
#define REG8(add) *((volatile unsigned char *)(add))
#define REG16(add) *((volatile unsigned short *)(add))
#define REG32(add) *((volatile unsigned long *)(add))

void printf(const char *fmt, ...);

/* For writing into SPR. */
void mtspr(unsigned long spr, unsigned long value);

/* For reading SPR. */
unsigned long mfspr(unsigned long spr);

#else /* OR1K */

#include <stdio.h>

#endif /* OR1K */

/* Function to be called at entry point - not defined here.  */
int main ();

/* Prints out a value */
void report(unsigned long value);

/* return value by making a syscall */
extern void or32_exit (int i) __attribute__ ((__noreturn__));

/* memcpy clone */
/*
extern void *memcpy (void *__restrict __dest,
                     __const void *__restrict __src, size_t __n);
*/

/* Timer functions */
extern void start_timer(int);
extern unsigned int read_timer(int);

extern unsigned long excpt_buserr;
extern unsigned long excpt_dpfault;
extern unsigned long excpt_ipfault;
extern unsigned long excpt_tick;
extern unsigned long excpt_align;
extern unsigned long excpt_illinsn;
extern unsigned long excpt_int;
extern unsigned long excpt_dtlbmiss;
extern unsigned long excpt_itlbmiss;
extern unsigned long excpt_range;
extern unsigned long excpt_syscall;
extern unsigned long excpt_break;
extern unsigned long excpt_trap;

#endif
