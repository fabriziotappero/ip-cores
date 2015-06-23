/*
 * mkmultest.c -- generate multiply test program
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>


unsigned mul(unsigned x, unsigned y) {
  return (unsigned) ((signed) x * (signed) y);
}


unsigned mulu(unsigned x, unsigned y) {
  return x * y;
}


unsigned nums[] = {
  0x00000000,
  0x00000001,
  0x00000002,
  0x00000003,
  0x0000FFFC,
  0x0000FFFD,
  0x0000FFFE,
  0x0000FFFF,
  0x00010000,
  0x00010001,
  0x00010002,
  0x00010003,
  0x7FFFFFFC,
  0x7FFFFFFD,
  0x7FFFFFFE,
  0x7FFFFFFF,
  0x80000000,
  0x80000001,
  0x80000002,
  0x80000003,
  0x8000FFFC,
  0x8000FFFD,
  0x8000FFFE,
  0x8000FFFF,
  0x80010000,
  0x80010001,
  0x80010002,
  0x80010003,
  0xFFFFFFFC,
  0xFFFFFFFD,
  0xFFFFFFFE,
  0xFFFFFFFF,
};

int snums = sizeof(nums) / sizeof(nums[0]);


struct {
  char *name;
  unsigned (*func)(unsigned x, unsigned y);
} ops[] = {
  { "mul",  mul  },
  { "mulu", mulu },
};

int sops = sizeof(ops) / sizeof(ops[0]);


int chooseReg(void) {
  int r;

  r = (rand() >> 8) % 16;
  return r + 8;
}


void chooseRegs(int *r1, int *r2, int *r3, int *r4) {
  *r1 = chooseReg();
  do {
    *r2 = chooseReg();
  } while (*r2 == *r1);
  do {
    *r3 = chooseReg();
  } while (*r3 == *r2 || *r3 == *r1);
  do {
    *r4 = chooseReg();
  } while (*r4 == *r3 || *r4 == *r2 || *r4 == *r1);
}


int newLabel(void) {
  static int lbl = 1000;
  return lbl++;
}


int main(void) {
  int i, j, k;
  unsigned res;
  int r1, r2, r3, r4;
  int lbl;

  printf("\tadd\t$7,$0,'.'\n");
  for (i = 0; i < snums; i++) {
    for (j = 0; j < snums; j++) {
      for (k = 0; k < sops; k++) {
        res = ops[k].func(nums[i], nums[j]);
        chooseRegs(&r1, &r2, &r3, &r4);
        lbl = newLabel();
        printf("\tadd\t$%d,$0,0x%08X\n", r1, nums[i]);
        printf("\tadd\t$%d,$0,0x%08X\n", r2, nums[j]);
        printf("\t%s\t$%d,$%d,$%d\n", ops[k].name, r3, r1, r2);
        printf("\tadd\t$%d,$0,0x%08X\n", r4, res);
        printf("\tbeq\t$%d,$%d,L%d\n", r3, r4, lbl);
        printf("\tadd\t$7,$0,'?'\n");
        printf("L%d:\n", lbl);
      }
    }
  }
  printf("out:\n");
  printf("\tadd\t$6,$0,0xF0300000\n");
  printf("out1:\n");
  printf("\tldw\t$5,$6,8\n");
  printf("\tand\t$5,$5,1\n");
  printf("\tbeq\t$5,$0,out1\n");
  printf("\tstw\t$7,$6,12\n");
  printf("halt:\n");
  printf("\tj\thalt\n");
  return 0;
}
