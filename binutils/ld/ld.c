/*
 * ld.c -- ECO32 linking loader
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <ctype.h>
#include <unistd.h>

#include "../include/a.out.h"


/**************************************************************/


#define MAX_STRLEN	200

#define PAGE_SHIFT	12
#define PAGE_SIZE	(1 << PAGE_SHIFT)
#define PAGE_MASK	(PAGE_SIZE - 1)
#define PAGE_ROUND(n)	(((n) + PAGE_SIZE - 1) & ~PAGE_MASK)

#define MSB	((unsigned int) 1 << (sizeof(unsigned int) * 8 - 1))


/**************************************************************/


int debugLink = 0;
int debugFixup = 0;

int withHeader = 1;

char codeName[L_tmpnam];
char dataName[L_tmpnam];
char *outName = NULL;
char *mapName = NULL;
char *inName = NULL;

FILE *codeFile = NULL;
FILE *dataFile = NULL;
FILE *outFile = NULL;
FILE *mapFile = NULL;
FILE *inFile = NULL;

unsigned int segPtr[4] = { 0, 0, 0, 0 };
int segStartDefined[4] = { 0, 0, 0, 0 };
unsigned int segStart[4] = { 0, 0, 0, 0 };
char *segName[4] = { "ABS", "CODE", "DATA", "BSS" };
char *methodName[5] = { "H16", "L16", "R16", "R26", "W32" };


typedef struct reloc {
  int segment;			/* in which segment to relocate */
  unsigned int offset;		/* where in the segment to relocate */
  int method;			/* how to relocate */
  int value;			/* additive part of value */
  int type;			/* 0: base is a segment */
				/* 1: base is a symbol */
  union {			/* relocation relative to .. */
    int segment;		/* .. a segment */
    struct symbol *symbol;	/* .. a symbol */
  } base;
  struct reloc *next;		/* next relocation */
} Reloc;


typedef struct symbol {
  char *name;			/* name of symbol */
  int type;			/* if MSB = 0: the symbol's segment */
				/* if MSB = 1: the symbol is undefined */
  int value;			/* if symbol defined: the symbol's value */
				/* if symbol not defined: meaningless */
  struct symbol *left;		/* left son in binary search tree */
  struct symbol *right;		/* right son in binary search tree */
} Symbol;


/**************************************************************/


void error(char *fmt, ...) {
  va_list ap;

  va_start(ap, fmt);
  fprintf(stderr, "Error: ");
  vfprintf(stderr, fmt, ap);
  fprintf(stderr, "\n");
  va_end(ap);
  if (codeFile != NULL) {
    fclose(codeFile);
    codeFile = NULL;
  }
  if (dataFile != NULL) {
    fclose(dataFile);
    dataFile = NULL;
  }
  if (outFile != NULL) {
    fclose(outFile);
    outFile = NULL;
  }
  if (mapFile != NULL) {
    fclose(mapFile);
    mapFile = NULL;
  }
  if (inFile != NULL) {
    fclose(inFile);
    inFile = NULL;
  }
  if (codeName != NULL) {
    unlink(codeName);
  }
  if (dataName != NULL) {
    unlink(dataName);
  }
  if (outName != NULL) {
    unlink(outName);
  }
  if (mapName != NULL) {
    unlink(mapName);
  }
  exit(1);
}


void *allocateMemory(unsigned int size) {
  void *p;

  p = malloc(size);
  if (p == NULL) {
    error("out of memory");
  }
  return p;
}


void freeMemory(void *p) {
  free(p);
}


/**************************************************************/


Reloc *relocs = NULL;


void addReloc(int segment, RelocRecord *relRec, Symbol **symMap) {
  Reloc *rel;

  rel = allocateMemory(sizeof(Reloc));
  rel->segment = segment;
  rel->offset = relRec->offset + segPtr[segment];
  rel->method = relRec->method;
  rel->value = relRec->value;
  if ((relRec->base & MSB) == 0) {
    /* relocation is relative to a segment */
    rel->type = 0;
    rel->base.segment = relRec->base;
    rel->value += segPtr[relRec->base];
  } else {
    /* relocation is relative to a symbol */
    rel->type = 1;
    rel->base.symbol = symMap[relRec->base & ~MSB];
  }
  rel->next = relocs;
  relocs = rel;
}


