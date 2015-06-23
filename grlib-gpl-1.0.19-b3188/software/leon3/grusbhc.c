/*
 * Tests for GRUSBHC
 *
 * Copyright (c) 2008 Gaisler Research AB
 *
 * Test functions:
 * ehc_test(..):     Tests EHC only
 * uhc_test(..):     Tests UHC only 
 * grusbhc_test(..): Tests UHC by calling uhc_test(..), then tests EHC by calling
 *                   ehc_test(..). If a address argument for a controller is 0 the
 *                   test for that controller will be skipped.
 * 
 * This test application transfers data but skips device resets and enumeration. 
 * It will not work with a real USB device.
 *
 * Requirements on simulation environment:
 * All ports must be connected to the utmi or ulpi simulation model
 * available in the gaisler simulation library lib/gaisler/sim.
 */

#include "testmod.h"
#include <malloc.h>

/***********/
/* Helpers */          
/***********/

#define byte_swap(x) ((((x) >> 24) & 0xff) | (((x) >> 8) & 0xff00) | \
		      (((x) << 8) & 0xff0000) | ((x) << 24))

#define cond_bswap(x, be) (be ? (x) : byte_swap(x))

#define hword_swap(x) ((((x) >> 16) & 0xffff) | ((x) << 16))


int *build_frame_list(int nelem, int bedesc)
{
  int i;
  int *flbase;

  flbase = memalign(4096, nelem*4);
  
  for (i = 0; i < nelem; i++)
    if (bedesc = 1)
      *(flbase + i) = 1;
    else 
      *(flbase + i) = 0x01000000;

  return flbase;
}

/*********************/
/* EHC specific code */
/*********************/

/* Register fields */
/* USBCMD */
#define EHC_USBCMD_ITHRES          (0xff << 16)
#define EHC_USBCMD_ITHRES_P        16
#define EHC_USBCMD_PMODE           (1 << 11)
#define EHC_USBCMD_PMODECNT        (3 << 8)
#define EHC_USBCMD_LHCRESET        (1 << 7)
#define EHC_USBCMD_AS_ADV_INT      (1 << 6)
#define EHC_USBCMD_AS_SCHED_EN     (1 << 5)
#define EHC_USBCMD_PER_SCHED_EN    (1 << 4)
#define EHC_USBCMD_FLSIZE          (3 << 2)
#define EHC_USBCMD_HCRESET         (1 << 1)
#define EHC_USBCMD_RUNSTOP         (1 << 0)

/* USBSTS */
#define EHC_USBSTS_ASSTAT          (1 << 15)
#define EHC_USBSTS_PERSTAT         (1 << 14)
#define EHC_USBSTS_RECL            (1 << 13)
#define EHC_USBSTS_HCHALTED        (1 << 12)
#define EHC_USBSTS_ASADV           (1 << 5)
#define EHC_USBSTS_HSERR           (1 << 4)
#define EHC_USBSTS_FLROLL          (1 << 3)
#define EHC_USBSTS_PCHANGE_DETECT  (1 << 2)
#define EHC_USBSTS_USBERRINT       (1 << 1)
#define EHC_USBSTS_USBINT          (1 << 0)

/* CONFIGFLAG */
#define EHC_CONFIGFLAG_CF          (1 << 0)

/* PORTSC */
#define EHC_PORTSC_WKOC_E          (1 << 22)
#define EHC_PORTSC_WKDSCNNT_E      (1 << 21)
#define EHC_PORTSC_WKCNNT_E        (1 << 20)
#define EHC_PORTSC_POWNER          (1 << 13)
#define EHC_PORTSC_PP              (1 << 12)
#define EHC_PORTSC_LS_P            10
#define EHC_PORTSC_PRESET          (1 << 8)
#define EHC_PORTSC_PSUSPEND        (1 << 7)
#define EHC_PORTSC_PRESUME         (1 << 6)
#define EHC_PORTSC_OC_CHANGE       (1 << 5)
#define EHC_PORTSC_OC_ACTIVE       (1 << 4)
#define EHC_PORTSC_PEN_CHANGE      (1 << 3)
#define EHC_PORTSC_PEN             (1 << 2)
#define EHC_PORTSC_CNNTSTAT_CHANGE (1 << 1)
#define EHC_PORTSC_CNNTSTAT        (1 << 0)

#define EHC_JSTATE 0x2

#define EHC_AUXREGS_OFF 0x54

#define EHC_USBCMD_RESVAL(aspm)  (aspm ? 0x00080b00 : 0x00080000)
#define EHC_USBSTS_RESVAL        0x00001000
#define EHC_USBINTR_RESVAL       0x00000000
#define EHC_FRINDEX_RESVAL       0x00000000
#define EHC_CTRLDSSEGMENT_RESVAL 0x00000000
#define EHC_CONFIGFLAG_RESVAL    0x00000000
#define EHC_PORTSC_RESVAL(ppc)   (ppc ? 0x00002000  : 0x00003000)        

