#include "testmod.h"
#include <stdlib.h>

struct spwregs 
{
   volatile int ctrl;
   volatile int status;
   volatile int nodeaddr;
   volatile int clkdiv;
   volatile int destkey;
   volatile int time;
   volatile int unused[2];
   volatile int dmactrl;
   volatile int rxmaxlen;
   volatile int txdesc;
   volatile int rxdesc;
};

static int snoopen;

static char *almalloc(int sz)
{
  char *tmp;
  tmp = (char *) malloc(2*sz);
  tmp = (char *) (((int)tmp+sz) & ~(sz -1));
  return(tmp);
}

static inline int loadmem(int addr)
{
  int tmp;        
  if (snoopen) {
    asm volatile (" ld [%1], %0 "
      : "=r"(tmp)
      : "r"(addr)
    );
  } else {
    asm volatile (" lda [%1]1, %0 "
      : "=r"(tmp)
      : "r"(addr)
    );
  }
  return tmp;
}

static inline char loadb(int addr)
{
  char tmp;        
  if (snoopen) {
    asm volatile (" ldub [%1], %0 "
      : "=r"(tmp)
      : "r"(addr)
    );
  } else {
    asm volatile (" lduba [%1]1, %0 "
      : "=r"(tmp)
      : "r"(addr)
    );
  }
  return tmp;
}

int spw_test(int addr)
{
  int i;
  int rmapaddr;
  int  *tmp;
  int  *size;
  volatile char *rx;
  volatile char *tx;
  volatile char *rmap;
  volatile char *rmaphdr;
  volatile int *rxd;
  volatile int *txd;
  
  struct spwregs *regs;

  report_device(0x0101F000);
  snoopen = rsysreg(0) & (1 << 23);

  if (snoopen) report_subtest(SPW_SNOOP_TEST);
  else report_subtest(SPW_NOSNOOP_TEST);

  regs = (struct spwregs *) addr;
  rx = (char *) malloc(64);
  tx = (char *) malloc(64);
  rmaphdr = (char *) malloc(32);
  rmap = (char *) malloc(64);
  rxd = (int *) almalloc(1024);
  txd = (int *) almalloc(1024);
  size = (int *) malloc(sizeof(int));
  
  /*reset link */
  regs->ctrl = (1 << 6);

  /*initiate registers*/
  regs->ctrl = 0x2;
  regs->ctrl = 0x2;
  regs->status = 0xFFFFFFFF;
  regs->nodeaddr = 0xFE;
  regs->clkdiv = 0;
  regs->destkey = 0;
  regs->time = 0;
  regs->dmactrl = 0x01E0;
  regs->rxmaxlen = 1024;
  regs->txdesc = 0;
  regs->rxdesc = 0;
  
  while(((loadmem((int)&regs->status) >> 21) & 7) != 5) {}

  /*check dma channel*/
  tmp = (int *) rx;
  for (i = 0; i < 64/sizeof(int); i++) {
    tmp[i] = 0;
  }
  tmp = (int *) tx;
  for (i = 0; i < 64/sizeof(int); i++) {
    tmp[i] = 0;
  }
  tmp = (int *) rmap;
  for (i = 0; i < 64/sizeof(int); i++) {
    tmp[i] = 0;
  }
  tmp = (int *) rmaphdr;
  for (i = 0; i < 32/sizeof(int); i++) {
    tmp[i] = 0;
  }
  for (i = 0; i < 8; i++) {
    txd[i] = 0;
  }
  for (i = 0; i < 8; i++) {
    rxd[i] = 0;
  }
  for(i = 1; i < 64; i++) {
    tx[i] = (char) i;
  }
  tx[0] = (char) 0xFE;

  rxd[1] = (int) rx;
  rxd[0] = (1 << 26) | (1 << 25);

  txd[4] = 0;
  txd[3] = (int)tx;
  txd[2] = 32;
  txd[1] = 0;
  txd[0] = (1 << 13) | (1 << 12);
  
  regs->txdesc = (int) txd;
  regs->rxdesc = (int) rxd;
  
  regs->dmactrl = 0x19E3;
  
  while((loadmem((int)&rxd[0]) >> 25) & 1) {}
  
  if (!((loadmem((int)&regs->dmactrl) >> 6) & 1)) {
    fail(3);
  }
  if (!((loadmem((int)&regs->dmactrl) >> 5) & 1)) {
    fail(4);
  }
  if ((loadmem((int)&regs->dmactrl) & 1)) {
    fail(5);
  }
  
  for(i = 0; i < 32; i++) {
    if (loadb((int)&rx[i]) != tx[i]) {
      fail(6);
    }
  }
  
  /*check rmap*/
  rmapaddr = (int) rmap;
  if ((loadmem((int)&regs->ctrl) >> 31) & 1) {
    report_subtest(SPW_RMAP_TEST);
    regs->ctrl = loadmem((int)&regs->ctrl) | (1 << 16);
    rmaphdr[0] = 0xFE;
    rmaphdr[1] = 1;
    rmaphdr[2] = 0x6C;
    rmaphdr[3] = 0;
    rmaphdr[4] = 0xFE;
    rmaphdr[5] = 0;
    rmaphdr[6] = 0;
    rmaphdr[7] = 0;
    rmaphdr[8] = (rmapaddr >> 24) & 0xFF;
    rmaphdr[9] = (rmapaddr >> 16) & 0xFF;
    rmaphdr[10] = (rmapaddr >> 8) & 0xFF;
    rmaphdr[11] = rmapaddr & 0xFF;
    rmaphdr[12] = 0;
    rmaphdr[13] = 0;
    rmaphdr[14] = 64;

    rxd[0] = (1 << 26) | (1 << 25);
    txd[2] = 64;
    txd[1] = (int) rmaphdr;
    txd[0] = (1 << 13) | (1 << 12) | 15 | (1 << 16) | (1 << 17);
    regs->dmactrl = 0x19E3;
    
    while((loadmem((int)&rxd[0]) >> 25) & 1) {}
    
    for(i = 0; i < 64; i++) {
      if (loadb((int)&rmap[i]) != tx[i]) {
        fail(7);
      }
    }
    
    rmaphdr[0] = 0xFE;
    rmaphdr[1] = 1;
    rmaphdr[2] = 0x2C;
    rmaphdr[3] = 0;
    rmaphdr[4] = 0xFE;
    rmaphdr[5] = 0;
    rmaphdr[6] = 0;
    
    if ((rxd[0] & 0x1FFFFFF) != 8) {
      fail(7);
    }
    
    for(i = 0; i < 7; i++) {
      if (loadb((int)&rx[i]) != rmaphdr[i]) {
        fail(8);
      }
    }

  }

  /*check time interface*/
  report_subtest(SPW_TIME_TEST);
  regs->ctrl = loadmem((int)&regs->ctrl) | (1 << 11) | (1 << 10);
  regs->ctrl = loadmem((int)&regs->ctrl) | (1 << 4);
  
  while((loadmem((int)&regs->ctrl) >> 4) & 1) {}
  
  if ((loadmem((int)&regs->status) & 1)) {
    fail(1);
  }
  if ((loadmem((int)&regs->time) & 0xFF) != 1) {
    fail(2);
  }

  return 0;
}
