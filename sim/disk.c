/*
 * disk.c -- disk simulation
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
#include "timer.h"
#include "disk.h"


static Bool debug = false;

static FILE *diskImage;
static long totalSectors;

static Word diskCtrl;
static Word diskCnt;
static Word diskSct;
static Word diskCap;

static Byte diskBuffer[8 * SECTOR_SIZE];

static long lastSct;


static Word readWord(Byte *p) {
  Word data;

  data = ((Word) *(p + 0)) << 24 |
         ((Word) *(p + 1)) << 16 |
         ((Word) *(p + 2)) <<  8 |
         ((Word) *(p + 3)) <<  0;
  return data;
}


static void writeWord(Byte *p, Word data) {
  *(p + 0) = (Byte) (data >> 24);
  *(p + 1) = (Byte) (data >> 16);
  *(p + 2) = (Byte) (data >>  8);
  *(p + 3) = (Byte) (data >>  0);
}


static void diskCallback(int n) {
  int numScts;

  if (debug) {
    cPrintf("\n**** DISK CALLBACK, n = %d ****\n", n);
  }
  if (n == 0) {
    /* startup time expired */
    diskCap = totalSectors;
    diskCtrl |= DISK_READY;
    return;
  }
  /* disk read or write */
  numScts = ((diskCnt - 1) & 0x07) + 1;
  if (diskCap != 0 &&
      diskSct < diskCap &&
      diskSct + numScts <= diskCap) {
    /* do the transfer */
    if (fseek(diskImage, diskSct * SECTOR_SIZE, SEEK_SET) != 0) {
      error("cannot position to sector in disk image");
    }
    if (diskCtrl & DISK_WRT) {
      /* buffer --> disk */
      if (fwrite(diskBuffer, SECTOR_SIZE, numScts, diskImage) != numScts) {
        error("cannot write to disk image");
      }
    } else {
      /* disk --> buffer */
      if (fread(diskBuffer, SECTOR_SIZE, numScts, diskImage) != numScts) {
        error("cannot read from disk image");
      }
    }
    lastSct = (long) diskSct + (long) numScts - 1;
  } else {
    /* sectors requested exceed disk capacity */
    /* or we have no disk at all */
    diskCtrl |= DISK_ERR;
  }
  diskCtrl &= ~DISK_STRT;
  diskCtrl |= DISK_DONE;
  if (diskCtrl & DISK_IEN) {
    /* raise disk interrupt */
    cpuSetInterrupt(IRQ_DISK);
  }
}


Word diskRead(Word addr) {
  Word data;

  if (debug) {
    cPrintf("\n**** DISK READ from 0x%08X", addr);
  }
  if (addr == DISK_CTRL) {
    data = diskCtrl;
  } else
  if (addr == DISK_CNT) {
    data = diskCnt;
  } else
  if (addr == DISK_SCT) {
    data = diskSct;
  } else
  if (addr == DISK_CAP) {
    data = diskCap;
  } else
  if (addr & 0x80000) {
    /* buffer access */
    data = readWord(diskBuffer + (addr & 0x0FFC));
  } else {
    /* illegal register */
    throwException(EXC_BUS_TIMEOUT);
  }
  if (debug) {
    cPrintf(", data = 0x%08X ****\n", data);
  }
  return data;
}


void diskWrite(Word addr, Word data) {
  long delta;

  if (debug) {
    cPrintf("\n**** DISK WRITE to 0x%08X, data = 0x%08X ****\n",
            addr, data);
  }
  if (addr == DISK_CTRL) {
    if (data & DISK_WRT) {
      diskCtrl |= DISK_WRT;
    } else {
      diskCtrl &= ~DISK_WRT;
    }
    if (data & DISK_IEN) {
      diskCtrl |= DISK_IEN;
    } else {
      diskCtrl &= ~DISK_IEN;
    }
    if (data & DISK_STRT) {
      diskCtrl |= DISK_STRT;
      diskCtrl &= ~DISK_ERR;
      diskCtrl &= ~DISK_DONE;
      /* only start a disk operation if disk is present */
      if (diskCap != 0) {
        delta = labs((long) diskSct - lastSct);
        if (delta > diskCap) {
          delta = diskCap;
        }
        timerStart(DISK_DELAY_USEC + (delta * DISK_SEEK_USEC) / diskCap,
                   diskCallback, 1);
      }
    } else {
      diskCtrl &= ~DISK_STRT;
      if (data & DISK_ERR) {
        diskCtrl |= DISK_ERR;
      } else {
        diskCtrl &= ~DISK_ERR;
      }
      if (data & DISK_DONE) {
        diskCtrl |= DISK_DONE;
      } else {
        diskCtrl &= ~DISK_DONE;
      }
    }
    if ((diskCtrl & DISK_IEN) != 0 &&
        (diskCtrl & DISK_DONE) != 0) {
      /* raise disk interrupt */
      cpuSetInterrupt(IRQ_DISK);
    } else {
      /* lower disk interrupt */
      cpuResetInterrupt(IRQ_DISK);
    }
  } else
  if (addr == DISK_CNT) {
    diskCnt = data;
  } else
  if (addr == DISK_SCT) {
    diskSct = data;
  } else
  if (addr == DISK_CAP) {
    /* this register is read-only */
    throwException(EXC_BUS_TIMEOUT);
  } else
  if (addr & 0x80000) {
    /* buffer access */
    writeWord(diskBuffer + (addr & 0x0FFC), data);
  } else {
    /* illegal register */
    throwException(EXC_BUS_TIMEOUT);
  }
}


void diskReset(void) {
  cPrintf("Resetting Disk...\n");
  diskCtrl = 0;
  diskCnt = 0;
  diskSct = 0;
  diskCap = 0;
  lastSct = 0;
  if (totalSectors != 0) {
    cPrintf("Disk of size %ld sectors (%ld bytes) installed.\n",
            totalSectors, totalSectors * SECTOR_SIZE);
    timerStart(DISK_START_USEC, diskCallback, 0);
  }
}


void diskInit(char *diskImageName) {
  long numBytes;

  if (diskImageName == NULL) {
    /* do not install disk */
    diskImage = NULL;
    totalSectors = 0;
  } else {
    /* try to install disk */
    diskImage = fopen(diskImageName, "r+b");
    if (diskImage == NULL) {
      error("cannot open disk image '%s'", diskImageName);
    }
    fseek(diskImage, 0, SEEK_END);
    numBytes = ftell(diskImage);
    fseek(diskImage, 0, SEEK_SET);
    if (numBytes % SECTOR_SIZE != 0) {
      error("disk image '%s' does not contain an integral number of sectors",
            diskImageName);
    }
    totalSectors = numBytes / SECTOR_SIZE;
  }
  diskReset();
}


void diskExit(void) {
  if (diskImage == NULL) {
    /* disk not installed */
    return;
  }
  fclose(diskImage);
}