void linkSymbol(Reloc *rel) {
  Symbol *sym;

  /* check if this is a reference to a symbol */
  if (rel->type != 1) {
    /* no: nothing to do here */
    return;
  }
  /* get information from the symbol table record */
  sym = rel->base.symbol;
  if (sym->type & MSB) {
    error("undefined symbol '%s'", sym->name);
  }
  /* output debugging info */
  if (debugLink) {
    printf("DEBUG: link '%s' (s:%s, v:%08X)\n",
           sym->name, segName[sym->type], sym->value);
    printf("       (s:%s, o:%08X, m:%s, v:%08X --> %08X, b:%s)\n",
           segName[rel->segment], rel->offset, methodName[rel->method],
           rel->value, rel->value + sym->value, segName[sym->type]);
  }
  /* update relocation information */
  rel->value += sym->value;
  rel->type = 0;
  rel->base.segment = sym->type;
}


void linkSymbols(void) {
  Reloc *rel;

  rel = relocs;
  while (rel != NULL) {
    linkSymbol(rel);
    rel = rel->next;
  }
}


void fixupRef(Reloc *rel) {
  FILE *file;
  unsigned int value;
  unsigned int final;

  /* determine the segment in which to do fixup */
  switch (rel->segment) {
    case SEGMENT_ABS:
      /* this should never happen */
      error("cannot do fixup in ABS");
      break;
    case SEGMENT_CODE:
      file = codeFile;
      break;
    case SEGMENT_DATA:
      file = dataFile;
      break;
    case SEGMENT_BSS:
      /* this should never happen */
      error("cannot do fixup in BSS");
      break;
    default:
      /* this should never happen */
      error("illegal segment in doFixup()");
      break;
  }
  /* check that the base is indeed a segment */
  if (rel->type != 0) {
    /* this should never happen */
    error("fixup cannot handle reference to symbol");
  }
  /* now patch according to method */
  switch (rel->method) {
    case METHOD_H16:
      value = rel->value + segStart[rel->base.segment];
      final = (value >> 16) & 0x0000FFFF;
      fseek(file, rel->offset + 2, SEEK_SET);
      fputc((final >> 8) & 0xFF, file);
      fputc((final >> 0) & 0xFF, file);
      break;
    case METHOD_L16:
      value = rel->value + segStart[rel->base.segment];
      final = value & 0x0000FFFF;
      fseek(file, rel->offset + 2, SEEK_SET);
      fputc((final >> 8) & 0xFF, file);
      fputc((final >> 0) & 0xFF, file);
      break;
    case METHOD_R16:
      value = (rel->value - (rel->offset + 4)) / 4;
      final = value & 0x0000FFFF;
      fseek(file, rel->offset + 2, SEEK_SET);
      fputc((final >> 8) & 0xFF, file);
      fputc((final >> 0) & 0xFF, file);
      break;
    case METHOD_R26:
      value = (rel->value - (rel->offset + 4)) / 4;
      fseek(file, rel->offset, SEEK_SET);
      final = (fgetc(file) << 24) & 0xFC000000;
      final |= value & 0x03FFFFFF;
      fseek(file, -1, SEEK_CUR);
      fputc((final >> 24) & 0xFF, file);
      fputc((final >> 16) & 0xFF, file);
      fputc((final >>  8) & 0xFF, file);
      fputc((final >>  0) & 0xFF, file);
      break;
    case METHOD_W32:
      value = rel->value + segStart[rel->base.segment];
      final = value;
      fseek(file, rel->offset, SEEK_SET);
      fputc((final >> 24) & 0xFF, file);
      fputc((final >> 16) & 0xFF, file);
      fputc((final >>  8) & 0xFF, file);
      fputc((final >>  0) & 0xFF, file);
      break;
    default:
      /* this should never happen */
      error("illegal method in doFixup()");
      break;
  }
  /* output debugging info */
  if (debugFixup) {
    printf("DEBUG: fixup (s:%s, o:%08X, m:%s, v:%08X), %08X --> %08X\n",
           segName[rel->segment], rel->offset, methodName[rel->method],
           rel->value, value, final);
  }
}


void relocateSegments(void) {
  Reloc *rel;

  /* determine start of segments */
  if (!segStartDefined[SEGMENT_CODE]) {
    segStart[SEGMENT_CODE] = 0;
    segStartDefined[SEGMENT_CODE] = 1;
  }
  if (!segStartDefined[SEGMENT_DATA]) {
    segStart[SEGMENT_DATA] = segStart[SEGMENT_CODE] +
                             PAGE_ROUND(segPtr[SEGMENT_CODE]);
    segStartDefined[SEGMENT_DATA] = 1;
  }
  if (!segStartDefined[SEGMENT_BSS]) {
    segStart[SEGMENT_BSS] = segStart[SEGMENT_DATA] +
                            segPtr[SEGMENT_DATA];
    segStartDefined[SEGMENT_BSS] = 1;
  }
  /* fixup all references (which now are only relative to segments) */
  while (relocs != NULL) {
    rel = relocs;
    relocs = rel->next;
    fixupRef(rel);
    freeMemory(rel);
  }
}


