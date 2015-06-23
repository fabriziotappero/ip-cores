/**************************************************************************
 *                      Intel 8039 Portable Emulator                      *
 *                                                                        *
 *                   Copyright (C) 1997 by Mirko Buffoni                  *
 *  Based on the original work (C) 1997 by Dan Boris, an 8048 emulator    *
 *     You are not allowed to distribute this software commercially       *
 *        Please, notify me, if you make any changes to this file         *
 *                                                                        *
 *    Adapted for the T48 uController project, 2004 by Arnim Laeuger      *
 *      See http://www.opencores.org/projects.cgi/web/t48/overview        *
 *                                                                        *
 * $Id: i8039.h,v 1.2 2004-04-15 22:03:53 arniml Exp $
 **************************************************************************/

#ifndef _I8039_H
#define _I8039_H

#ifndef INLINE
#define INLINE static inline
#endif

#include "types.h"


/**************************************************************************
    Internal Clock divisor

    External Clock is divided internally by 3 to produce the machine state
    generator. This is then divided by 5 for the instruction cycle times.
    (Each instruction cycle passes through 5 machine states).
*/

#define I8039_CLOCK_DIVIDER     (3*5)



enum { I8039_PC=1, I8039_SP, I8039_PSW, I8039_A,  I8039_TC,
       I8039_P1,   I8039_P2, I8039_R0,  I8039_R1, I8039_R2,
       I8039_R3,   I8039_R4, I8039_R5,  I8039_R6, I8039_R7
};

/*   This handling of special I/O ports should be better for actual MAME
 *   architecture.  (i.e., define access to ports { I8039_p1, I8039_p1, dkong_out_w })
 */

#define  I8039_p0   0x100   /* Not used */
#define  I8039_p1   0x101
#define  I8039_p2   0x102
#define  I8039_p4   0x104
#define  I8039_p5   0x105
#define  I8039_p6   0x106
#define  I8039_p7   0x107
#define  I8039_t0   0x110
#define  I8039_t1   0x111
#define  I8039_bus  0x120


#include "memory.h"

/*
 *   Input a UINT8 from given I/O port
 */
#define I8039_In(Port) ((UINT8)io_read_byte_8((UINT8)Port))


/*
 *   Output a UINT8 to given I/O port
 */
#define I8039_Out(Port,Value) (io_write_byte_8((UINT8)Port,(UINT8)Value))


/*
 *   Read a UINT8 from given memory location
 */
#define I8039_RDMEM(A) ((unsigned)program_read_byte_8(A))


/*
 *   Write a UINT8 to given memory location
 */
#define I8039_WRMEM(A,V) (program_write_byte_8(A,V))


/*
 *   I8039_RDOP() is identical to I8039_RDMEM() except it is used for reading
 *   opcodes. In case of system with memory mapped I/O, this function can be
 *   used to greatly speed up emulation
 */
#define I8039_RDOP(A) ((unsigned)cpu_readop(A))


/*
 *   I8039_RDOP_ARG() is identical to I8039_RDOP() except it is used for reading
 *   opcode arguments. This difference can be used to support systems that
 *   use different encoding mechanisms for opcodes and opcode arguments
 */
#define I8039_RDOP_ARG(A) ((unsigned)cpu_readop_arg(A))

int     Dasm8039(char *dst, unsigned pc);

void i8039_reset(void *);
int  i8039_execute(int, int);
void set_irq_line(int, int);

void logerror(char *, UINT16, UINT8);

#endif  /* _I8039_H */
