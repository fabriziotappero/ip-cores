/*
 * mmu.c -- MMU simulation
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <setjmp.h>

#include "common.h"
#include "console.h"
#include "error.h"
#include "except.h"
#include "cpu.h"
#include "mmu.h"
#include "memory.h"


static Bool debugUse = false;
static Bool debugWrite = false;


static TLB_Entry tlb[TLB_SIZE];
static Word tlbIndex;
static Word tlbEntryHi;
static Word tlbEntryLo;
static Word mmuBadAddr;
static Word mmuBadAccs;

static int randomIndex;


static void updateRandomIndex(void) {
  if (randomIndex == TLB_FIXED) {
    randomIndex = TLB_MASK;
  } else {
    randomIndex--;
  }
}


static int assoc(Word page) {
  int n, i;

  n = -1;
  for (i = 0; i < TLB_SIZE; i++) {
    if (tlb[i].page == page) {
      n = i;
    }
  }
  return n;
}


static Word v2p(Word vAddr, Bool userMode, Bool writing, int accsWidth) {
  Word pAddr;
  Word page, offset;
  int index;

  if (debugUse) {
    cPrintf("**** vAddr = 0x%08X", vAddr);
  }
  if ((vAddr & 0x80000000) != 0 && userMode) {
    /* trying to access a privileged address from user mode */
    mmuBadAccs = (writing ? MMU_ACCS_WRITE : MMU_ACCS_READ) | accsWidth;
    mmuBadAddr = vAddr;
    throwException(EXC_PRV_ADDRESS);
  }
  updateRandomIndex();
  if ((vAddr & 0xC0000000) == 0xC0000000) {
    /* unmapped address space */
    /* simulate delay introduced by assoc when using mapped
       addresses but not experienced with unmapped addresses */
    assoc(0);
    pAddr = vAddr & ~0xC0000000;
  } else {
    /* mapped address space */
    page = vAddr & PAGE_MASK;
    offset = vAddr & OFFSET_MASK;
    index = assoc(page);
    if (index == -1) {
      /* TLB miss exception */
      mmuBadAccs = (writing ? MMU_ACCS_WRITE : MMU_ACCS_READ) | accsWidth;
      mmuBadAddr = vAddr;
      tlbEntryHi = page;
      throwException(EXC_TLB_MISS);
    }
    if (!tlb[index].valid) {
      /* TLB invalid exception */
      mmuBadAccs = (writing ? MMU_ACCS_WRITE : MMU_ACCS_READ) | accsWidth;
      mmuBadAddr = vAddr;
      tlbEntryHi = page;
      throwException(EXC_TLB_INVALID);
    }
    if (!tlb[index].write && writing) {
      /* TLB write exception */
      mmuBadAccs = (writing ? MMU_ACCS_WRITE : MMU_ACCS_READ) | accsWidth;
      mmuBadAddr = vAddr;
      tlbEntryHi = page;
      throwException(EXC_TLB_WRITE);
    }
    pAddr = tlb[index].frame | offset;
  }
  if (debugUse) {
    cPrintf(", pAddr = 0x%08X ****\n", pAddr);
  }
  return pAddr;
}


Word mmuReadWord(Word vAddr, Bool userMode) {
  if ((vAddr & 3) != 0) {
    /* throw illegal address exception */
    mmuBadAccs = MMU_ACCS_READ | MMU_ACCS_WORD;
    mmuBadAddr = vAddr;
    throwException(EXC_ILL_ADDRESS);
  }
  return memoryReadWord(v2p(vAddr, userMode, false, MMU_ACCS_WORD));
}


Half mmuReadHalf(Word vAddr, Bool userMode) {
  if ((vAddr & 1) != 0) {
    /* throw illegal address exception */
    mmuBadAccs = MMU_ACCS_READ | MMU_ACCS_HALF;
    mmuBadAddr = vAddr;
    throwException(EXC_ILL_ADDRESS);
  }
  return memoryReadHalf(v2p(vAddr, userMode, false, MMU_ACCS_HALF));
}


Byte mmuReadByte(Word vAddr, Bool userMode) {
  return memoryReadByte(v2p(vAddr, userMode, false, MMU_ACCS_BYTE));
}


void mmuWriteWord(Word vAddr, Word data, Bool userMode) {
  if ((vAddr & 3) != 0) {
    /* throw illegal address exception */
    mmuBadAccs = MMU_ACCS_WRITE | MMU_ACCS_WORD;
    mmuBadAddr = vAddr;
    throwException(EXC_ILL_ADDRESS);
  }
  memoryWriteWord(v2p(vAddr, userMode, true, MMU_ACCS_WORD), data);
}


void mmuWriteHalf(Word vAddr, Half data, Bool userMode) {
  if ((vAddr & 1) != 0) {
    /* throw illegal address exception */
    mmuBadAccs = MMU_ACCS_WRITE | MMU_ACCS_HALF;
    mmuBadAddr = vAddr;
    throwException(EXC_ILL_ADDRESS);
  }
  memoryWriteHalf(v2p(vAddr, userMode, true, MMU_ACCS_HALF), data);
}


