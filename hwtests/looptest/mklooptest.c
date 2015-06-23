/*
 * mklooptest.c -- generate loop test program
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int main(void) {
  int i;

  printf("start:\n");
  for (i = 0; i < 100; i++) {
    printf("\tadd\t$1,$2,$3\n");
    printf("\tadd\t$1,$2,0x5555\n");
    printf("\tsub\t$4,$5,$6\n");
    printf("\tsub\t$4,$5,0xAAAA\n");
    printf("\tand\t$7,$8,$9\n");
    printf("\tand\t$7,$8,0x5555\n");
    printf("\tor\t$10,$11,$12\n");
    printf("\tor\t$10,$11,0xAAAA\n");
    printf("\txor\t$13,$14,$15\n");
    printf("\txor\t$13,$14,0x5555\n");
    printf("\txnor\t$16,$17,$18\n");
    printf("\txnor\t$16,$17,0xAAAA\n");
  }
  printf("\tj\tstart\n");
  return 0;
}
