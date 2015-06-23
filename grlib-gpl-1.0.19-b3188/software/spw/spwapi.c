/*****************************************************************************/
/*   This file is a part of the GRLIB VHDL IP LIBRARY */
/*   Copyright (C) 2004 GAISLER RESEARCH */

/*   This program is free software; you can redistribute it and/or modify */
/*   it under the terms of the GNU General Public License as published by */
/*   the Free Software Foundation; either version 2 of the License, or */
/*   (at your option) any later version. */

/*   See the file COPYING for the full details of the license. */
/*****************************************************************************/

#include "spwapi.h"
#include <stdlib.h>

static char *almalloc(int sz)
{
  char *tmp;
  tmp = calloc(1,2*sz);
  tmp = (char *) (((int)tmp+sz) & ~(sz -1));
  return(tmp);
}

static inline int loadmem(int addr)
{
  int tmp;        
  asm(" lda [%1]1, %0 "
      : "=r"(tmp)
      : "r"(addr)
    );
  return tmp;
}

/* static void storemem(int addr, int data)  */
/* { */
/*         asm("sta %0, [%1]1 " */
/*             :  */
/*             : "r"(data), "r"(addr)  */
/*            ); */
/* } */

int spw_setparam(int nodeaddr, int clkdiv, int destkey,
                 int timetxen, int timerxen, int spwadr, 
                 int khz, struct spwvars *spw) 
{
  if ((nodeaddr < 0) || (nodeaddr > 255)) {
    return 1;
  }
  if ((clkdiv < 0) || (clkdiv > 255)) {
    return 1;
  }
  if ((destkey < 0) || (destkey > 255)) {
    return 1;
  }
  if ((timetxen < 0) || (timetxen > 1)) {
    return 1;
  }
  if ((timerxen < 0) || (timerxen > 1)) {
    return 1;
  }
  spw->timetxen = timetxen;
  spw->timerxen = timerxen;
  spw->destkey = destkey;
  spw->nodeaddr = nodeaddr;
  spw->clkdiv = clkdiv;
  spw->khz = khz;
  spw->regs = (struct spwregs *) spwadr;
  return 0;
}

int spw_setparam_dma(int dmachan, int addr, int mask, int nospill, int rxmaxlen, struct spwvars *spw) 
{
  if ((addr < 0) || (addr > 255)) {
    return 1;
  }
  if ((mask < 0) || (mask > 255)) {
    return 1;
  }
  if ((rxmaxlen < 0) || (rxmaxlen > 33554432)) {
    return 1;
  }
  if ((nospill < 0) || (nospill > 1)) {
    return 1;
  }
  spw->dma[dmachan].nospill = nospill;
  spw->dma[dmachan].addr = addr;
  spw->dma[dmachan].mask = mask;
  spw->dma[dmachan].rxmaxlen = rxmaxlen;
  return 0;
}


