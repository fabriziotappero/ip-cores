/*
 * memory.c -- physical memory simulation
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
#include "memory.h"
#include "timer.h"
#include "dspkbd.h"
#include "serial.h"
#include "disk.h"
#include "output.h"
#include "shutdown.h"
#include "graph.h"


static Byte *rom;
static Byte *mem;
static unsigned int memSize;
static FILE *romImage;
static unsigned int romSize;
static FILE *progImage;
static unsigned int progSize;
static unsigned int progAddr;


Word memoryReadWord(Word pAddr) {
  Word data;

  if (pAddr <= memSize - 4) {
    data = ((Word) *(mem + pAddr + 0)) << 24 |
           ((Word) *(mem + pAddr + 1)) << 16 |
           ((Word) *(mem + pAddr + 2)) <<  8 |
           ((Word) *(mem + pAddr + 3)) <<  0;
    return data;
  }
  if (pAddr >= ROM_BASE &&
      pAddr <= ROM_BASE + ROM_SIZE - 4) {
    data = ((Word) *(rom + (pAddr - ROM_BASE) + 0)) << 24 |
           ((Word) *(rom + (pAddr - ROM_BASE) + 1)) << 16 |
           ((Word) *(rom + (pAddr - ROM_BASE) + 2)) <<  8 |
           ((Word) *(rom + (pAddr - ROM_BASE) + 3)) <<  0;
    return data;
  }
  if ((pAddr & IO_DEV_MASK) == TIMER_BASE) {
    data = timerRead(pAddr & IO_REG_MASK);
    return data;
  }
  if ((pAddr & IO_DEV_MASK) == DISPLAY_BASE) {
    data = displayRead(pAddr & IO_REG_MASK);
    return data;
  }
  if ((pAddr & IO_DEV_MASK) == KEYBOARD_BASE) {
    data = keyboardRead(pAddr & IO_REG_MASK);
    return data;
  }
  if ((pAddr & IO_DEV_MASK) == SERIAL_BASE) {
    data = serialRead(pAddr & IO_REG_MASK);
    return data;
  }
  if ((pAddr & IO_DEV_MASK) == DISK_BASE) {
    data = diskRead(pAddr & IO_REG_MASK);
    return data;
  }
  if ((pAddr & IO_DEV_MASK) == OUTPUT_BASE) {
    data = outputRead(pAddr & IO_REG_MASK);
    return data;
  }
  if ((pAddr & IO_DEV_MASK) == SHUTDOWN_BASE) {
    data = shutdownRead(pAddr & IO_REG_MASK);
    return data;
  }
  if ((pAddr & IO_DEV_MASK) >= GRAPH_BASE) {
    data = graphRead(pAddr & IO_GRAPH_MASK);
    return data;
  }
  /* throw bus timeout exception */
  throwException(EXC_BUS_TIMEOUT);
  /* not reached */
  data = 0;
  return data;
}


Half memoryReadHalf(Word pAddr) {
  Half data;

  if (pAddr <= memSize - 2) {
    data = ((Half) *(mem + pAddr + 0)) << 8 |
           ((Half) *(mem + pAddr + 1)) << 0;
    return data;
  }
  if (pAddr >= ROM_BASE &&
      pAddr <= ROM_BASE + ROM_SIZE - 2) {
    data = ((Half) *(rom + (pAddr - ROM_BASE) + 0)) << 8 |
           ((Half) *(rom + (pAddr - ROM_BASE) + 1)) << 0;
    return data;
  }
  /* throw bus timeout exception */
  throwException(EXC_BUS_TIMEOUT);
  /* not reached */
  data = 0;
  return data;
}


Byte memoryReadByte(Word pAddr) {
  Byte data;

  if (pAddr <= memSize - 1) {
    data = ((Byte) *(mem + pAddr + 0)) << 0;
    return data;
  }
  if (pAddr >= ROM_BASE &&
      pAddr <= ROM_BASE + ROM_SIZE - 1) {
    data = ((Byte) *(rom + (pAddr - ROM_BASE) + 0)) << 0;
    return data;
  }
  /* throw bus timeout exception */
  throwException(EXC_BUS_TIMEOUT);
  /* not reached */
  data = 0;
  return data;
}


