/*
 * biolib.c -- basic I/O library
 */


#include "biolib.h"


char getc(void) {
  unsigned int *base;
  char c;

  base = (unsigned int *) 0xF0300000;
  while ((*(base + 0) & 1) == 0) ;
  c = *(base + 1);
  return c;
}


void putc(char c) {
  unsigned int *base;

  base = (unsigned int *) 0xF0300000;
  while ((*(base + 2) & 1) == 0) ;
  *(base + 3) = c;
}
