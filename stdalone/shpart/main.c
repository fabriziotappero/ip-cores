/*
 * main.c -- show partitions on a disk
 */


#include "types.h"
#include "stdarg.h"
#include "iolib.h"
#include "start.h"
#include "idedsk.h"


#define NPE		(SECTOR_SIZE / sizeof(PartEntry))
#define DESCR_SIZE	20


typedef struct {
  unsigned int type;
  unsigned int start;
  unsigned int size;
  char descr[DESCR_SIZE];
} PartEntry;

PartEntry ptr[NPE];


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


unsigned int getNumber(unsigned char *p) {
  return (unsigned int) *(p + 0) << 24 |
         (unsigned int) *(p + 1) << 16 |
         (unsigned int) *(p + 2) <<  8 |
         (unsigned int) *(p + 3) <<  0;
}


void convertPartitionTable(PartEntry *e, int n) {
  int i;
  unsigned char *p;

  for (i = 0; i < n; i++) {
    p = (unsigned char *) &e[i];
    e[i].type = getNumber(p + 0);
    e[i].start = getNumber(p + 4);
    e[i].size = getNumber(p + 8);
  }
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
  unsigned int partLast;
  int i, j;
  char c;

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
  /* read partition table record */
  if (!readDisk(1, 1, (unsigned int *) ptr)) {
    error("cannot read partition table from disk");
  }
  convertPartitionTable(ptr, NPE);
  /* show partition table */
  printf("Partitions:\n");
  printf(" # b type       start      last       size       description\n");
  for (i = 0; i < NPE; i++) {
    if (ptr[i].type != 0) {
      partLast = ptr[i].start + ptr[i].size - 1;
    } else {
      partLast = 0;
    }
    printf("%2d %s 0x%08X 0x%08X 0x%08X 0x%08X ",
           i,
           ptr[i].type & 0x80000000 ? "*" : " ",
           ptr[i].type & 0x7FFFFFFF,
           ptr[i].start,
           partLast,
           ptr[i].size);
    for (j = 0; j < DESCR_SIZE; j++) {
      c = ptr[i].descr[j];
      if (c == '\0') {
        break;
      }
      if (c >= 0x20 && c < 0x7F) {
        printf("%c", c);
      } else {
        printf(".");
      }
    }
    printf("\n");
  }
  /* done */
  printf("Halting...\n");
}
