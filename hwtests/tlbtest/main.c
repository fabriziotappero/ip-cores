/*
 * main.c -- the main program
 */


#include "common.h"
#include "lib.h"
#include "start.h"


#define NUM_ENTRIES	32
#define NUM_FIXED	4


struct {
  Word hi;
  Word lo;
} randomEntries[NUM_ENTRIES] = {
  { 0x25FACEE3, 0x8ACF75B6 },
  { 0xCCDC1C4C, 0x524499EF },
  { 0x81CB5C0B, 0x7E098E5D },
  { 0xEB6F7F76, 0xAAA301DB },
  { 0x6FB1A2B8, 0x4E206502 },
  { 0x7FE39DFD, 0x3E74D858 },
  { 0x0422E083, 0x73B2D23A },
  { 0x71144B0A, 0xE623F4AF },
  { 0x5AAED767, 0xC34BEB52 },
  { 0x35A8D36A, 0x8E584748 },
  { 0x41B6B347, 0x544A9B0D },
  { 0x039AED34, 0x6927DF69 },
  { 0x3E3EEC16, 0xF7585602 },
  { 0x339AC351, 0xDD43F704 },
  { 0xA14C0101, 0x81FC5D62 },
  { 0x5B522D47, 0x9BC2EF2D },
  { 0x61235741, 0x67377AE9 },
  { 0x45BDFCA7, 0x4CDBDCF1 },
  { 0x2E044D77, 0xF70E7CE1 },
  { 0x33FC4126, 0x18B3D47C },
  { 0xF5F3CBEA, 0x9583DCC8 },
  { 0xA6B7454B, 0x887C5270 },
  { 0xED805C94, 0x9A6D6F8F },
  { 0xF27359EC, 0x2FC185D8 },
  { 0x0DDD34A3, 0x47B5D83A },
  { 0xEFDB299A, 0xC784294A },
  { 0x17A4E2F6, 0x5EAEFA99 },
  { 0x6EE1B054, 0xD716C16C },
  { 0xA34AF381, 0x8F775888 },
  { 0x2F48D37B, 0x46D72169 },
  { 0x97FC2065, 0xC3685619 },
  { 0x48B21FA3, 0x976B4EFB },
};


struct {
  Word hi;
  Word lo;
} mappingEntries[NUM_ENTRIES] = {
  { 0x00006000, 0x000F8001 },
  { 0x00017000, 0x00099001 },
  { 0x00004000, 0x0001A001 },
  { 0x0000D000, 0x000DB001 },
  { 0x00012000, 0x0009C001 },
  { 0x00013000, 0x0007D001 },
  { 0x00010000, 0x0001E001 },
  { 0x00009000, 0x0009F001 },
  { 0x0001E000, 0x00000001 },
  { 0x0000F000, 0x00021001 },
  { 0x0001C000, 0x000E2001 },
  { 0x00005000, 0x00023001 },
  { 0x0000A000, 0x000C4001 },
  { 0x0000B000, 0x00085001 },
  { 0x00008000, 0x00006001 },
  { 0x00001000, 0x00067001 },
  { 0x00016000, 0x000A8001 },
  { 0x00007000, 0x000A9001 },
  { 0x00014000, 0x0004A001 },
  { 0x0001D000, 0x0004B001 },
  { 0x00002000, 0x000EC001 },
  { 0x00003000, 0x0008D001 },
  { 0x00000000, 0x000EE001 },
  { 0x00019000, 0x0000F001 },
  { 0x0000E000, 0x00050001 },
  { 0x0001F000, 0x00011001 },
  { 0x0000C000, 0x000B2001 },
  { 0x00015000, 0x00093001 },
  { 0x0001A000, 0x00074001 },
  { 0x0001B000, 0x00075001 },
  { 0x00018000, 0x00036001 },
  { 0x00011000, 0x000D7001 },
};


void flushTLB(void) {
  unsigned int invalPage;
  int i;

  invalPage = 0xC0000000;
  for (i = 0; i < NUM_ENTRIES; i++) {
    setTLB(i, invalPage, 0);
    invalPage += (1 << 12);
  }
}


int countTLB(void) {
  int i;
  int n;
  Word hi;

  n = 0;
  for (i = 0; i < NUM_ENTRIES; i++) {
    hi = getTLB_HI(i);
    if ((hi & 0xC0000000) != 0xC0000000) {
      n++;
    }
  }
  return n;
}


/**************************************************************/


void indexedReadWriteTest(void) {
  int i;
  Word hi, lo;
  Bool fail;

  printf("Indexed R/W test\t\t");
  for (i = 0; i < NUM_ENTRIES; i++) {
    setTLB(i, randomEntries[i].hi, randomEntries[i].lo);
  }
  fail = false;
  for (i = 0; i < NUM_ENTRIES; i++) {
    hi = getTLB_HI(i);
    lo = getTLB_LO(i);
    if ((hi & 0xFFFFF000) != (randomEntries[i].hi & 0xFFFFF000) ||
        (lo & 0x3FFFF003) != (randomEntries[i].lo & 0x3FFFF003)) {
      fail = true;
    }
  }
  if (fail) {
    printf("failed\n");
  } else {
    printf("ok\n");
  }
}


