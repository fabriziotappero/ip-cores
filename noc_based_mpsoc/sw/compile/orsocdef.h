#ifndef _ORSOCDEF_
#define _ORSOCDEF_

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

  //typedef unsigned char     bool;

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