#define EHC_HCSPARAMS_NPORTS(x) (x & 0xf)
#define EHC_HCSPARAMS_PPC(x)    (x & 0x10)

#define EHC_HCCPARAMS_ASPM(x)   (x & 0x4)

struct ehccoreregs {
  volatile unsigned int capver;
  volatile unsigned int hcsparams;
  volatile unsigned int hccparams;
  volatile unsigned int hcspportroute[2];
  volatile unsigned int usbcmd;
  volatile unsigned int usbsts;
  volatile unsigned int usbintr;
  volatile unsigned int frindex;
  volatile unsigned int ctrldssegment;
  volatile unsigned int perlistbase;
  volatile unsigned int alistaddr;
};

struct ehcauxregs {
  volatile unsigned int configflag;
  volatile unsigned int portsc[15];
};

/* Descriptor fields and helper defines */

#define EHC_TYP_iTD     0x00
#define EHC_TYP_QH      0x02
#define EHC_T           (1 << 0)

#define EHC_HS          2

#define iTD_STATUS_P    28
#define iTD_ACTIVE      (1 << 3)
#define iTD_TLEN_P      16
#define iTD_IOC         (1 << 15)
#define iTD_IO          (1 << 11)

#define QH_RL_P         28
#define QH_C            (1 << 27)
#define QH_MAXP_P       16
#define QH_H            (1 << 15)
#define QH_DTC          (1 << 14)
#define QH_EPS_P        12
#define QH_ENDPT_P      8
#define QH_MULT_P       30

#define qTD_DT          (1 << 31)
#define qTD_TOTALB_P    16
#define qTD_IOC         (1 << 15) 
#define qTD_PID_P       8
#define qTD_ACTIVE      0x80
#define qTD_HALTBABXACT 0x58

#define qTD_OUT         0
#define qTD_IN          1
#define qTD_SETUP       10

#define MASK_UFRAME0    0x01
#define MASK_UFRAME1    0x02


struct ehc_itd {
  volatile unsigned int lp;
  volatile unsigned int status[8];
  volatile unsigned int buf[7];
};

struct ehc_qtd {
  volatile unsigned int next;
  volatile unsigned int anext;
  volatile unsigned int token;
  volatile unsigned int bufp[4];

};

struct ehc_qh {
  volatile unsigned int lp;
  volatile unsigned int chr;
  volatile unsigned int cap;
  volatile unsigned int curr;
  struct ehc_qtd qtd;
};


void ehc_check_opresvals(struct ehccoreregs *c, struct ehcauxregs *a, 
			 int beregs)
{
  int i = 0;
  int nports = EHC_HCSPARAMS_NPORTS(cond_bswap(c->hcsparams,beregs));
  int aspm =  EHC_HCCPARAMS_ASPM(cond_bswap(c->hccparams,beregs));
  int ppc = EHC_HCSPARAMS_PPC(cond_bswap(c->hcsparams,beregs));

  if (c->usbcmd != cond_bswap(EHC_USBCMD_RESVAL(aspm),beregs))
    fail(0);
  if (c->usbsts != cond_bswap(EHC_USBSTS_RESVAL,beregs))
    fail(1);
  if (c->usbintr != cond_bswap(EHC_USBINTR_RESVAL,beregs))
    fail(2);
  if (c->frindex != cond_bswap(EHC_FRINDEX_RESVAL,beregs))
    fail(3);
  if (c->ctrldssegment != cond_bswap(EHC_CTRLDSSEGMENT_RESVAL,beregs))
    fail(4);
  /* Periodic List Base has undefined reset value, not checked */
  /* Asynchronous List Address has undefined reset value, not checked */
  if (a->configflag != cond_bswap(EHC_CONFIGFLAG_RESVAL,beregs))
    fail(5);
  while (i < nports) {
    if (a->portsc[i] != cond_bswap(EHC_PORTSC_RESVAL(ppc),beregs))
      fail(6+i);
    i++;
  }
}


