//
//
//


#ifndef __DE1_OR1200_H
#define __DE1_OR1200_H

/* Register access macros */
#define REG8(add) *((volatile unsigned char *)(add))
#define REG16(add) *((volatile unsigned short *)(add))
#define REG32(add) *((volatile unsigned long *)(add))

#define LSR_BASE  ( REG8(0x50000005) )
#define THR_BASE  ( REG8(0x50000000) )


#endif
