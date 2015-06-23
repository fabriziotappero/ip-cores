/*
 * a.out.h -- structure of linkable object and executable files
 */


#ifndef _A_OUT_H_
#define _A_OUT_H_


#define EXEC_MAGIC	0x1AA09232

#define METHOD_H16	0	/* write 16 bits with high part of value */
#define METHOD_L16	1	/* write 16 bits with low part of value */
#define METHOD_R16	2	/* write 16 bits with value relative to PC */
#define METHOD_R26	3	/* write 26 bits with value relative to PC */
#define METHOD_W32	4	/* write full 32 bit word with value */

#define SEGMENT_ABS	0	/* absolute values */
#define SEGMENT_CODE	1	/* code segment */
#define SEGMENT_DATA	2	/* initialized data segment */
#define SEGMENT_BSS	3	/* uninitialized data segment */


typedef struct {
  unsigned int magic;		/* must be EXEC_MAGIC */
  unsigned int csize;		/* size of code in bytes */
  unsigned int dsize;		/* size of initialized data in bytes */
  unsigned int bsize;		/* size of uninitialized data in bytes */
  unsigned int crsize;		/* size of code relocation info in bytes */
  unsigned int drsize;		/* size of data relocation info in bytes */
  unsigned int symsize;		/* size of symbol table in bytes */
  unsigned int strsize;		/* size of string space in bytes */
} ExecHeader;

typedef struct {
  unsigned int offset;		/* where to relocate */
  int method;			/* how to relocate */
  int value;			/* additive part of value */
  int base;			/* if MSB = 0: segment number */
				/* if MSB = 1: symbol table index */
} RelocRecord;

typedef struct {
  unsigned int name;		/* offset in string space */
  int type;			/* if MSB = 0: the symbol's segment */
				/* if MSB = 1: the symbol is undefined */
  int value;			/* if symbol defined: the symbol's value */
				/* if symbol not defined: meaningless */
} SymbolRecord;


#endif /* _A_OUT_H_ */