int ehc_test(int addr, int bedesc, int beregs)
{
  int i;

  char *buf;
  int *flbase;
  
  struct ehccoreregs *c;
  struct ehcauxregs *a;

  struct ehc_itd *itdi, *itdo;
  struct ehc_qh *qhi, *qho, *aqh;
  struct ehc_qtd *qtdi, *qtdo, *aqtdi, *aqtdo;


  report_device(0x01026000);

  c = (struct ehccoreregs*)addr;
  a = (struct ehcauxregs*)(addr + EHC_AUXREGS_OFF);

  /* Check register reset values */
  report_subtest(1);

  ehc_check_opresvals(c, a, beregs);

  /* Perform HC Reset */
  report_subtest(2);

  c->usbcmd |= cond_bswap(EHC_USBCMD_HCRESET, beregs);

  while (c->usbcmd & cond_bswap(EHC_USBCMD_HCRESET,beregs))
    ;

  ehc_check_opresvals(c, a, beregs);

  /* Activate controller, reset device and transfer 1 byte isoch OUT and IN, 
     1 byte interrupt OUT and IN */
  report_subtest(3);

  a->configflag = cond_bswap(EHC_CONFIGFLAG_CF,beregs);
  
  if (EHC_HCSPARAMS_PPC(cond_bswap(c->hcsparams,beregs)))
    a->portsc[0] = cond_bswap(EHC_PORTSC_PP, beregs);
  
  while (!(a->portsc[0] & cond_bswap(EHC_PORTSC_CNNTSTAT, beregs)))
    ;

  /* Controller should discover connect */
  if (a->portsc[0] != cond_bswap(EHC_PORTSC_PP | 
				 (EHC_JSTATE << EHC_PORTSC_LS_P) |
				 EHC_PORTSC_CNNTSTAT_CHANGE |
				 EHC_PORTSC_CNNTSTAT, beregs))
    fail(0);
  
  a->portsc[0] |= cond_bswap(EHC_PORTSC_PRESET,beregs);
  
  /* Build schedule */
  flbase = build_frame_list(2, bedesc);

  if ((itdi = memalign(32, sizeof(struct ehc_itd))) == NULL)
    fail(1);
  if ((itdo = memalign(32, sizeof(struct ehc_itd))) == NULL)
    fail(2);
  if ((qhi = memalign(32, sizeof(struct ehc_qh))) == NULL)
    fail(3);
  if ((qho = memalign(32, sizeof(struct ehc_qh))) == NULL)
    fail(4);
  if ((qtdi = memalign(32, sizeof(struct ehc_qtd))) == NULL)
    fail(5);
  if ((qtdo = memalign(32, sizeof(struct ehc_qtd))) == NULL)
    fail(6);

  if ((buf = memalign(4096, 2)) == NULL)
    fail(7);

  *buf = 0xaa;
  *(buf+1) = 0xbb;

  itdo->lp = cond_bswap((int)itdi,bedesc);
  itdo->status[0] = cond_bswap((iTD_ACTIVE << iTD_STATUS_P) | 
			       (1 << iTD_TLEN_P),bedesc);
  for (i = 1; i < 8; i++)
    itdo->status[i] = 0;
  itdo->buf[0] = cond_bswap((int)buf,bedesc);
  itdo->buf[1] = cond_bswap(1,bedesc);
  itdo->buf[2] = cond_bswap(1,bedesc);
  itdi->lp = cond_bswap((int)qho | EHC_TYP_QH ,bedesc);
  itdi->status[0] = cond_bswap((iTD_ACTIVE << iTD_STATUS_P) | 
			       (1 << iTD_TLEN_P),bedesc);
  for (i = 1; i < 8; i++)
    itdi->status[i] = 0;
  itdi->buf[0] = cond_bswap((int)buf,bedesc);
  itdi->buf[1] = cond_bswap(iTD_IO | 1,bedesc);
  itdi->buf[2] = cond_bswap(1,bedesc);

  qho->lp = cond_bswap((int)qhi | EHC_TYP_QH,bedesc);
  qho->chr = cond_bswap((1 << QH_MAXP_P) | (EHC_HS << QH_EPS_P) | 
			(1 << QH_ENDPT_P),bedesc);
  qho->cap = cond_bswap(1 << QH_MULT_P | MASK_UFRAME0,bedesc);
  qho->curr = cond_bswap((int)qtdo,bedesc);
  qho->qtd.next = cond_bswap(EHC_T,bedesc);
  qho->qtd.anext = cond_bswap(EHC_T,bedesc);
  qho->qtd.token = cond_bswap((1 << qTD_TOTALB_P) | 
			      (qTD_OUT << qTD_PID_P) | qTD_ACTIVE,bedesc);
  qho->qtd.bufp[0] = cond_bswap((int)buf | 1,bedesc);
  qtdo->next = cond_bswap(EHC_T,bedesc);
  qtdo->anext = cond_bswap(EHC_T,bedesc);
  qtdo->token = cond_bswap((1 << qTD_TOTALB_P) | 
			      (qTD_OUT << qTD_PID_P) | qTD_ACTIVE,bedesc);
  qtdo->bufp[0] = cond_bswap((int)buf | 1,bedesc);
  
  qhi->lp = cond_bswap(EHC_T,bedesc);
  qhi->chr = cond_bswap((1 << QH_MAXP_P) | (EHC_HS << QH_EPS_P) |
			(1 << QH_ENDPT_P),bedesc);
  qhi->cap = cond_bswap(1 << QH_MULT_P | MASK_UFRAME0,bedesc);
  qhi->curr = cond_bswap((int)qtdi,bedesc);
  qhi->qtd.next = cond_bswap(EHC_T,bedesc);
  qhi->qtd.anext = cond_bswap(EHC_T,bedesc);
  qhi->qtd.token = cond_bswap((1 << qTD_TOTALB_P) | qTD_IOC | 
			      (qTD_IN << qTD_PID_P) | qTD_ACTIVE,bedesc);
  qhi->qtd.bufp[0] = cond_bswap((int)buf | 1,bedesc);
  qtdi->next = cond_bswap(EHC_T,bedesc);
  qtdi->anext = cond_bswap(EHC_T,bedesc);
  qtdi->token = cond_bswap((1 << qTD_TOTALB_P) | qTD_IOC | 
			      (qTD_IN << qTD_PID_P) | qTD_ACTIVE,bedesc);
  qtdi->bufp[0] = cond_bswap((int)buf | 1,bedesc);

  flbase[0] = cond_bswap((int)itdo,bedesc);

  c->perlistbase = cond_bswap((int)flbase,beregs);

  /* If the processor is operating at a high frequency we may
     set port reset to 0 too fast */
  a->portsc[0] &= cond_bswap(~EHC_PORTSC_PRESET,beregs);

  while (!(a->portsc[0] & cond_bswap(EHC_PORTSC_PEN,beregs)))
    ;
  
  c->usbsts = c->usbsts;

  c->usbcmd = cond_bswap((1 << EHC_USBCMD_ITHRES_P) | EHC_USBCMD_PER_SCHED_EN | 
			 EHC_USBCMD_RUNSTOP,beregs);

  /* Build schedule for test 4 */
  aqh = memalign(32, sizeof(struct ehc_qh));
  aqtdi = memalign(32, sizeof(struct ehc_qtd));
  aqtdo = memalign(32, sizeof(struct ehc_qtd));

  aqh->lp = cond_bswap((int)aqh,bedesc);
  aqh->chr = cond_bswap((1 << QH_MAXP_P) | QH_H | QH_DTC | 
			(EHC_HS << QH_EPS_P) | (1 << QH_ENDPT_P),bedesc);
  aqh->cap = cond_bswap(1 << QH_MULT_P,bedesc);
  aqh->curr = cond_bswap((int)aqtdo,bedesc);
  aqh->qtd.next = cond_bswap((int)aqtdi,bedesc);
  aqh->qtd.anext = cond_bswap(EHC_T,bedesc);
  aqh->qtd.token = cond_bswap((1 << qTD_TOTALB_P) | qTD_IOC | 
			      (qTD_OUT << qTD_PID_P) | qTD_ACTIVE,bedesc);
  aqh->qtd.bufp[0] = cond_bswap((int)buf,bedesc);
  aqtdo->next = cond_bswap((int)aqtdi,bedesc);
  aqtdo->anext = cond_bswap(EHC_T,bedesc);
  aqtdo->token = cond_bswap((1 << qTD_TOTALB_P) | qTD_IOC |
			    (qTD_OUT << qTD_PID_P) | qTD_ACTIVE,bedesc);
  aqtdo->bufp[0] = cond_bswap((int)buf,bedesc);

  aqtdi->next = cond_bswap(EHC_T,bedesc);
  aqtdi->anext = cond_bswap(EHC_T,bedesc);
  aqtdi->token = cond_bswap((qTD_IN << qTD_PID_P) | qTD_ACTIVE,bedesc);
  aqtdi->bufp[0] = cond_bswap((int)buf,bedesc);


  while (!(c->usbsts & cond_bswap(EHC_USBSTS_USBINT,beregs)))
    ;

  if (c->usbsts != cond_bswap(EHC_USBSTS_PERSTAT |
			      EHC_USBSTS_USBINT, beregs))
    fail(2);
  
  if (itdo->lp != cond_bswap((int)itdi,bedesc))
    fail(3);
  if (itdo->status[0] != cond_bswap((1 << iTD_TLEN_P) | 1,bedesc))
    fail(4);
  if (itdo->buf[0] != cond_bswap((int)buf,bedesc))
    fail(5);
  if (itdo->buf[1] != cond_bswap(1,bedesc))
    fail(6);
  if (itdo->buf[2] != cond_bswap(1,bedesc))
    fail(7);
  if (itdi->lp != cond_bswap((int)qho | EHC_TYP_QH ,bedesc))
    fail(8);
  if (itdi->status[0] != cond_bswap((1 << iTD_TLEN_P) | 1,bedesc))
    fail(9);
  if (itdi->buf[0] != cond_bswap((int)buf,bedesc))
    fail(10);
  if (itdi->buf[1] != cond_bswap(iTD_IO | 1,bedesc))
    fail(11);
  if (itdi->buf[2] != cond_bswap(1,bedesc))
    fail(12);

  if (*buf != 0x55)
    fail(13);

  if (qho->lp != cond_bswap((int)qhi | EHC_TYP_QH,bedesc))
    fail(14);
  if (qho->chr != cond_bswap((1 << QH_MAXP_P) | (EHC_HS << QH_EPS_P) |
			     (1 << QH_ENDPT_P),bedesc))
    fail(15);
  if (qho->cap != cond_bswap(1 << QH_MULT_P | MASK_UFRAME0,bedesc))
    fail(16);
  if (qho->curr != cond_bswap((int)qtdo,bedesc))
    fail(17);
  if (qho->qtd.next != cond_bswap(EHC_T,bedesc))
    fail(18);
  if (qho->qtd.anext != cond_bswap(EHC_T,bedesc))
    fail(19);
  if (qho->qtd.token != cond_bswap(qTD_DT | (qTD_OUT << qTD_PID_P),bedesc))
    fail(20);
  if (qho->qtd.bufp[0] != cond_bswap((int)buf | 2,bedesc))
    fail(21);
  if (qtdo->next != cond_bswap(EHC_T,bedesc))
    fail(22);
  if (qtdo->anext != cond_bswap(EHC_T,bedesc))
    fail(23);
  if (qtdo->token != cond_bswap(qTD_DT | (qTD_OUT << qTD_PID_P),bedesc))
    fail(24);
  if (qtdo->bufp[0] != cond_bswap((int)buf | 1,bedesc))
    fail(25);
  
  if (qhi->lp != cond_bswap(EHC_T,bedesc))
    fail(26);
  if (qhi->chr != cond_bswap((1 << QH_MAXP_P) | (EHC_HS << QH_EPS_P) |
			     (1 << QH_ENDPT_P),bedesc))
    fail(27);
  if (qhi->cap != cond_bswap(1 << QH_MULT_P | MASK_UFRAME0,bedesc))
    fail(28);
  if (qhi->curr != cond_bswap((int)qtdi,bedesc))
    fail(29);
  if (qhi->qtd.next != cond_bswap(EHC_T,bedesc))
    fail(30);
  if (qhi->qtd.anext != cond_bswap(EHC_T,bedesc))
    fail(31);
  if (qhi->qtd.token != cond_bswap(qTD_DT | qTD_IOC | 
				   (qTD_IN << qTD_PID_P),bedesc))
    fail(32);
  if (qhi->qtd.bufp[0] != cond_bswap((int)buf | 2,bedesc))
    fail(33);
  if (qtdi->next != cond_bswap(EHC_T,bedesc))
    fail(34);
  if (qtdi->anext != cond_bswap(EHC_T,bedesc))
    fail(35);
  if (qtdi->token != cond_bswap(qTD_DT | qTD_IOC | 
				(qTD_IN << qTD_PID_P),bedesc))
    fail(36);
  if (qtdi->bufp[0] != cond_bswap((int)buf | 1,bedesc))
    fail(37);

  if (*(buf+1) != 0x44)
    fail(38);

  c->usbsts = c->usbsts;

  /* Transfer 1b SETUP OUT and 0b bulk IN which should lead to babble error, 
     first traverse inactive per. sched. */
  report_subtest(4);

  c->alistaddr = cond_bswap((int)aqh,beregs);

  /* Enable both schedules */
  c->usbcmd = cond_bswap((1 << EHC_USBCMD_ITHRES_P) | EHC_USBCMD_PER_SCHED_EN | 
			 EHC_USBCMD_AS_SCHED_EN | EHC_USBCMD_RUNSTOP,beregs);

  while (!(c->usbsts & cond_bswap(EHC_USBSTS_USBERRINT,beregs)))
    ;

  if (c->usbsts != cond_bswap(EHC_USBSTS_PERSTAT | EHC_USBSTS_ASSTAT |
			      EHC_USBSTS_USBERRINT | EHC_USBSTS_USBINT, beregs))
    fail(1);
  
  c->usbcmd = 0;

  if (aqh->lp != cond_bswap((int)aqh,bedesc))
    fail(2);
  if (aqh->chr != cond_bswap((1 << QH_MAXP_P) | QH_H | QH_DTC | 
			     (EHC_HS << QH_EPS_P) | (1 << QH_ENDPT_P),bedesc))
    fail(3);
  if (aqh->cap != cond_bswap(1 << QH_MULT_P,bedesc))
    fail(4);
  if (aqh->curr != cond_bswap((int)aqtdi,bedesc))
    fail(5);
  if (aqh->qtd.next != cond_bswap(EHC_T,bedesc))
    fail(6);
  if (aqh->qtd.anext != cond_bswap(EHC_T,bedesc))
    fail(7);
  if (aqh->qtd.token != cond_bswap((qTD_IN << qTD_PID_P) | qTD_HALTBABXACT,bedesc))
    fail(8);
  if (aqh->qtd.bufp[0] != cond_bswap((int)buf,bedesc))
    fail(9);
  if (aqtdo->next != cond_bswap((int)aqtdi,bedesc))
    fail(10);
  if (aqtdo->anext != cond_bswap(EHC_T,bedesc))
    fail(11);
  if (aqtdo->token != cond_bswap(qTD_DT | qTD_IOC | qTD_OUT << qTD_PID_P,bedesc))
    fail(12);
  if (aqtdo->bufp[0] != cond_bswap((int)buf,bedesc))
    fail(13);
  if (aqtdi->next != cond_bswap(EHC_T,bedesc))
    fail(14);
  if (aqtdi->anext != cond_bswap(EHC_T,bedesc))
    fail(15);
  if (aqtdi->token != cond_bswap((qTD_IN << qTD_PID_P) | qTD_HALTBABXACT,bedesc))
    fail(16);
  if (aqtdi->bufp[0] != cond_bswap((int)buf,bedesc))
    fail(17);

  free(itdi);
  free(itdo);
  free(qhi);
  free(qho);
  free(qtdi);
  free(qtdo);
  free(aqh);
  free(aqtdi);
  free(aqtdo);
  free(buf);
  free(flbase);
  
  while (!(c->usbsts & cond_bswap(EHC_USBSTS_HCHALTED,beregs)))
    ;

  a->configflag = 0;

  return 0;
}

