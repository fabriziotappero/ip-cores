/*
 * ranlib.c -- archive index generator
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <time.h>
#include <fcntl.h>

#include "endian.h"
#include "ranlib.h"
#include "../include/ar.h"
#include "../include/a.out.h"


#define TEMP_NAME		"__.SYMDEF"

#define STRING_SIZE_INIT	1024
#define STRING_SIZE_GROW	2

#define MAX_SYM_ENTRIES		1000

#define MSB	((unsigned int) 1 << (sizeof(unsigned int) * 8 - 1))


typedef struct {
  unsigned int name;	/* name of symbol (as offset into string space) */
  long position;	/* position of member which defines the symbol */
			/* (as file offset to the member's ArHeader) */
} Entry;


FILE *fi;
FILE *fo;

long nxtOff;		/* file offset to next member */
long curOff;

Entry table[MAX_SYM_ENTRIES];
int numEntries;

int createIndex;
char firstName[MAX_NAME];

ArHeader arhdr;
ExecHeader exhdr;


/**************************************************************/


char *stringArea = NULL;
unsigned int sizeAllocated = 0;
unsigned int sizeUsed = 0;


unsigned int getStringPos(void) {
  return sizeUsed;
}


void storeCharacter(char c) {
  unsigned int newSize;
  char *newArea;

  if (sizeUsed + 1 > sizeAllocated) {
    if (sizeAllocated == 0) {
      newSize = STRING_SIZE_INIT;
    } else {
      newSize = STRING_SIZE_GROW * sizeAllocated;
    }
    newArea = malloc(newSize);
    if (newArea == NULL) {
      fprintf(stderr, "ar: cannot allocate string area\n");
      exit(1);
    }
    if (stringArea != NULL) {
      memcpy(newArea, stringArea, sizeUsed);
      free(stringArea);
    }
    stringArea = newArea;
    sizeAllocated = newSize;
  }
  stringArea[sizeUsed++] = c;
}


/**************************************************************/


int nextMember(void) {
  int pad;

  curOff = nxtOff;
  fseek(fi, nxtOff, SEEK_SET);
  if (fread(&arhdr, sizeof(arhdr), 1, fi) != 1) {
    return 0;
  }
  conv4FromEcoToNative((unsigned char *) &arhdr.date);
  conv4FromEcoToNative((unsigned char *) &arhdr.uid);
  conv4FromEcoToNative((unsigned char *) &arhdr.gid);
  conv4FromEcoToNative((unsigned char *) &arhdr.mode);
  conv4FromEcoToNative((unsigned char *) &arhdr.size);
  pad = -arhdr.size & 0x03;
  arhdr.size += pad;
  nxtOff = ftell(fi) + arhdr.size;
  return 1;
}


void addSymbol(unsigned int nameOffset) {
  long curPos;
  int c;

  if (numEntries >= MAX_SYM_ENTRIES) {
    fprintf(stderr, "ar: symbol table overflow\n");
    exit(1);
  }
  table[numEntries].name = getStringPos();
  table[numEntries].position = curOff;
  numEntries++;
  curPos = ftell(fi);
  fseek(fi, curOff + sizeof(arhdr) + nameOffset, SEEK_SET);
  do {
    c = fgetc(fi);
    storeCharacter(c);
  } while (c != 0) ;
  fseek(fi, curPos, SEEK_SET);
}


void fixSize(void) {
  long deltaOff;
  int pad;
  int i;

  deltaOff = sizeof(arhdr) + sizeof(int) +
             numEntries * sizeof(Entry) + getStringPos();
  pad = -deltaOff & 0x03;
  deltaOff += pad;
  nxtOff = sizeof(unsigned int);
  nextMember();
  if(strncmp(arhdr.name, TEMP_NAME, MAX_NAME) == 0) {
    /* there is an index already present */
    createIndex = 0;
    deltaOff -= sizeof(arhdr) + arhdr.size;
  } else {
    /* no index yet present, create new one */
    createIndex = 1;
    strncpy(firstName, arhdr.name, MAX_NAME);
  }
  for (i = 0; i < numEntries; i++) {
    table[i].position += deltaOff;
  }
}


/**************************************************************/


void showSymdefs(char *symdefs) {
  FILE *in;
  int numSymbols;
  int i;
  Entry e;
  long curPos;
  long pos;
  int c;

  in = fopen(symdefs, "r");
  if (in == NULL) {
    printf("error: cannot open symdef file '%s'\n", symdefs);
    exit(1);
  }
  if (fread(&numSymbols, sizeof(int), 1, in) != 1) {
    printf("cannot read symdef file\n");
    exit(1);
  }
  conv4FromEcoToNative((unsigned char *) &numSymbols);
  printf("%d symbols\n", numSymbols);
  for (i = 0; i < numSymbols; i++) {
    if (fread(&e, sizeof(e), 1, in) != 1) {
      printf("cannot read symdef file\n");
      exit(1);
    }
    conv4FromEcoToNative((unsigned char *) &e.name);
    conv4FromEcoToNative((unsigned char *) &e.position);
    printf("%4d: name = 0x%08X, position = 0x%08lX, string = '",
           i, e.name, e.position);
    curPos = ftell(in);
    pos = sizeof(int) + numSymbols * sizeof(Entry) + e.name;
    fseek(in, pos, SEEK_SET);
    while (1) {
      c = fgetc(in);
      if (c == EOF) {
        printf("\nerror: unexpected end of file\n");
        exit(1);
      }
      if (c == 0) {
        break;
      }
      printf("%c", c);
    }
    printf("'\n");
    fseek(in, curPos, SEEK_SET);
  }
  fclose(in);
}


/**************************************************************/


