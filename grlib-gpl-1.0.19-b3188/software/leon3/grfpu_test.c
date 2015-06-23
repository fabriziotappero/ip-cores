/**********************************************************************/
/*  This file is a part of the GRFPU IP core testbench                */
/*  Copyright (C) 2004-2008  Gaisler Research AB                      */
/*  ALL RIGHTS RESERVED                                               */
/*                                                                    */
/**********************************************************************/


#include "testmod.h" 

#define FTT_CEXC 0x1c01f
#define FTT 0x1c000
#define IEEE754EXC (1 << 14)
#define UNFINEXC   (1 << 15)
#define NX 1
#define DZ 2
#define UF 4
#define OF 8
#define NV 16
#define EQ 0
#define LT 1
#define GT 2
#define UN 3

typedef unsigned long long uint64;

extern void grfpu_fdivd(uint64 *a, uint64 *b, uint64 *c);
extern void grfpu_ttrap();
extern void divident(uint64 *a);
extern void divromtst(uint64 *a, uint64 *b);
extern volatile unsigned int fsr1, fq1, tfsr, grfpufq;
extern unsigned int grfpu_fitos(int a);
extern uint64 grfpu_fitod(int a);
extern unsigned int grfpu_fdtoi(uint64 a);
extern unsigned int grfpu_fstoi(unsigned int a);
extern unsigned int grfpu_fdtos(uint64 a);
extern uint64 grfpu_fstod(unsigned int a);
extern int grfpu_fcmpd(uint64 a, uint64 b);
extern int grfpu_fcmped(uint64 a, uint64 b);
extern uint64 grfpu_fsubd(uint64 a, uint64 b);
extern void grfpc_dpdep_tst(uint64 *a);
extern void grfpc_spdep_tst(unsigned int *a);
extern void grfpc_spdpdep_tst(uint64 *a);
extern void initfpreg();
extern int grfpc_edac_test();
	
struct dp3_type {
  uint64 op1;
  uint64 op2;
  uint64 res;
};


struct sp3_type {
  float op1;
  float op2;
  float res;
};

uint64 denorm = 0x0000000000010000LL;
/*
uint64 zero = 0x0;
uint64 pzero = 0x0;
*/
uint64 nzero = 0x8000000000000000LL;
uint64 inf =  0xfff0000000000000LL;
uint64 ninf = 0xfff0000000000000LL;
uint64 pinf = 0x7ff0000000000000LL;
uint64 qnan = 0x7ff8000000000000LL;
unsigned int qnan_sp = 0x7fc00000;
uint64 snan = 0x7ff4000000000000LL;
uint64 qsnan = 0x7fffe00000000000LL;
unsigned long int qsnan_sp = 0x7fff0000;

unsigned int divisor[256];
unsigned int divres[512];
unsigned int sqrtres[256];
struct dp3_type faddd_tv[16];
struct dp3_type fmuld_tv[11];
unsigned int fsr;

uint64 z;
unsigned int fl;

double dbl;

uint64 dpres = 0xbff8000000000000LL;
uint64 spdpres = 0x3fefdff00ffc484aLL; 

extern unsigned int fptrap;