/**************************************************************/


Symbol *symbolTable = NULL;


Symbol *newSymbol(char *name) {
  Symbol *p;

  p = allocateMemory(sizeof(Symbol));
  p->name = allocateMemory(strlen(name) + 1);
  strcpy(p->name, name);
  p->type = MSB;
  p->value = 0;
  p->left = NULL;
  p->right = NULL;
  return p;
}


Symbol *lookupEnter(char *name) {
  Symbol *p, *q, *r;
  int cmp;

  p = symbolTable;
  if (p == NULL) {
    r = newSymbol(name);
    symbolTable = r;
    return r;
  }
  while (1) {
    q = p;
    cmp = strcmp(name, q->name);
    if (cmp == 0) {
      return q;
    }
    if (cmp < 0) {
      p = q->left;
    } else {
      p = q->right;
    }
    if (p == NULL) {
      r = newSymbol(name);
      if (cmp < 0) {
        q->left = r;
      } else {
        q->right = r;
      }
      return r;
    }
  }
}


void walkTree(Symbol *s, void (*fp)(Symbol *sp)) {
  if (s == NULL) {
    return;
  }
  walkTree(s->left, fp);
  (*fp)(s);
  walkTree(s->right, fp);
}


void walkSymbols(void (*fp)(Symbol *sym)) {
  walkTree(symbolTable, fp);
}


/**************************************************************/


unsigned int read4FromEco(unsigned char *p) {
  return (unsigned int) p[0] << 24 |
         (unsigned int) p[1] << 16 |
         (unsigned int) p[2] <<  8 |
         (unsigned int) p[3] <<  0;
}


void write4ToEco(unsigned char *p, unsigned int data) {
  p[0] = data >> 24;
  p[1] = data >> 16;
  p[2] = data >>  8;
  p[3] = data >>  0;
}


void conv4FromEcoToNative(unsigned char *p) {
  unsigned int data;

  data = read4FromEco(p);
  * (unsigned int *) p = data;
}


void conv4FromNativeToEco(unsigned char *p) {
  unsigned int data;

  data = * (unsigned int *) p;
  write4ToEco(p, data);
}


/**************************************************************/


#define CODE_START(h)	(sizeof(ExecHeader))
#define DATA_START(h)	(CODE_START(h) + (h).csize)
#define CRELOC_START(h)	(DATA_START(h) + (h).dsize)
#define DRELOC_START(h)	(CRELOC_START(h) + (h).crsize)
#define SYMTBL_START(h)	(DRELOC_START(h) + (h).drsize)
#define STRING_START(h)	(SYMTBL_START(h) + (h).symsize)


ExecHeader inHeader;
Symbol **symMap;


void readHeader(void) {
  if (fseek(inFile, 0, SEEK_SET) < 0) {
    error("cannot seek to exec header");
  }
  if (fread(&inHeader, sizeof(ExecHeader), 1, inFile) != 1) {
    error("cannot read exec header");
  }
  conv4FromEcoToNative((unsigned char *) &inHeader.magic);
  conv4FromEcoToNative((unsigned char *) &inHeader.csize);
  conv4FromEcoToNative((unsigned char *) &inHeader.dsize);
  conv4FromEcoToNative((unsigned char *) &inHeader.bsize);
  conv4FromEcoToNative((unsigned char *) &inHeader.crsize);
  conv4FromEcoToNative((unsigned char *) &inHeader.drsize);
  conv4FromEcoToNative((unsigned char *) &inHeader.symsize);
  conv4FromEcoToNative((unsigned char *) &inHeader.strsize);
  if (inHeader.magic != EXEC_MAGIC) {
    error("wrong magic number in exec header");
  }
}


void readCode(void) {
  unsigned char *buffer;

  if (fseek(inFile, CODE_START(inHeader), SEEK_SET) < 0) {
    error("cannot seek to code section");
  }
  buffer = allocateMemory(inHeader.csize);
  if (fread(buffer, 1, inHeader.csize, inFile) != inHeader.csize) {
    error("cannot read code segment");
  }
  if (fwrite(buffer, 1, inHeader.csize, codeFile) != inHeader.csize) {
    error("cannot write code segment");
  }
  freeMemory(buffer);
}


