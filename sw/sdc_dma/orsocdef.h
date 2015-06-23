#ifndef __orsocdef_h_
#define __orsocdef_h_
/*$$HEADER*/
/******************************************************************************/
/*                                                                            */
/*                    H E A D E R   I N F O R M A T I O N                     */
/*                                                                            */
/******************************************************************************/

// Project Name                   : Development Board Debugger Example 
// File Name                      : orsocdef.h
// Prepared By                    : jb
// Project Start                  : 2009-01-01


/*$$COPYRIGHT NOTICE*/
/******************************************************************************/
/*                                                                            */
/*                      C O P Y R I G H T   N O T I C E                       */
/*                                                                            */
/******************************************************************************/

// Copyright (c) ORSoC 2009 All rights reserved.

// The information in this document is the property of ORSoC.
// Except as specifically authorized in writing by ORSoC, the receiver of
// this document shall keep the information contained herein confidential and
// shall protect the same in whole or in part thereof from disclosure and
// dissemination to third parties. Disclosure and disseminations to the receiver's
// employees shall only be made on a strict need to know basis.


/*$$DESCRIPTION*/
/******************************************************************************/
/*                                                                            */
/*                           D E S C R I P T I O N                            */
/*                                                                            */
/******************************************************************************/

// Define some types used in our project.

/*$$CHANGE HISTORY*/
/******************************************************************************/
/*                                                                            */
/*                         C H A N G E  H I S T O R Y                         */
/*                                                                            */
/******************************************************************************/

// Date		Version	Description
//------------------------------------------------------------------------
// 090101	1.0	First version				jb

/*$$GENERAL PARTS*/
/******************************************************************************/
/*                                                                            */
/*                        G E N E R A L   P A R T S                           */
/*                                                                            */
/******************************************************************************/


/******************************************************************************/
/*                              T Y P E D E F S                               */
/******************************************************************************/

typedef unsigned int        uint;

/******************************************************************************/
/*                              M A C R O S                                   */
/******************************************************************************/

/* Max and min functions */

#define MIN(a,b) (((a)<(b))?(a):(b))
#define MAX(a,b) (((a)>(b))?(a):(b))

/* the nuldelimiter of a string */

#define NUL3	      '\n'

#define OK		1
#define NOK		0

/* nullpointer is defined if not already done */

#ifndef NULL
 #define NULL          (void *)0
#endif

/* define min and max for all types */

#define INT8_MAX      0x7F
#define UINT8_MAX     0xFF
#define INT16_MAX     0x7FFF
#define UINT16_MAX    0xFFFF
#define INT32_MAX     0x7FFFFFFF
#define UINT32_MAX    0xFFFFFFFF
#define FALSE 0
#define TRUE  !FALSE

/******************************************************************************/
/*                 R E G I S T E R   A C C E S S   M A C R O S                */
/******************************************************************************/

#define REG8(add)  *((volatile unsigned char *)  (add))
#define REG16(add) *((volatile unsigned short *) (add))
#define REG32(add) *((volatile unsigned long *)  (add))


/******************************************************************************/
/*                            G C C   C O M P I L E R                         */
/******************************************************************************/

#if defined (__GNUC__)

  typedef unsigned char     bool;

  typedef signed char       int8;
  typedef signed short      int16;
  typedef signed long       int32;

  typedef unsigned char     uint8;
  typedef unsigned short    uint16;
  typedef unsigned long     uint32;

  typedef unsigned char     char8;
  typedef unsigned short    char16;


 #else

  #error Undefined compiler used !

#endif

#endif