int grfpu_test()
{
  int i;
  uint64 x, y;

  uint64 a, b, c;
  uint64 zero, pzero;

  unsigned int *unfaddr, unfinst, tmp;
  unsigned int *t_add;

  if (((get_asr17() >> 10) & 003) != 1) return(0);  // check if GRFPU is present

  report_subtest(GRFPU_TEST);  

  x = 0x3100a4068f346c9bLL;
  y = 0; zero = 0; pzero = 0;

  /* install FP trap handler */
  t_add = (unsigned int *) ((get_tbr() & ~0x0fff) | 0x80);
  *t_add = 0xA010000F;	/* or %o7,%g0,%l0 */
  t_add++;
  *t_add = (0x40000000 | (((unsigned int) (&fptrap-t_add)) ));	/* call fptrap */
  t_add++;
  *t_add = 0x9E100010;	/* or %l0,%g0,%o7 */  


  initfpreg();

  /* FITOS, FITOD */
  set_fsr(0x0f800000); tfsr = 0;
  if ((grfpu_fitod(0) != 0x0) || (tfsr != 0))  fail(11);
  if ((grfpu_fitod(-6) != 0xc018000000000000LL) || (tfsr != 0)) fail(11);
  if ((grfpu_fitod(20) != 0x4034000000000000LL) || (tfsr != 0)) fail(11);
  if ((grfpu_fitod(98) != 0x4058800000000000LL) || (tfsr != 0)) fail(11);
  if ((grfpu_fitos(5) != 0x40a00000) || (tfsr != 0)) fail(11);
  
  /* FSTOI, FDTOI */
  set_fsr(0x0f000000);
  if ((grfpu_fdtoi(0x7000000000000000LL) != 0x7fffffff) || ((tfsr & FTT_CEXC) != (IEEE754EXC | NV))) fail(12);
  if ((grfpu_fdtoi(0xf000000000000000LL) != 0x80000000) || ((tfsr & FTT_CEXC) != (IEEE754EXC | NV))) fail(12);
  tfsr = 0;
  if ((grfpu_fdtoi(0x0000000000000000LL) != 0) || (tfsr != 0)) fail(12);
  if ((grfpu_fdtoi(0x05100302a1000001LL) != 0) || (tfsr != 0)) fail(12);
  if ((grfpu_fstoi(0x47ffffff) != 0x0001ffff) || (tfsr != 0)) fail(12);
  if ((grfpu_fdtoi(qnan) != 0x7fffffff) || ((tfsr & FTT_CEXC) != (IEEE754EXC | NV))) fail(12);
  tfsr = 0;
  if ((grfpu_fdtoi(ninf) != 0x80000000) || ((tfsr & FTT_CEXC) != (IEEE754EXC | NV))) fail(12);
  tfsr = 0;
  if ((grfpu_fdtoi(snan) != 0x7fffffff) || ((tfsr & FTT_CEXC) != (IEEE754EXC | NV))) fail(12);
  tfsr = 0;
  grfpu_fdtoi(denorm); if (((tfsr >> 14) & 3) != 2) fail(12);  
  
  /* FSTOD, FDTOS */
  set_fsr(0x0f000000); tfsr = 0;
  if ((grfpu_fstod(0x45601234) != 0x40ac024680000000LL) || (tfsr != 0)) fail(13);
  if ((grfpu_fstod(0xf00abcd1) != 0xc601579a20000000LL) || (tfsr != 0)) fail(13);
  if ((grfpu_fdtos(0x47f0000000000000LL) != 0x7f800000) || ((tfsr & FTT_CEXC) != (IEEE754EXC | OF))) fail(13);
  tfsr = 0;
  if ((grfpu_fdtos(0x81f0043000040000LL) != 0x80000000) || ((tfsr & FTT_CEXC) != (IEEE754EXC | UF))) fail(13);
  tfsr = 0;
  if ((grfpu_fdtos(0x0) != 0) || (tfsr != 0)) fail(13);
  if ((grfpu_fdtos(qnan) != qnan_sp) || (tfsr != 0)) fail(13);
  if ((grfpu_fdtos(pinf) != 0x7f800000) || (tfsr != 0)) fail(13);
  if ((grfpu_fdtos(snan) != qsnan_sp) || ((tfsr & FTT_CEXC) != (IEEE754EXC | NV))) fail(13);  
  tfsr = 0;
  grfpu_fdtos(denorm); if (((tfsr >> 14) & 3) != 2) fail(13);    
  
  /* FMOVS, FABSS, FNEGS */
  set_fsr(0x0f800000); tfsr = 0;
  if ((grfpu_fmovs(0x231abcde) != 0x231abcde) || (tfsr != 0)) fail(14);
  if ((grfpu_fabss(0x231abcde) != 0x231abcde) || (tfsr != 0)) fail(14);
  if ((grfpu_fabss(0xa31abcde) != 0x231abcde) || (tfsr != 0)) fail(14);
  if ((grfpu_fnegs(0x231abcde) != 0xa31abcde) || (tfsr != 0)) fail(14);
  if ((grfpu_fnegs(0xa31abcde) != 0x231abcde) || (tfsr != 0)) fail(14);

  /* FCMPxx */
  set_fsr(0x0f800000);
  if ((grfpu_fcmpd(0x546f010343208541LL, 0xd46f010343208541LL) != GT) || (tfsr != 0)) fail(15);
  if ((grfpu_fcmpd(0xd46f010343208541LL, 0x546f010343208541LL) != LT) || (tfsr != 0)) fail(15);
  if ((grfpu_fcmpd(0x0, 0x8000000000000000LL) != EQ) || (tfsr != 0)) fail(15);
  if ((grfpu_fcmpd(pinf, ninf) != GT) || (tfsr != 0)) fail(15);
  if ((grfpu_fcmpd(0x546f010343208541LL, 0x546fa10343208541LL) != LT) || (tfsr != 0)) fail(15);
  if ((grfpu_fcmpd(0x546fa10343208541LL, 0x546f010343208541LL) != GT) || (tfsr != 0)) fail(15);
  if ((grfpu_fcmpd(0x546fa10343208541LL, qnan) != UN) || (tfsr != 0)) fail(15);
  if ((grfpu_fcmpd(0x546fa10343208541LL, snan) != UN) || ((tfsr & FTT_CEXC) != (IEEE754EXC | NV))) fail(15);
  tfsr = 0;
  if ((grfpu_fcmpd(0x546fa10343208541LL, denorm) != GT) || (tfsr != 0)) fail(15);   
  if ((grfpu_fcmpd(denorm, 0x546fa10343208541LL) != LT) || (tfsr != 0)) fail(15);    
  if ((grfpu_fcmpd(qnan, 0x546fa10343208541LL) != UN) || (tfsr != 0)) fail(15);  
  if ((grfpu_fcmpd(snan, 0x546fa10343208541LL) != UN) || ((tfsr & FTT_CEXC) != (IEEE754EXC | NV))) fail(15);

  tfsr = 0;
  if ((grfpu_fcmped(0x546f010343208541LL, 0xd46f010343208541LL) != GT) || (tfsr != 0)) fail(15);
  if ((grfpu_fcmped(0xd46f010343208541LL, 0x546f010343208541LL) != LT) || (tfsr != 0)) fail(15);
  if ((grfpu_fcmped(0x0, 0x8000000000000000LL) != EQ) || (tfsr != 0)) fail(15);
  if ((grfpu_fcmped(pinf, ninf) != GT) || (tfsr != 0)) fail(15);
  if ((grfpu_fcmped(0x546f010343208541LL, 0x546fa10343208541LL) != LT) || (tfsr != 0)) fail(15);
  if ((grfpu_fcmped(0x546fa10343208541LL, 0x546f010343208541LL) != GT) || (tfsr != 0)) fail(15);
  if ((grfpu_fcmped(0x546fa10343208541LL, qnan) != UN) || ((tfsr & FTT_CEXC) != (IEEE754EXC | NV))) fail(15);
  if ((grfpu_fcmped(0x546fa10343208541LL, snan) != UN) || ((tfsr & FTT_CEXC) != (IEEE754EXC | NV))) fail(15);
  tfsr = 0;
  if ((grfpu_fcmped(0x546fa10343208541LL, denorm) != GT) || (tfsr != 0)) fail(15);    
  if ((grfpu_fcmped(denorm, 0x546fa10343208541LL) != LT) || (tfsr != 0)) fail(15);   
  if ((grfpu_fcmped(qnan, 0x546fa10343208541LL) != UN) || ((tfsr & FTT_CEXC) != (IEEE754EXC | NV))) fail(15);
  if ((grfpu_fcmped(snan, 0x546fa10343208541LL) != UN) || ((tfsr & FTT_CEXC) != (IEEE754EXC | NV))) fail(15);
  tfsr = 0;
  if ((grfpu_fcmps(0x0123abcd, 0x12345678) != LT) || (tfsr != 0)) fail(15);
  if ((grfpu_fcmpes(0x0123abcd, 0x12345678) != LT) || (tfsr != 0)) fail(15);



  /* FADDx, FSUBx check */
  tfsr = 0;
  set_fsr(0x0f000000);  
  grfpu_faddd(&x, &zero, &z); if ((x != z) || (tfsr != 0)) fail(16);
  grfpu_faddd(&x, &inf, &z);  if ((z != inf) || (tfsr != 0)) fail(16);
  grfpu_faddd(&x, &qnan, &z); if ((z != qnan) || (tfsr != 0)) fail(16);
  grfpu_faddd(&x, &snan, &z); if ((tfsr & FTT_CEXC) != (IEEE754EXC | NV)) fail(16);
  tfsr = 0;  set_fsr(0x0);
  grfpu_faddd(&x, &snan, &z); if (z != qsnan) fail(16); 
  set_fsr(0x0f000000);
  grfpu_faddd(&x, &denorm, &z); if (((tfsr >> 14) & 3) != 2) fail(16);
  tfsr = 0;
  grfpu_faddd(&zero, &x, &z); if ((z != x) || (tfsr != 0)) fail(16);
  grfpu_faddd(&zero, &inf, &z); if ((z != inf) || (tfsr != 0)) fail(16);
  grfpu_faddd(&zero, &qnan, &z); if ((z != qnan) || (tfsr != 0)) fail(16);
  grfpu_faddd(&zero, &snan, &z); if ((tfsr & FTT_CEXC) != (IEEE754EXC | NV)) fail(16);
  set_fsr(0x0);
  grfpu_faddd(&zero, &snan, &z); if (z != qsnan) fail(16);
  set_fsr(0x0f000000);
  grfpu_faddd(&zero, &denorm, &z); if (((tfsr >> 14) & 3) != 2) fail(16);
  tfsr = 0;
  grfpu_faddd(&inf, &x, &z); if ((z != inf) || (tfsr != 0)) fail(16);
  grfpu_faddd(&inf, &zero, &z); if ((z != inf) || (tfsr != 0)) fail(16);  
  grfpu_faddd(&pinf, &pinf, &z); if ((z != pinf) || (tfsr != 0)) fail(16);    
  grfpu_faddd(&ninf, &ninf, &z); if ((z != ninf) || (tfsr != 0)) fail(16);    
  grfpu_faddd(&ninf, &pinf, &z); if ((tfsr & FTT_CEXC) != (IEEE754EXC | NV)) fail(16);
  set_fsr(0x0);
  grfpu_faddd(&ninf, &pinf, &z); if (z != qsnan) fail(16);
  set_fsr(0x0f000000); tfsr = 0;
  grfpu_faddd(&pinf, &ninf, &z); if ((z != qsnan) || ((tfsr & FTT_CEXC) != (IEEE754EXC | NV))) fail(16);  
  grfpu_faddd(&inf, &denorm, &z); if (((tfsr >> 14) & 3) != 2) fail(16);  
  tfsr = 0;
  grfpu_faddd(&qnan, &x, &z); if ((z != qnan) || (tfsr != 0)) fail(16);
  grfpu_faddd(&qnan, &zero, &z); if ((z != qnan) || (tfsr != 0)) fail(16);
  grfpu_faddd(&qnan, &inf, &z); if ((z != qnan) || (tfsr != 0)) fail(16);
  grfpu_faddd(&qnan, &qnan, &z); if ((z != qnan) || (tfsr != 0)) fail(16);
  grfpu_faddd(&qnan, &snan, &z); if ((tfsr & FTT_CEXC) != (IEEE754EXC | NV)) fail(16);  
  tfsr = 0;
  grfpu_faddd(&snan, &x, &z); if ((tfsr & FTT_CEXC) != (IEEE754EXC | NV)) fail(16);  
  tfsr = 0;
  grfpu_faddd(&snan, &zero, &z); if ((tfsr & FTT_CEXC) != (IEEE754EXC | NV)) fail(16);  
  tfsr = 0;
  grfpu_faddd(&snan, &inf, &z); if ((tfsr & FTT_CEXC) != (IEEE754EXC | NV)) fail(16);  
  tfsr = 0;
  grfpu_faddd(&snan, &qnan, &z); if ((tfsr & FTT_CEXC) != (IEEE754EXC | NV)) fail(16);  
  tfsr = 0;
  grfpu_faddd(&snan, &snan, &z); if ((tfsr & FTT_CEXC) != (IEEE754EXC | NV)) fail(16);  
  tfsr = 0;  
  grfpu_faddd(&snan, &denorm, &z); if (((tfsr >> 14) & 3) != 2) fail(16);

  set_fsr(0x0f000000); tfsr = 0;
  for (i = 0; i < 13; i++)
  {
    grfpu_faddd(&faddd_tv[i].op1, &faddd_tv[i].op2, &z);
    if (z != *((uint64 *) &faddd_tv[i].res))  fail(16); 
  }
  if (tfsr != 0) fail(16);
  grfpu_faddd(&faddd_tv[13].op1, &faddd_tv[13].op2, &z); 
  if ((z != faddd_tv[13].res) || ((tfsr & FTT_CEXC) != (IEEE754EXC | OF))) fail(16);
  grfpu_faddd(&faddd_tv[14].op1, &faddd_tv[14].op2, &z); 
  if ((z != faddd_tv[14].res) || ((tfsr & FTT_CEXC) != (IEEE754EXC | UF))) fail(16);  
  grfpu_faddd(&faddd_tv[15].op1, &faddd_tv[15].op2, &z); 
  if ((z != faddd_tv[15].res) || ((tfsr & FTT_CEXC) != (IEEE754EXC | UF))) fail(16);  
  tfsr = 0;
  if ((grfpu_fsubd(0x4000000000000000LL, 0x3ff0000000000000LL) != 0x3ff0000000000000LL) || (tfsr != 0)) fail(16);
  if ((grfpu_fsubd(0x4000000000000000LL, 0xbff0000000000000LL) != 0x4008000000000000LL) || (tfsr != 0)) fail(16);
  if ((grfpu_fsubd(0xc000000000000000LL, 0x3ff0000000000000LL) != 0xc008000000000000LL) || (tfsr != 0)) fail(16);
  if ((grfpu_fsubd(0xc000000000000000LL, 0xbff0000000000000LL) != 0xbff0000000000000LL) || (tfsr != 0)) fail(16);

  if ((grfpu_fadds(0x40000000, 0x3f800000) != 0x40400000) || (tfsr != 0)) fail(16);
  if ((grfpu_fsubs(0x40000000, 0x3f800000) != 0x3f800000) || (tfsr != 0)) fail(16);
  

  /* FDIVD check */
  tfsr = 0;
  grfpu_fdivd(&x, &nzero, &z); if ((z != ninf) || ((tfsr & FTT_CEXC) != (IEEE754EXC | DZ))) fail(17);
  tfsr = 0;
  grfpu_fdivd(&x, &pinf, &z); if ((z != pzero) || (tfsr != 0)) fail(17);
  grfpu_fdivd(&x, &qnan, &z); if ((z != qnan) || (tfsr != 0)) fail(17);
  grfpu_fdivd(&x, &snan, &z); if ((z != qsnan) || ((tfsr & FTT_CEXC) != (IEEE754EXC | NV))) fail(17);
  grfpu_fdivd(&x, &denorm, &z); if ((tfsr & FTT) != UNFINEXC) fail(17);
  tfsr = 0;
  grfpu_fdivd(&zero, &x, &z); if ((z != zero) || (tfsr != 0)) fail(17);
  grfpu_fdivd(&nzero, &pzero, &z); if ((z != qsnan) || ((tfsr & FTT_CEXC) != (IEEE754EXC | NV))) fail(17);
  tfsr = 0;
  grfpu_fdivd(&nzero, &pinf, &z); if ((z != nzero) || (tfsr != 0)) fail(17);  
  grfpu_fdivd(&zero, &qnan, &z); if ((z != qnan) || (tfsr != 0)) fail (7);
  grfpu_fdivd(&zero, &snan, &z); if ((tfsr & FTT_CEXC) != (IEEE754EXC | NV)) fail(17);
  tfsr = 0;
  grfpu_fdivd(&zero, &denorm, &z); if ((tfsr & FTT) != UNFINEXC) fail(17);
  tfsr = 0;
  grfpu_fdivd(&ninf, &x, &z); if ((z != ninf) || (tfsr != 0)) fail(17);
  grfpu_fdivd(&ninf, &nzero, &z); if ((z != pinf) || (tfsr != 0)) fail(17);
  grfpu_fdivd(&inf, &inf, &z); if ((z != qsnan) || ((tfsr & FTT_CEXC) != (IEEE754EXC | NV))) fail(17);
  tfsr = 0;
  grfpu_fdivd(&inf, &qnan, &z); if ((z != qnan) || (tfsr != 0)) fail(17);
  grfpu_fdivd(&inf, &snan, &z); if ((z != qsnan) || ((tfsr & FTT_CEXC) != (IEEE754EXC | NV))) fail(17);
  tfsr = 0;
  grfpu_fdivd(&inf, &denorm, &z); if ((tfsr & FTT) != UNFINEXC) fail(17);
  tfsr = 0;
  grfpu_fdivd(&qnan, &x, &z); if ((z != qnan) || (tfsr != 0)) fail(17);
  grfpu_fdivd(&qnan, &zero, &z); if ((z != qnan) || (tfsr != 0)) fail(17);  
  grfpu_fdivd(&qnan, &inf, &z); if ((z != qnan) || (tfsr != 0)) fail(17);  
  grfpu_fdivd(&qnan, &qnan, &z); if ((z != qnan) || (tfsr != 0)) fail(17);  
  grfpu_fdivd(&qnan, &snan, &z); if ((z != qsnan) || ((tfsr & FTT_CEXC) != (IEEE754EXC | NV))) fail(17);    
  grfpu_fdivd(&qnan, &denorm, &z); if ((tfsr & FTT) != UNFINEXC) fail(17);
  grfpu_fdivd(&snan, &x, &z); if ((tfsr & FTT_CEXC) != (IEEE754EXC | NV)) fail(17);  
  tfsr = 0;
  grfpu_fdivd(&snan, &zero, &z); if ((tfsr & FTT_CEXC) != (IEEE754EXC | NV)) fail(17);  
  tfsr = 0;
  grfpu_fdivd(&snan, &inf, &z); if ((tfsr & FTT_CEXC) != (IEEE754EXC | NV)) fail(17);  
  tfsr = 0;
  grfpu_fdivd(&snan, &qnan, &z); if ((tfsr & FTT_CEXC) != (IEEE754EXC | NV)) fail(17);  
  tfsr = 0;
  grfpu_fdivd(&snan, &snan, &z); if ((tfsr & FTT_CEXC) != (IEEE754EXC | NV)) fail(17);  
  tfsr = 0;  
  grfpu_fdivd(&snan, &denorm, &z); if ((tfsr & FTT) != UNFINEXC) fail(17);
  
  tfsr = 0; a = 0x7f000102030000b0LL; b = 0x80fa0fff008723a1LL;  /* OF */
  grfpu_fdivd(&a, &b, &c); if ((c != 0xfff0000000000000LL) || ((tfsr & FTT_CEXC) != (IEEE754EXC | OF))) fail(17);    
  tfsr = 0; a = 0x01000102030000b0LL; b = 0x421a0fff008723a1LL;  /* UF */
  grfpu_fdivd(&a, &b, &c); if ((c != 0x0) || ((tfsr & FTT_CEXC) != (IEEE754EXC | UF))) fail(17);  
  tfsr = 0; a = 0x001abc0000000010LL; b = 0x3ff000400a07610cLL; /* emin */
  grfpu_fdivd(&a, &b, &c); if ((c != 0x001abb9500ea6b0fLL) || (tfsr != 0)) fail(17);  
  tfsr = 0; a = 0x001abc0000000010LL; b = 0x3fffff400a07610cLL; /* emin - 1 */
  grfpu_fdivd(&a, &b, &c); if ((c != 0x0) || ((tfsr & FTT_CEXC) != (IEEE754EXC | UF))) fail(17);    


  /* FDIVS */
  tfsr = 0;
  if ((grfpu_fdivs(0x42200000, 0x40040000) != 0x419b26ca) || (tfsr != 0)) fail(17);
  if ((grfpu_fdivs(0x46effbff, 0x31c10000) != 0x549f291e) || (tfsr != 0)) fail(17);  
  if ((grfpu_fdivs(0x7981f800, 0x431ffffc) != 0x75cff338) || (tfsr != 0)) fail(17);     
  if ((grfpu_fdivs(0x00800000, 0x3f800001) != 0x0) || ((tfsr & FTT_CEXC) != (IEEE754EXC | UF))) fail(17);


  /* FMULD */
  tfsr = 0;
  grfpu_fmuld(&x, &nzero, &z); if ((z != nzero) || (tfsr != 0)) fail(18);
  grfpu_fmuld(&x, &pinf, &z); if ((z != pinf) || (tfsr != 0)) fail(18);
  grfpu_fmuld(&x, &qnan, &z); if ((z != qnan) || (tfsr != 0)) fail(18);
  grfpu_fmuld(&x, &snan, &z); if ((z != qsnan) || ((tfsr & FTT_CEXC) != (IEEE754EXC | NV))) fail(18);
  grfpu_fmuld(&x, &denorm, &z); if ((tfsr & FTT) != UNFINEXC) fail(18);
  tfsr = 0;
  grfpu_fmuld(&zero, &x, &z); if ((z != zero) || (tfsr != 0)) fail(18);
  grfpu_fmuld(&nzero, &ninf, &z); if ((z != qsnan) || ((tfsr & FTT_CEXC) != (IEEE754EXC | NV))) fail(18);
  tfsr = 0;
  grfpu_fmuld(&zero, &qnan, &z); if ((z != qnan) || (tfsr != 0)) fail(1177);
  grfpu_fmuld(&zero, &snan, &z); if ((z != qsnan) || ((tfsr & FTT_CEXC) != (IEEE754EXC | NV))) fail(18);
  grfpu_fmuld(&zero, &denorm, &z); if ((tfsr & FTT) != UNFINEXC) fail(18);
  tfsr = 0;
  grfpu_fmuld(&inf, &x, &z); if ((z != inf) || (tfsr != 0)) fail(18);
  grfpu_fmuld(&inf, &zero, &z); if ((z != qsnan) || ((tfsr & FTT_CEXC) != (IEEE754EXC | NV))) fail(18);
  tfsr = 0;
  grfpu_fmuld(&inf, &qnan, &z); if ((z != qnan) || (tfsr != 0)) fail(18);
  grfpu_fmuld(&inf, &snan, &z); if ((z != qsnan) || ((tfsr & FTT_CEXC) != (IEEE754EXC | NV))) fail(18);
  grfpu_fmuld(&inf, &denorm, &z); if ((tfsr & FTT) != UNFINEXC) fail(18);
  tfsr = 0;
  grfpu_fmuld(&qnan, &x, &z); if ((z != qnan) || (tfsr != 0)) fail(18);
  grfpu_fmuld(&qnan, &zero, &z); if ((z != qnan) || (tfsr != 0)) fail(18);
  grfpu_fmuld(&qnan, &inf, &z); if ((z != qnan) || (tfsr != 0)) fail(18);
  grfpu_fmuld(&qnan, &qnan, &z); if ((z != qnan) || (tfsr != 0)) fail(18);
  grfpu_fmuld(&qnan, &snan, &z); if ((tfsr & FTT_CEXC) != (IEEE754EXC | NV)) fail(18);  
  tfsr = 0;
  grfpu_fmuld(&snan, &x, &z); if ((tfsr & FTT_CEXC) != (IEEE754EXC | NV)) fail(18);  
  tfsr = 0;
  grfpu_fmuld(&snan, &zero, &z); if ((tfsr & FTT_CEXC) != (IEEE754EXC | NV)) fail(18);  
  tfsr = 0;
  grfpu_fmuld(&snan, &inf, &z); if ((tfsr & FTT_CEXC) != (IEEE754EXC | NV)) fail(18);  
  tfsr = 0;
  grfpu_fmuld(&snan, &qnan, &z); if ((tfsr & FTT_CEXC) != (IEEE754EXC | NV)) fail(18);  
  tfsr = 0;
  grfpu_fmuld(&snan, &snan, &z); if ((tfsr & FTT_CEXC) != (IEEE754EXC | NV)) fail(18);  
  tfsr = 0;  
  grfpu_fmuld(&snan, &denorm, &z); if (((tfsr >> 14) & 3) != 2) fail(18);


  set_fsr(0x0f000000); tfsr = 0;
  for (i = 0; i < 6; i++)
  {
    grfpu_fmuld(&fmuld_tv[i].op1, &fmuld_tv[i].op2, &z);
    if ((z != fmuld_tv[i].res) || (tfsr != 0)) fail(18); 
  }
  grfpu_fmuld(&fmuld_tv[6].op1, &fmuld_tv[6].op2, &z); if ((z != fmuld_tv[6].res) || ((tfsr & FTT_CEXC) != (IEEE754EXC | UF))) fail(18); tfsr = 0;
  grfpu_fmuld(&fmuld_tv[7].op1, &fmuld_tv[7].op2, &z); if ((z != fmuld_tv[7].res) || ((tfsr & FTT_CEXC) != (IEEE754EXC | OF))) fail(18); tfsr = 0; 
  grfpu_fmuld(&fmuld_tv[8].op1, &fmuld_tv[8].op2, &z); if ((z != fmuld_tv[8].res) || ((tfsr & FTT_CEXC) != (IEEE754EXC | OF))) fail(18); tfsr = 0;
  grfpu_fmuld(&fmuld_tv[9].op1, &fmuld_tv[9].op2, &z); if ((z != fmuld_tv[9].res) || ((tfsr & FTT_CEXC) != (IEEE754EXC | UF))) fail(18); tfsr = 0; 
  grfpu_fmuld(&fmuld_tv[10].op1, &fmuld_tv[10].op2, &z); if ((z != fmuld_tv[10].res) || ((tfsr & FTT_CEXC) != (IEEE754EXC | OF))) fail(18); tfsr = 0; 
  if ((grfpu_fmuls(0x40400000, 0x40000000) != 0x40c00000) || (tfsr != 0)) fail(18);
  


  /* FSQRTD */
  set_fsr(0x0f000000); tfsr = 0;
  grfpu_sqrtd(&pzero, &z); if ((z != pzero) || (tfsr != 0)) fail(19);
  grfpu_sqrtd(&nzero, &z); if ((z != nzero) || (tfsr != 0)) fail(19);
  grfpu_sqrtd(&pinf, &z); if ((z != pinf) || (tfsr != 0)) fail(19);
  grfpu_sqrtd(&ninf, &z); if ((z != qsnan) || ((tfsr & FTT_CEXC) != (IEEE754EXC | NV))) fail(19);
  tfsr = 0;
  grfpu_sqrtd(&snan, &z); if ((z != qsnan) || ((tfsr & FTT_CEXC) != (IEEE754EXC | NV))) fail(19);
  tfsr = 0;
  grfpu_sqrtd(&qnan, &z); if ((z != qnan) || (tfsr != 0)) fail(19);
  x = 0x4030000000000000LL; y = 0xc03de00030002001LL;
  grfpu_sqrtd(&x, &z); if ((z != 0x4010000000000000LL) || (tfsr != 0)) fail(19);
  grfpu_sqrtd(&y, &z); if ((z != qsnan) || ((tfsr & FTT_CEXC) != (IEEE754EXC | NV))) fail(19);
  grfpu_sqrtd(&denorm, &z); if (((tfsr >> 14) & 3) != 2) fail(19);


  /* FSQRTS */
  tfsr = 0;
  if ((grfpu_fsqrts(0x47c80000) != 0x43a00000) || (tfsr != 0)) fail(19);


  /* check non-IEEE mode */
  set_fsr(0x00400000);
  grfpu_faddd(&x, &denorm, &z); if ((z != 0x4030000000000000LL) || (tfsr != 0)) fail(20);
  grfpu_fmuld(&denorm, &y, &z); if ((z != 0x8000000000000000LL) || (tfsr != 0)) fail(20);
  
  /* check RZ, RP, RM rounding modes */
  set_fsr(0x40000000); x = 0x3ff0000000000000LL; y = 0x3ca00000100200f0LL;
  grfpu_faddd(&x, &y, &z); if (z != 0x3ff0000000000000LL) fail(21);
  set_fsr(0x80000000); x = 0x3ff0000000000000LL; y = 0x0050000000010001LL;
  grfpu_faddd(&x, &y, &z); if (z != 0x3ff0000000000001LL) fail(21);
  set_fsr(0xc0000000); x = 0xbff0000000000000LL; y = 0x8050000000010001LL;
  grfpu_faddd(&x, &y, &z); if (z != 0xbff0000000000001LL) fail(21);

  set_fsr(0x40000000); x = 0x3ff0000000000000LL;
  grfpu_faddd(&x, &inf, &z); if (z != inf) fail(21);
  set_fsr(0x80000000); x = 0x3ff0000000000000LL; y = 0x0050000000010001LL;
  grfpu_faddd(&x, &inf, &z); if (z != inf) fail(21);
  set_fsr(0xc0000000); x = 0xbff0000000000000LL; y = 0x8050000000010001LL;
  grfpu_faddd(&x, &inf, &z); if (z != inf) fail(21);

  set_fsr(0x40000000); x = 0x3ff0000000000001LL; y = 0x4000000000000001LL;
  grfpu_fmuld(&x, &y, &z); if (z != 0x4000000000000002LL) fail(21);
  set_fsr(0x80000000); 
  grfpu_fmuld(&x, &y, &z); if (z != 0x4000000000000003LL) fail(21);
  set_fsr(0xc0000000); x = 0xbff0000000000001LL;
  grfpu_fmuld(&x, &y, &z); if (z != 0xc000000000000003LL) fail(21);

  set_fsr(0x40000000); x = 0x3ffab954734ba011LL; y = 0x3ff01012bc985631LL;
  grfpu_fdivd(&x, &y, &z); if (z != 0x3ffa9e96b06cd02fLL) fail(21);  
  set_fsr(0x80000000);
  grfpu_fdivd(&x, &y, &z); if (z != 0x3ffa9e96b06cd030LL) fail(21);
  set_fsr(0xc0000000); y = 0xbff01012bc985631LL;  
  grfpu_fdivd(&x, &y, &z); if (z != 0xbffa9e96b06cd030LL) fail(21);  

  set_fsr(0x40000000); x = 0x40e0000000000000LL; y = 0x4040000000000000LL;
  grfpu_fdivd(&x, &y, &z); if (z != 0x4090000000000000LL) fail(21);  
  set_fsr(0x80000000);
  grfpu_fdivd(&x, &y, &z); if (z != 0x4090000000000000LL) fail(21);
  set_fsr(0xc0000000); 
  grfpu_fdivd(&x, &y, &z); if (z != 0x4090000000000000LL) fail(21);  

  set_fsr(0x40000000);
  if ((grfpu_fdivs(0x00800000, 0x3f800001) != 0x0)) fail(21);
  set_fsr(0x80000000);
  if ((grfpu_fdivs(0x00800000, 0x3f800001) != 0x0)) fail(21);
  set_fsr(0xc0000000);
  if ((grfpu_fdivs(0x00800000, 0x3f800001) != 0x0)) fail(21);
  
  set_fsr(0x40000000); x = 0x3ff0000000000000LL;
  grfpu_sqrtd(&x, &z); if ((z != x) || (tfsr != 0)) fail(21);
  set_fsr(0x80000000);
  grfpu_sqrtd(&x, &z); if ((z != x) || (tfsr != 0)) fail(21);
  set_fsr(0xc0000000);
  grfpu_sqrtd(&x, &z); if ((z != x) || (tfsr != 0)) fail(21);

  set_fsr(0x40000000);
  if ((grfpu_fsqrts(0x3f7fffff) != 0x3f7fffff)) fail(21);
  set_fsr(0x80000000);
  if ((grfpu_fsqrts(0x3f7fffff) != 0x3f800000)) fail(21);
  set_fsr(0xc0000000);
  if ((grfpu_fsqrts(0x3f7fffff) != 0x3f7fffff)) fail(21);

  
  /* check GRFPC lock logic */
  set_fsr(0);
  grfpc_dpdep_tst(&z); if (z != 0xbff8000000000000LL) fail(22);
  grfpc_spdep_tst(&fl); if (fl != 0xbfc00000) fail(22);
  grfpc_spdpdep_tst(&z); if (z != 0x3fefdff00ffc484aLL) fail(22); 

  /* check unfinished FP trap */
  grfpu_fdivd(&x, &denorm, &z);
  if (((tfsr & ((1 << 17) - 1)) >> 14) != 2) fail(23); 
  /* check FP instruction in FQ */
  //unfaddr = ((unsigned int *) &grfpu_fdivd) + 2; unfinst = *unfaddr;
  unfaddr = ((unsigned int *) grfpu_fdivd) + 2; unfinst = *unfaddr;
  if (((unsigned int) unfaddr) != grfpufq) fail(24);  
  if (unfinst != *(&grfpufq+1)) fail(24);
  if (*(&grfpufq+2) != 0) fail(24);
  if (*(&grfpufq+3) != 0) fail(24);

  

  /* look-up table test */
  x = 0x3100a4068f346c9bLL; y = 0;
  divident(&x); 
  for (i = 0 ; i < 256; i++)
  {
    *((unsigned int *) &y) = divisor[i];
    divromtst(&y, &z);
    if (z != *((uint64 *) &divres[2*i]))  fail(25); 
  }

  for (i = 0; i < 256; i = i + 2) 
  {
    *((unsigned int *) &y) = divisor[i];
    grfpu_sqrtd(&y, &z);
    if (z != *((uint64 *) &sqrtres[i])) fail(26);
  }

//  report_end(); 
}   

