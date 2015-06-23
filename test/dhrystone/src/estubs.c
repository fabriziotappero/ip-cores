/*******************************************************************************
 * Copyright (c) 2004 by Graham Davies, ECROS Technology.  This work is        *
 * released into the Public Domain on condition that the forgoing copyright    *
 * notice is preserved in this and all derived files.                          *
 ******************************************************************************/

/*******************************************************************************
 * File: estubs.c - embedded stubs used to adapt the Dhrystone benchmark for
 * small (4 Kbyte RAM) microcontrollers.
 *
 * Last edited on $Date: Wednesday, June 09, 2004 1:05:22 PM $ by
 * $Author: Graham $ saved as $Revision: 1.5 $ $Version: NONE $
 ******************************************************************************/

#include <stdio.h>
#include <stdarg.h>
#include "dhry.h"

#if defined(__LIGHT52__)
#include "../../common/soc.h"
#endif

/*******************************************************************************
 * Function emalloc() - provides a dynamic memory allocation service sufficient
 * for two allocations of 50 bytes each or less.
 */
void * emalloc( size_t nbytes )
{
   static char   space[100];
   static char * ptr = space;
   static char * result;

   result = ptr;
   nbytes = (nbytes & 0xFFFC) + 4;
   ptr += nbytes;

   return ( result );

} /* end of function emalloc() */

#if defined(__LIGHT52__)

int exit(int v){
    return 0;
}

#endif

/*******************************************************************************
 * Function fopen() - initialize an output port bit.
 */
FILE * fopen( const char * filename, const char * mode )
{
#if defined(__LIGHT52__)
   /* We don't use the ports to time the loop */
#elif defined( __AVR_ARCH__ )
   DDRB = 0x01;    /* bit 0 output */
   PORTB = 0x00;   /* start low (zero) */
#elif defined( __ENCORE__ )
   PAADDR = 4;
   PACTL  = 0x01;  /* bit 0 high drive */
   PAADDR = 1;
   PACTL  = 0xFE;  /* bit 0 output */
   PAADDR = 0;
   PAOUT  = 0x00;  /* start low (zero) */
#endif

   return ( (FILE *)1 );

} /* end of function fopen() */

/*******************************************************************************
 * Function fclose() - stub; does nothing.
 */
int fclose( FILE * stream )
{
   return ( 0 );

} /* end of function fclose() */

/*******************************************************************************
 * Function scanf() - fake a value typed by the user.
 */
int scanf( const char * format, ... )
{
   va_list args;
   int *   ptr;
   
   va_start( args, format );
   ptr = va_arg( args, int * );
   *ptr = 30000;
   va_end( args );

   return ( 0 );

} /* end of function scanf() */

/* end of file estubs.c */
