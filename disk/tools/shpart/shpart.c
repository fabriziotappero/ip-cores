/*
 * shpart.c -- show partitions on a disk
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>


#define SECTOR_SIZE	512
#define NPE		(SECTOR_SIZE / sizeof(PartEntry))
#define DESCR_SIZE	20


typedef struct {
  unsigned int type;
  unsigned int start;
  unsigned int size;
  char descr[DESCR_SIZE];
} PartEntry;

PartEntry ptr[NPE];


/**************************************************************/


void error(char *fmt, ...) {
  va_list ap;

  va_start(ap, fmt);
  printf("Error: ");
  vprintf(fmt, ap);
  printf("\n");
  va_end(ap);
  exit(1);
}


/**************************************************************/


unsigned int getNumber(unsigned char *p) {
  return (unsigned int) *(p + 0) << 24 |
         (unsigned int) *(p + 1) << 16 |
         (unsigned int) *(p + 2) <<  8 |
         (unsigned int) *(p + 3) <<  0;
}


void convertPartitionTable(PartEntry *e, int n) {
  int i;
  unsigned char *p;

  for (i = 0; i < n; i++) {
    p = (unsigned char *) &e[i];
    e[i].type = getNumber(p + 0);
    e[i].start = getNumber(p + 4);
    e[i].size = getNumber(p + 8);
  }
}


/**************************************************************/


int main(int argc, char *argv[]) {
  char *diskName;
  FILE *disk;
  unsigned long diskSize;
  unsigned int numSectors;
  unsigned int partLast;
  int i, j;
  char c;

  /* check command line arguments */
  if (argc != 2) {
    printf("Usage: %s <disk image file>\n", argv[0]);
    exit(1);
  }
  diskName = argv[1];
  /* determine disk size */
  disk = fopen(diskName, "rb");
  if (disk == NULL) {
    error("cannot open disk image '%s'", diskName);
  }
  fseek(disk, 0, SEEK_END);
  diskSize = ftell(disk);
  numSectors = diskSize / SECTOR_SIZE;
  fclose(disk);
  printf("Disk '%s' has %u (0x%X) sectors.\n",
         diskName, numSectors, numSectors);
  if (numSectors < 32) {
    error("disk is too small");
  }
  if (diskSize % SECTOR_SIZE != 0) {
    printf("Warning: disk size is not a multiple of sector size!\n");
  }
  /* read partition table record */
  disk = fopen(diskName, "rb");
  if (disk == NULL) {
    error("cannot open disk image '%s'", diskName);
  }
  fseek(disk, 1 * SECTOR_SIZE, SEEK_SET);
  if (fread(ptr, 1, SECTOR_SIZE, disk) != SECTOR_SIZE) {
    error("cannot read partition table from disk image '%s'", diskName);
  }
  fclose(disk);
  convertPartitionTable(ptr, NPE);
  /* show partition table */
  printf("Partitions:\n");
  printf(" # b type       start      last       size       description\n");
  for (i = 0; i < NPE; i++) {
    if (ptr[i].type != 0) {
      partLast = ptr[i].start + ptr[i].size - 1;
    } else {
      partLast = 0;
    }
    printf("%2d %s 0x%08X 0x%08X 0x%08X 0x%08X ",
           i,
           ptr[i].type & 0x80000000 ? "*" : " ",
           ptr[i].type & 0x7FFFFFFF,
           ptr[i].start,
           partLast,
           ptr[i].size);
    for (j = 0; j < DESCR_SIZE; j++) {
      c = ptr[i].descr[j];
      if (c == '\0') {
        break;
      }
      if (c >= 0x20 && c < 0x7F) {
        printf("%c", c);
      } else {
        printf(".");
      }
    }
    printf("\n");
  }
  /* done */
  return 0;
}
