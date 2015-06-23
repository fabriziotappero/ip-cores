/*
 * main.c -- the main program
 */


#include "common.h"
#include "lib.h"
#include "start.h"


int charAvail = 0;
char charRead;


/**************************************************************/


/*
 * Interrupt and exception messages which will be shown if
 * the corresponding interrupt or exception is not handled.
 */
char *exceptionCause[32] = {
  /* 00 */  "terminal 0 transmitter interrupt",
  /* 01 */  "terminal 0 receiver interrupt",
  /* 02 */  "terminal 1 transmitter interrupt",
  /* 03 */  "terminal 1 receiver interrupt",
  /* 04 */  "keyboard interrupt",
  /* 05 */  "unknown interrupt 5",
  /* 06 */  "unknown interrupt 6",
  /* 07 */  "unknown interrupt 7",
  /* 08 */  "disk interrupt",
  /* 09 */  "unknown interrupt 9",
  /* 10 */  "unknown interrupt 10",
  /* 11 */  "unknown interrupt 11",
  /* 12 */  "unknown interrupt 12",
  /* 13 */  "unknown interrupt 13",
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
  /* 26 */  "unknown exception 26",
  /* 27 */  "unknown exception 27",
  /* 28 */  "unknown exception 28",
  /* 29 */  "unknown exception 29",
  /* 30 */  "unknown exception 30",
  /* 31 */  "unknown exception 31"
};


/*
 * This is the default interrupt service routine.
 * It simply panics with a message that tells the cause.
 */
void defaultISR(int irq, InterruptContext *icp) {
  printf("**** %s ****\n", exceptionCause[irq]);
  while (1) ;
}


/*
 * Initialize all interrupts and exceptions to the default ISR.
 * Enable interrupts.
 */
void initInterrupts(void) {
  int i;

  for (i = 0; i < 32; i++) {
    setISR(i, defaultISR);
  }
  enable();
}


/**************************************************************/


void kbdISR(int irq, InterruptContext *icp) {
  unsigned int *p;

  p = (unsigned int *) 0xF0200000;
  charRead = *(p + 1);
  charAvail = 1;
}


void kbdEnable(void) {
  unsigned int *p;

  p = (unsigned int *) 0xF0200000;
  *p = 2;
}


int main(void) {
  unsigned char c;
  int n;

  printf("Keyboard Test:\n");
  printf("initializing interrupts...\n");
  initInterrupts();
  printf("setting kbd ISR...\n");
  setISR(4, kbdISR);
  printf("enabling kbd interrupt mask bit...\n");
  setMask(getMask() | (1 << 4));
  printf("enabling interrupts in kbd controller...\n");
  kbdEnable();
  n = 0;
  while (1) {
    while (charAvail == 0) ;
    disable();
    c = charRead;
    charAvail = 0;
    enable();
    printf("%02X ", c);
    if (++n == 24) {
      n = 0;
      printf("\n");
    }
  }
  return 0;
}