void readData(void) {
  unsigned char *buffer;

  if (fseek(inFile, DATA_START(inHeader), SEEK_SET) < 0) {
    error("cannot seek to data section");
  }
  buffer = allocateMemory(inHeader.dsize);
  if (fread(buffer, 1, inHeader.dsize, inFile) != inHeader.dsize) {
    error("cannot read data segment");
  }
  if (fwrite(buffer, 1, inHeader.dsize, dataFile) != inHeader.dsize) {
    error("cannot write data segment");
  }
  freeMemory(buffer);
}


void readCodeRelocs(void) {
  int n, i;
  RelocRecord relRec;

  if (fseek(inFile, CRELOC_START(inHeader), SEEK_SET) < 0) {
    error("cannot seek to code relocation section");
  }
  n = inHeader.crsize / sizeof(RelocRecord);
  for (i = 0; i < n; i++) {
    if (fread(&relRec, sizeof(RelocRecord), 1, inFile) != 1) {
      error("cannot read code relocation records");
    }
    conv4FromEcoToNative((unsigned char *) &relRec.offset);
    conv4FromEcoToNative((unsigned char *) &relRec.method);
    conv4FromEcoToNative((unsigned char *) &relRec.value);
    conv4FromEcoToNative((unsigned char *) &relRec.base);
    addReloc(SEGMENT_CODE, &relRec, symMap);
  }
}


void readDataRelocs(void) {
  int n, i;
  RelocRecord relRec;

  if (fseek(inFile, DRELOC_START(inHeader), SEEK_SET) < 0) {
    error("cannot seek to data relocation section");
  }
  n = inHeader.drsize / sizeof(RelocRecord);
  for (i = 0; i < n; i++) {
    if (fread(&relRec, sizeof(RelocRecord), 1, inFile) != 1) {
      error("cannot read data relocation records");
    }
    conv4FromEcoToNative((unsigned char *) &relRec.offset);
    conv4FromEcoToNative((unsigned char *) &relRec.method);
    conv4FromEcoToNative((unsigned char *) &relRec.value);
    conv4FromEcoToNative((unsigned char *) &relRec.base);
    addReloc(SEGMENT_DATA, &relRec, symMap);
  }
}


void readString(unsigned int offset, char *buffer, int size) {
  long pos;
  int c;

  pos = ftell(inFile);
  if (fseek(inFile, STRING_START(inHeader) + offset, SEEK_SET) < 0) {
    error("cannot seek to string");
  }
  do {
    c = fgetc(inFile);
    if (c == EOF) {
      error("unexpected end of file");
    }
    *buffer++ = c;
    if (--size == 0) {
      error("string buffer overflow");
    }
  } while (c != 0);
  fseek(inFile, pos, SEEK_SET);
}


void readSymbols(void) {
  int n, i;
  SymbolRecord symRec;
  char strBuf[MAX_STRLEN];
  Symbol *sym;

  if (fseek(inFile, SYMTBL_START(inHeader), SEEK_SET) < 0) {
    error("cannot seek to symbol table section");
  }
  n = inHeader.symsize / sizeof(SymbolRecord);
  symMap = allocateMemory(n * sizeof(Symbol *));
  for (i = 0; i < n; i++) {
    if (fread(&symRec, sizeof(SymbolRecord), 1, inFile) != 1) {
      error("cannot read symbol table");
    }
    conv4FromEcoToNative((unsigned char *) &symRec.name);
    conv4FromEcoToNative((unsigned char *) &symRec.type);
    conv4FromEcoToNative((unsigned char *) &symRec.value);
    readString(symRec.name, strBuf, MAX_STRLEN);
    sym = lookupEnter(strBuf);
    if ((symRec.type & MSB) == 0) {
      /* the symbol is defined in this symbol record */
      if ((sym->type & MSB) == 0) {
        /* the symbol was already defined in the table */
        error("symbol '%s' multiply defined", sym->name);
      } else {
        /* the symbol was not yet defined in the table, so define it now */
        /* the segment is copied directly from the file */
        /* the value is the sum of the value given in the file */
        /* and this module's segment start of the symbol's segment */
        sym->type = symRec.type;
        sym->value = symRec.value + segPtr[symRec.type];
      }
    } else {
      /* the symbol is undefined in this symbol record */
      /* nothing to do here: lookupEnter already entered */
      /* the symbol into the symbol table, if necessary */
    }
    /* in any case remember the symbol table entry, so that */
    /* a symbol index in a relocation record can be resolved */
    symMap[i] = sym;
  }
}


