/*
 * $Id: types.h,v 1.1.1.1 2004-04-09 19:20:53 arniml Exp $
 *
 */

#ifndef _TYPES_H_
#define _TYPES_H_

typedef unsigned char  UINT8;
typedef unsigned short UINT16;
typedef unsigned int   UINT32;


#define LSB_FIRST

/******************************************************************************
 * Union of UINT8, UINT16 and UINT32 in native endianess of the target
 * This is used to access bytes and words in a machine independent manner.
 * The upper bytes h2 and h3 normally contain zero (16 bit CPU cores)
 * thus PAIR.d can be used to pass arguments to the memory system
 * which expects 'int' really.
 ******************************************************************************/
typedef union {
#ifdef LSB_FIRST
        struct { UINT8 l,h,h2,h3; } b;
        struct { UINT16 l,h; } w;
#else
        struct { UINT8 h3,h2,h,l; } b;
        struct { UINT16 h,l; } w;
#endif
        UINT32 d;
}       PAIR;


/*************************************
 *
 *  Interrupt line constants
 *
 *************************************/

enum
{
    /* line states */
    CLEAR_LINE = 0,             /* clear (a fired, held or pulsed) line */
    ASSERT_LINE,                /* assert an interrupt immediately */
    HOLD_LINE,                  /* hold interrupt line until acknowledged */
    PULSE_LINE,                 /* pulse interrupt line for one instruction */

    /* internal flags (not for use by drivers!) */
    INTERNAL_CLEAR_LINE = 100 + CLEAR_LINE,
    INTERNAL_ASSERT_LINE = 100 + ASSERT_LINE,

    /* interrupt parameters */
    MAX_IRQ_LINES = 32+1,            /* maximum number of IRQ lines per CPU */
    IRQ_LINE_NMI = MAX_IRQ_LINES - 1 /* IRQ line for NMIs */
};

#endif