int spw_init(struct spwvars *spw)
{
  int i;
  int j;
  int tmp;
  /*determine grspw version by checking if timer and disconnect register exists */
  spw->regs->timer = 0xFFFFFF;
  tmp = loadmem((int)&(spw->regs->timer));
  spw->ver = 0;
  if (!tmp) 
          spw->ver = 1;
  tmp = loadmem((int)&(spw->regs->ctrl));
  spw->rmap = (tmp >> 31) & 1;
  spw->rxunaligned = (tmp >> 30) & 1;
  spw->rmapcrc = (tmp >> 29) & 1;
  spw->dmachan = ((tmp >> 27) & 3) + 1;
  spw->regs->nodeaddr = spw->nodeaddr; /*set node address*/
  spw->regs->clkdiv = spw->clkdiv | (spw->clkdivs << 8); /* set clock divisor */
  
  for(i = 0; i < spw->dmachan; i++) {
          spw->regs->dma[i].rxmaxlen = spw->dma[i].rxmaxlen; /*set rx maxlength*/
          if (loadmem((int)&(spw->regs->dma[i].rxmaxlen)) != spw->dma[i].rxmaxlen) {
                  return 1;
          }
  }
  if (spw->khz) 
          spw->regs->timer = ((spw->khz*64)/10000) | ((((spw->khz*850)/1000000)-3) << 12);
  if (spw->rmap == 1) {
    spw->regs->destkey = spw->destkey;
  }
  for(i = 0; i < spw->dmachan; i++) {
          spw->regs->dma[i].ctrl = 0xFFFE01E0; /*clear status, set ctrl for dma chan*/
          if (loadmem((int)&(spw->regs->dma[i].ctrl)) != 0) {
                  return 2;
          }
          /*set tx descriptor pointer*/
          if ((spw->dma[i].txd = (struct txdescriptor *)almalloc(1024)) == NULL) {
                  return 3;
          }
          spw->dma[i].txpnt = 0;
          spw->dma[i].txchkpnt = 0;
          spw->regs->dma[i].txdesc = (int) spw->dma[i].txd;
          /*set rx descriptor pointer*/
          if (( spw->dma[i].rxd = (struct rxdescriptor *)almalloc(1024)) == NULL) {
                  return 4;
          }
          spw->dma[i].rxpnt = 0;
          spw->dma[i].rxchkpnt = 0;
          spw->regs->dma[i].rxdesc = (int) spw->dma[i].rxd;
  }
  spw->regs->status = 0xFFF; /*clear status*/
  spw->regs->ctrl = 0x2 | (spw->timetxen << 10) | (spw->timerxen << 11); /*set ctrl*/
  for(i = 0; i < spw->dmachan; i++) {
          spw->regs->dma[i].ctrl = loadmem((int)&(spw->regs->dma[i].ctrl)) | (spw->dma[i].nospill << 12);
  }
  return 0;
}

int wait_running(struct spwvars *spw) 
{
        int i;
        int j;
        
        j = 0;
        while (((loadmem((int)&(spw->regs->status)) >> 21) & 7) != 5) {
                if (j > 1000) {
                        return 1;
                }
                for(i = 0; i < 1000; i++) {}
		j++;
        }
        return 0;
}

int set_txdesc(int dmachan, int pnt, struct spwvars *spw) 
{
        spw->regs->dma[dmachan].txdesc = pnt;
        spw->dma[dmachan].txpnt = 0;
        spw->dma[dmachan].txchkpnt = 0;
        if (loadmem((int)&(spw->regs->dma[dmachan].txdesc)) != pnt) {
                return 1;
        }
        return 0;
}

int set_rxdesc(int dmachan, int pnt, struct spwvars *spw) 
{
        spw->regs->dma[dmachan].rxdesc = pnt;
        spw->dma[dmachan].rxpnt = 0;
        spw->dma[dmachan].rxchkpnt = 0;
        if (loadmem((int)&(spw->regs->dma[dmachan].rxdesc)) != pnt) {
                return 1;
        }
        return 0;
}

void spw_disable(struct spwvars *spw) 
{
        spw->regs->ctrl = loadmem((int)&(spw->regs->ctrl)) | 1;
}

void spw_enable(struct spwvars *spw) 
{
        spw->regs->ctrl = loadmem((int)&(spw->regs->ctrl)) & 0x20F7E;
}

void spw_start(struct spwvars *spw) 
{
        spw->regs->ctrl = loadmem((int)&(spw->regs->ctrl)) | (1 << 1);
}

void spw_stop(struct spwvars *spw) 
{
        spw->regs->ctrl = loadmem((int)&(spw->regs->ctrl)) & 0x20F7D;
}

int spw_setclockdiv(struct spwvars *spw) 
{
        if ( (spw->clkdiv < 0) || (spw->clkdiv > 255) ) {
                return 1;
        } else {
                spw->regs->clkdiv = spw->clkdiv;
                return 0;
        }
}

int spw_set_nodeadr(struct spwvars *spw) 
{
        if ( (spw->nodeaddr < 0) || (spw->nodeaddr > 255) || 
             (spw->mask < 0) || (spw->mask > 255) ) {
                return 1;
        } else {
                spw->regs->nodeaddr = (spw->nodeaddr & 0xFF) | ((spw->mask & 0xFF) << 8);
                return 0;
        }
}