struct dp3_type fmuld_tv[11] = {
  {0x7e71000000000000LL, 0x4160100000000000LL, 0x7fe1110000000000LL}, /* max exp, no shift */
  {0x0178100000000000LL, 0x3e880000fff00000LL, 0x00120c00c073f800LL}, /* min exp - 1, shift */
  {0xc1efffffc0002000LL, 0x3fb3c75d224f280fLL, 0xc1b3c75cfac08192LL}, /* inc, shift */
  {0xa12fff8000001fffLL, 0x3ee0000000ff0000LL, 0xa01fff8001fe1807LL}, /* trunc */
  {0x41cffffe00000020LL, 0x40303ffffffffffdLL, 0x42103ffefc00000dLL}, /* shift */
  {0x3fd000003fefffffLL, 0xbfd0000010000000LL, 0xbfb000004ff0003fLL},  /* inc */
  {0x0170100000000000LL, 0x3e8000011a000000LL, 0x0LL},                /* min exp - 1, no shift */
  {0x7e7c000000000000LL, 0x416a100001000010LL, 0x7ff0000000000000LL}, /* max exp, shift */
  {0x75012034056ac000LL, 0xfa1009091000104fLL, 0xfff0000000000000LL}, /* of */
  {0x0100203040030200LL, 0x003020340000a00bLL, 0x0LL},                /* uf */
  {0x7fe0001010200001LL, 0x400000000010200aLL, 0x7ff0000000000000LL} /* of (emax + 1) */
};