void writeRandomTest(void) {
  int i;
  int n;
  int i04, i08, i12, i16;
  int i20, i24, i28;

  printf("Write random test\n");
  flushTLB();
  i04 = 0;
  i08 = 0;
  i12 = 0;
  i16 = 0;
  i20 = 0;
  i24 = 0;
  i28 = 0;
  for (i = 1; i <= 100 * NUM_ENTRIES; i++) {
    wrtRndTLB(i << 12, i << 12);
    n = countTLB();
    if (n == 4 && i04 == 0) {
      i04 = i;
    }
    if (n == 8 && i08 == 0) {
      i08 = i;
    }
    if (n == 12 && i12 == 0) {
      i12 = i;
    }
    if (n == 16 && i16 == 0) {
      i16 = i;
    }
    if (n == 20 && i20 == 0) {
      i20 = i;
    }
    if (n == 24 && i24 == 0) {
      i24 = i;
    }
    if (n == 28 && i28 == 0) {
      i28 = i;
    }
    wait(randomEntries[i % NUM_ENTRIES].hi & 0xFF);
  }
  if (i04 > 0) {
    printf("     4 entries filled after %3d random writes\n", i04);
  } else {
    printf("     4 entries never filled\n");
  }
  if (i08 > 0) {
    printf("     8 entries filled after %3d random writes\n", i08);
  } else {
    printf("     8 entries never filled\n");
  }
  if (i12 > 0) {
    printf("    12 entries filled after %3d random writes\n", i12);
  } else {
    printf("    12 entries never filled\n");
  }
  if (i16 > 0) {
    printf("    16 entries filled after %3d random writes\n", i16);
  } else {
    printf("    16 entries never filled\n");
  }
  if (i20 > 0) {
    printf("    20 entries filled after %3d random writes\n", i20);
  } else {
    printf("    20 entries never filled\n");
  }
  if (i24 > 0) {
    printf("    24 entries filled after %3d random writes\n", i24);
  } else {
    printf("    24 entries never filled\n");
  }
  if (i28 > 0) {
    printf("    28 entries filled after %3d random writes\n", i28);
  } else {
    printf("    28 entries never filled\n");
  }
}


void searchTest(void) {
  int i;
  Word index;
  Bool fail;

  printf("Search test\t\t\t");
  for (i = 0; i < NUM_ENTRIES; i++) {
    setTLB(i, randomEntries[i].hi, randomEntries[i].lo);
  }
  fail = false;
  for (i = 0; i < NUM_ENTRIES; i++) {
    index = probeTLB(randomEntries[i].hi);
    if (index != i) {
      fail = true;
    }
  }
  index = probeTLB(0xDEADBEEF);
  if ((index & 0x80000000) == 0) {
    fail = true;
  }
  if (fail) {
    printf("failed\n");
  } else {
    printf("ok\n");
  }
}


void mapTest(void) {
  int i;
  Word page, offset;
  Word virt;
  int index;
  Word frame;
  Word phys;
  Word cont;
  Bool fail;

  printf("Map test\t\t\t");
  /* preset each memory word (below 1M) with its physical address */
  for (i = 0; i < 0x100000; i += 4) {
    *(Word *)(0xC0000000 | i) = i;
  }
  /* preset TLB */
  for (i = 0; i < NUM_ENTRIES; i++) {
    setTLB(i, mappingEntries[i].hi, mappingEntries[i].lo);
  }
  /* now access memory and check if addresses are mapped correctly */
  fail = false;
  page = 7;
  offset = 0x123;
  for (i = 0; i < 100000; i++) {
    /* compute pseudo-random virtual word address (page number 0..31) */
    page = (page * 13 + 1) & 0x1F;
    offset = (offset * 109) & 0x00000FFF;
    virt = (page << 12) | (offset & 0xFFFFFFFC);
    /* lookup frame number in TLB and construct physical word address */
    index = probeTLB(virt);
    if (index & 0x80000000) {
      fail = true;
      break;
    }
    frame = getTLB_LO(index) & 0xFFFFF000;
    phys = frame | (offset & 0xFFFFFFFC);
    /* access memory by dereferencing the virtual address */
    cont = *(Word *)virt;
    /* word read should equal physical address */
    if (cont != phys) {
      fail = true;
    }
  }
  if (fail) {
    printf("failed\n");
  } else {
    printf("ok\n");
  }
}


/**************************************************************/


int main(void) {
  printf("\nStart of TLB tests.\n\n");
  indexedReadWriteTest();
  writeRandomTest();
  searchTest();
  mapTest();
  printf("\nEnd of TLB tests.\n");
  while (1) ;
  return 0;
}
