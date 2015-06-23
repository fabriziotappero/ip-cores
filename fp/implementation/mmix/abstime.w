\datethis
\def\title{ABSTIME}
@* Intro. This tiny program prints the number of seconds
elapsed since 00:00:00 Greenwich Mean Time
on January 1, 1970. (Greenwich Mean Time is now more properly
called Coordinated Universal Time, or UTC.)

On January 19, 2038, at 03:14:08 UTC,
a 32-bit signed integer will become too small to hold the
desired result. (The number of elapsed seconds will then be $2^{31}$.)
This program will still work on
January 20 of that year if it has been compiled
with a \CEE/ compiler that has type \&{time\_t}
equivalent to \&{long}, provided that \&{long} integers
hold more than 32 bits.

@c
#include <stdio.h>
#include <time.h>
@#
main()
{
  printf("#define ABSTIME %ld\n",time(NULL));
  return 0;
}

