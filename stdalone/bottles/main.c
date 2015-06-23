/*
 * main.c -- main program
 */


#include "types.h"
#include "stdarg.h"
#include "iolib.h"


#define MAX_BEER	99


char *t = "bottle";
char *b = "of beer";
char *w = "on the wall";
char *m = "more";


void beer(int n) {
  char *s;

  s = (n == 1 ? "" : "s");
  printf("%d %s%s %s %s, ", n, t, s, b, w);
  printf("%d %s%s %s.\n", n, t, s, b);
  n--;
  s = (n == 1 ? "" : "s");
  printf("Take one down and pass it around, ");
  if (n == 0) {
    printf("no %s", m);
  } else {
    printf("%d", n);
  }
  printf(" %s%s %s %s.\n\n", t, s, b, w);
}


void main(void) {
  int i;

  for (i = MAX_BEER; i > 0; i--) {
    beer(i);
  }
  printf("No %s %ss %s %s, ", m, t, b, w);
  printf("no %s %ss %s.\n", m, t, b);
  printf("Go to the store and buy some %s, ", m);
  printf("%d %ss %s %s.\n", MAX_BEER, t, b, w);
}