/*********************/
/* UHC specific code */
/*********************/

/* Register fields */
/* USBCMD */
#define UHC_USBCMD_UMAXP      (1 << 7)
#define UHC_USBCMD_UCF        (1 << 6)
#define UHC_USBCMD_SWDBG      (1 << 5)
#define UHC_USBCMD_FGR        (1 << 4)
#define UHC_USBCMD_EGSM       (1 << 3)
#define UHC_USBCMD_GRESET     (1 << 2)
#define UHC_USBCMD_HCRESET    (1 << 1)
#define UHC_USBCMD_RUNSTOP    (1 << 0)

/* USBSTS */
#define UHC_USBSTS_HCHALTED   (1 << 5)
#define UHC_USBSTS_HCP        (1 << 4)
#define UHC_USBSTS_HCERROR    (1 << 3)
#define UHC_USBSTS_RSDETECT   (1 << 2)
#define UHC_USBSTS_USBERRINT  (1 << 1)
#define UHC_USBSTS_USBINT     (1 << 0)

/* PORTSC */
#define UHC_PORTSC_SUSPEND    (1 << 12)
#define UHC_PORTSC_PRESET     (1 << 9)
#define UHC_PORTSC_LS         (1 << 8)
#define UHC_PORTSC_RES        (1 << 7)
#define UHC_PORTSC_RSDETECT   (1 << 6)
#define UHC_PORTSC_LINESTATUS (3 << 4)
#define UHC_PORTSC_PEN_CHANGE (1 << 3)
#define UHC_PORTSC_PEN        (1 << 2)
#define UHC_PORTSC_CNNTSTATC  (1 << 1)
#define UHC_PORTSC_CNNTSTAT   (1 << 0)