void mmuWriteByte(Word vAddr, Byte data, Bool userMode) {
  memoryWriteByte(v2p(vAddr, userMode, true, MMU_ACCS_BYTE), data);
}


Word mmuGetIndex(void) {
  return tlbIndex;
}


void mmuSetIndex(Word value) {
  tlbIndex = value & TLB_MASK;
}


Word mmuGetEntryHi(void) {
  return tlbEntryHi;
}


void mmuSetEntryHi(Word value) {
  tlbEntryHi = value & PAGE_MASK;
}


Word mmuGetEntryLo(void) {
  return tlbEntryLo;
}


void mmuSetEntryLo(Word value) {
  tlbEntryLo = value & (PAGE_MASK | TLB_WRITE | TLB_VALID);
}


Word mmuGetBadAddr(void) {
  return mmuBadAddr;
}


void mmuSetBadAddr(Word value) {
  mmuBadAddr = value;
}


Word mmuGetBadAccs(void) {
  return mmuBadAccs;
}


void mmuSetBadAccs(Word value) {
  mmuBadAccs = value;
}


void mmuTbs(void) {
  int index;

  index = assoc(tlbEntryHi & PAGE_MASK);
  if (index == -1) {
    tlbIndex = 0x80000000;
  } else {
    tlbIndex = index;
  }
}


void mmuTbwr(void) {
  int index;

  /* choose a random index, but don't touch fixed entries */
  index = randomIndex;
  tlb[index].page = tlbEntryHi & PAGE_MASK;
  tlb[index].frame = tlbEntryLo & PAGE_MASK;
  tlb[index].write = tlbEntryLo & TLB_WRITE ? true : false;
  tlb[index].valid = tlbEntryLo & TLB_VALID ? true : false;
  if (debugWrite) {
    cPrintf("**** TLB[%02d] <- 0x%08X 0x%08X %c %c ****\n",
            index, tlb[index].page, tlb[index].frame,
            tlb[index].write ? 'w' : '-',
            tlb[index].valid ? 'v' : '-');
  }
}


void mmuTbri(void) {
  int index;

  index = tlbIndex & TLB_MASK;
  tlbEntryHi = tlb[index].page;
  tlbEntryLo = tlb[index].frame;
  if (tlb[index].write) {
    tlbEntryLo |= TLB_WRITE;
  }
  if (tlb[index].valid) {
    tlbEntryLo |= TLB_VALID;
  }
}


void mmuTbwi(void) {
  int index;

  index = tlbIndex & TLB_MASK;
  tlb[index].page = tlbEntryHi & PAGE_MASK;
  tlb[index].frame = tlbEntryLo & PAGE_MASK;
  tlb[index].write = tlbEntryLo & TLB_WRITE ? true : false;
  tlb[index].valid = tlbEntryLo & TLB_VALID ? true : false;
  if (debugWrite) {
    cPrintf("**** TLB[%02d] <- 0x%08X 0x%08X %c %c ****\n",
            index, tlb[index].page, tlb[index].frame,
            tlb[index].write ? 'w' : '-',
            tlb[index].valid ? 'v' : '-');
  }
}


TLB_Entry mmuGetTLB(int index) {
  return tlb[index & TLB_MASK];
}


void mmuSetTLB(int index, TLB_Entry tlbEntry) {
  index &= TLB_MASK;
  tlb[index] = tlbEntry;
  if (debugWrite) {
    cPrintf("**** TLB[%02d] <- 0x%08X 0x%08X %c %c ****\n",
            index, tlb[index].page, tlb[index].frame,
            tlb[index].write ? 'w' : '-',
            tlb[index].valid ? 'v' : '-');
  }
}


void mmuReset(void) {
  int i;

  cPrintf("Resetting MMU...\n");
  for (i = 0; i < TLB_SIZE; i++) {
    tlb[i].page = rand() & PAGE_MASK;
    tlb[i].frame = rand() & PAGE_MASK;
    tlb[i].write = rand() & 0x1000 ? true : false;
    tlb[i].valid = rand() & 0x1000 ? true : false;
    if (debugWrite) {
      cPrintf("**** TLB[%02d] <- 0x%08X 0x%08X %c %c ****\n",
              i, tlb[i].page, tlb[i].frame,
              tlb[i].write ? 'w' : '-',
              tlb[i].valid ? 'v' : '-');
    }
  }
  tlbIndex = rand() & TLB_MASK;
  tlbEntryHi = rand() & PAGE_MASK;
  tlbEntryLo = rand() & (PAGE_MASK | TLB_WRITE | TLB_VALID);
  mmuBadAddr = rand();
  mmuBadAccs = rand() & MMU_ACCS_MASK;
  randomIndex = TLB_MASK;
}


void mmuInit(void) {
  mmuReset();
}


void mmuExit(void) {
}
