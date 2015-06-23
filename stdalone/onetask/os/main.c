/*
 * main.c -- start the ball rolling
 */


#include "stdarg.h"
#include "start.h"


/**************************************************************/


unsigned char taskCode[] = {
  #include "task.dump"
};


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


void loadTask(unsigned char *code,
              int csize, unsigned int physCodeAddr,
              int dsize, unsigned int physDataAddr,
              int bsize) {
  unsigned char *virtLoadAddr;
  int i;

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


unsigned int getNumber(unsigned char *p) {
  return (unsigned int) *(p + 0) << 24 |
         (unsigned int) *(p + 1) << 16 |
         (unsigned int) *(p + 2) <<  8 |
         (unsigned int) *(p + 3) <<  0;
}


void main(void) {
  unsigned int magic;
  unsigned int csize;
  unsigned int dsize;
  unsigned int bsize;

  printf("\n");
  printf("OS: initializing interrupts\n");
  initInterrupts();
  setISR(20, trapISR);
  /* load code at 256 k, data at (256 + 16) k */
  printf("OS: loading task\n");
  magic = getNumber(taskCode + 0);
  csize = getNumber(taskCode + 4);
  dsize = getNumber(taskCode + 8);
  bsize = getNumber(taskCode + 12);
  if (magic != 0x1AA09232) {
    printf("Error: Load module is not executable!\n");
    while (1) ;
  }
  printf("(csize = 0x%x, dsize = 0x%x, bsize = 0x%x)\n",
         csize, dsize, bsize);
  loadTask(taskCode + 8 * sizeof(unsigned int),
           csize, 64 << 12,
           dsize, 68 << 12,
           bsize);
  printf("OS: presetting TLB\n");
  flushTLB();
  setTLB(5, 0x00000000, 64 << 12 | 0x01);
  setTLB(27, (csize + 0x00000FFF) & 0xFFFFF000, 68 << 12 | 0x03);
  setTLB(22, 0x7FFFF000, 80 << 12 | 0x03);
  printf("OS: starting task\n");
  startTask(80 << 12);  /* stack at (256 + 64) k */
}
