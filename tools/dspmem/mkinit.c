/*
 * mkinit.c -- generate Verilog defparam statements from C data
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#define ATT_HI_FILE_NAME	"dspatthi.init"
#define ATT_LO_FILE_NAME	"dspattlo.init"
#define CHR_HI_FILE_NAME	"dspchrhi.init"
#define CHR_LO_FILE_NAME	"dspchrlo.init"


unsigned char data[][80] = {
  #include "screen"
};


int main(void) {
  FILE *outFile;
  int i, j;
  unsigned char b[64];
  int index, row, col;

  if (sizeof(data) != 30 * 80) {
    printf("Error: wrong size of data\n");
    exit(1);
  }
  outFile = fopen(ATT_HI_FILE_NAME, "w");
  if (outFile == NULL) {
    printf("Error: cannot open file '%s'\n", ATT_HI_FILE_NAME);
    exit(1);
  }
  for (i = 0; i < 64; i++) {
    fprintf(outFile, "  defparam display_att_hi.INIT_%02X = 256'h", i);
    for (j = 0; j < 64; j++) {
      index = i * 64 + j;
      row = index / 128;
      col = index % 128;
      if (0 <= row && row < 30 &&
          0 <= col && col < 80) {
        b[j] = 0x07;
      } else {
        b[j] = 0;
      }
    }
    for (j = 63; j >= 0; j--) {
      fprintf(outFile, "%01X", (b[j] >> 4) & 0x0F);
    }
    fprintf(outFile, ";\n");
  }
  fclose(outFile);
  outFile = fopen(ATT_LO_FILE_NAME, "w");
  if (outFile == NULL) {
    printf("Error: cannot open file '%s'\n", ATT_LO_FILE_NAME);
    exit(1);
  }
  for (i = 0; i < 64; i++) {
    fprintf(outFile, "  defparam display_att_lo.INIT_%02X = 256'h", i);
    for (j = 0; j < 64; j++) {
      index = i * 64 + j;
      row = index / 128;
      col = index % 128;
      if (0 <= row && row < 30 &&
          0 <= col && col < 80) {
        b[j] = 0x07;
      } else {
        b[j] = 0;
      }
    }
    for (j = 63; j >= 0; j--) {
      fprintf(outFile, "%01X", (b[j] >> 0) & 0x0F);
    }
    fprintf(outFile, ";\n");
  }
  fclose(outFile);
  outFile = fopen(CHR_HI_FILE_NAME, "w");
  if (outFile == NULL) {
    printf("Error: cannot open file '%s'\n", CHR_HI_FILE_NAME);
    exit(1);
  }
  for (i = 0; i < 64; i++) {
    fprintf(outFile, "  defparam display_chr_hi.INIT_%02X = 256'h", i);
    for (j = 0; j < 64; j++) {
      index = i * 64 + j;
      row = index / 128;
      col = index % 128;
      if (0 <= row && row < 30 &&
          0 <= col && col < 80) {
        b[j] = data[row][col];
      } else {
        b[j] = 0;
      }
    }
    for (j = 63; j >= 0; j--) {
      fprintf(outFile, "%01X", (b[j] >> 4) & 0x0F);
    }
    fprintf(outFile, ";\n");
  }
  fclose(outFile);
  outFile = fopen(CHR_LO_FILE_NAME, "w");
  if (outFile == NULL) {
    printf("Error: cannot open file '%s'\n", CHR_LO_FILE_NAME);
    exit(1);
  }
  for (i = 0; i < 64; i++) {
    fprintf(outFile, "  defparam display_chr_lo.INIT_%02X = 256'h", i);
    for (j = 0; j < 64; j++) {
      index = i * 64 + j;
      row = index / 128;
      col = index % 128;
      if (0 <= row && row < 30 &&
          0 <= col && col < 80) {
        b[j] = data[row][col];
      } else {
        b[j] = 0;
      }
    }
    for (j = 63; j >= 0; j--) {
      fprintf(outFile, "%01X", (b[j] >> 0) & 0x0F);
    }
    fprintf(outFile, ";\n");
  }
  fclose(outFile);
  return 0;
}