struct dp3_type faddd_tv[16] = {
  {0x4200000000000000LL, 0x400fffffffffffffLL, 0x4200000000200000LL}, /* shift, round up */
  {0x420fffffffffffffLL, 0x4000000000000000LL, 0x4210000000080000LL},                    
  {0x4200000000000001LL, 0x3eb0000000000001LL, 0x4200000000000002LL}, /* guard, sticky */
  {0x420f484c0137d208LL, 0xc20e780f256007abLL, 0x41ba079b7af94ba0LL}, /* close, pos */
  {0x4201484c0137d208LL, 0x420e780f256007abLL, 0x4217e02d934becdaLL}, /* close, neg */
  {0x420f484c0137d208LL, 0xc21e780f256007abLL, 0xc20da7d249883d4eLL}, /* close, pos */
  {0x421f484c0137d208LL, 0xc20e780f256007abLL, 0x42100c446e87ce32LL},	/* close, neg */
  {0xc03340ab37120891LL, 0x0000000000000000LL, 0xc03340ab37120891LL}, /* zero */
  {0x0000000000000000LL, 0xc29e7a0f236007a6LL, 0xc29e7a0f236007a6LL}, /* zero */
  {0x6f3f484c0137d208LL, 0x6e2e780f256007abLL, 0x6f3f485b3d3f64b8LL},
  {0x6f3f484c0137d208LL, 0xee2e780f256007abLL, 0x6f3f483cc5303f58LL},
  {0x7fe2f780ab123809LL, 0x7fd0000000000000LL, 0x7feaf780ab123809LL}, /* emax, no shift */
  {0x0020000000000000LL, 0x8028000000000000LL, 0x8010000000000000LL}, /* emin, no uf */
  {0x7feff780ab123809LL, 0x7feff2010203a111LL, 0x7ff0000000000000LL}, /* emax, shift, of */
  {0x0010000000001000LL, 0x801ffffff203a111LL, 0x8000000000000000LL}, /* emin, uf */  
  {0x001abcd000023809LL, 0x801abcd000000111LL, 0x0}, /* emin, uf, lz */  
};


