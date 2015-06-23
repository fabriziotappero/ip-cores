/*
 * wrpart.c -- write a binary image to a partition on a disk
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
  char *partNmbr;
  char *partName;
  FILE *disk;
  unsigned int diskSize;
  char *endp;
  int partno;
  unsigned int partStart;
  unsigned int partSize;
  FILE *image;
  unsigned int imageSize;
  unsigned int i;
  unsigned char sectBuf[SECTOR_SIZE];
  int n;

  /* check command line arguments */
  if (argc != 4) {
    printf("Usage: %s <disk image> ", argv[0]);
    printf("<partition number> <partition image>\n");
    exit(1);
  }
  diskName = argv[1];
  partNmbr = argv[2];
  partName = argv[3];
  /* read partition table record */
  disk = fopen(diskName, "r+b");
  if (disk == NULL) {
    error("cannot open disk image '%s'", diskName);
  }
  fseek(disk, 0, SEEK_END);
  diskSize = ftell(disk) / SECTOR_SIZE;
  printf("disk '%s' has %u (0x%X) sectors\n",
         diskName, diskSize, diskSize);
  fseek(disk, 1 * SECTOR_SIZE, SEEK_SET);
  if (fread(ptr, 1, SECTOR_SIZE, disk) != SECTOR_SIZE) {
    error("cannot read partition table from disk image '%s'", diskName);
  }
  convertPartitionTable(ptr, NPE);
  /* get partition number, determine start and size of partition */
  partno = strtol(partNmbr, &endp, 10);
  if (*endp != '\0') {
    error("cannot read partition number");
  }
  if (partno < 0 || partno > 15) {
    error("illegal partition number %d", partno);
  }
  if ((ptr[partno].type & 0x7FFFFFFF) == 0) {
    error("partition %d is not allocated in partition table", partno);
  }
  partStart = ptr[partno].start;
  partSize = ptr[partno].size;
  printf("partition %d: start sector %u (0x%X), size is %u (0x%X) sectors\n",
         partno, partStart, partStart, partSize, partSize);
  if (partStart >= diskSize || partStart + partSize > diskSize) {
    error("partition %d is larger than the disk", partno);
  }
  fseek(disk, partStart * SECTOR_SIZE, SEEK_SET);
  /* open partition image, check size (rounded up to whole sectors) */
  image = fopen(partName, "rb");
  if (image == NULL) {
    error("cannot open partition image '%s'", partName);
  }
  fseek(image, 0, SEEK_END);
  imageSize = (ftell(image) + SECTOR_SIZE - 1) / SECTOR_SIZE;
  printf("partition image '%s' occupies %d (0x%X) sectors\n",
         partName, imageSize, imageSize);
  if (imageSize > partSize) {
    error("partition image (%d sectors) too big for partition (%d sectors)",
          imageSize, partSize);
  }
  fseek(image, 0, SEEK_SET);
  /* copy partition image to partition on disk */
  for (i = 0; i < imageSize; i++) {
    n = fread(sectBuf, 1, SECTOR_SIZE, image);
    if (n != SECTOR_SIZE) {
      if (i != imageSize - 1) {
        error("cannot read partition image '%s'", partName);
      } else {
        while (n < SECTOR_SIZE) {
          sectBuf[n++] = 0;
        }
      }
    }
    n = fwrite(sectBuf, 1, SECTOR_SIZE, disk);
    if (n != SECTOR_SIZE) {
      error("cannot write disk image '%s'", diskName);
    }
  }
  printf("partition image '%s' (%d sectors) copied to partition %d\n",
         partName, imageSize, partno);
  fclose(image);
  fclose(disk);
  return 0;
}
