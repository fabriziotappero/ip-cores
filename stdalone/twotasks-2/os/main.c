/*
 * main.c -- start the ball rolling
 */


#include "stdarg.h"
#include "start.h"


/**************************************************************/


int currentTask;
unsigned int **currentPageDir;
unsigned int *currentStkTop;


/**************************************************************/


unsigned int task0Stack[256];
unsigned int *task0StkTop = task0Stack + 256;


unsigned char task1Code[] = {
  #include "task1.dump"
};

unsigned int task1Stack[256];
unsigned int *task1StkTop = task1Stack + 256;

unsigned int **task1PageDir;


unsigned char task2Code[] = {
  #include "task2.dump"
};

unsigned int task2Stack[256];
unsigned int *task2StkTop = task2Stack + 256;

unsigned int **task2PageDir;


/**************************************************************/


unsigned int pageTablePool[10][1024];
int nextPageTable = 0;


unsigned int *allocPageTable(void) {
  unsigned int *pageTable;
  int i;

  pageTable = pageTablePool[nextPageTable++];
  for (i = 0; i < 1024; i++) {
    pageTable[i] = 0;
  }
  return pageTable;
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


void defaultISR(int irq, unsigned int *registers) {
  printf("\n%s\n", exceptionCause[irq]);
}


void initInterrupts(void) {
  int i;

  for (i = 0; i < 32; i++) {
    setISR(i, defaultISR);
  }
}


/**************************************************************/


unsigned int getNumber(unsigned char *p) {
  return (unsigned int) *(p + 0) << 24 |
         (unsigned int) *(p + 1) << 16 |
         (unsigned int) *(p + 2) <<  8 |
         (unsigned int) *(p + 3) <<  0;
}


unsigned int **loadTask(unsigned char *code,
                        unsigned int physCodeAddr,
                        unsigned int physDataAddr,
                        unsigned int physStackAddr) {
  unsigned int magic;
  unsigned int csize;
  unsigned int dsize;
  unsigned int bsize;
  unsigned char *virtLoadAddr;
  int i;
  unsigned int **pageDir;

  magic = getNumber(code);
  code += sizeof(unsigned int);
  csize = getNumber(code);
  code += sizeof(unsigned int);
  dsize = getNumber(code);
  code += sizeof(unsigned int);
  bsize = getNumber(code);
  code += sizeof(unsigned int);
  if (magic != 0x1AA09232) {
    printf("Error: Load module is not executable!\n");
    while (1) ;
  }
  code += 4 * sizeof(unsigned int);
  printf("(csize = 0x%x, dsize = 0x%x, bsize = 0x%x)\n",
         csize, dsize, bsize);
  virtLoadAddr = (unsigned char *) (0xC0000000 | physCodeAddr);
  for (i = 0; i < csize; i++) {
    *virtLoadAddr++ = *code++;
  }
  virtLoadAddr = (unsigned char *) (0xC0000000 | physDataAddr);
  for (i = 0; i < dsize; i++) {
    *virtLoadAddr++ = *code++;
  }
  for (i = 0; i < bsize; i++) {
    *virtLoadAddr++ = '\0';
  }
  /* allocate a page directory and two page tables */
  pageDir = (unsigned int **) allocPageTable();
  pageDir[0] = allocPageTable();
  pageDir[0][0] = physCodeAddr | 0x01;
  pageDir[0][1] = physDataAddr | 0x03;
  pageDir[511] = allocPageTable();
  pageDir[511][1023] = physStackAddr | 0x03;
  return pageDir;
}


/**************************************************************/


void trapISR(int irq, unsigned int *registers) {
  /* 'putchar' is the only system call yet */
  putchar(registers[4]);
  /* skip the trap instruction */
  registers[30] += 4;
}


/**************************************************************/


void flushTLB(void) {
  unsigned int invalPage;
  int i;

  invalPage = 0xC0000000;
  for (i = 0; i < 32; i++) {
    setTLB(i, invalPage, 0);
    invalPage += (1 << 12);
  }
}


/**************************************************************/


void initTimer(void) {
  unsigned int *timerBase;

  timerBase = (unsigned int *) 0xF0000000;
  *(timerBase + 1) = 50000000;
  *timerBase = 2;
  orMask(1 << 14);
}


int task1Started = 0;
int task2Started = 0;


void timerISR(int irq, unsigned int *registers) {
  unsigned int *timerBase;

  timerBase = (unsigned int *) 0xF0000000;
  *timerBase = 2;
  printf(">|<");
  if (currentTask == 0) {
    if (!task1Started) {
      /* load & start task1 */
      printf("\nOS: loading task1\n");
      task1PageDir = loadTask(task1Code, 64 << 12, 68 << 12, 80 << 12);
      printf("OS: starting task1\n");
      task1Started = 1;
      currentTask = 1;
      currentPageDir = task1PageDir;
      currentStkTop = task1StkTop;
      flushTLB();
      startTask();
    }
  } else if (currentTask == 1) {
    if (!task2Started) {
      /* load & start task2 */
      printf("\nOS: loading task2\n");
      task2PageDir = loadTask(task2Code, 96 << 12, 100 << 12, 112 << 12);
      printf("OS: starting task2\n");
      task2Started = 1;
      currentTask = 2;
      currentPageDir = task2PageDir;
      currentStkTop = task2StkTop;
      flushTLB();
      startTask();
    } else {
      /* switch tasks */
      currentTask = 2;
      currentPageDir = task2PageDir;
      currentStkTop = task2StkTop;
      flushTLB();
    }
  } else if (currentTask == 2) {
    /* switch tasks */
    currentTask = 1;
    currentPageDir = task1PageDir;
    currentStkTop = task1StkTop;
    flushTLB();
  }
}


/**************************************************************/


void main(void) {
  currentTask = 0;
  currentStkTop = task0StkTop;
  printf("\n");
  printf("OS: initializing interrupts\n");
  initInterrupts();
  setISR(20, trapISR);
  setISR(14, timerISR);
  printf("OS: initializing timer\n");
  initTimer();
  printf("OS: waiting for interrupt...\n");
  enable();
  while (1) ;
}
