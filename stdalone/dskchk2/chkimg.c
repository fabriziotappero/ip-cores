/*
 * chkimg.c -- check test image
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>


#define NUM_SECTORS	262144		/* sync with image generator */
#define SECTOR_SIZE	512


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


static unsigned int randomState = 0;


void setRandomSeed(unsigned int seed) {
  randomState = seed;
}


unsigned int nextRandomNumber(void) {
  unsigned int retVal;

  retVal = randomState;
  randomState = randomState * 1103515245 + 12345;
  return retVal;
}


/**************************************************************/


static unsigned int randomSector = 0xDEADBEEF;


unsigned int nextRandomSector(unsigned int numSectors) {
  randomSector = randomSector * 1103515245 + 12345;
  return randomSector % numSectors;
}


/**************************************************************/


static void usage(char *myself) {
  printf("Usage: %s <image file name> <number of checks>\n", myself);
  exit(1);
}


int main(int argc, char *argv[]) {
  char *imageFileName;
  unsigned int numChecks;
  char *endptr;
  FILE *imageFile;
  unsigned int check;
  unsigned int sectorRequ;
  unsigned char buffer[SECTOR_SIZE];
  int i;
  unsigned int sectorRead;
  unsigned int number;
  unsigned int wrong, corrupted;

  printf("\nIDE disk check\n\n");
  if (argc != 3) {
    usage(argv[0]);
  }
  imageFileName = argv[1];
  imageFile = fopen(imageFileName, "r");
  if (imageFile == NULL) {
    error("cannot open image file '%s'", imageFileName);
  }
  numChecks = strtoul(argv[2], &endptr, 0);
  if (*endptr != '\0') {
    error("illegal number of checks");
  }
  if (numChecks < 1) {
    error("number of checks too small");
  }
  wrong = 0;
  corrupted = 0;
  for (check = 0; check < numChecks; check++) {
    sectorRequ = nextRandomSector(NUM_SECTORS);
    fseek(imageFile, sectorRequ * SECTOR_SIZE, SEEK_SET);
    if (fread(buffer, 1, SECTOR_SIZE, imageFile) != SECTOR_SIZE) {
      error("cannot read image file '%s'", imageFileName);
    }
    sectorRead = (buffer[0] << 24) |
                 (buffer[1] << 16) |
                 (buffer[2] <<  8) |
                 (buffer[3] <<  0);
    if (sectorRead != sectorRequ) {
      wrong++;
    }
    setRandomSeed(sectorRead);
    for (i = 0; i < SECTOR_SIZE / 4; i++) {
      number = (buffer[4 * i + 0] << 24) |
               (buffer[4 * i + 1] << 16) |
               (buffer[4 * i + 2] <<  8) |
               (buffer[4 * i + 3] <<  0);
      if (number != nextRandomNumber()) {
        corrupted++;
        break;
      }
    }
    printf("check #%06d: requ 0x%08x, read 0x%08x, sector %s\n",
           check, sectorRequ, sectorRead,
           i == SECTOR_SIZE / 4 ? "ok" : "corrupted");
  }
  fclose(imageFile);
  printf("\nTotal number of sectors: %u read, %u wrong, %u corrupted\n\n",
         numChecks, wrong, corrupted);
  return 0;
}
