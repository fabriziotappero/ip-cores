/*
 * main.c -- the main program
 */


#include "common.h"
#include "lib.h"
#include "start.h"


Word userMissTaken;


static InterruptContext initial = {
  /* regs */
  0x00000011, 0x11111112, 0x22222213, 0x33333314,
  0x44444415, 0x55555516, 0x66666617, 0x77777718,
  0x88888819, 0x9999991A, 0xAAAAAA1B, 0xBBBBBB1C,
  0xCCCCCC1D, 0xDDDDDD1E, 0xEEEEEE1F, 0xFFFFFF10,
  0x00000021, 0x11111122, 0x22222223, 0x33333324,
  0x44444425, 0x55555526, 0x66666627, 0x77777728,
  0x88888829, 0x9999992A, 0xAAAAAA2B, 0xBBBBBB2C,
  0xCCCCCC2D, 0xDDDDDD2E, 0xEEEEEE2F, 0xFFFFFF20,
  /* PSW */
  0x03FF5678,
  /* TLB index */
  0x87654321,
  /* TLB EntryHi */
  0x9ABCDEF0,
  /* TLB EntryLo */
  0x0FEDCBA9,
  /* bad address */
  0xDEADBEEF,
};

static InterruptContext ic;


static char *errorMessage[] = {
  /*  0 */  "no error",
  /*  1 */  "general register clobbered",
  /*  2 */  "write to register 0 succeeded",
  /*  3 */  "locus of exception incorrect",
  /*  4 */  "TLB register clobbered",
  /*  5 */  "vector bit incorrect",
  /*  6 */  "user mode bits incorrect",
  /*  7 */  "interrupt enable bits incorrect",
  /*  8 */  "wrong exception number",
  /*  9 */  "interrupt mask bits clobbered",
  /* 10 */  "ISR entry was 'user miss'",
  /* 11 */  "ISR entry was not 'user miss'",
  /* 12 */  "bad address register clobbered",
  /* 13 */  "bad address register incorrect",
};


static void flushTLB(void) {
  Word invalPage;
  int i;

  invalPage = 0xC0000000;
  for (i = 0; i < 32; i++) {
    setTLB(i, invalPage, 0);
    invalPage += (1 << 12);
  }
}


static void check(unsigned int *res1, unsigned int *res2,
                  Word expectedEntryHi) {
  int i;

  *res1 = 0;
  *res2 = 0;
  for (i = 0; i < 32; i++) {
    if (ic.reg[i] != initial.reg[i]) {
      *res1 |= (1 << i);
    }
  }
  if ((ic.psw & 0x0FFFFFFF) != (initial.psw & 0x0FFFFFFF)) {
    *res2 |= (1 << 0);
  }
  if ((ic.tlbIndex & 0x0000001F) != (initial.tlbIndex & 0x0000001F)) {
    *res2 |= (1 << 1);
  }
  if ((ic.tlbHi & 0xFFFFF000) != (expectedEntryHi & 0xFFFFF000)) {
    *res2 |= (1 << 2);
  }
  if ((ic.tlbLo & 0x3FFFF003) != (initial.tlbLo & 0x3FFFF003)) {
    *res2 |= (1 << 3);
  }
}


