/*
 * mkshtest.c -- generate shift test program
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#define N0	((unsigned) 0x48E6F0B2)
#define N1	((unsigned) 0xC8E6F0B3)


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


unsigned sar(unsigned n, int shamt) {
  unsigned mask;

  mask = (n & 0x80000000) ? ~((unsigned) 0xFFFFFFFF >> shamt) : 0x00000000;
  return mask | (n >> shamt);
}


int main(void) {
  int shamt;
  int src;
  int sha;
  int dst;
  int ref;
  int lbl;

  printf("\tadd\t$7,$0,'.'\n");
  for (shamt = 0; shamt < 32; shamt++) {
    /* sll, N0 */
    printf("\t; sll, n0\n");
    chooseRegs(&src, &sha, &dst, &ref);
    printf("\tadd\t$%d,$0,0x%08X\n", src, N0);
    printf("\tadd\t$%d,$0,%d\n", sha, shamt);
    printf("\tsll\t$%d,$%d,$%d\n", dst, src, sha);
    printf("\tadd\t$%d,$0,0x%08X\n", ref, N0 << shamt);
    lbl = newLabel();
    printf("\tbeq\t$%d,$%d,L%d\n", dst, ref, lbl);
    printf("\tadd\t$7,$0,'?'\n");
    printf("L%d:\n", lbl);
    /* slli, N0 */
    printf("\t; slli, n0\n");
    chooseRegs(&src, &sha, &dst, &ref);
    printf("\tadd\t$%d,$0,0x%08X\n", src, N0);
    printf("\tsll\t$%d,$%d,%d\n", dst, src, shamt);
    printf("\tadd\t$%d,$0,0x%08X\n", ref, N0 << shamt);
    lbl = newLabel();
    printf("\tbeq\t$%d,$%d,L%d\n", dst, ref, lbl);
    printf("\tadd\t$7,$0,'?'\n");
    printf("L%d:\n", lbl);
    /* sll, N1 */
    printf("\t; sll, n1\n");
    chooseRegs(&src, &sha, &dst, &ref);
    printf("\tadd\t$%d,$0,0x%08X\n", src, N1);
    printf("\tadd\t$%d,$0,%d\n", sha, shamt);
    printf("\tsll\t$%d,$%d,$%d\n", dst, src, sha);
    printf("\tadd\t$%d,$0,0x%08X\n", ref, N1 << shamt);
    lbl = newLabel();
    printf("\tbeq\t$%d,$%d,L%d\n", dst, ref, lbl);
    printf("\tadd\t$7,$0,'?'\n");
    printf("L%d:\n", lbl);
    /* slli, N1 */
    printf("\t; slli, n1\n");
    chooseRegs(&src, &sha, &dst, &ref);
    printf("\tadd\t$%d,$0,0x%08X\n", src, N1);
    printf("\tsll\t$%d,$%d,%d\n", dst, src, shamt);
    printf("\tadd\t$%d,$0,0x%08X\n", ref, N1 << shamt);
    lbl = newLabel();
    printf("\tbeq\t$%d,$%d,L%d\n", dst, ref, lbl);
    printf("\tadd\t$7,$0,'?'\n");
    printf("L%d:\n", lbl);

    /* slr, N0 */
    printf("\t; slr, n0\n");
    chooseRegs(&src, &sha, &dst, &ref);
    printf("\tadd\t$%d,$0,0x%08X\n", src, N0);
    printf("\tadd\t$%d,$0,%d\n", sha, shamt);
    printf("\tslr\t$%d,$%d,$%d\n", dst, src, sha);
    printf("\tadd\t$%d,$0,0x%08X\n", ref, N0 >> shamt);
    lbl = newLabel();
    printf("\tbeq\t$%d,$%d,L%d\n", dst, ref, lbl);
    printf("\tadd\t$7,$0,'?'\n");
    printf("L%d:\n", lbl);
    /* slri, N0 */
    printf("\t; slri, n0\n");
    chooseRegs(&src, &sha, &dst, &ref);
    printf("\tadd\t$%d,$0,0x%08X\n", src, N0);
    printf("\tslr\t$%d,$%d,%d\n", dst, src, shamt);
    printf("\tadd\t$%d,$0,0x%08X\n", ref, N0 >> shamt);
    lbl = newLabel();
    printf("\tbeq\t$%d,$%d,L%d\n", dst, ref, lbl);
    printf("\tadd\t$7,$0,'?'\n");
    printf("L%d:\n", lbl);
    /* slr, N1 */
    printf("\t; slr, n1\n");
    chooseRegs(&src, &sha, &dst, &ref);
    printf("\tadd\t$%d,$0,0x%08X\n", src, N1);
    printf("\tadd\t$%d,$0,%d\n", sha, shamt);
    printf("\tslr\t$%d,$%d,$%d\n", dst, src, sha);
    printf("\tadd\t$%d,$0,0x%08X\n", ref, N1 >> shamt);
    lbl = newLabel();
    printf("\tbeq\t$%d,$%d,L%d\n", dst, ref, lbl);
    printf("\tadd\t$7,$0,'?'\n");
    printf("L%d:\n", lbl);
    /* slri, N1 */
    printf("\t; slri, n1\n");
    chooseRegs(&src, &sha, &dst, &ref);
    printf("\tadd\t$%d,$0,0x%08X\n", src, N1);
    printf("\tslr\t$%d,$%d,%d\n", dst, src, shamt);
    printf("\tadd\t$%d,$0,0x%08X\n", ref, N1 >> shamt);
    lbl = newLabel();
    printf("\tbeq\t$%d,$%d,L%d\n", dst, ref, lbl);
    printf("\tadd\t$7,$0,'?'\n");
    printf("L%d:\n", lbl);

    /* sar, N0 */
    printf("\t; sar, n0\n");
    chooseRegs(&src, &sha, &dst, &ref);
    printf("\tadd\t$%d,$0,0x%08X\n", src, N0);
    printf("\tadd\t$%d,$0,%d\n", sha, shamt);
    printf("\tsar\t$%d,$%d,$%d\n", dst, src, sha);
    printf("\tadd\t$%d,$0,0x%08X\n", ref, sar(N0, shamt));
    lbl = newLabel();
    printf("\tbeq\t$%d,$%d,L%d\n", dst, ref, lbl);
    printf("\tadd\t$7,$0,'?'\n");
    printf("L%d:\n", lbl);
    /* sari, N0 */
    printf("\t; sari, n0\n");
    chooseRegs(&src, &sha, &dst, &ref);
    printf("\tadd\t$%d,$0,0x%08X\n", src, N0);
    printf("\tsar\t$%d,$%d,%d\n", dst, src, shamt);
    printf("\tadd\t$%d,$0,0x%08X\n", ref, sar(N0, shamt));
    lbl = newLabel();
    printf("\tbeq\t$%d,$%d,L%d\n", dst, ref, lbl);
    printf("\tadd\t$7,$0,'?'\n");
    printf("L%d:\n", lbl);
    /* sar, N1 */
    printf("\t; sar, n1\n");
    chooseRegs(&src, &sha, &dst, &ref);
    printf("\tadd\t$%d,$0,0x%08X\n", src, N1);
    printf("\tadd\t$%d,$0,%d\n", sha, shamt);
    printf("\tsar\t$%d,$%d,$%d\n", dst, src, sha);
    printf("\tadd\t$%d,$0,0x%08X\n", ref, sar(N1, shamt));
    lbl = newLabel();
    printf("\tbeq\t$%d,$%d,L%d\n", dst, ref, lbl);
    printf("\tadd\t$7,$0,'?'\n");
    printf("L%d:\n", lbl);
    /* sari, N1 */
    printf("\t; sari, n1\n");
    chooseRegs(&src, &sha, &dst, &ref);
    printf("\tadd\t$%d,$0,0x%08X\n", src, N1);
    printf("\tsar\t$%d,$%d,%d\n", dst, src, shamt);
    printf("\tadd\t$%d,$0,0x%08X\n", ref, sar(N1, shamt));
    lbl = newLabel();
    printf("\tbeq\t$%d,$%d,L%d\n", dst, ref, lbl);
    printf("\tadd\t$7,$0,'?'\n");
    printf("L%d:\n", lbl);
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
