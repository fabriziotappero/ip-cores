/*
 * boot.c -- bootstrap from disk
 */


#include "common.h"
#include "stdarg.h"
#include "romlib.h"
#include "boot.h"
#include "cpu.h"
#include "mmu.h"
#include "start.h"


void boot(int dskno, Bool start) {
  Word capacity;
  Byte sig1, sig2;

  capacity = dskcap(dskno);
  if (capacity == 0) {
    printf("Disk not found!\n");
    return;
  }
  printf("Disk with 0x%08X sectors found, booting...\n", capacity);
  if (dskio(dskno, 'r', 0, PHYS_BOOT, 1) != 0) {
    printf("Disk error!\n");
    return;
  }
  sig1 = mmuReadByte(VIRT_BOOT + 512 - 2);
  sig2 = mmuReadByte(VIRT_BOOT + 512 - 1);
  if (sig1 != 0x55 || sig2 != 0xAA) {
    printf("MBR signature missing!\n");
    return;
  }
  /*
   * Boot convention:
   *   $16  disk number of boot disk
   *   $17  start sector number of disk or partition to boot
   *   $18  total number of sectors of disk or partition to boot
   */
  cpuSetReg(16, dskno);
  cpuSetReg(17, 0);
  cpuSetReg(18, capacity);
  cpuSetPC(VIRT_BOOT);
  if (start) {
    cpuRun();
  }
}
