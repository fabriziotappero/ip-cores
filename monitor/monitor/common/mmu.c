/*
 * mmu.c -- memory and TLB access
 */


#include "common.h"
#include "stdarg.h"
#include "romlib.h"
#include "mmu.h"
#include "start.h"


static Word tlbIndex;
static Word tlbEntryHi;
static Word tlbEntryLo;
static Word badAddress;
static Word badAccess;


Word mmuReadWord(Word vAddr) {
  return *(Word *)vAddr;
}


Half mmuReadHalf(Word vAddr) {
  return *(Half *)vAddr;
}


Byte mmuReadByte(Word vAddr) {
  return *(Byte *)vAddr;
}


void mmuWriteWord(Word vAddr, Word data) {
  *(Word *)vAddr = data;
}


void mmuWriteHalf(Word vAddr, Half data) {
  *(Half *)vAddr = data;
}


void mmuWriteByte(Word vAddr, Byte data) {
  *(Byte *)vAddr = data;
}


Word mmuGetIndex(void) {
  return tlbIndex;
}


void mmuSetIndex(Word value) {
  tlbIndex = value;
}


Word mmuGetEntryHi(void) {
  return tlbEntryHi;
}


void mmuSetEntryHi(Word value) {
  tlbEntryHi = value;
}


Word mmuGetEntryLo(void) {
  return tlbEntryLo;
}


void mmuSetEntryLo(Word value) {
  tlbEntryLo = value;
}


Word mmuGetBadAddr(void) {
  return badAddress;
}


void mmuSetBadAddr(Word value) {
  badAddress = value;
}


Word mmuGetBadAccs(void) {
  return badAccess;
}


void mmuSetBadAccs(Word value) {
  badAccess = value;
}


TLB_Entry mmuGetTLB(int index) {
  Word hi;
  Word lo;
  TLB_Entry result;

  hi = getTLB_HI(index);
  lo = getTLB_LO(index);
  result.page = hi & PAGE_MASK;
  result.frame = lo & PAGE_MASK;
  result.write = (lo & TLB_WRITE) ? true : false;
  result.valid = (lo & TLB_VALID) ? true : false;
  return result;
}


void mmuSetTLB(int index, TLB_Entry tlbEntry) {
  Word flags;

  flags = 0;
  if (tlbEntry.write) {
    flags |= TLB_WRITE;
  }
  if (tlbEntry.valid) {
    flags |= TLB_VALID;
  }
  setTLB(index, tlbEntry.page, tlbEntry.frame | flags);
}
