/*
 * main.c -- start the ball rolling
 */


#include "stdarg.h"
#include "start.h"
#include "idedsk.h"


#define NUM_SECTORS	500
#define SECTOR_RANGE	8000

#define NUM_BLOCKS	300
#define BLOCK_RANGE	1000


/**************************************************************/


#define RAND_MAX	0x7FFF


static unsigned int randomNumber = 1;


void srand(int seed) {
  randomNumber = seed;
}


int rand(void) {
  randomNumber = randomNumber * 1103515245 + 12345;
  return (unsigned int)(randomNumber >> 16) & RAND_MAX;
}


/**************************************************************/


void putchar(char c) {
  unsigned int *base;

  if (c == '\n') {
    putchar('\r');
  }
  base = (unsigned int *) 0xF0300000;
  while ((*(base + 2) & 1) == 0) ;
  *(base + 3) = c;
}


void puts(char *s) {
  char c;

  while ((c = *s++) != '\0') {
    putchar(c);
  }
}


void printn(int n) {
  int a;

  if (n < 0) {
    putchar('-');
    n = -n;
  }
  a = n / 10;
  if (a != 0) {
    printn(a);
  }
  putchar(n % 10 + '0');
}


void printu(unsigned int n, unsigned int b) {
  unsigned int a;

  a = n / b;
  if (a != 0) {
    printu(a, b);
  }
  putchar("0123456789ABCDEF"[n % b]);
}


