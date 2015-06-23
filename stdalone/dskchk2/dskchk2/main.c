/*
 * main.c -- start the ball rolling
 */


#include "types.h"
#include "stdarg.h"
#include "iolib.h"
#include "start.h"
#include "idedsk.h"


#define NUM_SECTORS	262144		/* sync with image generator */
#define LINE_SIZE	100


/**************************************************************/


void halt(void) {
  printf("\nHalting...\n");
  while (1) ;
}


void error(char *fmt, ...) {
  va_list ap;

  va_start(ap, fmt);
  printf("Error: ");
  vprintf(fmt, ap);
  printf("\n");
  va_end(ap);
  halt();
}


/**************************************************************/


static unsigned int randomState = 0;


void setRandomSeed(unsigned int seed) {
  randomState = seed;
}


unsigned int nextRandomNumber(void) {
  unsigned int retVal;

  retVal = randomState;
  randomState = randomState * 1103515245 + 12345;
  return retVal;
}


/**************************************************************/


static unsigned int randomSector = 0xDEADBEEF;


unsigned int nextRandomSector(unsigned int numSectors) {
  randomSector = randomSector * 1103515245 + 12345;
  return randomSector % numSectors;
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


#define TIMER_CTRL	((unsigned *) 0xF0000000)
#define TIMER_DIV	((unsigned *) 0xF0000004)


int hundredth = 0;


int clockISR(int irq) {
  *TIMER_CTRL = 2;
  hundredth++;
  return 0;
}


void initClock(void) {
  setISR(14, clockISR);
  *TIMER_DIV = 500000;
  *TIMER_CTRL = 2;
  setMask(1 << 14);
  enable();
}


/**************************************************************/


unsigned int buffer[WPS];


int diskReady(void) {
  unsigned int retry;

  retry = READY_RETRIES;
  while (retry) {
    if (*DISK_CTRL & DISK_CTRL_READY) {
      return 1;
    }
    retry--;
  }
  return 0;
}


int readSector(unsigned int sector, unsigned int *buffer) {
  int i;

  if (!diskReady()) {
    return 0;
  }
  *DISK_SCT = sector;
  *DISK_CNT = 1;
  *DISK_CTRL = *DISK_CTRL & ~(DISK_CTRL_DONE | DISK_CTRL_ERR);
  *DISK_CTRL = *DISK_CTRL | DISK_CTRL_STRT;
  while ((*DISK_CTRL & DISK_CTRL_DONE) == 0) ;
  if (*DISK_CTRL & DISK_CTRL_ERR) {
    return 0;
  }
  for (i = 0; i < WPS; i++) {
    buffer[i] = DISK_BUFFER[i];
  }
  return 1;
}


void check(unsigned int numChecks) {
  unsigned int check;
  unsigned int sectorRequ;
  int i;
  unsigned int sectorRead;
  unsigned int number;
  unsigned int wrong, corrupted;

  wrong = 0;
  corrupted = 0;
  for (check = 0; check < numChecks; check++) {
    sectorRequ = nextRandomSector(NUM_SECTORS);
    if (!readSector(sectorRequ, buffer)) {
      error("cannot read disk");
    }
    sectorRead = buffer[0];
    if (sectorRead != sectorRequ) {
      wrong++;
    }
    setRandomSeed(sectorRead);
    for (i = 0; i < WPS; i++) {
      number = buffer[i];
      if (number != nextRandomNumber()) {
        corrupted++;
        break;
      }
    }
    printf("check #%06d: requ 0x%08x, read 0x%08x, sector %s\n",
           check, sectorRequ, sectorRead,
           i == WPS ? "ok" : "corrupted");
  }
  printf("\nTotal number of sectors: %u read, %u wrong, %u corrupted\n",
         numChecks, wrong, corrupted);
}


/**************************************************************/


void main(void) {
  char line[LINE_SIZE];
  char *p;
  unsigned int numChecks;

  initInterrupts();
  initClock();
  printf("\nIDE disk check\n\n");
  getLine("Please enter number of sectors to check: ", line, LINE_SIZE);
  numChecks = 0;
  p = line;
  while (*p >= '0' && *p <= '9') {
    numChecks = numChecks * 10 + (*p - '0');
    p++;
  }
  check(numChecks);
  halt();
}
