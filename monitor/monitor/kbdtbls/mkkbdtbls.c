/*
 * mkkbdtbls.c -- construct keyboard translation tables
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>


typedef struct {
  unsigned char ascii;
  unsigned char key;
} Entry;


Entry tbl1[] = {
  { 0x1B, 0x76 },
  { '1',  0x16 },
  { '2',  0x1E },
  { '3',  0x26 },
  { '4',  0x25 },
  { '5',  0x2E },
  { '6',  0x36 },
  { '7',  0x3D },
  { '8',  0x3E },
  { '9',  0x46 },
  { '0',  0x45 },
  { '^',  0x0E },
  { 0x08, 0x66 },
  { 0x09, 0x0D },
  { 'q',  0x15 },
  { 'w',  0x1D },
  { 'e',  0x24 },
  { 'r',  0x2D },
  { 't',  0x2C },
  { 'z',  0x35 },
  { 'u',  0x3C },
  { 'i',  0x43 },
  { 'o',  0x44 },
  { 'p',  0x4D },
  { '\r', 0x5A },
  { ' ',  0x29 },
  { 'a',  0x1C },
  { 's',  0x1B },
  { 'd',  0x23 },
  { 'f',  0x2B },
  { 'g',  0x34 },
  { 'h',  0x33 },
  { 'j',  0x3B },
  { 'k',  0x42 },
  { 'l',  0x4B },
  { 'y',  0x1A },
  { 'x',  0x22 },
  { 'c',  0x21 },
  { 'v',  0x2A },
  { 'b',  0x32 },
  { 'n',  0x31 },
  { 'm',  0x3A },
  { ',',  0x41 },
  { '.',  0x49 },
  { '-',  0x4A },
  { '+',  0x5B },
  { '#',  0x5D },
  { '<',  0x61 },
};


Entry tbl2[] = {
  { 0x1B, 0x76 },
  { '!',  0x16 },
  { '"',  0x1E },
  { '3',  0x26 },
  { '$',  0x25 },
  { '%',  0x2E },
  { '&',  0x36 },
  { '/',  0x3D },
  { '(',  0x3E },
  { ')',  0x46 },
  { '=',  0x45 },
  { '^',  0x0E },
  { 0x08, 0x66 },
  { 0x09, 0x0D },
  { 'Q',  0x15 },
  { 'W',  0x1D },
  { 'E',  0x24 },
  { 'R',  0x2D },
  { 'T',  0x2C },
  { 'Z',  0x35 },
  { 'U',  0x3C },
  { 'I',  0x43 },
  { 'O',  0x44 },
  { 'P',  0x4D },
  { '\r', 0x5A },
  { ' ',  0x29 },
  { 'A',  0x1C },
  { 'S',  0x1B },
  { 'D',  0x23 },
  { 'F',  0x2B },
  { 'G',  0x34 },
  { 'H',  0x33 },
  { 'J',  0x3B },
  { 'K',  0x42 },
  { 'L',  0x4B },
  { 'Y',  0x1A },
  { 'X',  0x22 },
  { 'C',  0x21 },
  { 'V',  0x2A },
  { 'B',  0x32 },
  { 'N',  0x31 },
  { 'M',  0x3A },
  { ';',  0x41 },
  { ':',  0x49 },
  { '_',  0x4A },
  { '*',  0x5B },
  { '\'',  0x5D },
  { '>',  0x61 },
};


int main(void) {
  unsigned char codes[256];
  int i, j;

  for (i = 0; i < 256; i++) {
    codes[i] = '\0';
  }
  for (i = 0; i < sizeof(tbl1)/sizeof(tbl1[0]); i++) {
    codes[tbl1[i].key] = tbl1[i].ascii;
  }
  printf(";\n");
  printf("; keyboard code tables\n");
  printf(";\n");
  printf("\n");
  printf("\t.export\txltbl1\n");
  printf("\t.export\txltbl2\n");
  printf("\n");
  printf("\t.code\n");
  printf("\t.align\t4\n");
  printf("\n");
  printf("xltbl1:\n");
  for (i = 0; i < 32; i++) {
    printf("\t.byte\t");
    for (j = 0; j < 8; j++) {
      printf("0x%02X", codes[i * 8 + j]);
      if (j < 7) {
        printf(", ");
      }
    }
    printf("\n");
  }
  printf("\n");
  for (i = 0; i < 256; i++) {
    codes[i] = '\0';
  }
  for (i = 0; i < sizeof(tbl2)/sizeof(tbl2[0]); i++) {
    codes[tbl2[i].key] = tbl2[i].ascii;
  }
  printf("xltbl2:\n");
  for (i = 0; i < 32; i++) {
    printf("\t.byte\t");
    for (j = 0; j < 8; j++) {
      printf("0x%02X", codes[i * 8 + j]);
      if (j < 7) {
        printf(", ");
      }
    }
    printf("\n");
  }
  return 0;
}