static int execTest(void (*run)(InterruptContext *icp),
                    Word *expectedLocus,
                    int expectedException,
                    Bool execInUserMode,
                    Bool clobberEntryHi,
                    Bool shouldTakeUserMiss,
                    Bool shouldSetBadAddr,
                    Word expectedBadAddr) {
  unsigned int res1, res2;
  int result;
  Word *locus;
  Word badAddr;

  if (execInUserMode) {
    initial.psw |= 1 << 26;
  }
  ic = initial;
  flushTLB();
  userMissTaken = 0xFFFFFFFF;
  (*run)(&ic);
  if (execInUserMode) {
    locus = (Word *) (0xC0000000 | ic.reg[30]);
  } else {
    locus = (Word *) ic.reg[30];
  }
  badAddr = ic.badAddr;
  if (!clobberEntryHi) {
    check(&res1, &res2, initial.tlbHi);
  } else {
    if (shouldTakeUserMiss) {
      check(&res1, &res2, initial.reg[3]);
    } else {
      check(&res1, &res2, initial.reg[11]);
    }
  }
  result = 0;
  if (((ic.psw >> 16) & 0x1F) != expectedException) {
    result = 8;
  } else
  if (!shouldTakeUserMiss && userMissTaken != 0) {
    result = 10;
  } else
  if (shouldTakeUserMiss && userMissTaken != (Word) &userMissTaken) {
    result = 11;
  } else
  if (res1 != 0x50000001) {
    result = 1;
  } else
  if (ic.reg[0] != 0x00000000) {
    result = 2;
  } else
  if (locus != expectedLocus) {
    result = 3;
  } else
  if (!shouldSetBadAddr && badAddr != initial.badAddr) {
    result = 12;
  } else
  if (shouldSetBadAddr && badAddr != expectedBadAddr) {
    result = 13;
  } else
  if (res2 != 0x00000001) {
    result = 4;
  } else
  if (((ic.psw >> 27) & 0x01) != ((initial.psw >> 27) & 0x01)) {
    result = 5;
  } else
  if (((ic.psw >> 24) & 0x07) != ((initial.psw >> 25) & 0x03)) {
    result = 6;
  } else
  if (((ic.psw >> 21) & 0x07) != ((initial.psw >> 22) & 0x03)) {
    result = 7;
  } else
  if (((ic.psw >>  0) & 0xFF) != ((initial.psw >>  0) & 0xFF)) {
    result = 9;
  }
  if (execInUserMode) {
    initial.psw &= ~((unsigned) 1 << 26);
  }
  return result;
}


