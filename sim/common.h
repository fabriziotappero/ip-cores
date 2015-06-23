/*
 * common.h -- common definitions
 */


#ifndef _COMMON_H_
#define _COMMON_H_


#define K		1024		/* Kilo */
#define M		(K * K)		/* Mega */

#define RAM_BASE	0x00000000	/* physical RAM base address */
#define RAM_SIZE_MAX	(512 * M)	/* maximum RAM size */
#define RAM_SIZE_DFL	(4 * M)		/* default RAM size */
#define ROM_BASE	0x20000000	/* physical ROM base address */
#define ROM_SIZE_MAX	(256 * M)	/* maximum ROM size */
#define ROM_SIZE	(256 * K)	/* actual ROM size */
#define IO_BASE		0x30000000	/* physical I/O base address */
#define IO_SIZE_MAX	(256 * M)	/* maximum I/O size */

#define IO_DEV_MASK	0x3FF00000	/* I/O device mask */
#define IO_REG_MASK	0x000FFFFF	/* I/O register mask */
#define IO_GRAPH_MASK	0x003FFFFF	/* I/O graphics mask */

#define TIMER_BASE	0x30000000	/* physical timer base address */
#define DISPLAY_BASE	0x30100000	/* physical display base address */
#define KEYBOARD_BASE	0x30200000	/* physical keyboard base address */
#define SERIAL_BASE	0x30300000	/* physical serial line base address */
#define MAX_NSERIALS	2		/* max number of serial lines */
#define DISK_BASE	0x30400000	/* physical disk base address */
#define OUTPUT_BASE	0x3F000000	/* physical output device address */
#define SHUTDOWN_BASE	0x3F100000	/* physical shutdown device address */
#define GRAPH_BASE	0x3FC00000	/* physical grahics base address */
					/* extends to end of address space */

#define PAGE_SIZE	(4 * K)		/* size of a page and a page frame */
#define OFFSET_MASK	(PAGE_SIZE - 1)	/* mask for offset within a page */
#define PAGE_MASK	(~OFFSET_MASK)	/* mask for page number */

#define CC_PER_USEC	50		/* clock cycles per microsecond */
#define CC_PER_INSTR	18		/* clock cycles per instruction */


typedef enum { false, true } Bool;	/* truth values */


typedef unsigned char Byte;		/* 8 bit quantities */
typedef unsigned short Half;		/* 16 bit quantities */
typedef unsigned int Word;		/* 32 bit quantities */


#endif /* _COMMON_H_ */
