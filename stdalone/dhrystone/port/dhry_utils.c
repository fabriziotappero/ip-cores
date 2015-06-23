/*
 * dhry_utils.c -- utility functions
 */

#include "dhry_utils.h"

/**************************************************************/

clock_t times(struct tms *buf) {
  static int firstCall = 1;
  volatile unsigned int *timerDivisor;
  volatile unsigned int *timerCounter;

  if (firstCall) {
    firstCall = 0;
    timerDivisor = (unsigned int *) 0xF0000004;
    *timerDivisor = 0xFFFFFFFF;
    buf->tms_utime = 0;
    buf->tms_stime = 0;
    buf->tms_cutime = 0;
    buf->tms_cstime = 0;
  } else {
    timerCounter = (unsigned int *) 0xF0000008;
    /* the counter counts in units of 20 nsec */
    /* but we want to count in units of 1 msec */
    buf->tms_utime = (0xFFFFFFFF - *timerCounter) / 50000;
    buf->tms_stime = 0;
    buf->tms_cutime = 0;
    buf->tms_cstime = 0;
  }
  return 0;
}

/**************************************************************/

#define MAX_MALLOC	100

static unsigned int a[MAX_MALLOC];
static unsigned int *p = a;

void *malloc(unsigned size) {
  void *q;

  size = (size + sizeof(unsigned) - 1) / sizeof(unsigned);
  if (p + size > &a[MAX_MALLOC]) {
    return 0;
  }
  q = p;
  p += size;
  return q;
}
