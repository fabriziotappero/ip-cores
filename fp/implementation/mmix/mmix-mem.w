% This file is part of the MMIXware package (c) Donald E Knuth 1999
@i boilerplate.w %<< legal stuff: PLEASE READ IT BEFORE MAKING ANY CHANGES!

\def\title{MMIX-MEM}
\def\MMIX{\.{MMIX}}
\def\Hex#1{\hbox{$^{\scriptscriptstyle\#}$\tt#1}} % experimental hex constant
@s octa int

@* Memory-mapped input and output. This module supplies procedures for reading
@^I/O@>
@^input/output@>
@^memory-mapped input/output@>
and writing \MMIX\ memory addresses that exceed 48 bits. Such addresses are
used by the operating system for input and output, so they require special
treatment. At present only dummy versions of these routines are implemented.
Users who need nontrivial versions of |spec_read| and/or |spec_write| should
prepare their own and link them with the rest of the simulator.

@p
#include <stdio.h>
#include "mmix-pipe.h" /* header file for all modules */
extern octa read_hex(); /* found in the main program module */
static char buf[20];

@ If the |interactive_read_bit| of the |verbose| control is set,
the user is supposed to supply values dynamically. Otherwise
zero is read.

@p
octa spec_read @,@,@[ARGS((octa))@];@+@t}\6{@>
octa spec_read(addr)
  octa addr;
{
  octa val;
  if (verbose&interactive_read_bit) {
    printf("** Read from loc %08x%08x: ",addr.h,addr.l);
    fgets(buf,20,stdin);
    val=read_hex(buf);
  } else val.l=val.h=0;
  if (verbose&show_spec_bit)
    printf("   (spec_read %08x%08x from %08x%08x at time %d)\n",
      val.h,val.l,addr.h,addr.l,ticks.l);
  return val;
}

@ The default |spec_write| just reports its arguments, without actually
writing anything.

@p
void spec_write @,@,@[ARGS((octa,octa))@];@+@t}\6{@>
void spec_write(addr,val)
  octa addr,val;
{
  if (verbose&show_spec_bit) 
    printf("   (spec_write %08x%08x to %08x%08x at time %d)\n",
      val.h,val.l,addr.h,addr.l,ticks.l);
}

@* Index.