/* Reset values */
#define UHC_USBCMD_RESVAL 0x0000
#define UHC_USBSTS_RESVAL 0x0020
#define UHC_USBINT_RESVAL 0x0000
#define UHC_FRNUM_RESVAL  0x0000
#define UHC_SOFMOD_RESVAL(b) (b ? 0x4000 : 0x40)
#define UHC_PORTSC_RESVAL 0x0083

struct uhcregs {
  volatile unsigned int usbcmdsts;
  volatile unsigned int usbintfrnum;
  volatile unsigned int fladdr;
  volatile unsigned int sofmod;
  volatile unsigned int portsc[4];
};


/* TD fields and helper defines */
#define TD_VF (1 << 2)
#define TD_Q  (1 << 1)
#define TD_T  (1 << 0)

#define TD_SPD (1 << 29)
#define TD_CERR_P 27
#define TD_LS (1 << 26)
#define TD_ISO (1 << 25)
#define TD_IOC (1 << 24)
#define TD_STATUS (255 << 16)
#define TD_STATUS_P 16
#define TD_STATUS_ACTIVE 0x80
#define TD_ACTIVE (TD_STATUS_ACTIVE << TD_STATUS_P)
#define TD_MAXLEN_P 21
#define TD_ENDPT_P 15
#define TD_D (1 << 19)