void memoryWriteWord(Word pAddr, Word data) {
  if (pAddr <= memSize - 4) {
    *(mem + pAddr + 0) = (Byte) (data >> 24);
    *(mem + pAddr + 1) = (Byte) (data >> 16);
    *(mem + pAddr + 2) = (Byte) (data >>  8);
    *(mem + pAddr + 3) = (Byte) (data >>  0);
    return;
  }
  if ((pAddr & IO_DEV_MASK) == TIMER_BASE) {
    timerWrite(pAddr & IO_REG_MASK, data);
    return;
  }
  if ((pAddr & IO_DEV_MASK) == DISPLAY_BASE) {
    displayWrite(pAddr & IO_REG_MASK, data);
    return;
  }
  if ((pAddr & IO_DEV_MASK) == KEYBOARD_BASE) {
    keyboardWrite(pAddr & IO_REG_MASK, data);
    return;
  }
  if ((pAddr & IO_DEV_MASK) == SERIAL_BASE) {
    serialWrite(pAddr & IO_REG_MASK, data);
    return;
  }
  if ((pAddr & IO_DEV_MASK) == DISK_BASE) {
    diskWrite(pAddr & IO_REG_MASK, data);
    return;
  }
  if ((pAddr & IO_DEV_MASK) == OUTPUT_BASE) {
    outputWrite(pAddr & IO_REG_MASK, data);
    return;
  }
  if ((pAddr & IO_DEV_MASK) == SHUTDOWN_BASE) {
    shutdownWrite(pAddr & IO_REG_MASK, data);
    return;
  }
  if ((pAddr & IO_DEV_MASK) >= GRAPH_BASE) {
    graphWrite(pAddr & IO_GRAPH_MASK, data);
    return;
  }
  /* throw bus timeout exception */
  throwException(EXC_BUS_TIMEOUT);
}


void memoryWriteHalf(Word pAddr, Half data) {
  if (pAddr <= memSize - 2) {
    *(mem + pAddr + 0) = (Byte) (data >> 8);
    *(mem + pAddr + 1) = (Byte) (data >> 0);
    return;
  }
  /* throw bus timeout exception */
  throwException(EXC_BUS_TIMEOUT);
}


void memoryWriteByte(Word pAddr, Byte data) {
  if (pAddr <= memSize - 1) {
    *(mem + pAddr + 0) = (Byte) (data >> 0);
    return;
  }
  /* throw bus timeout exception */
  throwException(EXC_BUS_TIMEOUT);
}


void memoryReset(void) {
  unsigned int i;

  cPrintf("Resetting Memory...\n");
  for (i = 0; i < memSize; i++) {
    mem[i] = rand();
  }
  cPrintf("%6d MB RAM installed", memSize / M);
  if (progImage != NULL) {
    fseek(progImage, 0, SEEK_SET);
    if (fread(mem + progAddr, progSize, 1, progImage) != 1) {
      error("cannot read program image file");
    }
    cPrintf(", %d bytes loaded", progSize);
  }
  cPrintf(".\n");
  for (i = 0; i < ROM_SIZE; i++) {
    rom[i] = 0xFF;
  }
  if (romImage != NULL) {
    fseek(romImage, 0, SEEK_SET);
    if (fread(rom, romSize, 1, romImage) != 1) {
      error("cannot read ROM image file");
    }
    cPrintf("%6d KB ROM installed, %d bytes programmed.\n",
            ROM_SIZE / K, romSize);
  }
}


void memoryInit(unsigned int memorySize,
                char *progImageName,
                unsigned int loadAddr,
                char *romImageName) {
  /* allocate RAM */
  memSize = memorySize;
  mem = malloc(memSize);
  if (mem == NULL) {
    error("cannot allocate RAM");
  }
  /* possibly load program image */
  if (progImageName == NULL) {
    /* no program to load */
    progImage = NULL;
  } else {
    /* load program */
    progImage = fopen(progImageName, "rb");
    if (progImage == NULL) {
      error("cannot open program file '%s'", progImageName);
    }
    fseek(progImage, 0, SEEK_END);
    progSize = ftell(progImage);
    progAddr = loadAddr;
    if (progAddr + progSize > memSize) {
      error("program file or load address too big");
    }
    /* do actual loading of image in memoryReset() */
  }
  /* allocate ROM */
  rom = malloc(ROM_SIZE);
  if (rom == NULL) {
    error("cannot allocate ROM");
  }
  /* possibly load ROM image */
  if (romImageName == NULL) {
    /* no ROM to plug in */
    romImage = NULL;
  } else {
    /* plug in ROM */
    romImage = fopen(romImageName, "rb");
    if (romImage == NULL) {
      error("cannot open ROM image '%s'", romImageName);
    }
    fseek(romImage, 0, SEEK_END);
    romSize = ftell(romImage);
    if (romSize > ROM_SIZE) {
      error("ROM image too big");
    }
    /* do actual loading of image in memoryReset() */
  }
  memoryReset();
}


void memoryExit(void) {
  free(mem);
  free(rom);
}