int spw_set_chanadr(int dmachan, struct spwvars *spw) 
{
        if ( (spw->dma[dmachan].addr < 0) || (spw->dma[dmachan].addr > 255) || 
             (spw->dma[dmachan].mask < 0) || (spw->dma[dmachan].mask > 255) ) {
                return 1;
        } else {
                spw->regs->dma[dmachan].addr = (spw->dma[dmachan].addr & 0xFF) | ((spw->dma[dmachan].mask & 0xFF) << 8);
                return 0;
        }
}

int spw_set_rxmaxlength(int dmachan, struct spwvars *spw) 
{
        if ((spw->dma[dmachan].rxmaxlen < 4) || (spw->dma[dmachan].rxmaxlen > 33554431)) {
                return 1;
        } else {
                spw->regs->dma[dmachan].rxmaxlen = spw->dma[dmachan].rxmaxlen;
                return 0;
        }
}

int spw_tx(int dmachan, int hcrc, int dcrc, int skipcrcsize, int hsize, char *hbuf, int dsize, char *dbuf, struct spwvars *spw) 
{
  if ((dsize < 0) || (dsize > 16777215)) {
    return 6;
  }
  if ((hsize < 0) || (hsize > 255)) {
    return 5;
  }
  if ((dbuf == NULL) || (hbuf == NULL)) {
    return 4;
  }
  if ( (((hcrc == 1) || (dcrc == 1)) && ((spw->rmapcrc | spw->rmap) == 0)) || (hcrc < 0) || (hcrc > 1) || (dcrc < 0) || (dcrc > 1)) {
    return 3;
  } 
  if ((skipcrcsize < 0) || (skipcrcsize > 15) ) {
    return 2;
  }
  if ((loadmem((int)&(spw->dma[dmachan].txd[spw->dma[dmachan].txpnt].ctrl)) >> 12) & 1) {
    return 1;
  }
  spw->dma[dmachan].txd[spw->dma[dmachan].txpnt].haddr = (int)hbuf;
  spw->dma[dmachan].txd[spw->dma[dmachan].txpnt].dlen = dsize;
  spw->dma[dmachan].txd[spw->dma[dmachan].txpnt].daddr = (int)dbuf;
  if (spw->dma[dmachan].txpnt == 63) {
    spw->dma[dmachan].txd[spw->dma[dmachan].txpnt].ctrl = 0x3000 | hsize | (hcrc << 16) | (dcrc << 17) | (skipcrcsize << 8);
    spw->dma[dmachan].txpnt = 0;
  } else {
    spw->dma[dmachan].txd[spw->dma[dmachan].txpnt].ctrl = 0x1000 | hsize | (hcrc << 16) | (dcrc << 17) | (skipcrcsize << 8);
    spw->dma[dmachan].txpnt++;
  }
  spw->regs->dma[dmachan].ctrl = loadmem((int)&(spw->regs->dma[dmachan].ctrl)) & 0xFAAA | 1;
  
  return 0;
}

int spw_rx(int dmachan, char *buf, struct spwvars *spw) 
{
  if (((loadmem((int)&(spw->dma[dmachan].rxd[spw->dma[dmachan].rxpnt].ctrl)) >> 25) & 1)) {
    return 1;
  }
  spw->dma[dmachan].rxd[spw->dma[dmachan].rxpnt].daddr = (int)buf;
  if (spw->dma[dmachan].rxpnt == 127) {
    spw->dma[dmachan].rxd[spw->dma[dmachan].rxpnt].ctrl = 0x6000000;
    spw->dma[dmachan].rxpnt = 0;
  } else {
    spw->dma[dmachan].rxd[spw->dma[dmachan].rxpnt].ctrl = 0x2000000;
    spw->dma[dmachan].rxpnt++;
  }
  spw->regs->dma[dmachan].ctrl = loadmem((int)&(spw->regs->dma[dmachan].ctrl)) & 0xF955 | 2 | (1 << 11);
  return 0;
}

