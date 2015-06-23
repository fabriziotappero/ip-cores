/*
 * mboot.c -- the master bootstrap (boot manager)
 */


#include "stdarg.h"
#include "biolib.h"


#define DEFAULT_PARTITION	""	/* default boot partition number */

#define LOAD_ADDR		0xC0010000

#define LINE_SIZE		80
#define SECTOR_SIZE		512
#define NPE			(SECTOR_SIZE / sizeof(PartEntry))
#define DESCR_SIZE		20


unsigned int bootDisk = 0;	/* gets loaded by previous stage */
unsigned int startSector = 0;	/* gets loaded by previous stage */
unsigned int numSectors = 0;	/* gets loaded by previous stage */


typedef struct {
  unsigned int type;
  unsigned int start;
  unsigned int size;
  char descr[DESCR_SIZE];
} PartEntry;

PartEntry ptr[NPE];


int strlen(char *str) {
  int i;

  i = 0;
  while (*str++ != '\0') {
    i++;
  }
  return i;
}


void strcpy(char *dst, char *src) {
  while ((*dst++ = *src++) != '\0') ;
}


char getchar(void) {
  return getc();
}


void putchar(char c) {
  if (c == '\n') {
    putchar('\r');
  }
  putc(c);
}


void puts(char *s) {
  char c;

  while ((c = *s++) != '\0') {
    putchar(c);
  }
}


void getline(char *prompt, char *line, int n) {
  int i;
  char c;

  puts(prompt);
  puts(line);
  i = strlen(line);
  while (i < n - 1) {
    c = getchar();
    if (c >= ' ' && c < 0x7F) {
      putchar(c);
      line[i] = c;
      i++;
    } else
    if (c == '\r') {
      putchar('\n');
      line[i] = '\0';
      i = n - 1;
    } else
    if (c == '\b' || c == 0x7F) {
      if (i > 0) {
        putchar('\b');
        putchar(' ');
        putchar('\b');
        i--;
      }
    }
  }
  line[n - 1] = '\0';
}


int countPrintn(int n) {
  int a;
  int res;

  res = 0;
  if (n < 0) {
    res++;
    n = -n;
  }
  a = n / 10;
  if (a != 0) {
    res += countPrintn(a);
  }
  return res + 1;
}


void printn(int n) {
  int a;

  if (n < 0) {
    putchar('-');
    n = -n;
  }
  a = n / 10;
  if (a != 0) {
    printn(a);
  }
  putchar(n % 10 + '0');
}


void printf(char *fmt, ...) {
  va_list ap;
  char c;
  int n;
  unsigned int u;
  char *s;
  char filler;
  int width, count, i;

  va_start(ap, fmt);
  while (1) {
    while ((c = *fmt++) != '%') {
      if (c == '\0') {
        va_end(ap);
        return;
      }
      putchar(c);
    }
    c = *fmt++;
    if (c == '0') {
      filler = '0';
      c = *fmt++;
    } else {
      filler = ' ';
    }
    width = 0;
    if (c >= '0' && c <= '9') {
      width = c - '0';
      c = *fmt++;
    }
    if (c == 'd') {
      n = va_arg(ap, int);
      if (width > 0) {
        count = countPrintn(n);
        for (i = 0; i < width - count; i++) {
          putchar(filler);
        }
      }
      printn(n);
    } else
    if (c == 's') {
      s = va_arg(ap, char *);
      puts(s);
    } else
    if (c == 'c') {
      c = va_arg(ap, char);
      putchar(c);
    } else {
      putchar(c);
    }
  }
}


void halt(void) {
  printf("bootstrap halted\n");
  while (1) ;
}


void readDisk(unsigned int sector, unsigned char *buffer, int count) {
  int result;

  if (sector + count > numSectors) {
    printf("sector number exceeds disk or partition size\n");
    halt();
  }
  result = rwscts(bootDisk, 'r', sector + startSector,
                  (unsigned int) buffer & 0x3FFFFFFF, count);
  if (result != 0) {
    printf("disk read error\n");
    halt();
  }
}


unsigned int entryPoint;	/* where to continue from main() */


int main(void) {
  int i;
  char line[LINE_SIZE];
  char *p;
  int part;

  printf("Bootstrap manager executing...\n");
  strcpy(line, DEFAULT_PARTITION);
  readDisk(1, (unsigned char *) ptr, 1);
  while (1) {
    printf("\nPartitions:\n");
    printf(" # | b | description\n");
    printf("---+---+----------------------\n");
    for (i = 0; i < NPE; i++) {
      if (ptr[i].type != 0) {
        printf("%2d | %s | %s\n",
               i, ptr[i].type & 0x80000000 ? "*" : " ", ptr[i].descr);
      }
    }
    getline("\nBoot partition #: ", line, LINE_SIZE);
    part = 0;
    if (line[0] == '\0') {
      continue;
    }
    p = line;
    while (*p >= '0' && *p <= '9') {
      part = part * 10 + (*p - '0');
      p++;
    }
    if (*p != '\0' || part < 0 || part > 15) {
      printf("illegal partition number\n");
      continue;
    }
    if ((ptr[part].type & 0x7FFFFFFF) == 0) {
      printf("partition %d does not contain a file system\n", part);
      continue;
    }
    if ((ptr[part].type & 0x80000000) == 0) {
      printf("partition %d is not bootable\n", part);
      continue;
    }
    /* load boot sector of selected partition */
    readDisk(ptr[part].start, (unsigned char *) LOAD_ADDR, 1);
    /* check for signature */
    if ((*((unsigned char *) LOAD_ADDR + SECTOR_SIZE - 2) != 0x55) ||
        (*((unsigned char *) LOAD_ADDR + SECTOR_SIZE - 1) != 0xAA)) {
      printf("boot sector of partition %d has no signature\n", part);
      continue;
    }
    /* we have a valid boot sector, leave loop */
    break;
  }
  /* boot manager finished, now go executing loaded boot sector */
  startSector = ptr[part].start;
  numSectors = ptr[part].size;
  entryPoint = LOAD_ADDR;
  return 0;
}
