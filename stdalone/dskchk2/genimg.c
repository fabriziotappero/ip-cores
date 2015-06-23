/*
 * genimg.c -- generate test image
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>


#define NUM_SECTORS	262144		/* sync with image checker */
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


static void usage(char *myself) {
  printf("Usage: %s <image file name>\n", myself);
  exit(1);
}


int main(int argc, char *argv[]) {
  char *imageFileName;
  FILE *imageFile;
  unsigned int sector;
  unsigned char buffer[SECTOR_SIZE];
  int i;
  unsigned int number;

  if (argc != 2) {
    usage(argv[0]);
  }
  imageFileName = argv[1];
  imageFile = fopen(imageFileName, "w");
  if (imageFile == NULL) {
    error("cannot open image file '%s'", imageFileName);
  }
  for (sector = 0; sector < NUM_SECTORS; sector++) {
    setRandomSeed(sector);
    for (i = 0; i < SECTOR_SIZE / 4; i++) {
      number = nextRandomNumber();
      buffer[4 * i + 0] = (number >> 24) & 0xFF;
      buffer[4 * i + 1] = (number >> 16) & 0xFF;
      buffer[4 * i + 2] = (number >>  8) & 0xFF;
      buffer[4 * i + 3] = (number >>  0) & 0xFF;
    }
    if (fwrite(buffer, 1, SECTOR_SIZE, imageFile) != SECTOR_SIZE) {
      error("cannot write image file '%s'", imageFileName);
    }
  }
  fclose(imageFile);
  return 0;
}