int spw_checkrx(int dmachan, int *size, struct rxstatus *rxs, struct spwvars *spw) 
{
  int tmp;
  tmp = loadmem((int)&(spw->dma[dmachan].rxd[spw->dma[dmachan].rxchkpnt].ctrl));
  if (!((tmp >> 25) & 1)) {
    *size = tmp & 0x1FFFFFF;
    rxs->truncated = (tmp >> 31) & 1;
    rxs->dcrcerr = (tmp >> 30) & 1;
    rxs->hcrcerr = (tmp >> 29) & 1;
    rxs->eep = (tmp >> 28) & 1;
    if (spw->dma[dmachan].rxchkpnt == 127) {
      spw->dma[dmachan].rxchkpnt = 0;
    } else {
      spw->dma[dmachan].rxchkpnt++;
    }
    return 1;
  } else {
    return 0;
  }
}

int spw_checktx(int dmachan, struct spwvars *spw)
{
  int tmp;
  tmp = loadmem((int)&(spw->dma[dmachan].txd[spw->dma[dmachan].txchkpnt].ctrl));
  if (!((tmp >> 12) & 1)) {
    if (spw->dma[dmachan].txchkpnt == 63) {
      spw->dma[dmachan].txchkpnt = 0;
    } else {
      spw->dma[dmachan].txchkpnt++;
    }
    if ((tmp >> 15) & 1) {
      return 2;
    } else {
      return 1;
    }
  } else {
    return 0;
  }
}

void send_time(struct spwvars *spw)
{
  int i;
  while( ((loadmem((int)&(spw->regs->ctrl)) >> 4) & 1)) {
    for(i = 0; i < 16; i++) {}
  }
  spw->regs->ctrl = loadmem((int)&(spw->regs->ctrl)) | (1 << 4);
}

int check_time(struct spwvars *spw) 
{
  int tmp = loadmem((int)&(spw->regs->status)) & 1;
  if (tmp) {
    spw->regs->status = loadmem((int)&(spw->regs->status)) | 1;
  }
  return tmp;
}

int get_time(struct spwvars *spw) 
{
  return (loadmem((int)&(spw->regs->timereg)) & 0x3F );
}

void spw_reset(struct spwvars *spw) 
{
  spw->regs->ctrl = loadmem((int)&(spw->regs->ctrl)) | (1 << 6);
}
        
void spw_rmapen(struct spwvars *spw) 
{
  spw->regs->ctrl = loadmem((int)&(spw->regs->ctrl)) | (1 << 16);
}

void spw_rmapdis(struct spwvars *spw) 
{
  spw->regs->ctrl = loadmem((int)&(spw->regs->ctrl)) & 0xEFFFF;
}

int spw_setdestkey(struct spwvars *spw) 
{
  if ((spw->destkey < 0) || (spw->destkey > 255)) {
    return 1;
  }
  spw->regs->destkey = spw->destkey;
  return 0;
}

void spw_setsepaddr(int dmachan, struct spwvars *spw) 
{
        spw->regs->dma[dmachan].ctrl = loadmem((int)&(spw->regs->dma[dmachan].ctrl)) | (1 << 13);
}

void spw_disablesepaddr(int dmachan, struct spwvars *spw) 
{
        spw->regs->dma[dmachan].ctrl = loadmem((int)&(spw->regs->dma[dmachan].ctrl)) & 0xFFFFDFFF;
}


void spw_enablerx(int dmachan, struct spwvars *spw) 
{
        spw->regs->dma[dmachan].ctrl = loadmem((int)&(spw->regs->dma[dmachan].ctrl)) | 0x2;
}


void spw_disablerx(int dmachan, struct spwvars *spw) 
{
        spw->regs->dma[dmachan].ctrl = loadmem((int)&(spw->regs->dma[dmachan].ctrl)) & 0xFFFFFFFD;
}