/* PIDS */
#define TD_PID_IN    0x69
#define TD_PID_OUT   0xE1
#define TD_PID_SETUP 0x2D

struct uhc_td {
  volatile unsigned int lp;
  volatile unsigned int stat;
  volatile unsigned int token;
  volatile unsigned int bufp;
};

struct uhc_qh {
  volatile unsigned int lp;
  volatile unsigned int elp;
  volatile unsigned int pad1;
  volatile unsigned int pad2;
};


#define get_lhw(x) ((x >> 16) & 0xffff)
#define get_hhw(x) (x & 0xffff)

#define fix_end(x) (beregs ? x : hword_swap(byte_swap(x)))  

#define cond_regswap(x) (beregs ? x : byte_swap(hword_swap(x)))

#define get_usbcmd(x) get_lhw(fix_end(x->usbcmdsts))
#define get_usbsts(x) get_hhw(fix_end(x->usbcmdsts))
#define get_usbint(x) get_lhw(fix_end(x->usbintfrnum))
#define get_frnum(x)  get_hhw(fix_end(x->usbintfrnum))
#define get_fladdr(x) byte_swap(x->fladdr)
#define get_sofmod(x) get_lhw(fix_end(x->sofmod))
#define get_portsc(x, i) (i % 2 ? get_hhw(fix_end(x->portsc[i/2])) : get_lhw(fix_end(x->portsc[i/2])))