unsigned int divisor[256] = {
0x65300000,
0x65301000,
0x65302000,
0x65303000,
0x65304000,
0x65305000,
0x65306000,
0x65307000,
0x65308000,
0x65309000,
0x6530A000,
0x6530B000,
0x6530C000,
0x6530D000,
0x6530E000,
0x6530F000,
0x65310000,
0x65311000,
0x65312000,
0x65313000,
0x65314000,
0x65315000,
0x65316000,
0x65317000,
0x65318000,
0x65319000,
0x6531A000,
0x6531B000,
0x6531C000,
0x6531D000,
0x6531E000,
0x6531F000,
0x65320000,
0x65321000,
0x65322000,
0x65323000,
0x65324000,
0x65325000,
0x65326000,
0x65327000,
0x65328000,
0x65329000,
0x6532A000,
0x6532B000,
0x6532C000,
0x6532D000,
0x6532E000,
0x6532F000,
0x65330000,
0x65331000,
0x65332000,
0x65333000,
0x65334000,
0x65335000,
0x65336000,
0x65337000,
0x65338000,
0x65339000,
0x6533A000,
0x6533B000,
0x6533C000,
0x6533D000,
0x6533E000,
0x6533F000,
0x65340000,
0x65341000,
0x65342000,
0x65343000,
0x65344000,
0x65345000,
0x65346000,
0x65347000,
0x65348000,
0x65349000,
0x6534A000,
0x6534B000,
0x6534C000,
0x6534D000,
0x6534E000,
0x6534F000,
0x65350000,
0x65351000,
0x65352000,
0x65353000,
0x65354000,
0x65355000,
0x65356000,
0x65357000,
0x65358000,
0x65359000,
0x6535A000,
0x6535B000,
0x6535C000,
0x6535D000,
0x6535E000,
0x6535F000,
0x65360000,
0x65361000,
0x65362000,
0x65363000,
0x65364000,
0x65365000,
0x65366000,
0x65367000,
0x65368000,
0x65369000,
0x6536A000,
0x6536B000,
0x6536C000,
0x6536D000,
0x6536E000,
0x6536F000,
0x65370000,
0x65371000,
0x65372000,
0x65373000,
0x65374000,
0x65375000,
0x65376000,
0x65377000,
0x65378000,
0x65379000,
0x6537A000,
0x6537B000,
0x6537C000,
0x6537D000,
0x6537E000,
0x6537F000,
0x65380000,
0x65381000,
0x65382000,
0x65383000,
0x65384000,
0x65385000,
0x65386000,
0x65387000,
0x65388000,
0x65389000,
0x6538A000,
0x6538B000,
0x6538C000,
0x6538D000,
0x6538E000,
0x6538F000,
0x65390000,
0x65391000,
0x65392000,
0x65393000,
0x65394000,
0x65395000,
0x65396000,
0x65397000,
0x65398000,
0x65399000,
0x6539A000,
0x6539B000,
0x6539C000,
0x6539D000,
0x6539E000,
0x6539F000,
0x653A0000,
0x653A1000,
0x653A2000,
0x653A3000,
0x653A4000,
0x653A5000,
0x653A6000,
0x653A7000,
0x653A8000,
0x653A9000,
0x653AA000,
0x653AB000,
0x653AC000,
0x653AD000,
0x653AE000,
0x653AF000,
0x653B0000,
0x653B1000,
0x653B2000,
0x653B3000,
0x653B4000,
0x653B5000,
0x653B6000,
0x653B7000,
0x653B8000,
0x653B9000,
0x653BA000,
0x653BB000,
0x653BC000,
0x653BD000,
0x653BE000,
0x653BF000,
0x653C0000,
0x653C1000,
0x653C2000,
0x653C3000,
0x653C4000,
0x653C5000,
0x653C6000,
0x653C7000,
0x653C8000,
0x653C9000,
0x653CA000,
0x653CB000,
0x653CC000,
0x653CD000,
0x653CE000,
0x653CF000,
0x653D0000,
0x653D1000,
0x653D2000,
0x653D3000,
0x653D4000,
0x653D5000,
0x653D6000,
0x653D7000,
0x653D8000,
0x653D9000,
0x653DA000,
0x653DB000,
0x653DC000,
0x653DD000,
0x653DE000,
0x653DF000,
0x653E0000,
0x653E1000,
0x653E2000,
0x653E3000,
0x653E4000,
0x653E5000,
0x653E6000,
0x653E7000,
0x653E8000,
0x653E9000,
0x653EA000,
0x653EB000,
0x653EC000,
0x653ED000,
0x653EE000,
0x653EF000,
0x653F0000,
0x653F1000,
0x653F2000,
0x653F3000,
0x653F4000,
0x653F5000,
0x653F6000,
0x653F7000,
0x653F8000,
0x653F9000,
0x653FA000,
0x653FB000,
0x653FC000,
0x653FD000,
0x653FE000,
0x653FF000};

