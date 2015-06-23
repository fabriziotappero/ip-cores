/*
 * main.c -- dump the master boot record of a disk
 */


#include "types.h"
#include "stdarg.h"
#include "iolib.h"
#include "start.h"
#include "idedsk.h"


/**************************************************************/


void error(char *fmt, ...) {
  va_list ap;

  va_start(ap, fmt);
  printf("Error: ");
  vprintf(fmt, ap);
  printf(", halting...\n");
  va_end(ap);
  while (1) ;
}


/**************************************************************/


static char *exceptionCause[32] = {
  /* 00 */  "terminal 0 transmitter interrupt",
  /* 01 */  "terminal 0 receiver interrupt",
  /* 02 */  "terminal 1 transmitter interrupt",
  /* 03 */  "terminal 1 receiver interrupt",
  /* 04 */  "keyboard interrupt",
  /* 05 */  "unknown interrupt",
  /* 06 */  "unknown interrupt",
  /* 07 */  "unknown interrupt",
  /* 08 */  "disk interrupt",
  /* 09 */  "unknown interrupt",
  /* 10 */  "unknown interrupt",
  /* 11 */  "unknown interrupt",
  /* 12 */  "unknown interrupt",
  /* 13 */  "unknown interrupt",
  /* 14 */  "timer 0 interrupt",
  /* 15 */  "timer 1 interrupt",
  /* 16 */  "bus timeout exception",
  /* 17 */  "illegal instruction exception",
  /* 18 */  "privileged instruction exception",
  /* 19 */  "divide instruction exception",
  /* 20 */  "trap instruction exception",
  /* 21 */  "TLB miss exception",
  /* 22 */  "TLB write exception",
  /* 23 */  "TLB invalid exception",
  /* 24 */  "illegal address exception",
  /* 25 */  "privileged address exception",
  /* 26 */  "unknown exception",
  /* 27 */  "unknown exception",
  /* 28 */  "unknown exception",
  /* 29 */  "unknown exception",
  /* 30 */  "unknown exception",
  /* 31 */  "unknown exception"
};


int defaultISR(int irq) {
  printf("\n%s\n", exceptionCause[irq]);
  return 0;  /* do not skip any instruction */
}


void initInterrupts(void) {
  int i;

  for (i = 0; i < 32; i++) {
    setISR(i, defaultISR);
  }
}


/**************************************************************/


Bool checkDiskReady(void) {
  int tries;
  int i;

  for (tries = 0; tries < 10; tries++) {
    for (i = 0; i < 500000; i++) {
      if ((*DISK_CTRL & DISK_CTRL_READY) != 0) {
        return TRUE;
      }
    }
    printf(".");
  }
  return FALSE;
}


unsigned int getDiskSize(void) {
  return *DISK_CAP;
}


Bool readDisk(unsigned int sector,
              unsigned int count,
              unsigned int *addr) {
  unsigned int n;
  unsigned int *p;
  unsigned int i;

  while (count != 0) {
    n = count > 8 ? 8 : count;
    *DISK_SCT = sector;
    *DISK_CNT = n;
    *DISK_CTRL = DISK_CTRL_STRT;
    while ((*DISK_CTRL & DISK_CTRL_DONE) == 0) ;
    if (*DISK_CTRL & DISK_CTRL_ERR) {
      return FALSE;
    }
    p = DISK_BUFFER;
    for (i = 0; i < n * SECTOR_SIZE / sizeof(unsigned int); i++) {
      *addr++ = *p++;
    }
    sector += n;
    count -= n;
  }
  return TRUE;
}


/**************************************************************/


void main(void) {
  unsigned int numSectors;
  unsigned int buffer[SECTOR_SIZE / sizeof(unsigned int)];
  int i, j;
  unsigned char *p, *q;
  unsigned char c;

  /* init interrupts */
  initInterrupts();
  /* check disk ready */
  if (!checkDiskReady()) {
    error("disk not ready");
  }
  /* determine disk size */
  numSectors = getDiskSize();
  printf("Disk has %u (0x%X) sectors.\n",
         numSectors, numSectors);
  if (numSectors < 32) {
    error("disk is too small");
  }
  /* read master boot record */
  if (!readDisk(0, 1, buffer)) {
    error("cannot read master boot record from disk");
  }
  /* dump master boot record */
  p = (unsigned char *) buffer;
  for (i = 0; i < 32; i++) {
    printf("%08X:  ", i * 16);
    q = p;
    for (j = 0; j < 16; j++) {
      c = *q++;
      printf("%02X ", c);
    }
    printf("  ");
    q = p;
    for (j = 0; j < 16; j++) {
      c = *q++;
      if (c >= 32 && c <= 126) {
        printf("%c", c);
      } else {
        printf(".");
      }
    }
    printf("\n");
    p = q;
  }
  /* done */
  printf("Halting...\n");
}
