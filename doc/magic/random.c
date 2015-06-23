/*
 * random.c -- a random generator to generate magic numbers
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>


unsigned long currentRandom = 0x3AE82DD4;


void nextRandom(void) {
  currentRandom = 3141592621U * currentRandom + 12345;
}


int main(int argc, char *argv[]) {
  int n, i;

  if (argc != 2) {
    printf("Usage: %s <number>\n", argv[0]);
    return 1;
  }
  n = atoi(argv[1]);
  for (i = 0; i < n; i++) {
    printf("%3d: 0x%08lX\n", i, currentRandom);
    nextRandom();
  }
  return 0;
}