void readModule(void) {
  /* read the file header to determine the sizes */
  readHeader();
  /* read and transfer the code and data segments */
  readCode();
  readData();
  /* read and build the symbol table and a symbol map */
  readSymbols();
  /* read and build a list of relocation records */
  readCodeRelocs();
  readDataRelocs();
  /* free the symbol map, it is no longer needed */
  freeMemory(symMap);
  /* update accumulated segment sizes */
  segPtr[SEGMENT_CODE] += inHeader.csize;
  segPtr[SEGMENT_DATA] += inHeader.dsize;
  segPtr[SEGMENT_BSS] += inHeader.bsize;
}


/**************************************************************/


void printSymbol(Symbol *s) {
  fprintf(mapFile, "%-32s", s->name);
  if (s->type & MSB) {
    /* symbol is undefined */
    fprintf(mapFile, "%-15s", "UNDEFINED");
  } else {
    /* symbol is defined */
    switch (s->type) {
      case SEGMENT_ABS:
        fprintf(mapFile, "%-15s", "ABS");
        break;
      case SEGMENT_CODE:
        fprintf(mapFile, "%-15s", "CODE");
        break;
      case SEGMENT_DATA:
        fprintf(mapFile, "%-15s", "DATA");
        break;
      case SEGMENT_BSS:
        fprintf(mapFile, "%-15s", "BSS");
        break;
      default:
        error("illegal symbol segment in printToMap()");
    }
  }
  fprintf(mapFile, "0x%08X", s->value);
  fprintf(mapFile, "\n");
}


void printToMapFile(void) {
  walkSymbols(printSymbol);
  fprintf(mapFile, "\n");
  fprintf(mapFile, "CODE     start 0x%08X     size 0x%08X\n",
          segStart[SEGMENT_CODE], segPtr[SEGMENT_CODE]);
  fprintf(mapFile, "DATA     start 0x%08X     size 0x%08X\n",
          segStart[SEGMENT_DATA], segPtr[SEGMENT_DATA]);
  fprintf(mapFile, "BSS      start 0x%08X     size 0x%08X\n",
          segStart[SEGMENT_BSS], segPtr[SEGMENT_BSS]);
}


/**************************************************************/


void writeHeader(void) {
  ExecHeader outHeader;

  if (withHeader) {
    outHeader.magic = EXEC_MAGIC;
    outHeader.csize = segPtr[SEGMENT_CODE];
    outHeader.dsize = segPtr[SEGMENT_DATA];
    outHeader.bsize = segPtr[SEGMENT_BSS];
    outHeader.crsize = 0;
    outHeader.drsize = 0;
    outHeader.symsize = 0;
    outHeader.strsize = 0;
    conv4FromNativeToEco((unsigned char *) &outHeader.magic);
    conv4FromNativeToEco((unsigned char *) &outHeader.csize);
    conv4FromNativeToEco((unsigned char *) &outHeader.dsize);
    conv4FromNativeToEco((unsigned char *) &outHeader.bsize);
    conv4FromNativeToEco((unsigned char *) &outHeader.crsize);
    conv4FromNativeToEco((unsigned char *) &outHeader.drsize);
    conv4FromNativeToEco((unsigned char *) &outHeader.symsize);
    conv4FromNativeToEco((unsigned char *) &outHeader.strsize);
    fwrite(&outHeader, sizeof(ExecHeader), 1, outFile);
  }
}


void writeCode(void) {
  int data;

  rewind(codeFile);
  while (1) {
    data = fgetc(codeFile);
    if (data == EOF) {
      break;
    }
    fputc(data, outFile);
  }
}


void writeData(void) {
  int data;

  rewind(dataFile);
  while (1) {
    data = fgetc(dataFile);
    if (data == EOF) {
      break;
    }
    fputc(data, outFile);
  }
}


/**************************************************************/


int readNumber(char *str, unsigned int *np) {
  int base;
  int value;
  int digit;

  base = 10;
  value = 0;
  if (*str == '0') {
    str++;
    if (*str == 'x' || *str == 'X') {
      base = 16;
      str++;
    } else
    if (isdigit((int) *str)) {
      base = 8;
    } else
    if (*str == '\0') {
      *np = value;
      return 1;
    } else {
      return 0;
    }
  }
  while (isxdigit((int) *str)) {
    digit = *str++ - '0';
    if (digit >= 'A' - '0') {
      if (digit >= 'a' - '0') {
        digit += '0' - 'a' + 10;
      } else {
        digit += '0' - 'A' + 10;
      }
    }
    if (digit >= base) {
      return 0;
    }
    value *= base;
    value += digit;
  }
  if (*str == '\0') {
    *np = value;
    return 1;
  } else {
    return 0;
  }
}


