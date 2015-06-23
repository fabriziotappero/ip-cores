/*
 * except.c -- exception handling
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <setjmp.h>

#include "error.h"
#include "except.h"


#define MAX_ENV_NEST_DEPTH	10


static jmp_buf *environments[MAX_ENV_NEST_DEPTH];
static int currentEnvironment = -1;


void throwException(int exception) {
  if (currentEnvironment < 0) {
    error("exception %d thrown while no environment active", exception);
  }
  longjmp(*environments[currentEnvironment], exception);
}


void pushEnvironment(jmp_buf *environment) {
  if (currentEnvironment == MAX_ENV_NEST_DEPTH - 1) {
    error("too many environments active");
  }
  currentEnvironment++;
  environments[currentEnvironment] = environment;
}


void popEnvironment(void) {
  if (currentEnvironment < 0) {
    error("cannot pop environment - none active");
  }
  currentEnvironment--;
}


static char *cause[32] = {
  /*  0 */  "serial line 0 xmt interrupt",
  /*  1 */  "serial line 0 rcv interrupt",
  /*  2 */  "serial line 1 xmt interrupt",
  /*  3 */  "serial line 1 rcv interrupt",
  /*  4 */  "keyboard interrupt",
  /*  5 */  "unknown interrupt",
  /*  6 */  "unknown interrupt",
  /*  7 */  "unknown interrupt",
  /*  8 */  "disk interrupt",
  /*  9 */  "unknown interrupt",
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


char *exceptionToString(int exception) {
  if (exception < 0 ||
      exception >= sizeof(cause)/sizeof(cause[0])) {
    error("exception number out of bounds");
  }
  return cause[exception];
}
