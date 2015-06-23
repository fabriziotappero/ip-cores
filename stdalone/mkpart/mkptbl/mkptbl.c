/*
 * mkptbl.c -- make partition table
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>


#define SECTOR_SIZE	512
#define NPE		(SECTOR_SIZE / sizeof(PartEntry))
#define DESCR_SIZE	20

#define LINE_SIZE	100


typedef struct {
  unsigned int type;
  unsigned int start;
  unsigned int size;
  char descr[DESCR_SIZE];
} PartEntry;

PartEntry ptr[NPE];


void error(char *fmt, ...) {
  va_list ap;

  va_start(ap, fmt);
  printf("Error: ");
  vprintf(fmt, ap);
  printf("\n");
  va_end(ap);
  exit(1);
}


void convertNumber(unsigned char *p, unsigned int val) {
  *(p + 0) = val >> 24;
  *(p + 1) = val >> 16;
  *(p + 2) = val >>  8;
  *(p + 3) = val >>  0;
}


void convertPartitionTable(PartEntry *e, int n) {
  int i;
  unsigned char *p;

  for (i = 0; i < n; i++) {
    p = (unsigned char *) &e[i];
    convertNumber(p + 0, e[i].type);
    convertNumber(p + 4, e[i].start);
    convertNumber(p + 8, e[i].size);
  }
}


int parseNumber(char **pc, unsigned int *pi) {
  char *p;
  unsigned int base, dval;
  unsigned int n;

  p = *pc;
  while (*p == ' ' || *p == '\t') {
    p++;
  }
  if (*p == '\0' || *p == '\n') {
    printf("Error: number is missing!\n");
    return 0;
  }
  base = 10;
  if (*p == '0') {
    p++;
    if (*p != '\0' && *p != '\n') {
      if (*p == 'x' || *p == 'X') {
        base = 16;
        p++;
      } else {
        base = 8;
      }
    }
  }
  n = 0;
  while ((*p >= '0' && *p <= '9') ||
         (*p >= 'a' && *p <= 'f') ||
         (*p >= 'A' && *p <= 'F')) {
    if (*p >= '0' && *p <= '9') {
      dval = (*p - '0');
    } else
    if (*p >= 'a' && *p <= 'f') {
      dval = (*p - 'a' + 10);
    } else
    if (*p >= 'A' && *p <= 'F') {
      dval = (*p - 'A' + 10);
    }
    if (dval >= base) {
      printf("Error: digit value %d is illegal in number base %d\n",
             dval, base);
      return 0;
    }
    n *= base;
    n += dval;
    p++;
  }
  while (*p == ' ' || *p == '\t') {
    p++;
  }
  *pc = p;
  *pi = n;
  return 1;
}


int parseString(char **pc, char *dst) {
  char *p;

  p = *pc;
  while (*p == ' ' || *p == '\t') {
    p++;
  }
  if (*p != '\"') {
    return 0;
  }
  p++;
  while (*p != '\"' && *p != '\0' && *p != '\n') {
    *dst++ = *p++;
  }
  if (*p != '\"') {
    return 0;
  }
  p++;
  while (*p == ' ' || *p == '\t') {
    p++;
  }
  *pc = p;
  *dst = '\0';
  return 1;
}


int main(int argc, char *argv[]) {
  char *confName;
  char *outName;
  FILE *conf;
  FILE *out;
  char line[LINE_SIZE];
  char *p;
  int lineNumber;
  unsigned int partNum;
  unsigned int bootable;
  unsigned int partType;
  unsigned int partStart;
  unsigned int partLast;
  unsigned int partSize;
  char descr[LINE_SIZE];

  /* check command line arguments */
  if (argc != 3) {
    printf("Usage: %s <configuration file> <output file>\n", argv[0]);
    exit(1);
  }
  confName = argv[1];
  outName = argv[2];
  /* create partition table */
  conf = fopen(confName, "rt");
  if (conf == NULL) {
    error("cannot open configuration file '%s'", confName);
  }
  lineNumber = 0;
  /* handle partition table entries */
  while (fgets(line, LINE_SIZE, conf) != NULL) {
    lineNumber++;
    p = line;
    while (*p == ' ' || *p == '\t') {
      p++;
    }
    if (*p == '\0' || *p == '\n' || *p == '#') {
      continue;
    }
    if (!parseNumber(&p, &partNum)) {
      error("cannot read partition number in config file '%s', line %d",
            confName, lineNumber);
    }
    if (partNum >= 16) {
      error("illegal partition number in config file '%s', line %d",
            confName, lineNumber);
    }
    if (*p == '*') {
      p++;
      bootable = 0x80000000;
    } else {
      bootable = 0x00000000;
    }
    if (!parseNumber(&p, &partType)) {
      error("cannot read partition type in config file '%s', line %d",
            confName, lineNumber);
    }
    if ((partType & 0x80000000) != 0) {
      error("illegal partition type in config file '%s', line %d",
            confName, lineNumber);
    }
    if (!parseNumber(&p, &partStart)) {
      error("cannot read start sector in config file '%s', line %d",
            confName, lineNumber);
    }
    if (partStart < 32) {
      error("illegal start sector in config file '%s', line %d",
            confName, lineNumber);
    }
    if (!parseNumber(&p, &partLast)) {
      error("cannot read last sector in config file '%s', line %d",
            confName, lineNumber);
    }
    if (partLast < partStart) {
      error("illegal last sector in config file '%s', line %d",
            confName, lineNumber);
    }
    partSize = partLast - partStart + 1;
    if (!parseString(&p, descr)) {
      error("cannot read description in config file '%s', line %d",
            confName, lineNumber);
    }
    if (strlen(descr) >= DESCR_SIZE) {
      error("description too long in config file '%s', line %d",
            confName, lineNumber);
    }
    if (partType != 0) {
      ptr[partNum].type = bootable | partType;
      ptr[partNum].start = partStart;
      ptr[partNum].size = partSize;
      memset(ptr[partNum].descr, 0, DESCR_SIZE);
      strcpy(ptr[partNum].descr, descr);
    } else {
      ptr[partNum].type = 0;
      ptr[partNum].start = 0;
      ptr[partNum].size = 0;
      memset(ptr[partNum].descr, 0, DESCR_SIZE);
    }
  }
  fclose(conf);
  /* next, show partition table */
  printf("Partitions:\n");
  printf(" # b type       start      last       size       description\n");
  for (partNum = 0; partNum < NPE; partNum++) {
    if (ptr[partNum].type != 0) {
      partLast = ptr[partNum].start + ptr[partNum].size - 1;
    } else {
      partLast = 0;
    }
    printf("%2u %s 0x%08X 0x%08X 0x%08X 0x%08X %s\n",
           partNum,
           ptr[partNum].type & 0x80000000 ? "*" : " ",
           ptr[partNum].type & 0x7FFFFFFF,
           ptr[partNum].start,
           partLast,
           ptr[partNum].size,
           ptr[partNum].descr);
  }
  /* finally, write partition table to output file */
  convertPartitionTable(ptr, NPE);
  out = fopen(outName, "wb");
  if (out == NULL) {
    error("cannot open output file '%s'", outName);
  }
  if (fwrite(ptr, 1, SECTOR_SIZE, out) != SECTOR_SIZE) {
    error("cannot write partition table to output file '%s'", outName);
  }
  fclose(out);
  /* done */
  return 0;
}
