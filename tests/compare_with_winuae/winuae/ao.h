/* 
 * Copyright 2010, Aleksander Osman, alfik@poczta.fm. All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without modification, are
 * permitted provided that the following conditions are met:
 *
 *  1. Redistributions of source code must retain the above copyright notice, this list of
 *     conditions and the following disclaimer.
 *
 *  2. Redistributions in binary form must reproduce the above copyright notice, this list
 *     of conditions and the following disclaimer in the documentation and/or other materials
 *     provided with the distribution.
 *
 * THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR IMPLIED
 * WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
 * FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR OR
 * CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
 * SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON
 * ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
 * NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF
 * ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

#ifndef __AO_H__
#define __AO_H__

#include <stdio.h>
#include <stdlib.h>
#include <stdarg.h>
#include <string.h>
#include <wchar.h>
#include <assert.h>

//from sysdeps.h -----------------------

#define ENUMDECL typedef enum
#define ENUMNAME(name) name

typedef unsigned char uae_u8;
typedef signed char uae_s8;

typedef unsigned short uae_u16;
typedef short uae_s16;

typedef unsigned int uae_u32;
typedef int uae_s32;

typedef uae_u32 uaecptr;

typedef wchar_t TCHAR;

#define CPU_EMU_SIZE 0
#define CYCLE_UNIT 512

#define STATIC_INLINE static __inline__ __attribute__ ((always_inline))

//-------------------------------------

#define _vsnprintf vsnprintf
#define xfree free
#define xmalloc malloc
#define _tcsncmp wcsncmp
#define _istspace iswspace
#define _tcscmp wcscmp
#define _tcslen wcslen

STATIC_INLINE char *ua (const TCHAR *str) {
	int len;
	
	len = wcslen(str);
	char *result = (char*)xmalloc(len);
	
	const wchar_t *ptr = str;
	wcsrtombs(result, &ptr, len, NULL);
	return result;
}


// z newcpu.h ----------
#define get_iword(o) get_wordi((uaecptr)((regs).pc_p + (o)))

#define REGPARAM
#define REGPARAM2
#define REGPARAM3
typedef unsigned long REGPARAM3 cpuop_func (uae_u32) REGPARAM;
typedef void REGPARAM3 cpuop_func_ce (uae_u32) REGPARAM;

struct cputbl {
	cpuop_func *handler;
	uae_u16 opcode;
};

typedef uae_u8 flagtype;

extern struct regstruct
{
	uae_u32 regs[16];

	uae_u32 pc;
	uae_u8 *pc_p;
	uae_u8 *pc_oldp;

	uae_u16 irc, ir;
	uae_u32 spcflags;

	uaecptr usp, isp, msp;
	uae_u16 sr;
	flagtype t1;
	flagtype t0;
	flagtype s;
	flagtype m;
	flagtype x;
	flagtype stopped;
	int intmask;

	uae_u32 vbr, sfc, dfc;

#ifdef FPUEMU
	fptype fp[8];
	fptype fp_result;

	uae_u32 fpcr, fpsr, fpiar;
	uae_u32 fpsr_highbyte;
#endif
#ifndef CPUEMU_68000_ONLY
	uae_u32 cacr, caar;
	uae_u32 itt0, itt1, dtt0, dtt1;
	uae_u32 tcr, mmusr, urp, srp, buscr;
	uae_u32 mmu_fslw, mmu_fault_addr;
	uae_u16 mmu_ssw;
	uae_u32 wb3_data;
	uae_u16 wb3_status;
	int mmu_enabled;
	int mmu_pagesize_8k;
	uae_u32 fault_pc;
#endif

	uae_u32 pcr;
	uae_u32 address_space_mask;

	uae_u8 panic;
	uae_u32 panic_pc, panic_addr;

	uae_u32 prefetch020data;
	uae_u32 prefetch020addr;
	int ce020memcycles;

} regs, lastint_regs, mmu_backup_regs;

#define m68k_dreg(r,num) ((r).regs[(num)])
#define m68k_areg(r,num) (((r).regs + 8)[(num)])

extern const int imm8_table[];
extern const int areg_byteinc[];

extern int movem_index1[256];
extern int movem_index2[256];
extern int movem_next[256];

//m68k.h
struct flag_struct {
    unsigned int c;
    unsigned int z;
    unsigned int n;
    unsigned int v;
    unsigned int x;
};

extern struct flag_struct regflags;

#define ZFLG (regflags.z)
#define NFLG (regflags.n)
#define CFLG (regflags.c)
#define VFLG (regflags.v)
#define XFLG (regflags.x)

static __inline__ int cctrue(const int cc)
{
    switch(cc){
     case 0: return 1;                       /* T */
     case 1: return 0;                       /* F */
     case 2: return !CFLG && !ZFLG;          /* HI */
     case 3: return CFLG || ZFLG;            /* LS */
     case 4: return !CFLG;                   /* CC */
     case 5: return CFLG;                    /* CS */
     case 6: return !ZFLG;                   /* NE */
     case 7: return ZFLG;                    /* EQ */
     case 8: return !VFLG;                   /* VC */
     case 9: return VFLG;                    /* VS */
     case 10:return !NFLG;                   /* PL */
     case 11:return NFLG;                    /* MI */
     case 12:return NFLG == VFLG;            /* GE */
     case 13:return NFLG != VFLG;            /* LT */
     case 14:return !ZFLG && (NFLG == VFLG); /* GT */
     case 15:return ZFLG || (NFLG != VFLG);  /* LE */
    }
    abort();
    return 0;
}

//newcpu.h
#define SET_CFLG(x) (CFLG = (x))
#define SET_NFLG(x) (NFLG = (x))
#define SET_VFLG(x) (VFLG = (x))
#define SET_ZFLG(x) (ZFLG = (x))
#define SET_XFLG(x) (XFLG = (x))

#define GET_CFLG() CFLG
#define GET_NFLG() NFLG
#define GET_VFLG() VFLG
#define GET_ZFLG() ZFLG
#define GET_XFLG() XFLG

#define CLEAR_CZNV() do { \
	SET_CFLG (0); \
	SET_ZFLG (0); \
	SET_NFLG (0); \
	SET_VFLG (0); \
} while (0)

#define COPY_CARRY() (SET_XFLG (GET_CFLG ()))

//...newcpu.h

#define m68k_incpc(o) ((regs).pc_p += (o))

#define get_cpu_model() 68000

#endif // __AO_H__

