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
#define MAXMEM 0xFFFF
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
   _solo_info.psize=32; \
   _solo_info.begin=n; \
   _solo_info.end=n; \
   _solo_info.memsize=MAXMEM; \
   _solo_info.ary=malloc(_solo_info.memsize); \
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


// Note: This looks wrong but solo asm adjusts the top bit
#define R(n) ((n)+0x1000)
#define F(unit,sub) ((sub)<<8|(unit))


///////////////////////////// Old style definitions
//// Note these are no longer maintained
#ifdef OLDSTYLE
#include "soloasm-old.inc"

/////////////////////// New style definitions (preferred)
#else

#define FPC 1
#define FPC_VALUE F(FPC,0)
// RW
#define FPC_PLUS1 F(FPC,1)
#define FPC_PLUS2 F(FPC,2)
#define FPC_PGMRDADD F(FPC,4)
#define FPC_INTVECTOR F(FPC,7)
#define FPC_RETINT F(FPC,0xB)
#define FPC_RETINTX F(FPC,0xC)
#define FPC_WADD F(FPC,9) 
#define FPC_WDATA F(FPC,10)
#define FPC_WRITE F(FPC,13)
#define FPC_IMMVAL F(FPC,14)
// Writes
#define FPC_ADD F(FPC,1)  
#define FPC_SKIP2 F(FPC,3)
#define FPC_PGMRD F(FPC,5)
#define FPC_CLEAR F(FPC,6) 
#define FPC_IMM F(FPC,15)
#define FPC_CALL F(FPC,8)
// Reads
#define FPC_PLUS1 F(FPC,1)
// aliases
#define FIMMV 0xE01
#define FIMM 0xF01
#define INTENABLE MOV(FPC_RETINT,FZERO)
#define INTDISABLE MOV(FPC_RETINTX,FZERO)
#define RETI MOV(FPC_RETINT,FPC)
#define RETIX MOV(FPC_RETINTX,FPC)


#define MOVI(n) MOV(FZERO,FIMM); DATA(n)
#define LDI(n) MOVI(n)
#define LDIQ(d) __setary(_solo_add++,0x10000000|(d&0xFFFFFFF))
#define MOVIQ LDIQ
#define LDRIQ(d,dest) LDIQ((d)); MOV(FIMMV,(dest))
#define LDRI(d,dest) MOVI(d); MOV(FIMMV,(dest))

#define JMP(n) MOVI(n); MOV(FIMMV,FPC)
#define JMPQ(n) LDIQ(n); MOV(FIMMV,FPC)
#define CALL(n) MOVI(n); MOV(FIMMV,FPC_CALL)
#define CALLR(n) MOV(R(n),FPC_CALL)
#define JMPR(n) MOV(R(n),FPC)
#define CALLQ(n) LDIQ(n); MOV(FIMMV,FPC_CALL)

#define FCON 0
#define FCON_0 F(FCON,0)
#define FCON_1 F(FCON,1)
#define FCON_2 F(FCON,2)
#define FCON_80000000 F(FCON,3)
#define FCON_4 F(FCON,4)
#define FCON_ff F(FCON,5)
#define FCON_ff00 F(FCON,6)
#define FCON_ff0000 F(FCON,7)
#define FCON_ff000000 F(FCON,8)
#define FCON_10 F(FCON,9)
#define FCON_a F(FCON,10)
#define FCON_f F(FCON,11)
#define FCON_f0 F(FCON,12)
#define FCON_80 F(FCON,13)
#define FCON_aaaaaaaa F(FCON,14)
#define FCON_ffffffff F(FCON,15)
#define FCON_neg1 F(FCON,15)
// aliases
#define FZERO 0x000
#define FONE 0x100
#define ZERO(r) MOV(FZERO,r)

#define FACC 2
#define FACC_VALUE F(FACC,0)
#define FACC_ADD F(FACC,1)
#define FACC_SUB F(FACC,2)
#define FACC_SHL F(FACC,3)
#define FACC_SHR F(FACC,4)
#define FACC_RAL F(FACC,5)
#define FACC_RAR F(FACC,6)
#define FACC_OR F(FACC,7)
#define FACC_AND F(FACC,8)
#define FACC_XOR F(FACC,9)
#define FACC_ADC F(FACC,10)
#define FACC_FLAGS F(FACC,15)  // Read only


#define FMEM 3    
#define FMEM_MP0 F(FMEM,0)
#define FMEM_SIZE0 F(FMEM,1)
#define FMEM_VALUE0 F(FMEM,2)
#define FMEM_VALUE0POST F(FMEM,3)
#define FMEM_VALUE0PRE F(FMEM,4)
#define FMEM_OFFSET0 F(FMEM,5)
#define FMEM_VALUE0OFFSET F(FMEM,6)
#define FMEM_MP0ADD F(FMEM,7)
#define FMEM_MP1 F(FMEM,8)
#define FMEM_SIZE1 F(FMEM,9)
#define FMEM_VALUE1 F(FMEM,10)
#define FMEM_VALUE1POST F(FMEM,11)
#define FMEM_VALUE1PRE F(FMEM,12)
#define FMEM_OFFSET1 F(FMEM,13)
#define FMEM_VALUE1OFFSET F(FMEM,14)
#define FMEM_MP1ADD F(FMEM,15)