unsigned int divres[512] = { 
0x0bc0a406,
0x8f346c9b,
0x0bc09373,
0x1c185447,
0x0bc08300,
0x8e183c23,
0x0bc072ae,
0x83a9704a,
0x0bc0627c,
0x9cc166ff,
0x0bc0526a,
0x7ace64a4,
0x0bc04277,
0xc0b04ada,
0x0bc032a4,
0x12b191a0,
0x0bc022ef,
0x16806950,
0x0bc01358,
0x73280473,
0x0bc003df,
0xd10a0848,
0x0bbfe909,
0xb3b04632,
0x0bbfca8e,
0x711b8e88,
0x0bbfac4d,
0x32d41430,
0x0bbf8e45,
0x53d34b1b,
0x0bbf7076,
0x318237ef,
0x0bbf52df,
0x2badf99c,
0x0bbf357f,
0xa47c936c,
0x0bbf1857,
0x0061f5eb,
0x0bbefb64,
0xa6154515,
0x0bbedea7,
0xfe865a2b,
0x0bbec220,
0x74d37fbc,
0x0bbea5cd,
0x763f6669,
0x0bbe89ae,
0x722750f0,
0x0bbe6dc2,
0xd9f97623,
0x0bbe520a,
0x212b976c,
0x0bbe3683,
0xbd31caa2,
0x0bbe1b2f,
0x257575ca,
0x0bbe000b,
0xd34c7baf,
0x0bbde519,
0x41f097fe,
0x0bbdca56,
0xee76e9d0,
0x0bbdafc4,
0x57c7ab73,
0x0bbd9560,
0xfe961669,
0x0bbd7b2c,
0x65587275,
0x0bbd6126,
0x10404ec0,
0x0bbd474d,
0x8532e409,
0x0bbd2da2,
0x4bc19edf,
0x0bbd1423,
0xed22d101,
0x0bbcfad1,
0xf42a88e4,
0x0bbce1ab,
0xed438e80,
0x0bbcc8b1,
0x66688482,
0x0bbcafe1,
0xef1d2d01,
0x0bbc973d,
0x1867d0ef,
0x0bbc7ec2,
0x74cac962,
0x0bbc6671,
0x983e29fe,
0x0bbc4e4a,
0x18298ba9,
0x0bbc364b,
0x8b5df6db,
0x0bbc1e75,
0x8a0fecbf,
0x0bbc06c7,
0xadd18e7e,
0x0bbbef41,
0x918ce1f6,
0x0bbbd7e2,
0xd17e3336,
0x0bbbc0ab,
0x0b2e921b,
0x0bbba999,
0xdd6e6b65,
0x0bbb92ae,
0xe8503ca7,
0x0bbb7be9,
0xcd236272,
0x0bbb654a,
0x2e6f002c,
0x0bbb4ecf,
0xafed00fe,
0x0bbb3879,
0xf685313f,
0x0bbb2248,
0xa8486fde,
0x0bbb0c3b,
0x6c6bf73b,
0x0bbaf651,
0xeb44bcee,
0x0bbae08b,
0xce42e7f1,
0x0bbacae8,
0xbfed5cc0,
0x0bbab568,
0x6bdd5edd,
0x0bbaa00a,
0x7eba475e,
0x0bba8ace,
0xa6354feb,
0x0bba75b4,
0x910571db,
0x0bba60bb,
0xeee358ef,
0x0bba4be4,
0x70856941,
0x0bba372d,
0xc79bd7fe,
0x0bba2297,
0xa6ccd68c,
0x0bba0e21,
0xc1b0cfa0,
0x0bb9f9cb,
0xccceb605,
0x0bb9e595,
0x7d98648b,
0x0bb9d17e,
0x8a670ee7,
0x0bb9bd86,
0xaa77c310,
0x0bb9a9ad,
0x95e7fac4,
0x0bb995f3,
0x05b23ce5,
0x0bb98256,
0xb3aace57,
0x0bb96ed8,
0x5a7c7206,
0x0bb95b77,
0xb5a537c8,
0x0bb94834,
0x817359cc,
0x0bb9350e,
0x7b02284d,
0x0bb92205,
0x6037032e,
0x0bb90f18,
0xefbe614a,
0x0bb8fc48,
0xe908e522,
0x0bb8e995,
0x0c487ea9,
0x0bb8d6fd,
0x1a6d99e8,
0x0bb8c480,
0xd5245a34,
0x0bb8b21f,
0xfed1e1bc,
0x0bb89fda,
0x5a91a526,
0x0bb88daf,
0xac32cb0a,
0x0bb87b9f,
0xb83596f6,
0x0bb869aa,
0x43c8dfe1,
0x0bb857cf,
0x14c791b5,
0x0bb8460d,
0xf1b639c6,
0x0bb83466,
0xa1c09df9,
0x0bb822d8,
0xecb75e6e,
0x0bb81164,
0x9b0da16b,
0x0bb80009,
0x75d6c959,
0x0bb7eec7,
0x46c434a5,
0x0bb7dd9d,
0xd8230752,
0x0bb7cc8c,
0xf4d9fe01,
0x0bb7bb94,
0x68674a50,
0x0bb7aab3,
0xfede7854,
0x0bb799eb,
0x84e65d0c,
0x0bb7893a,
0xc7b70d96,
0x0bb778a1,
0x9517df01,
0x0bb7681f,
0xbb5d6e91,
0x0bb757b5,
0x0967b24c,
0x0bb74761,
0x4ea011a2,
0x0bb73724,
0x5af78614,
0x0bb726fd,
0xfee4c3a0,
0x0bb716ee,
0x0b6268e8,
0x0bb706f4,
0x51ed36ce,
0x0bb6f710,
0xa4824f80,
0x0bb6e742,
0xd59d7cb4,
0x0bb6d78a,
0xb8377d0e,
0x0bb6c7e8,
0x1fc45872,
0x0bb6b85a,
0xe031bb32,
0x0bb6a8e2,
0xcde557f9,
0x0bb6997f,
0xbdbb5045,
0x0bb68a31,
0x8504a35c,
0x0bb67af7,
0xf985a39b,
0x0bb66bd2,
0xf17471ff,
0x0bb65cc2,
0x43777fce,
0x0bb64dc5,
0xc6a41642,
0x0bb63edd,
0x527ce411,
0x0bb63008,
0xbef090cf,
0x0bb62147,
0xe45855eb,
0x0bb6129a,
0x9b769d52,
0x0bb60400,
0xbd75a584,
0x0bb5f57a,
0x23e62b07,
0x0bb5e706,
0xa8be172c,
0x0bb5d8a6,
0x265733ff,
0x0bb5ca58,
0x776de54b,
0x0bb5bc1d,
0x771fe6ab,
0x0bb5adf5,
0x00eb0e78,
0x0bb59fde,
0xf0ac1594,
0x0bb591db,
0x229d63f2,
0x0bb583e9,
0x7355e1c1,
0x0bb57609,
0xbfc7cd32,
0x0bb5683b,
0xe53f94b8,
0x0bb55a7f,
0xc162b5b6,
0x0bb54cd5,
0x322e9f7f,
0x0bb53f3c,
0x15f79aa1,
0x0bb531b4,
0x4b67b45a,
0x0bb5243d,
0xb17dae30,
0x0bb516d8,
0x278bf18f,
0x0bb50983,
0x8d378767,
0x0bb4fc3f,
0xc27713ae,
0x0bb4ef0c,
0xa791d4bb,
0x0bb4e1ea,
0x1d1ea668,
0x0bb4d4d8,
0x040308e5,
0x0bb4c7d6,
0x3d722b37,
0x0bb4bae4,
0xaaebf948,
0x0bb4ae03,
0x2e3c2d7e,
0x0bb4a131,
0xa97965c9,
0x0bb4946f,
0xff043c1c,
0x0bb487be,
0x11866236,
0x0bb47b1b,
0xc3f1c0bf,
0x0bb46e88,
0xf97f999b,
0x0bb46205,
0x95afad73,
0x0bb45591,
0x7c476454,
0x0bb4492c,
0x9150f96c,
0x0bb43cd6,
0xb91aa9c8,
0x0bb4308f,
0xd835e60b,
0x0bb42457,
0xd3768716,
0x0bb4182e,
0x8ff20590,
0x0bb40c13,
0xf2feb43b,
0x0bb40007,
0xe232fd1f,
0x0bb3f40a,
0x4364a167,
0x0bb3e81a,
0xfca7fbf0,
0x0bb3dc39,
0xf44f468a,
0x0bb3d067,
0x10e9e1c3,
0x0bb3c4a2,
0x39439f4f,
0x0bb3b8eb,
0x54640ef1,
0x0bb3ad42,
0x498dcddf,
0x0bb3a1a7,
0x003dd89b,
0x0bb39619,
0x602adf2b,
0x0bb38a99,
0x51449bb8,
0x0bb37f26,
0xbbb32b79,
0x0bb373c1,
0x87d669ea,
0x0bb36869,
0x9e454e44,
0x0bb35d1e,
0xe7cd4b2d,
0x0bb351e1,
0x4d71b098,
0x0bb346b0,
0xb86b0fc3,
0x0bb33b8d,
0x1226a15a,
0x0bb33076,
0x4445adac,
0x0bb3256c,
0x389cf6eb,
0x0bb31a6e,
0xd934256e,
0x0bb30f7e,
0x104535f5,
0x0bb30499,
0xc83be9d6,
0x0bb2f9c1,
0xebb53923,
0x0bb2eef6,
0x657ec6aa,
0x0bb2e437,
0x209655d5,
0x0bb2d984,
0x08294263,
0x0bb2cedd,
0x0793f9e7,
0x0bb2c442,
0x0a617719,
0x0bb2b9b2,
0xfc4abeda,
0x0bb2af2f,
0xc9365eff,
0x0bb2a4b8,
0x5d37eec1,
0x0bb29a4c,
0xa48f90e3,
0x0bb28fec,
0x8ba97779,
0x0bb28597,
0xff1d694d,
0x0bb27b4e,
0xebae48dd,
0x0bb27111,
0x3e499cee,
0x0bb266de,
0xe4071aa8,
0x0bb25cb7,
0xca283138,
0x0bb2529b,
0xde1796f7,
0x0bb2488b,
0x0d68d803,
0x0bb23e85,
0x45d7e65a,
0x0bb2348a,
0x7548ab54,
0x0bb22a9a,
0x89c69a97,
0x0bb220b5,
0x71844661,
0x0bb216db,
0x1adaf53f,
0x0bb20d0b,
0x744a3910,
0x0bb20346,
0x6c77876c,
0x0bb1f98b,
0xf22dd349,
0x0bb1efdb,
0xf45d27ff,
0x0bb1e636,
0x621a457e,
0x0bb1dc9b,
0x2a9e3dd5,
0x0bb1d30a,
0x3d4613ee,
0x0bb1c983,
0x89925b81,
0x0bb1c006,
0xff26da3f,
0x0bb1b694,
0x8dca2a28,
0x0bb1ad2c,
0x25655d0f,
0x0bb1a3cd,
0xb603a13d,
0x0bb19a79,
0x2fd1e741,
0x0bb1912e,
0x831e88d2,
0x0bb187ed,
0xa058f0d6,
0x0bb17eb6,
0x78114473,
0x0bb17588,
0xfaf80d3a,
0x0bb16c65,
0x19dde45d,
0x0bb1634a,
0xc5b31eef,
0x0bb15a39,
0xef877b28,
0x0bb15132,
0x8889ceae,
0x0bb14834,
0x8207b5db,
0x0bb13f3f,
0xcd6d43ff,
0x0bb13654,
0x5c44b49a,
0x0bb12d72,
0x20361d87,
0x0bb12499,
0x0b07221b,
0x0bb11bc9,
0x0e9aa72d,
0x0bb11302,
0x1cf0880f,
0x0bb10a44,
0x28254c65,
0x0bb1018f,
0x2271dee5,
0x0bb0f8e2,
0xfe2b44f4,
0x0bb0f03f,
0xadc25723,
0x0bb0e7a5,
0x23c37a85,
0x0bb0df13,
0x52d65ad9,
0x0bb0d68a,
0x2dbda58c,
0x0bb0ce09,
0xa756c589,
0x0bb0c591,
0xb2999fdb,
0x0bb0bd22,
0x42985115,
0x0bb0b4bb,
0x4a7eeb87,
0x0bb0ac5c,
0xbd933636};


