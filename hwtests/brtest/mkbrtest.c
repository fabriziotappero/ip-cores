/*
 * mkbrtest.c -- generate branch test program
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>


typedef int Bool;


Bool eq(unsigned x, unsigned y) {
  return x == y;
}


Bool ne(unsigned x, unsigned y) {
  return x != y;
}


Bool gt(unsigned x, unsigned y) {
  return (signed) x > (signed) y;
}


Bool ge(unsigned x, unsigned y) {
  return (signed) x >= (signed) y;
}


Bool lt(unsigned x, unsigned y) {
  return (signed) x < (signed) y;
}


Bool le(unsigned x, unsigned y) {
  return (signed) x <= (signed) y;
}


Bool gtu(unsigned x, unsigned y) {
  return x > y;
}


Bool geu(unsigned x, unsigned y) {
  return x >= y;
}


Bool ltu(unsigned x, unsigned y) {
  return x < y;
}


Bool leu(unsigned x, unsigned y) {
  return x <= y;
}


unsigned nums[] = {
  0x00000000,
  0x00000001,
  0x00000002,
  0x00000003,
  0x7FFFFFFC,
  0x7FFFFFFD,
  0x7FFFFFFE,
  0x7FFFFFFF,
  0x80000000,
  0x80000001,
  0x80000002,
  0x80000003,
  0xFFFFFFFC,
  0xFFFFFFFD,
  0xFFFFFFFE,
  0xFFFFFFFF,
};

int snums = sizeof(nums) / sizeof(nums[0]);


struct {
  char *name;
  Bool (*func)(unsigned x, unsigned y);
} ops[] = {
  { "eq",  eq  },
  { "ne",  ne  },
  { "gt",  gt  },
  { "ge",  ge  },
  { "lt",  lt  },
  { "le",  le  },
  { "gtu", gtu },
  { "geu", geu },
  { "ltu", ltu },
  { "leu", leu },
};

int sops = sizeof(ops) / sizeof(ops[0]);


int chooseReg(void) {
  int r;

  r = (rand() >> 8) % 16;
  return r + 8;
}


void chooseRegs(int *r1, int *r2) {
  *r1 = chooseReg();
  do {
    *r2 = chooseReg();
  } while (*r2 == *r1);
}


int newLabel(void) {
  static int lbl = 1000;
  return lbl++;
}


int main(void) {
  int i, j, k;
  Bool res;
  int r1, r2;
  int lbl1, lbl2;

  printf("\tadd\t$7,$0,'.'\n");
  for (i = 0; i < snums; i++) {
    for (j = 0; j < snums; j++) {
      for (k = 0; k < sops; k++) {
        res = ops[k].func(nums[i], nums[j]);
        chooseRegs(&r1, &r2);
        lbl1 = newLabel();
        printf("\tadd\t$%d,$0,0x%08X\n", r1, nums[i]);
        printf("\tadd\t$%d,$0,0x%08X\n", r2, nums[j]);
        printf("\tb%s\t$%d,$%d,L%d\n", ops[k].name, r1, r2, lbl1);
        if (res) {
          printf("\tadd\t$7,$0,'?'\n");
          printf("L%d:\n", lbl1);
        } else {
          lbl2 = newLabel();
          printf("\tj\tL%d\n", lbl2);
          printf("L%d:\n", lbl1);
          printf("\tadd\t$7,$0,'?'\n");
          printf("L%d:\n", lbl2);
        }
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