void printf(char *fmt, ...) {
  va_list ap;
  char c;
  int n;
  unsigned int u;
  char *s;

  va_start(ap, fmt);
  while (1) {
    while ((c = *fmt++) != '%') {
      if (c == '\0') {
        va_end(ap);
        return;
      }
      putchar(c);
    }
    c = *fmt++;
    if (c == 'd') {
      n = va_arg(ap, int);
      printn(n);
    } else
    if (c == 'u' || c == 'o' || c == 'x') {
      u = va_arg(ap, int);
      printu(u, c == 'o' ? 8 : (c == 'x' ? 16 : 10));
    } else
    if (c == 's') {
      s = va_arg(ap, char *);
      puts(s);
    } else {
      putchar(c);
    }
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


void checkDisk1(void) {
  unsigned res;

  printf("\nIs the disk present?\n");
  res = *DISK_CTRL;
  printf("yes, CTRL = 0x%x\n", res);
}


void checkDisk2(void) {
  int start;
  int ready;

  printf("\nDoes the disk get ready?\n");
  start = hundredth;
  ready = 0;
  while (start + 10 * 100 > hundredth) {
    if (*DISK_CTRL & DISK_CTRL_READY) {
      ready = hundredth;
      break;
    }
  }
  if (ready == 0) {
    printf("disk did not get ready\n");
  } else {
    printf("disk got ready after %d/100 seconds\n", ready - start);
  }
}


void checkDisk3(void) {
  int errors;
  int seed;
  unsigned int *p;
  int i, j;

  printf("\nDisk sector buffer read/write\n");
  errors = 0;
  srand(321);
  for (i = 0; i < NUM_SECTORS; i++) {
    seed = rand();
    srand(seed);
    p = DISK_BUFFER;
    for (j = 0; j < WPS; j++) {
      *p++ = rand();
    }
    srand(seed);
    p = DISK_BUFFER;
    for (j = 0; j < WPS; j++) {
      if (*p++ != rand()) {
        errors++;
        break;
      }
    }
  }
  printf("%d errors in %d sectors\n", errors, NUM_SECTORS);
}


void checkDisk4(void) {
  int sector;
  unsigned int *p;
  int i, j;
  int start, done;
  int errors;

  printf("\nRandom sector read/write, polled\n");
  printf("writing...\n");
  srand(321);
  for (i = 0; i < NUM_SECTORS; i++) {
    sector = rand() % SECTOR_RANGE;
    p = DISK_BUFFER;
    for (j = 0; j < WPS; j++) {
      *p++ = sector + j;
    }
    *DISK_SCT = sector;
    *DISK_CNT = 1;
    *DISK_CTRL = *DISK_CTRL
                 & ~(DISK_CTRL_DONE | DISK_CTRL_ERR)
                 | (DISK_CTRL_WRT | DISK_CTRL_STRT);
    start = hundredth;
    done = 0;
    while (start + 2 * 100 > hundredth) {
      if (*DISK_CTRL & DISK_CTRL_DONE) {
        done = hundredth;
        break;
      }
    }
    if (done == 0) {
      printf("disk did not complete a sector write command\n");
      return;
    }
  }
  printf("reading...\n");
  errors = 0;
  srand(321);
  for (i = 0; i < NUM_SECTORS; i++) {
    sector = rand() % SECTOR_RANGE;
    *DISK_SCT = sector;
    *DISK_CNT = 1;
    *DISK_CTRL = *DISK_CTRL
                 & ~(DISK_CTRL_DONE | DISK_CTRL_ERR | DISK_CTRL_WRT)
                 | DISK_CTRL_STRT;
    start = hundredth;
    done = 0;
    while (start + 2 * 100 > hundredth) {
      if (*DISK_CTRL & DISK_CTRL_DONE) {
        done = hundredth;
        break;
      }
    }
    if (done == 0) {
      printf("disk did not complete a sector read command\n");
      return;
    }
    p = DISK_BUFFER;
    for (j = 0; j < WPS; j++) {
      if (*p++ != sector + j) {
        errors++;
        break;
      }
    }
  }
  printf("%d errors in %d sectors (range 0..%d)\n",
         errors, NUM_SECTORS, SECTOR_RANGE);
}


void checkDisk5(void) {
  int errors;
  int seed;
  unsigned int *p;
  int i, j;

  printf("\nDisk block buffer read/write\n");
  errors = 0;
  srand(321);
  for (i = 0; i < NUM_BLOCKS; i++) {
    seed = rand();
    srand(seed);
    p = DISK_BUFFER;
    for (j = 0; j < WPB; j++) {
      *p++ = rand();
    }
    srand(seed);
    p = DISK_BUFFER;
    for (j = 0; j < WPB; j++) {
      if (*p++ != rand()) {
        errors++;
        break;
      }
    }
  }
  printf("%d errors in %d blocks\n", errors, NUM_BLOCKS);
}


void checkDisk6(void) {
  int block;
  unsigned int *p;
  int i, j;
  int start, done;
  int errors;

  printf("\nRandom block read/write, polled\n");
  printf("writing...\n");
  srand(321);
  for (i = 0; i < NUM_BLOCKS; i++) {
    block = rand() % BLOCK_RANGE;
    p = DISK_BUFFER;
    for (j = 0; j < WPB; j++) {
      *p++ = block + j;
    }
    *DISK_SCT = 8 * block;
    *DISK_CNT = 8;
    *DISK_CTRL = *DISK_CTRL
                 & ~(DISK_CTRL_DONE | DISK_CTRL_ERR)
                 | (DISK_CTRL_WRT | DISK_CTRL_STRT);
    start = hundredth;
    done = 0;
    while (start + 2 * 100 > hundredth) {
      if (*DISK_CTRL & DISK_CTRL_DONE) {
        done = hundredth;
        break;
      }
    }
    if (done == 0) {
      printf("disk did not complete a block write command\n");
      return;
    }
  }
  printf("reading...\n");
  errors = 0;
  srand(321);
  for (i = 0; i < NUM_BLOCKS; i++) {
    block = rand() % BLOCK_RANGE;
    *DISK_SCT = 8 * block;
    *DISK_CNT = 8;
    *DISK_CTRL = *DISK_CTRL
                 & ~(DISK_CTRL_DONE | DISK_CTRL_ERR | DISK_CTRL_WRT)
                 | DISK_CTRL_STRT;
    start = hundredth;
    done = 0;
    while (start + 2 * 100 > hundredth) {
      if (*DISK_CTRL & DISK_CTRL_DONE) {
        done = hundredth;
        break;
      }
    }
    if (done == 0) {
      printf("disk did not complete a block read command\n");
      return;
    }
    p = DISK_BUFFER;
    for (j = 0; j < WPB; j++) {
      if (*p++ != block + j) {
        errors++;
        break;
      }
    }
  }
  printf("%d errors in %d blocks (range 0..%d)\n",
         errors, NUM_BLOCKS, BLOCK_RANGE);
}


/**************************************************************/


void main(void) {
  initInterrupts();
  initClock();
  checkDisk1();
  checkDisk2();
  checkDisk3();
  checkDisk4();
  checkDisk5();
  checkDisk6();
  printf("\nHalting...\n");
}