#define FSTK 4
#define FSTK_PUSH F(FSTK,3)
#define FSTK_POP F(FSTK,4)
#define FSTK_SP F(FSTK,0)
#define FSTK_TOS F(FSTK,2)
#define FSTK_OFFSET F(FSTK,5)
#define FSTK_ATOFFSET F(FSTK,6)
#define FSTK_SPADD F(FSTK,7)
#define FSTK_LOCAL1 F(FSTK,9)
#define FSTK_LOCAL2 F(FSTK,10)
#define FSTK_LOCAL3 F(FSTK,11)
#define FSTK_LOCAL4 F(FSTK,12)
#define FSTK_LOCAL5 F(FSTK,13)
#define FSTK_LOCAL6 F(FSTK,14)
#define FSTK_LOCAL7 F(FSTK,15)
#define FSTK_LOCAL(n) F(FSTK,(8+(n))&0xF)

#define PUSH(r) MOV(r,FSTK_PUSH)
#define POP(r) MOV(FSTK_POP,r)

#define FCMP 5 
#define FCMP_X F(FCMP,0)
#define FCMP_TARGET F(FCMP,4)
#define FCMP_EQ F(FCMP,1)
#define FCMP_EQ2 F(FCMP,5)
#define FCMP_NE F(FCMP,9)
#define FCMP_NE2 F(FCMP,0xD)
#define FCMP_LT F(FCMP,2)
#define FCMP_LT2 F(FCMP,6)
#define FCMP_GT F(FCMP,3)
#define FCMP_GT2 F(FCMP,7)
#define FCMP_LE F(FCMP,11)
#define FCMP_LE2 F(FCMP,15)
#define FCMP_GE F(FCMP,10)
#define FCMP_GE2 F(FCMP,14)

#define FBYTE 6
#define FBYTE_0 F(FBYTE,0)
#define FBYTE_1 F(FBYTE,1)
#define FBYTE_2 F(FBYTE,2)
#define FBYTE_3 F(FBYTE,3)
#define FBYTE_W0 F(FBYTE,4)
#define FBYTE_W1 F(FBYTE,5)
#define FBYTE_SWAP16 F(FBYTE,6)
#define FBYTE_BLEFT F(FBYTE,7)
#define FBYTE_BRIGHT F(FBYTE,8)

#define FLOOP 7 
#define FLOOP_I F(FLOOP,0)     // loop variable (set to init)
#define FLOOP_IINC F(FLOOP,1)  // loop increment (can be negative)
#define FLOOP_IEND F(FLOOP,2)  // loop end
#define FLOOP_IADD F(FLOOP,3)  // address to send if loop not ended or pc+1
#define FLOOP_J F(FLOOP,4)     // loop variable (set to init)
#define FLOOP_JINC F(FLOOP,5)  // loop increment (can be negative)
#define FLOOP_JEND F(FLOOP,6)  // loop end
#define FLOOP_JADD F(FLOOP,7)  // address to send if loop not ended or pc+1
#define FLOOP_IADDR F(FLOOP,8) // relative address (returns 0 if loop ends)
#define FLOOP_JADDR F(FLOOP,9) // relative address (returns 0 if loop ends)
#define I FLOOP_I
#define J FLOOP_J

#define FACC2 8
#define FACC2_VALUE F(FACC2,0)
#define FACC2_ADD F(FACC2,1)
#define FACC2_SUB F(FACC2,2)
#define FACC2_SHL F(FACC2,3)
#define FACC2_SHR F(FACC2,4)
#define FACC2_RAL F(FACC2,5)
#define FACC2_RAR F(FACC2,6)
#define FACC2_OR F(FACC2,7)
#define FACC2_AND F(FACC2,8)
#define FACC2_XOR F(FACC2,9)
#define FACC2_ADC F(FACC2,10)
#define FACC2_FLAGS F(FACC2,15)  // Read only
// note flags don't work in FACC2

#define FDSTK 9
#define FDSTK_PUSH F(FDSTK,3)
#define FDSTK_POP F(FDSTK,4)
#define FDSTK_SP F(FDSTK,0)
#define FDSTK_TOS F(FDSTK,2)
#define FDSTK_OFFSET F(FDSTK,5)
#define FDSTK_ATOFFSET F(FDSTK,6)
#define FDSTK_SPADD F(FDSTK,7)
#define FDSTK_LOCAL1 F(FDSTK,9)
#define FDSTK_LOCAL2 F(FDSTK,10)
#define FDSTK_LOCAL3 F(FDSTK,11)
#define FDSTK_LOCAL4 F(FDSTK,12)
#define FDSTK_LOCAL5 F(FDSTK,13)
#define FDSTK_LOCAL6 F(FDSTK,14)
#define FDSTK_LOCAL7 F(FDSTK,15)
#define FDSTK_LOCAL(n) F(FDSTK,(8+(n))&0xF)