int hasSymbols(char *archive) {
  unsigned int arMagic;
  int res;

  fi = fopen(archive, "r");
  if (fi == NULL) {
    return 0;
  }
  nxtOff = sizeof(unsigned int);
  if (fread(&arMagic, sizeof(arMagic), 1, fi) != 1 ||
      read4FromEco((unsigned char *) &arMagic) != AR_MAGIC) {
    fclose(fi);
    return 0;
  }
  fseek(fi, 0, SEEK_SET);
  if (nextMember() == 0) {
    fclose(fi);
    return 0;
  }
  fclose(fi);
  res = (strncmp(arhdr.name, TEMP_NAME, MAX_NAME) == 0);
  return res;
}


int updateSymbols(char *archive, int verbose) {
  unsigned int arMagic;
  unsigned int skip;
  int numSymbols;
  unsigned int stringStart;
  SymbolRecord symbol;
  int i;
  char *args[3];
  int res;

  if (verbose) {
    printf("ar: updating symbols in %s\n", archive);
  }
  fi = fopen(archive, "r");
  if (fi == NULL) {
    fprintf(stderr, "ar: cannot re-open %s\n", archive);
    return 1;
  }
  nxtOff = sizeof(unsigned int);
  if (fread(&arMagic, sizeof(arMagic), 1, fi) != 1 ||
      read4FromEco((unsigned char *) &arMagic) != AR_MAGIC) {
    fprintf(stderr, "ar: %s not in archive format\n", archive);
    fclose(fi);
    return 1;
  }
  fseek(fi, 0, SEEK_SET);
  numEntries = 0;
  if (nextMember() == 0) {
    fclose(fi);
    return 0;
  }
  /* iterate over archive members */
  do {
    if (fread(&exhdr, sizeof(exhdr), 1, fi) != 1 ||
        read4FromEco((unsigned char *) &exhdr.magic) != EXEC_MAGIC) {
      /* archive member not in proper format - skip */
      continue;
    }
    conv4FromEcoToNative((unsigned char *) &exhdr.magic);
    conv4FromEcoToNative((unsigned char *) &exhdr.csize);
    conv4FromEcoToNative((unsigned char *) &exhdr.dsize);
    conv4FromEcoToNative((unsigned char *) &exhdr.bsize);
    conv4FromEcoToNative((unsigned char *) &exhdr.crsize);
    conv4FromEcoToNative((unsigned char *) &exhdr.drsize);
    conv4FromEcoToNative((unsigned char *) &exhdr.symsize);
    conv4FromEcoToNative((unsigned char *) &exhdr.strsize);
    skip = exhdr.csize + exhdr.dsize + exhdr.crsize + exhdr.drsize;
    fseek(fi, skip, SEEK_CUR);
    numSymbols = exhdr.symsize / sizeof(SymbolRecord);
    if (numSymbols == 0) {
      fprintf(stderr,
              "ar: symbol table of %s is empty\n",
              arhdr.name);
      continue;
    }
    stringStart = sizeof(exhdr) + skip + exhdr.symsize;
    /* iterate over symbols */
    while (--numSymbols >= 0) {
      if (fread(&symbol, sizeof(symbol), 1, fi) != 1) {
        fprintf(stderr, "ar: cannot read archive\n");
        break;
      }
      conv4FromEcoToNative((unsigned char *) &symbol.name);
      conv4FromEcoToNative((unsigned char *) &symbol.type);
      conv4FromEcoToNative((unsigned char *) &symbol.value);
      if ((symbol.type & MSB) == 0) {
        /* this is an exported symbol */
        addSymbol(stringStart + symbol.name);
      }
    }
  } while (nextMember() != 0) ;
  fixSize();
  fclose(fi);
  fo = fopen(TEMP_NAME, "w");
  if (fo == NULL) {
    fprintf(stderr, "ar: can't create temporary file\n");
    return 1;
  }
  conv4FromNativeToEco((unsigned char *) &numEntries);
  if (fwrite(&numEntries, sizeof(numEntries), 1, fo) != 1) {
    fprintf(stderr, "ar: can't write temporary file\n");
    fclose(fo);
    unlink(TEMP_NAME);
    return 1;
  }
  conv4FromEcoToNative((unsigned char *) &numEntries);
  for (i = 0; i < numEntries; i++) {
    conv4FromNativeToEco((unsigned char *) &table[i].name);
    conv4FromNativeToEco((unsigned char *) &table[i].position);
  }
  if (fwrite(table, sizeof(Entry), numEntries, fo) != numEntries) {
    fprintf(stderr, "ar: can't write temporary file\n");
    fclose(fo);
    unlink(TEMP_NAME);
    return 1;
  }
  for (i = 0; i < numEntries; i++) {
    conv4FromEcoToNative((unsigned char *) &table[i].name);
    conv4FromEcoToNative((unsigned char *) &table[i].position);
  }
  if (fwrite(stringArea, 1, getStringPos(), fo) != getStringPos()) {
    fprintf(stderr, "ar: can't write temporary file\n");
    fclose(fo);
    unlink(TEMP_NAME);
    return 1;
  }
  fclose(fo);
  if (verbose) {
    showSymdefs(TEMP_NAME);
  }
  if (createIndex) {
    /* ar -rlb firstName archive TEMP_NAME */
    args[0] = firstName;
    args[1] = archive;
    args[2] = TEMP_NAME;
    res = exec_rCmd(1, args);
  } else {
    /* ar -rl archive TEMP_NAME */
    args[0] = archive;
    args[1] = TEMP_NAME;
    args[2] = NULL;
    res = exec_rCmd(0, args);
  }
  unlink(TEMP_NAME);
  return res;
}
