/************************************************************/
/* Filename   : common.h                                    */
/* Description: Prototypes for commonly used functions.     */
/* Author     : Nikolaos Kavvadias, <nkavv@physics.auth.gr> */
/* Date       : Tuesday, 09/02/2010.                        */
/* Revision   : --                                          */
/************************************************************/

#include <stdio.h>

                       
void print_vhdl_header_common(FILE *);
unsigned ipow(unsigned, unsigned);
unsigned dectobin(unsigned, int);
unsigned log2(unsigned);
void print_binary_value(FILE *, int, int);
void print_binary_value_fbone(FILE *, int);
