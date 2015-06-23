/*
 * main.c -- the main program
 */


#include "common.h"
#include "lib.h"
#include "start.h"


int main(void) {
  int i, j;
  unsigned int attr, ch;
  unsigned int *p;

  for (i = 0; i < 16; i++) {
    for (j = 0; j < 16; j++) {
      attr = i * 16 + j;
      ch = (attr << 8) | 0x23;
      p = (unsigned int *) 0xF0100000;
      p += 128 * i + 2 * j;
      *p = ch;
    }
  }
  while (1) ;
  return 0;
}
