/*
 * dhry_utils.h -- utility functions
 */

#include "stdarg.h"
#include "iolib.h"

#define HZ	1000	/* 1000 clock ticks per second */

typedef unsigned long clock_t;

typedef struct tms {
  clock_t tms_utime;	/* user time */
  clock_t tms_stime;	/* system time */
  clock_t tms_cutime;	/* user time of children */
  clock_t tms_cstime;	/* system time of children */
};

clock_t times(struct tms *buf);
void *malloc(unsigned size);