void uhc_check_resvals(struct uhcregs *regs, int beregs)
{
  int i = 0;

  if (get_usbcmd(regs) != UHC_USBCMD_RESVAL)
    fail(0);
  if (get_usbsts(regs) != UHC_USBSTS_RESVAL)
    fail(1);
  if (get_usbint(regs) != UHC_USBINT_RESVAL)
    fail(2);
  if (get_frnum(regs) != UHC_FRNUM_RESVAL)
    fail(3);
  /* fladdr has undefined reset value */
  if (get_sofmod(regs) != UHC_SOFMOD_RESVAL(beregs))
    fail(4);
  while (get_portsc(regs,i) & UHC_PORTSC_RES) {
    if (get_portsc(regs,i) != UHC_PORTSC_RESVAL)
      fail(5+i);
    i++;
  }
}


int uhc_test(int addr, int bedesc, int beregs)
{
  int i;

  struct uhc_td *td;
  struct uhc_qh *qh;
  char *buf;
  int *flbase;
  struct uhcregs *regs;

  report_device(0x01027000);
  
  regs = (struct uhcregs*)addr;

  /* Check register reset values */
  report_subtest(1);

  uhc_check_resvals(regs, beregs);
  
  /* Perform HC reset */
  report_subtest(2);

  regs->usbcmdsts = cond_regswap(UHC_USBCMD_HCRESET);

  while (get_usbcmd(regs) & UHC_USBCMD_HCRESET)
    ;

  uhc_check_resvals(regs, beregs);

  /* Transfer 1 byte isoch packet OUT and IN */
  report_subtest(3);

  flbase = build_frame_list(2, bedesc);
 
  buf = malloc(1);
  td = memalign(16, 2*sizeof(struct uhc_td));

  *buf = 0xaa;
  
  td[0].lp = cond_bswap((int)(td+1), bedesc);
  td[0].stat = cond_bswap(TD_ISO | TD_ACTIVE, bedesc);
  td[0].token = cond_bswap(TD_PID_OUT, bedesc);
  td[0].bufp = cond_bswap((int)buf, bedesc);
  
  td[1].lp = cond_bswap(TD_T, bedesc);
  td[1].stat = cond_bswap(TD_ISO | TD_IOC | TD_ACTIVE, bedesc);
  td[1].token = cond_bswap(TD_PID_IN, bedesc);
  td[1].bufp = cond_bswap((int)buf, bedesc);
  
  flbase[0] = cond_bswap((int)td, bedesc);

  regs->fladdr = cond_bswap((int)flbase, beregs);

  regs->portsc[0] = cond_regswap(UHC_PORTSC_PEN << 16);

  regs->usbcmdsts = cond_regswap(UHC_USBCMD_RUNSTOP << 16);
  
  while (!get_usbsts(regs))
    ;

  if (!(get_usbsts(regs) & UHC_USBSTS_USBINT) || (get_usbsts(regs) >> 1))
    fail(0);

  regs->usbcmdsts = cond_regswap(0x0000ffff);

  if (!(get_usbsts(regs) & UHC_USBSTS_HCHALTED))
    fail(1);
  

  if (td[0].lp != cond_bswap((int)(td+1),bedesc))
    fail(2);
  if (td[0].stat != cond_bswap(TD_ISO,bedesc))
    fail(3);
  if (td[0].token != cond_bswap(TD_PID_OUT,bedesc))
    fail(4);
  if (td[0].bufp != cond_bswap((int)buf,bedesc))
    fail(5);
  if (td[1].lp != cond_bswap(TD_T,bedesc))
    fail(6);
  if (td[1].stat != cond_bswap(TD_ISO | TD_IOC,bedesc))
    fail(7);
  if (td[1].token != cond_bswap(TD_PID_IN,bedesc))
    fail(8);
  if (td[1].bufp != cond_bswap((int)buf,bedesc))
    fail(9);
  if (*buf != 0x55)
    fail(10);

  /* Transfer 0 byte control OUT and bulk IN */
  report_subtest(4);

  qh = memalign(16, 2*sizeof(struct uhc_qh));

  qh[0].lp = cond_bswap((int)(qh+1) | TD_Q,bedesc);
  qh[0].elp = cond_bswap((int)td,bedesc);

  qh[1].lp = cond_bswap(TD_T,bedesc);
  qh[1].elp = cond_bswap((int)(td+1),bedesc);

  td[0].lp = cond_bswap(TD_T,bedesc);
  td[0].stat = cond_bswap(TD_ACTIVE,bedesc);
  td[0].token = cond_bswap((0x7FF << TD_MAXLEN_P) | (1 << TD_ENDPT_P) | 
			   TD_PID_SETUP,bedesc);
  td[0].bufp = cond_bswap((int)buf,bedesc);
  
  td[1].lp = cond_bswap(TD_T,bedesc);
  td[1].stat = cond_bswap(TD_IOC | TD_ACTIVE,bedesc);
  td[1].token = cond_bswap((0x7FF << TD_MAXLEN_P) | (1 << TD_ENDPT_P) | 
			   TD_PID_IN,bedesc);
  td[1].bufp = cond_bswap((int)buf,bedesc);

  flbase[0] = cond_bswap((int)qh | TD_Q,bedesc);
  
  regs->usbcmdsts = cond_regswap(UHC_USBCMD_RUNSTOP << 16);
  
  while (!get_usbsts(regs))
    ;

  if (!(get_usbsts(regs) & UHC_USBSTS_USBINT) || (get_usbsts(regs) >> 1))
    fail(0);

  regs->usbcmdsts = cond_regswap(0x0000ffff);

  if (!(get_usbsts(regs) & UHC_USBSTS_HCHALTED))
    fail(1);

  if (td[0].lp != cond_bswap(TD_T,bedesc))
    fail(2);
  if (td[0].stat != cond_bswap(0x7ff,bedesc))
    fail(3);
  if (td[0].token != cond_bswap((0x7FF << TD_MAXLEN_P) | (1 << TD_ENDPT_P) | 
				TD_PID_SETUP,bedesc))
    fail(4);
  if (td[0].bufp != cond_bswap((int)buf,bedesc))
    fail(5);
  if (td[1].lp != cond_bswap(TD_T,bedesc))
    fail(6);
  if (td[1].stat != cond_bswap(TD_IOC | 0x7ff,bedesc))
    fail(7);
  if (td[1].token != cond_bswap((0x7FF << TD_MAXLEN_P) | (1 << TD_ENDPT_P) | 
				TD_PID_IN,bedesc))
    fail(8);
  if (td[1].bufp != cond_bswap((int)buf,bedesc))
    fail(9);
  if (*buf != 0x55)
    fail(10);
  
  if (qh[0].lp != cond_bswap((int)(qh+1) | TD_Q,bedesc))
    fail(11);
  if (qh[0].elp != cond_bswap(TD_T,bedesc))
    fail(12);
  if (qh[1].lp != cond_bswap(TD_T,bedesc))
    fail(13);
  if (qh[1].elp != cond_bswap(TD_T,bedesc))
    fail(14);

  free(td);
  free(qh);
  free(buf);
  free(flbase);

  return 0;
}

/*****************/
/* Complete test */
/*****************/

int grusbhc_test(int ehc_addr, int uhc_addr, int bedesc, int beregs)
{
  if (uhc_addr)
    uhc_test(uhc_addr, bedesc, beregs);

  if (ehc_addr)
    ehc_test(ehc_addr, bedesc, beregs);

  return 0;
}
