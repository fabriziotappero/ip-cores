/* Support */

#ifndef OR1K
#include <sys/time.h>
#endif

#include "spr_defs.h"
#include "support.h"
#include "int.h"

#if OR1K
//void excpt_dummy();
//void int_main();

//unsigned long excpt_buserr = (unsigned long) excpt_dummy;
//unsigned long excpt_dpfault = (unsigned long) excpt_dummy;
//unsigned long excpt_ipfault = (unsigned long) excpt_dummy;
//unsigned long excpt_tick = (unsigned long) excpt_dummy;
//unsigned long excpt_align = (unsigned long) excpt_dummy;
//unsigned long excpt_illinsn = (unsigned long) excpt_dummy;
//unsigned long excpt_int = (unsigned long) int_main;
//unsigned long excpt_dtlbmiss = (unsigned long) excpt_dummy;
//unsigned long excpt_itlbmiss = (unsigned long) excpt_dummy;
//unsigned long excpt_range = (unsigned long) excpt_dummy;
//unsigned long excpt_syscall = (unsigned long) excpt_dummy;
//unsigned long excpt_break = (unsigned long) excpt_dummy;
//unsigned long excpt_trap = (unsigned long) excpt_dummy;


/* Start function, called by reset exception handler.  */
void reset ()
{
  int i = main();
  exit (i); 
}

/* return value by making a syscall */
void exit (int i)
{
  asm("l.add r3,r0,%0": : "r" (i));
  asm("l.nop %0": :"K" (NOP_EXIT));
  while (1);
}

/* activate printf support in simulator */
//void printf(const char *fmt, ...)
//{
//  va_list args;
//  va_start(args, fmt);
//  __asm__ __volatile__ ("  l.addi\tr3,%1,0\n \
//                           l.addi\tr4,%2,0\n \
//                           l.nop %0": :"K" (NOP_PRINTF), "r" (fmt), "r"  (args));
//}

/* print long */
void report(unsigned long value)
{
  asm("l.addi\tr3,%0,0": :"r" (value));
  asm("l.nop %0": :"K" (NOP_REPORT));
}

/* just to satisfy linker */
//void __main()
//{
//}

/* start_TIMER                    */
void start_timer(int x)
{
}

/* read_TIMER                    */
/*  Returns a value since started in uS */
unsigned int read_timer(int x)
{
  unsigned long count = 0;

  /* Read the Time Stamp Counter */
/*        asm("simrdtsc %0" :"=r" (count)); */
  /*asm("l.sys 201"); */
  return count;
}

/* For writing into SPR. */
void mtspr(unsigned long spr, unsigned long value) __attribute__ ((section(".icm")));
void mtspr(unsigned long spr, unsigned long value)
{	
  asm("l.mtspr\t\t%0,%1,0": : "r" (spr), "r" (value));
}

/* For reading SPR. */
unsigned long mfspr(unsigned long spr) __attribute__ ((section(".icm")));
unsigned long mfspr(unsigned long spr)
{	
  unsigned long value;
  asm("l.mfspr\t\t%0,%1,0" : "=r" (value) : "r" (spr));
  return value;
}

#else
void report(unsigned long value)
{
  printf("report(0x%x);\n", (unsigned) value);
}

/* start_TIMER                    */
void start_timer(int tmrnum)
{
}

/* read_TIMER                    */
/*  Returns a value since started in uS */
unsigned int read_timer(int tmrnum)
{
  struct timeval tv;
  struct timezone tz;

  gettimeofday(&tv, &tz);
	
  return(tv.tv_sec*1000000+tv.tv_usec);
}

#endif

void *memcpy (void *__restrict dstvoid,
              __const void *__restrict srcvoid, size_t length)
{
  char *dst = dstvoid;
  const char *src = (const char *) srcvoid;

  while (length--)
    *dst++ = *src++;
  return dst;
}

//void excpt_dummy() {}
