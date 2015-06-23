/*
 * common.h -- common definitions
 */


#ifndef _COMMON_H_
#define _COMMON_H_


#define PAGE_SHIFT	12			/* log2 of page size */
#define PAGE_SIZE	(1 << PAGE_SHIFT)	/* page size in bytes */
#define OFFSET_MASK	(PAGE_SIZE - 1)		/* mask for offset in page */
#define PAGE_MASK	(~OFFSET_MASK)		/* mask for page number */


typedef enum { false, true } Bool;		/* truth values */


typedef unsigned int Word;			/* 32 bit quantities */
typedef unsigned short Half;			/* 16 bit quantities */
typedef unsigned char Byte;			/*  8 bit quantities */


#define NULL	((void *) 0)


#endif /* _COMMON_H_ */
