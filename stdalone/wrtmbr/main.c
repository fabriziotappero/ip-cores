/*
 * main.c -- start the ball rolling
 */


#include "stdarg.h"
#include "start.h"


#define SCT_SIZE	512		/* in bytes */

#define DISK_BASE	0xF0400000

#define DISK_CTRL	0		/* word offset from DISK_BASE */
#define DISK_CNT	1		/* ditto */
#define DISK_SCT	2		/* ditto */
#define DISK_CAP	3		/* ditto */

#define DISK_BUF_STRT	0x00020000	/* word offset from DISK_BASE */
#define DISK_BUF_SIZE	0x00000400	/* in words */

#define DISK_CTRL_STRT	0x01
#define DISK_CTRL_IEN	0x02
#define DISK_CTRL_WRT	0x04
#define DISK_CTRL_ERR	0x08
#define DISK_CTRL_DONE	0x10
#define DISK_CTRL_RDY	0x20


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


/* the MBR buffer need not be word-aligned */
unsigned char mbr[SCT_SIZE] = {
  #include "mbr/mbr.dump"
};

/* the following two buffers must be word-aligned */
unsigned int wrBuf[SCT_SIZE / sizeof(unsigned int)];
unsigned int rdBuf[SCT_SIZE / sizeof(unsigned int)];


void copyMBR(void) {
  unsigned char *p;
  unsigned char *q;
  int i;

  p = (unsigned char *) wrBuf;
  q = (unsigned char *) mbr;
  for (i = 0; i < SCT_SIZE; i++) {
    *p++ = *q++;
  }
}


int compareMBR(void) {
  unsigned char *p;
  unsigned char *q;
  int i;

  p = (unsigned char *) rdBuf;
  q = (unsigned char *) mbr;
  for (i = 0; i < SCT_SIZE; i++) {
    if (*p++ != *q++) {
      return 0;
    }
  }
  return 1;
}


void clearCtrl(void) {
  unsigned int *p;
  int i;

  p = (unsigned int *) DISK_BASE + DISK_BUF_STRT;
  for (i = 0; i < DISK_BUF_SIZE; i++) {
    *p++ = 0;
  }
}


void copyToCtrl(void) {
  unsigned int *p;
  unsigned int *q;
  int i;

  p = (unsigned int *) DISK_BASE + DISK_BUF_STRT;
  q = (unsigned int *) wrBuf;
  for (i = 0; i < SCT_SIZE / sizeof(unsigned int); i++) {
    *p++ = *q++;
  }
}


void copyFromCtrl(void) {
  unsigned int *p;
  unsigned int *q;
  int i;

  p = (unsigned int *) rdBuf;
  q = (unsigned int *) DISK_BASE + DISK_BUF_STRT;
  for (i = 0; i < SCT_SIZE / sizeof(unsigned int); i++) {
    *p++ = *q++;
  }
}


int checkDiskReady(void) {
  unsigned int *p;
  int tries;
  int i;

  p = (unsigned int *) DISK_BASE;
  for (tries = 0; tries < 10; tries++) {
    for (i = 0; i < 500000; i++) {
      if ((*(p + DISK_CTRL) & DISK_CTRL_RDY) != 0) {
        return 1;
      }
    }
    printf(".");
  }
  return 0;
}


void writeMBR(void) {
  unsigned int *p;

  p = (unsigned int *) DISK_BASE;
  *(p + DISK_CNT) = 1;
  *(p + DISK_SCT) = 0;
  *(p + DISK_CTRL) = DISK_CTRL_WRT | DISK_CTRL_STRT;
  while ((*(p + DISK_CTRL) & DISK_CTRL_DONE) == 0) ;
}


void readMBR(void) {
  unsigned int *p;

  p = (unsigned int *) DISK_BASE;
  *(p + DISK_CNT) = 1;
  *(p + DISK_SCT) = 0;
  *(p + DISK_CTRL) = DISK_CTRL_STRT;
  while ((*(p + DISK_CTRL) & DISK_CTRL_DONE) == 0) ;
}


void main(void) {
  initInterrupts();
  printf("Checking disk ready...");
  if (!checkDiskReady()) {
    printf(" disk not ready\n");
  } else {
    printf(" ok\n");
    printf("Writing MBR...\n");
    copyMBR();
    clearCtrl();
    copyToCtrl();
    writeMBR();
    printf("Reading MBR...\n");
    clearCtrl();
    readMBR();
    copyFromCtrl();
    printf("Comparing MBR...");
    if (!compareMBR()) {
      printf(" error\n");
    } else {
      printf(" ok\n");
    }
  }
  printf("Halting...\n");
}