unsigned int sqrtres[256] = {
0x52900000,
0x00000000,
0x52900ff8,
0x07f60deb,
0x52901fe0,
0x3f61bad0,
0x52902fb8,
0xd4e30f48,
0x52903f81,
0xf636b80c,
0x52904f3b,
0xd03c0a64,
0x52905ee6,
0x8efad48b,
0x52906e82,
0x5da8fc2b,
0x52907e0f,
0x66afed07,
0x52908d8d,
0xd3b1d9aa,
0x52909cfd,
0xcd8ed009,
0x5290ac5f,
0x7c69a3c8,
0x5290bbb3,
0x07acafdb,
0x5290caf8,
0x960e710d,
0x5290da30,
0x4d95fb06,
0x5290e95a,
0x539f492c,
0x5290f876,
0xccdf6cd9,
0x52910785,
0xdd689a29,
0x52911687,
0xa8ae14a3,
0x5291257c,
0x5187fd09,
0x52913463,
0xfa37014e,
0x5291433e,
0xc467effb,
0x5291520c,
0xd1372feb,
0x529160ce,
0x41341d74,
0x52916f83,
0x34644df9,
0x52917e2b,
0xca46bab9,
0x52918cc8,
0x21d6d3e3,
0x52919b58,
0x598f7c9f,
0x5291a9dc,
0x8f6df104,
0x5291b854,
0xe0f496a0,
0x5291c6c1,
0x6b2db870,
0x5291d522,
0x4aae2ee1,
0x5291e377,
0x9b97f4a8,
0x5291f1c1,
0x799ca8ff,
0x52920000,
0x00000000,
0x52920e33,
0x499a21a9,
0x52921c5b,
0x70d9f824,
0x52922a78,
0x8fc76de5,
0x5292388a,
0xc0059c28,
0x52924692,
0x1ad4ea49,
0x5292548e,
0xb9151e85,
0x52926280,
0xb3476096,
0x52927068,
0x21902e9a,
0x52927e45,
0x1bb944c3,
0x52928c17,
0xb9337834,
0x529299e0,
0x11188575,
0x5292a79e,
0x3a2cd2e6,
0x5292b552,
0x4ae1278e,
0x5292c2fc,
0x595456a7,
0x5292d09c,
0x7b54e03e,
0x5292de32,
0xc6628741,
0x5292ebbf,
0x4fafdd4b,
0x5292f942,
0x2c23c47e,
0x529306bb,
0x705ae7c3,
0x5293142b,
0x30a929ab,
0x52932191,
0x811b0a41,
0x52932eee,
0x75770416,
0x52933c42,
0x213ee0c9,
0x5293498c,
0x97b10540,
0x529356cd,
0xebc9b5e2,
0x52936406,
0x30445306,
0x52937135,
0x779c8dcb,
0x52937e5b,
0xd40f95a1,
0x52938b79,
0x579d3eab,
0x5293988e,
0x1409212e,
0x5293a59a,
0x1adbb257,
0x5293b29d,
0x7d635662,
0x5293bf98,
0x4cb56c77,
0x5293cc8a,
0x99af5453,
0x5293d974,
0x74f76df2,
0x5293e655,
0xeefe1367,
0x5293f32f,
0x17fe8d04,
0x52940000,
0x00000000,
0x52940cc8,
0xb6d657c2,
0x52941989,
0x4c2329f0,
0x52942641,
0xcf569572,
0x529432f2,
0x4fb01c7a,
0x52943f9a,
0xdc3f79ce,
0x52944c3b,
0x83e57153,
0x529458d4,
0x55549c1a,
0x52946565,
0x5f122ff6,
0x529471ee,
0xaf76c2c6,
0x52947e70,
0x54af0989,
0x52948aea,
0x5cbc935f,
0x5294975c,
0xd5768088,
0x5294a3c7,
0xcc8a358a,
0x5294b02b,
0x4f7c0a88,
0x5294bc87,
0x6ba7f6ec,
0x5294c8dc,
0x2e423980,
0x5294d529,
0xa457fcfc,
0x5294e16f,
0xdacff937,
0x5294edae,
0xde6b10fe,
0x5294f9e6,
0xbbc4ecb3,
0x52950617,
0x7f5491bb,
0x52951241,
0x356cf6e0,
0x52951e63,
0xea3d95b0,
0x52952a7f,
0xa9d2f8ea,
0x52953694,
0x80174810,
0x529542a2,
0x78d2d036,
0x52954ea9,
0x9fac8a0f,
0x52955aaa,
0x002a9d5a,
0x529566a3,
0xa5b2e1b1,
0x52957296,
0x9b8b5cd8,
0x52957e82,
0xecdabe8d,
0x52958a68,
0xa4a8d9f3,
0x52959647,
0xcddf1ca5,
0x5295a220,
0x73490377,
0x5295adf2,
0x9f948cfb,
0x5295b9be,
0x5d52a9da,
0x5295c583,
0xb6f7ab03,
0x5295d142,
0xb6dbadc5,
0x5295dcfb,
0x673b05df,
0x5295e8ad,
0xd236a58f,
0x5295f45a,
0x01d483b4,
0x52960000,
0x00000000,
0x52960b9f,
0xd68a4554,
0x52961739,
0x8f2aaa48,
0x529622cd,
0x337f0fe8,
0x52962e5a,
0xcd0c3ebe,
0x529639e2,
0x653e421b,
0x52964564,
0x0568c1c3,
0x529650df,
0xb6c759f4,
0x52965c55,
0x827df1d2,
0x529667c5,
0x7199104b,
0x5296732f,
0x8d0e2f77,
0x52967e93,
0xddbc0e73,
0x529689f2,
0x6c6b01d0,
0x5296954b,
0x41cd4293};
