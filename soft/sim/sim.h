#ifndef SIM_H
#define SIM_H
#include <assert.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <time.h>
#include <stdio.h>
#include <sys/types.h>

#include <stdarg.h>

#include "bfd.h"

#include "getopt.h"

/* in io.c */
void nonfatal PARAMS ((const char *));

/* in load.c */
static void read_exe PARAMS ((char *, char *));

#endif

