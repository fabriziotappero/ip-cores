/**********************************************************************
axasm Copyright 2006, 2007, 2008, 2009 
by Al Williams (alw@al-williams.com).


This file is part of axasm.

axasm is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public Licenses as published
by the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

axasm is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY: without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with axasm (see LICENSE.TXT). 
If not, see http://www.gnu.org/licenses/.

If a non-GPL license is desired, contact the author.

This is the One-Der definition file

***********************************************************************/
#ifndef __SOLO_ASM_INC
#define __SOLO_ASM_INC
#include <stdio.h>  // needed for XSYM
#include <stdlib.h>
#include <soloasm.h>

/* Define _SOLO_XSYM to get symbol xref dumped to stderr */

// Define this to override to a different memory size (in words, not bytes!)
#ifndef MAXMEM
#define MAXMEM 99
#endif

static void __setary(unsigned int a, unsigned int v)
  {
  if (a>=MAXMEM) 
     {
     fprintf(stderr,"Memory overflow, program too large.\n");
     _solo_info.err=1;
     }
  else _solo_info.ary[a]=v;
  }


// note ORG is only for first address, use REORG to start over
#define ORG(n) unsigned int genasm(int _solo_pass) { \
   unsigned _solo_add=n;\
   _solo_info.psize=16; \
   _solo_info.begin=n; \
   _solo_info.end=n; \
   _solo_info.memsize=MAXMEM; \
   _solo_info.ary=malloc(_solo_info.memsize*_solo_info.psize); \
   _solo_info.err=(_solo_info.ary==NULL)

#define REORG(n) _solo_info.end=((_solo_add)-1)>_solo_info.end?((_solo_add)-1):_solo_info.end; _solo_add=n; _solo_info.begin=(n)<_solo_info.begin?(n):_solo_info.begin
// Assume end is at the highest address
#define END _solo_info.end=_solo_info.end<_solo_add-1?_solo_add-1:_solo_info.end; return _solo_info.end; }
// Note this requires a compiler like gcc that supports var 
// declarations inthe middle of a block
#define DEFLABEL(l) static unsigned l
#ifdef _SOLO_XSYM
#define LABEL(l) l=_solo_add; if (_solo_pass==2) fprintf(stderr,"%-32s:\t%08X\n",#l,_solo_add)
#else
#define LABEL(l) l=_solo_add
#endif


#define bcd(n) ((((n)/100)<<8)+((((n)/10)%10)<<4)+((n)%10))

#define DATA(d) __setary(_solo_add++,(bcd(d)))
#define NEGDATA(d) __setary(_solo_add++,0x1000 + bcd(d))

#define INP(r) __setary(_solo_add++,bcd(r))
#define LOD(r) __setary(_solo_add++,bcd(100+(r)))
#define ADD(r) __setary(_solo_add++,bcd(200+(r)))
#define TAC(r) __setary(_solo_add++,bcd(300+(r)))
#define SFT(r,l) __setary(_solo_add++,bcd(400+((r)*10)+(l)))
#define OUT(r) __setary(_solo_add++,bcd(500+(r)))
#define STO(r) __setary(_solo_add++,bcd(600+(r)))
#define SUB(r) __setary(_solo_add++,bcd(700+(r)))
#define JMP(r) __setary(_solo_add++,bcd(800+(r)))
#define HLT __setary(_solo_add++,bcd(900))


#endif