#define PUSHD(r) MOV(r,FDSTK_PUSH)
#define POPD(r) MOV(FDSTK_POP,r)



#define FDEBUG 0xFD
#define FDEBUG_SOURCE F(FDEBUG,0)
#define FDEBUG_MASK F(FDEBUG,1)
#define FDEBUG_PC F(FDEBUG 2)
#define FDEBUG_SRC F(FDEBUG,3)
#define FDEBUG_DST F(FDEBUG,4)

#define FDEBUG_PCINT 0
#define FDEBUG_SRCINT 1
#define FDEBUG_SRCDST 2
#define FDEBUG_STEP 8



#define FIO  0xFE
#define FIO_LED F(FIO,0)
#define FIO_SW F(FIO,0)
#define FIO_DISP F(FIO,1)
#define FIO_DPS F(FIO,2)
#define FIO_UART F(FIO,3)
#define FIO_UART_DR F(FIO,4)
#define FIO_UART_TBE F(FIO,5)
#define FIO_UART_TSE F(FIO,6)
#define FIO_INP F(FIO,7)
#define FIO_OUT F(FIO,8)
#define FIO_INTFLAG F(FIO,9)
#define FIO_INTMASK F(FIO,10)
#define FIO_TIMER F(FIO,11)
#define FIO_SWI F(FIO,0xE)
#define FIO_DELAY F(FIO,0xF)

#define FIO_INTSWI 0
#define FIO_INTTIMER 1
#define FIO_INTPB 2
#define FIO_INTUARTRX 4
#define FIO_INTUARTTX 8
#define FIO_INTUARTERR 16
#define FIO_INTB0RISE 32
#define FIO_DEBUG 63



#define RET MOV(FSTK_POP,FPC)
#define RETURN RET

#endif



#define DATA(d) __setary(_solo_add++,(d))
// DATA4 is requird for STRINGPACK
#define DATA4(a,b,c,d) DATA(((a)<<24)|((b)<<16)|((c)<<8)|(d))
// 28-bit sign extended immediate load

#define soloASM(mask,cond,src,dst) __setary(_solo_add++,((mask)<<29)|((cond)<<26)|((src)&0x1000)<<13|((dst)&0x1000)<<12 | ((src) & 0xFFF)<<12 | ((dst & 0xFFF)))

// note: these look "wrong" but soloasm does the right shifts
#define Z 4
#define C 2
#define S 1


#define MOV(src,dst) soloASM(0,0,src,dst)
#define MOVIF(mask,cond,src,dst) soloASM(mask,cond,src,dst)
#define MOVZ(src,dst) soloASM(Z,Z,src,dst)
#define MOVNZ(src,dst) soloASM(Z,0,src,dst)
#define MOVC(src,dst) soloASM(C,C,src,dst)
#define MOVNC(src,dst) soloASM(C,0,src,dst)
#define MOVP(src,dst) soloASM(S,0,src,dst)
#define MOVN(src,dst) soloASM(S,S,src,dst)

// could define combos (16 total) but MOVIF takes care of it


// Other condtional things
#define RETZ MOVZ(FSTK_POP,FPC)
#define RETNZ MOVNZ(FSTK_POP,FPC)
#define RETC MOVC(FSTK_POP,FPC)
#define RETNC MOVNC(FSTK_POP,FPC)
#define RETP MOVP(FSTK_POP,FPC)
#define RETN MOVN(FSTK_POP,FPC)

#define JMPZ(lbl) MOVI(lbl); MOVZ(FIMMV,FPC)
#define JMPZQ(lbl) MOVIQ(lbl); MOVZ(FIMMV,FPC)
#define JMPNZ(lbl) MOVI(lbl); MOVNZ(FIMMV,FPC)
#define JMPNZQ(lbl) MOVIQ(lbl); MOVNZ(FIMMV,FPC)
#define JMPC(lbl) MOVI(lbl); MOVC(FIMMV,FPC)
#define JMPCQ(lbl) MOVIQ(lbl); MOVC(FIMMV,FPC)
#define JMPNC(lbl) MOVI(lbl); MOVNC(FIMMV,FPC)
#define JMPNCQ(lbl) MOVIQ(lbl); MOVNC(FIMMV,FPC)
#define JMPP(lbl) MOVI(lbl); MOVP(FIMMV,FPC)
#define JMPPQ(lbl) MOVIQ(lbl); MOVP(FIMMV,FPC)
#define JMPN(lbl) MOVI(lbl); MOVN(FIMMV,FPC)
#define JMPNQ(lbl) MOVIQ(lbl); MOVN(FIMMV,FPC)

#define HALT MOV(FCON_0,FPC_ADD)
#define NOP MOV(FZERO,FZERO)

#define SWI MOV(FZERO,FIO_SWI)
#define SWIN(n) LDRIQ(n,FIO_SWI)

#define INC MOV(FONE,FACC_ADD)
#define INC2 MOV(FONE,FACC2_ADD)


#endif
