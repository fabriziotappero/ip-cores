/*
 * wrtmbr.c -- write the master boot record to the disk
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>


#define SECTOR_SIZE		512


void error(char *fmt, ...) {
  va_list ap;

  va_start(ap, fmt);
  fprintf(stderr, "Error: ");
  vfprintf(stderr, fmt, ap);
  fprintf(stderr, "\n");
  va_end(ap);
  exit(1);
}


void usage(char *myself) {
  fprintf(stderr,
          "Usage: %s <disk file> <master boot record file>\n",
          myself);
  exit(1);
}


int main(int argc, char *argv[]) {
  FILE *diskFile;
  FILE *bootFile;
  unsigned char sectorBuffer[SECTOR_SIZE];

  if (argc != 3) {
    usage(argv[0]);
  }
  diskFile = fopen(argv[1], "r+b");
  if (diskFile == NULL) {
    error("cannot open disk file '%s'", argv[1]);
  }
  bootFile = fopen(argv[2], "rb");
  if (bootFile == NULL) {
    error("cannot open boot sector file '%s'", argv[2]);
  }
  if (fseek(bootFile, 0, SEEK_END) != 0) {
    error("cannot position to end of boot sector file");
  }
  if (ftell(bootFile) != SECTOR_SIZE) {
    error("'%s' is not a proper boot sector file (wrong length)", argv[2]);
  }
  if (fseek(bootFile, 0, SEEK_SET) != 0) {
    error("cannot position to start of boot sector file");
  }
  if (fread(sectorBuffer, SECTOR_SIZE, 1, bootFile) != 1) {
    error("cannot read data from boot sector file");
  }
  fclose(bootFile);
  if (sectorBuffer[SECTOR_SIZE - 2] != 0x55 ||
      sectorBuffer[SECTOR_SIZE - 1] != 0xAA) {
    error("'%s' is not a proper boot sector file (no signature)", argv[2]);
  }
  if (fseek(diskFile, 0, SEEK_SET) != 0) {
    error("cannot position to start of disk file");
  }
  if (fwrite(sectorBuffer, 1, SECTOR_SIZE, diskFile) != SECTOR_SIZE) {
    error("cannot write boot sector to disk file");
  }
  fclose(diskFile);
  return 0;
}
