/*
 * output.c -- output to file on host system
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "common.h"
#include "console.h"
#include "error.h"
#include "output.h"


static FILE *outputFile;


Word outputRead(Word addr) {
  if (outputFile == NULL) {
    /* output device not installed */
    error("output device not installed");
  }
  /* output device always returns 0 on read */
  return 0;
}


void outputWrite(Word addr, Word data) {
  char c;

  if (outputFile == NULL) {
    /* output device not installed */
    error("output device not installed");
  }
  c = data;
  if (fwrite(&c, 1, 1, outputFile) != 1) {
    error("write error on output device");
  }
}


void outputReset(void) {
  if (outputFile == NULL) {
    /* output device not installed */
    return;
  }
  cPrintf("Resetting Output Device...\n");
  fseek(outputFile, 0, SEEK_SET);
}


void outputInit(char *outputFileName) {
  if (outputFileName == NULL) {
    /* do not install output device */
    outputFile = NULL;
  } else {
    /* try to install output device */
    outputFile = fopen(outputFileName, "wb");
    if (outputFile == NULL) {
      error("cannot open output device file '%s'", outputFileName);
    }
    setvbuf(outputFile, NULL, _IONBF, 0);
  }
  outputReset();
}


void outputExit(void) {
  if (outputFile == NULL) {
    /* output device not installed */
    return;
  }
  fclose(outputFile);
}