void usage(char *myself) {
  fprintf(stderr, "Usage: %s\n", myself);
  fprintf(stderr, "         [-h]             do not write object header\n");
  fprintf(stderr, "         [-o objfile]     set output file name\n");
  fprintf(stderr, "         [-m mapfile]     produce map file\n");
  fprintf(stderr, "         [-rc addr]       relocate code segment\n");
  fprintf(stderr, "         [-rd addr]       relocate data segment\n");
  fprintf(stderr, "         [-rb addr]       relocate bss segment\n");
  fprintf(stderr, "         file             object file name\n");
  fprintf(stderr, "         [files...]       additional object files\n");
  exit(1);
}


int main(int argc, char *argv[]) {
  int i;
  char *argp;
  unsigned int *ssp;
  int *ssdp;

  tmpnam(codeName);
  tmpnam(dataName);
  outName = "a.out";
  for (i = 1; i < argc; i++) {
    argp = argv[i];
    if (*argp != '-') {
      break;
    }
    argp++;
    switch (*argp) {
      case 'h':
        withHeader = 0;
        break;
      case 'o':
        if (i == argc - 1) {
          usage(argv[0]);
        }
        outName = argv[++i];
        break;
      case 'm':
        if (i == argc - 1) {
          usage(argv[0]);
        }
        mapName = argv[++i];
        break;
      case 'r':
        if (argp[1] == 'c') {
          ssp = &segStart[SEGMENT_CODE];
          ssdp = &segStartDefined[SEGMENT_CODE];
        } else
        if (argp[1] == 'd') {
          ssp = &segStart[SEGMENT_DATA];
          ssdp = &segStartDefined[SEGMENT_DATA];
        } else
        if (argp[1] == 'b') {
          ssp = &segStart[SEGMENT_BSS];
          ssdp = &segStartDefined[SEGMENT_BSS];
        } else {
          usage(argv[0]);
        }
        if (i == argc - 1) {
          usage(argv[0]);
        }
        if (!readNumber(argv[++i], ssp)) {
          error("cannot read number given with option '-%s'", argp);
        }
        *ssdp = 1;
        break;
      default:
        usage(argv[0]);
    }
  }
  if (i == argc) {
    usage(argv[0]);
  }
  codeFile = fopen(codeName, "w+b");
  if (codeFile == NULL) {
    error("cannot create temporary code file '%s'", codeName);
  }
  dataFile = fopen(dataName, "w+b");
  if (dataFile == NULL) {
    error("cannot create temporary data file '%s'", dataName);
  }
  outFile = fopen(outName, "wb");
  if (outFile == NULL) {
    error("cannot open output file '%s'", outName);
  }
  if (mapName != NULL) {
    mapFile = fopen(mapName, "wt");
    if (mapFile == NULL) {
      error("cannot open map file '%s'", mapName);
    }
  }
  do {
    inName = argv[i];
    if (*inName == '-') {
      usage(argv[0]);
    }
    inFile = fopen(inName, "rb");
    if (inFile == NULL) {
      error("cannot open input file '%s'", inName);
    }
    fprintf(stderr, "Reading module '%s'...\n", inName);
    readModule();
    if (inFile != NULL) {
      fclose(inFile);
      inFile = NULL;
    }
  } while (++i < argc);
  fprintf(stderr, "Linking modules...\n");
  linkSymbols();
  fprintf(stderr, "Relocating segments...\n");
  relocateSegments();
  writeHeader();
  writeCode();
  writeData();
  if (mapFile != NULL) {
    printToMapFile();
  }
  if (codeFile != NULL) {
    fclose(codeFile);
    codeFile = NULL;
  }
  if (dataFile != NULL) {
    fclose(dataFile);
    dataFile = NULL;
  }
  if (outFile != NULL) {
    fclose(outFile);
    outFile = NULL;
  }
  if (mapFile != NULL) {
    fclose(mapFile);
    mapFile = NULL;
  }
  if (codeName != NULL) {
    unlink(codeName);
  }
  if (dataName != NULL) {
    unlink(dataName);
  }
  return 0;
}
