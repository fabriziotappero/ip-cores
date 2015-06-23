#include "testmod.h"
#include "leon3.h"

#define CCTRL_IFP (1<<15)
#define CCTRL_DFP (1<<14)

#define DDIAGMSK ((1<<DTAGLOW)-1)
#define IDIAGMSK ((1<<ITAGLOW)-1)

#define ICLOCK_BIT 6
#define DCLOCK_BIT 7


int icconf, dcconf, dsetsize, isetsize;
int dsetbits, isetbits;
int DSETS, DTAGLOW, DTAGAMSK, ITAGAMSK, ITAGLOW;

flush()
{
	asm(" flush");
}

getitag(addr, set)
int addr, set;
{
  int tag;

  tag = asmgetitag((addr & IDIAGMSK) + (set<<isetbits));
  return(tag);
}


setitag(addr, set, data)
int addr, set, data;
{
  asmsetitag((addr & IDIAGMSK) + (set<<isetbits), data);
}

setidata(addr, set, data)
int addr, set, data;
{
  asmsetidata((addr & IDIAGMSK) + (set<<isetbits), data);
}


getidata(addr, set)
int addr, set;
{
  int idata;
  
  idata = asmgetidata((addr & IDIAGMSK) + (set<<isetbits));
  return(idata);
}


asmgetitag(addr) int addr; { asm(" lda	[%o0] 0xc, %o0 "); }
asmsetitag(addr,data) int *addr,data; { asm(" sta	%o1, [%o0] 0xc "); }

asmgetidata(addr) int addr; { asm(" lda	[%o0] 0xd, %o0 "); }
asmsetidata(addr,data) int *addr,data; { asm(" sta	%o1, [%o0] 0xd "); }

wsysreg(addr,data) int *addr,data; { asm(" sta	%o1, [%o0] 0x2 "); }
rsysreg(addr) int addr; { asm(" lda	[%o0] 0x2, %o0 "); }


setdtag(addr, set, data)
int addr, set, data;
{
  asmsetdtag((addr & DDIAGMSK) + (set<<dsetbits), data);
}

setddata(addr, set, data)
int addr, set, data;
{
  asmsetddata((addr & DDIAGMSK) + (set<<dsetbits), data);
}

chkdtag(addr) 
int addr;
{
  int tm[16];
  int tmp, i;

  tmp = 0; 
  for (i=0;i<DSETS;i++) {
    if (((asmgetdtag((addr & DDIAGMSK) + (i<<dsetbits))) & DTAGAMSK) == (addr & DTAGAMSK))
      tmp++;
  }
  if (tmp != 0)
    return 0;
  else 
    return 1;
}  

getdtag(addr, set)
int addr;
{
  int tag;
  
  tag = asmgetdtag((addr & DDIAGMSK) + (set<<dsetbits));
  return(tag);
}


getddata(addr, set)
int addr, set;
{
  int ddata;

  ddata = asmgetddata((addr & DDIAGMSK) + (set<<dsetbits)); 
  return(ddata);
}



dma(int addr, int len,  int write)
{
	volatile unsigned int *dm = (unsigned int *) 0xa0000000;

	dm[0] = addr;
	dm[1] = (write <<13) + 0x1000 + len;

}

asmgetdtag(addr) int addr; { asm(" lda	[%o0] 0xe, %o0 "); }
asmsetdtag(addr,data) int addr,data; { asm(" sta	%o1, [%o0] 0xe "); }

asmgetddata(addr) int *addr; { asm(" lda	[%o0] 0xf, %o0 "); }
asmsetddata(addr,data) int *addr,data; { asm(" sta	%o1, [%o0] 0xf "); }

setudata(addr,data) int *addr,data; { asm(" sta	%o1, [%o0] 0x0 "); }
getudata(addr) int addr; { asm(" lda	[%o0] 0x0, %o0 "); }
xgetpsr() { asm(" mov	%psr, %o0 "); }
setpsr(psr) int psr; { asm(" mov  %o0, %psr; nop; nop; nop "); }

flushi(addr,data) int *addr,data; { asm(" sta	%g0, [%g0] 0x5 "); }
flushd(addr,data) int *addr,data; { asm(" sta	%g0, [%g0] 0x6 "); }

extern line0();
extern line1();
extern line2();
extern line3();

asm(
"    .text           \n"
"    .align 4        \n"
"getdw:              \n"
"    retl            \n"
"    ldd [%o0], %o0  \n"
);