static struct {
  char *name;
  void (*run)(InterruptContext *icp);
  Word *locus;
  int exception;
  Bool execInUserMode;
  Bool clobberEntryHi;
  Bool shouldTakeUserMiss;
  Bool shouldSetBadAddr;
  Word expectedBadAddr;
} tests[] = {
  { "Trap instr test:\t\t\t",
    xtest1,  &xtest1x,  20, false, false, false, false, 0 },
  { "Illegal instr test:\t\t\t",
    xtest2,  &xtest2x,  17, false, false, false, false, 0 },
  { "Divide instr test 1 (div):\t\t",
    xtest3,  &xtest3x,  19, false, false, false, false, 0 },
  { "Divide instr test 2 (divi):\t\t",
    xtest4,  &xtest4x,  19, false, false, false, false, 0 },
  { "Divide instr test 3 (divu):\t\t",
    xtest5,  &xtest5x,  19, false, false, false, false, 0 },
  { "Divide instr test 4 (divui):\t\t",
    xtest6,  &xtest6x,  19, false, false, false, false, 0 },
  { "Divide instr test 5 (rem):\t\t",
    xtest7,  &xtest7x,  19, false, false, false, false, 0 },
  { "Divide instr test 6 (remi):\t\t",
    xtest8,  &xtest8x,  19, false, false, false, false, 0 },
  { "Divide instr test 7 (remu):\t\t",
    xtest9,  &xtest9x,  19, false, false, false, false, 0 },
  { "Divide instr test 8 (remui):\t\t",
    xtest10, &xtest10x, 19, false, false, false, false, 0 },
  { "Bus timeout test 1 (fetch):\t\t",
    xtest11, &xtest11x, 16, false, false, false, false, 0 },
  { "Bus timeout test 2 (load):\t\t",
    xtest12, &xtest12x, 16, false, false, false, false, 0 },
  { "Bus timeout test 3 (store):\t\t",
    xtest13, &xtest13x, 16, false, false, false, false, 0 },
  { "Privileged instr test 1 (rfx):\t\t",
    xtest14, &xtest14x, 18, true,  false, false, false, 0 },
  { "Privileged instr test 2 (mvts):\t\t",
    xtest15, &xtest15x, 18, true,  false, false, false, 0 },
  { "Privileged instr test 3 (tb..):\t\t",
    xtest16, &xtest16x, 18, true,  false, false, false, 0 },
  { "Privileged address test 1 (fetch):\t",
    xtest17, &xtest17x, 25, true,  false, false, true,  0xffffff10 },
  { "Privileged address test 2 (load):\t",
    xtest18, &xtest18x, 25, true,  false, false, true,  0xffffff10 },
  { "Privileged address test 3 (store):\t",
    xtest19, &xtest19x, 25, true,  false, false, true,  0xffffff10 },
  { "Illegal address test 1 (fetch):\t\t",
    xtest20, &xtest20x, 24, false, false, false, true,  0x11111122 },
  { "Illegal address test 2 (fetch):\t\t",
    xtest21, &xtest21x, 24, false, false, false, true,  0x00000021 },
  { "Illegal address test 3 (ldw):\t\t",
    xtest22, &xtest22x, 24, false, false, false, true,  0xffffff12 },
  { "Illegal address test 4 (ldw):\t\t",
    xtest23, &xtest23x, 24, false, false, false, true,  0xffffff11 },
  { "Illegal address test 5 (ldh):\t\t",
    xtest24, &xtest24x, 24, false, false, false, true,  0xffffff11 },
  { "Illegal address test 6 (stw):\t\t",
    xtest25, &xtest25x, 24, false, false, false, true,  0xffffff12 },
  { "Illegal address test 7 (stw):\t\t",
    xtest26, &xtest26x, 24, false, false, false, true,  0xffffff11 },
  { "Illegal address test 8 (sth):\t\t",
    xtest27, &xtest27x, 24, false, false, false, true,  0xffffff11 },
  { "TLB user miss test 1 (fetch):\t\t",
    xtest28, &xtest28x, 21, false, true,  true,  true,  0x33333314 },
  { "TLB user miss test 2 (load):\t\t",
    xtest29, &xtest29x, 21, false, true,  true,  true,  0x33333314 },
  { "TLB user miss test 3 (store):\t\t",
    xtest30, &xtest30x, 21, false, true,  true,  true,  0x33333314 },
  { "TLB kernel miss test 1 (fetch):\t\t",
    xtest31, &xtest31x, 21, false, true,  false, true,  0xbbbbbb1c },
  { "TLB kernel miss test 2 (load):\t\t",
    xtest32, &xtest32x, 21, false, true,  false, true,  0xbbbbbb1c },
  { "TLB kernel miss test 3 (store):\t\t",
    xtest33, &xtest33x, 21, false, true,  false, true,  0xbbbbbb1c },
  { "TLB invalid test 1 (fetch):\t\t",
    xtest34, &xtest34x, 23, false, true,  false, true,  0xbbbbbb1c },
  { "TLB invalid test 2 (load):\t\t",
    xtest35, &xtest35x, 23, false, true,  false, true,  0xbbbbbb1c },
  { "TLB invalid test 3 (store):\t\t",
    xtest36, &xtest36x, 23, false, true,  false, true,  0xbbbbbb1c },
  { "TLB wrtprot test (store):\t\t",
    xtest37, &xtest37x, 22, false, true,  false, true,  0xbbbbbb1c },
};


int main(void) {
  int i;
  int result;

  printf("\nStart of exception tests.\n\n");
  for (i = 0; i < sizeof(tests)/sizeof(tests[0]); i++) {
    printf("%s", tests[i].name);
    result = execTest(tests[i].run,
                      tests[i].locus,
                      tests[i].exception,
                      tests[i].execInUserMode,
                      tests[i].clobberEntryHi,
                      tests[i].shouldTakeUserMiss,
                      tests[i].shouldSetBadAddr,
                      tests[i].expectedBadAddr);
    if (result == 0) {
      printf("ok");
    } else {
      printf("failed (%s)", errorMessage[result]);
    }
    printf("\n");
  }
  printf("\nEnd of exception tests.\n");
  while (1) ;
  return 0;
}