#define ITAGMASK ((1<<ILINESZ)-1)
#define DTAGMASK (~((1<<DLINESZ)-1))
#define DIAGADDRMASK ((1<<DTAGLOW)-1)

static maintest();

cachetest()
{
    int tmp;

    tmp = maintest();
    wsysreg(0, 0x81000f);
    return(tmp);
}

long long int getdw();

    
static maintest()
{

	volatile double mrl[8192 + 8]; /* enough for 64 K caches */
	volatile int mrx[16];
	volatile double *ll = (double *) mrx;
	volatile int *mr = (int *) mrl;
	volatile unsigned char *mrc = (char *) mrl;
	volatile unsigned short *mrh = (short *) mrl;
	volatile long long int dw;
	int vbits, vpos, addrmsk;
	int i, j, tmp, cachectrl; 
	int ITAGS, DTAGS;
	int ILINESZ, DLINESZ;
	int ITAG_BITS, ILINEBITS, DTAG_BITS, DLINEBITS;
	int IVALMSK, tag, data;
	int ISETS;
 	int (*line[4])() = {line0, line1, line2, line3}; 

	report_subtest(CACHE_TEST);

	cachectrl = rsysreg(0); wsysreg(0, cachectrl & ~0x0f); 
	do cachectrl = rsysreg(0); while(cachectrl & (CCTRL_IFP | CCTRL_DFP));
	flush();
	do cachectrl = rsysreg(0); while(cachectrl & (CCTRL_IFP | CCTRL_DFP));
	cachectrl = rsysreg(0); wsysreg(0, cachectrl | 0x81000f);

	icconf = rsysreg(8);
	dcconf = rsysreg(12);

	ILINEBITS = (icconf >> 16) & 7;
	DLINEBITS = ((dcconf >> 16) & 7);
	ITAG_BITS = ((icconf >> 20) & 15) + 8 - ILINEBITS;
	DTAG_BITS = ((dcconf >> 20) & 15) + 8 - DLINEBITS;
	isetsize = (1<<((icconf >> 20) & 15)) * 1024;
	dsetsize = (1<<((dcconf >> 20) & 15)) * 1024;
	isetbits = ((icconf >> 20) & 15) + 10;
	dsetbits = ((dcconf >> 20) & 15) + 10;
	ITAGS = (1 << ITAG_BITS);
	ILINESZ = (1 << ILINEBITS);
	DTAGS = (1 << DTAG_BITS);
 	DLINESZ = (1 << DLINEBITS); 
	IVALMSK = (1 << ILINESZ)-1;
	ITAGAMSK = 0x7fffffff - (1 << (ITAG_BITS + ILINEBITS +2)) + 1;
	DTAGAMSK = 0x7fffffff - (1 << (DTAG_BITS + DLINEBITS +2)) + 1;
	ISETS = ((icconf >> 24) & 3) + 1;
	DSETS = ((dcconf >> 24) & 3) + 1;

	ITAGLOW = 10 + ((icconf >> 20) & 15);
	DTAGLOW = 10 + ((dcconf >> 20) & 15); 

	/**** INSTRUCTION CACHE TESTS ****/

	for (i=0;i<ISETS;i++) {
	  line[i]();
	}	
	
	cachectrl = rsysreg(0); wsysreg(0, cachectrl & ~0x03); /* disable icache */
	/* check tags */
	tmp = 0;
	for (i=0;i<ISETS;i++) { 
 	  for (j=0;j<ISETS;j++) { 
	    tag = getitag((int) line[i], j);
	    if ( ((tag & IVALMSK) == IVALMSK) && ((tag & ITAGAMSK) == (((int) line[i]) & ITAGAMSK)) )
	      tmp++;
	  }
	}
	cachectrl = rsysreg(0); wsysreg(0, cachectrl | 3); /* enable icache */
	if (tmp == 0) fail(1);

      if (((cachectrl >> ITE_BIT) & 3) == 0) {
	/* iparity checks */
	if ((cachectrl >> CPP_CONF_BIT) & CPP_CONF_MASK) {
	  cachectrl = rsysreg(0); wsysreg(0, cachectrl & ~0x3fc0);
	  line2();
	  wsysreg(0, cachectrl | CPTB_MASK);
	  for (i=0;i<ISETS;i++) { 
	    setidata((int) line2, i, 0);
	  }
	  line2();
	  cachectrl = rsysreg(0);
	  if (((cachectrl >> IDE_BIT) & 3) != 1) fail(2);
	  
	  setitag((int) line2, 0, 0);
	  cachectrl = rsysreg(0); wsysreg(0, cachectrl & ~CPTB_MASK);
	  //setidata((int) line2, 0, 0);
	  line2();
	  cachectrl = rsysreg(0);
	  if (((cachectrl >> ITE_BIT) & 3) != 1) fail(3);
	}
	

	/**** DATA CACHE TESTS ****/

	flush();
	do cachectrl = rsysreg(0); while(cachectrl & (CCTRL_IFP | CCTRL_DFP));

	for (i=0;i<DSETS;i++) {
	  setdtag((int) mr, i, 0); 	/* clear tags */
	}
	for (i=0;i<31;i++) mr[i] = 0;
	mr[0] = 5; mr[1] = 1; mr[2] = 2; mr[3] = 3;
	
	/* check that write does not allocate line */
	if (chkdtag((int) mr) == 0) fail(5);

	if (mr[0] != 5) fail(6);

	/* check that line was allocated */
   	if (chkdtag((int) mr) != 0) fail(7);  

	/* check that data is in cache */
	for (i=0;i<DSETS;i++) { 
		setddata((int)mr,i,0); setddata((int) &mr[1], i, 0);
	}
	getudata((int) &mr[0]); getudata((int) &mr[8]); 
	getudata((int) &mr[16]); getudata((int) &mr[24]); 
	tmp = 0;
	for (i=0;i<DSETS;i++) { if (getddata((int) mr, i) == 5) tmp++; }
	if (tmp == 0) fail(8);

	*ll = mrl[0];
	if ((mrx[0] != 5) || (mrx[1] != 1)) fail(9);
	tmp = 0;
	for (i=0;i<DSETS;i++) {
	  if (getddata((int) &mr[1], i) == 1) tmp++;
	}
	if (tmp != 1) fail(10);
	
	/* dcache parity */ 							 
	if ((cachectrl >> CPP_CONF_BIT) & CPP_CONF_MASK) {
	  cachectrl = rsysreg(0); wsysreg(0, cachectrl & ~CE_CLEAR);
	  setddata(&mrx[0],0,0);
	  cachectrl = rsysreg(0); wsysreg(0, cachectrl | CPTB_MASK);
	  for (i=0;i<DSETS;i++) setddata((int *)mrx,i,5);
	  *((char *) mrx) = 1;
	  if (mrx[0] != 0x01000005) fail(11);
	  cachectrl = rsysreg(0);
	  if (((cachectrl >> DDE_BIT) & 3) != 1) fail(12);
	  cachectrl = rsysreg(0); wsysreg(0, cachectrl & ~CPTB_MASK);
	  setddata(&mrx[0],0,0);
	  cachectrl = rsysreg(0); wsysreg(0, cachectrl | CPTB_MASK);
	  do cachectrl = rsysreg(0); while (!(cachectrl & CPTB_MASK));
	  for (i=0;i<DSETS;i++) {
	    setdtag((int *)mrx,i,(1 << DLINESZ)-1);
	  }
	  wsysreg(0, cachectrl & ~CPTB_MASK);
	  do cachectrl = rsysreg(0); while (cachectrl & CPTB_MASK);
	  if (mrx[0] != 0x01000005) fail(13);
//	  if (getddata(&mr[0],0) != 5) fail(14);
	  cachectrl = rsysreg(0); if (((cachectrl >> DTE_BIT) & 3) != 1) fail(15);
//	  if ((getdtag(mrx,1) & DTAGMASK) != (1 <<((((int) mrx)>>2)&(DLINESZ-1)))) fail(16);
	  *((volatile long long int *) &dw) = 0x0000001100000055LL;
	  cachectrl = rsysreg(0); wsysreg(0, (cachectrl | CPTB_MASK) & ~DDE_MASK);
	  getdw(&dw);
	  for (i=0;i<DSETS;i++) {
	    setddata(((int)&dw)+4,i,0x00000055);
	  }
	  if (getdw(&dw) != 0x0000001100000055LL) fail(16);
	  cachectrl = rsysreg(0); if (((cachectrl >> DDE_BIT) & 3) != 1) fail(16);	  
	  wsysreg(0, cachectrl & (~CE_CLEAR & ~CPTB_MASK));
	}

	/* check that tag is properly replaced */
	mr[0] = 5; mr[1] = 1; mr[2] = 2; mr[3] = 3;
	mr[DTAGS*DLINESZ] = 0xbbbbbbbb;

	/* check that tag is not evicted on write miss */
	if (chkdtag((int) mr) != 0) fail(17);

	/* check that write update memory ok */	
	if (mr[DTAGS*DLINESZ] != 0xbbbbbbbb) fail(18);


	/* check that valid bits have been reset */
/* 	if ((getdtag(mr) & DTAGMASK) != (1 <<((((int) mr)>>2)&(DLINESZ-1))))  */
/* 		fail(19); */
/* 	tmp = 0; */
/* 	if ((getdtag((int) mr & DIAGADDRMASK + i*dsetsize) & DTAGMASK) != (1 <<((((int) mr)>>2)&(DLINESZ-1)))) */
/* 	  tmp = 1; */
/* 	if (tmp == 1)  fail(19); */
	  

      }
	/* check partial word access */

	mr[8] = 0x01234567;
	mr[9] = 0x89abcdef;
	if (mrc[32] != 0x01) fail(26);
	if (mrc[33] != 0x23) fail(27);
	if (mrc[34] != 0x45) fail(28);
	if (mrc[35] != 0x67) fail(29);
	if (mrc[36] != 0x89) fail(30);
	if (mrc[37] != 0xab) fail(31);
	if (mrc[38] != 0xcd) fail(32);
	if (mrc[39] != 0xef) fail(33);
	if (mrh[16] != 0x0123) fail(34);
	if (mrh[17] != 0x4567) fail(35);
	if (mrh[18] != 0x89ab) fail(36);
	if (mrh[19] != 0xcdef) fail(37);
	mrc[32] = 0x30; if (mr[8] != 0x30234567) fail(39);
	mrc[33] = 0x31; if (mr[8] != 0x30314567) fail(40);
	mrc[34] = 0x32; if (mr[8] != 0x30313267) fail(41);
	mrc[35] = 0x33; if (mr[8] != 0x30313233) fail(42);
	mrc[36] = 0x34; if (mr[9] != 0x34abcdef) fail(43);
	mrc[37] = 0x35; if (mr[9] != 0x3435cdef) fail(44);
	mrc[38] = 0x36; if (mr[9] != 0x343536ef) fail(45);
	mrc[39] = 0x37; if (mr[9] != 0x34353637) fail(46);
	mrh[16] = 0x4041; if (mr[8] != 0x40413233) fail(47);
	mrh[17] = 0x4243; if (mr[8] != 0x40414243) fail(48);
	mrh[18] = 0x4445; if (mr[9] != 0x44453637) fail(49);
	mrh[19] = 0x4647; if (mr[9] != 0x44454647) fail(50);

	/*
	if (((lr->leonconf >> 2) & 3) == 3) { dma((int)&mr[0], 9, 1); }
	if (((lr->leonconf >> 2) & 3) == 3) { dma((int)&mr[0], 9, 1); }
	*/

	/* write data to the memory */
	flush();
	for (i=0;i<DSETS;i++) { 
	  for (j=0;j<DLINESZ;j++) {
	    mr[j+(i<<dsetbits)] = ((i<<16) | j); 
	  } 
	} 
	
	/* check that write miss does not allocate line */
	do cachectrl = rsysreg(0); while(cachectrl & (CCTRL_DFP));
	for (i=0;i<DSETS;i++) {
	  if ((getdtag((int) mr, i) & DTAGAMSK) == ((int) mr & DTAGAMSK))
	    fail(51);
	}

	/* check flush operation */
	/* check that flush clears valid bits */
	/*
	cachectrl = rsysreg(0); wsysreg(0, cachectrl & ~0x0f); 
	flushi();
	do cachectrl = rsysreg(0); while(cachectrl & (CCTRL_IFP));
	
	if (chkitags(ITAG_MAX_ADDRESS,(1<<(ILINEBITS + 2)),0,0) & ((1<<ILINESZ)-1))
		fail(51);

	for (i

	lr->cachectrl |= 0x03; 
	flushd();
	while(lr->cachectrl & CCTRL_DFP) {}

	if (chkdtags(DTAG_MAX_ADDRESS,(1<<(DLINEBITS + 2)),0,0) & ((1<<DLINESZ)-1)) 
		fail(52);
	*/
	
	/* flush();
	setdtag(0,0,0x11111111);
	setdtag(0,1,0x22222222);
	setdtag(0,2,0x33333333);
	setdtag(0,3,0x44444444);*/
	
	cachectrl = rsysreg(0); wsysreg(0, cachectrl | 0xf); 
	
	return(0);

/* to be tested: diag access during flush, diag byte/halfword access,
   write error, cache freeze operation */

}


