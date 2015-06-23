/*********************************************************************/
/** \file    ser.h
 **********************************************************************
 *
 * \date    04/26/99  we                update
 * \date    04/27/99  we                add comments/header
 **********************************************************************
 * \version 4498 
 * \date    2006-12-02 11:53:42Z 
 * \author  MaartenBrock     
 */

#ifndef _SER_H_
#define _SER_H_

void ser_init(void);
void isr_SERIAL_0(void) interrupt;
void ser_putc(unsigned char);
unsigned char ser_getc(void);
void ser_printString(char *String);
char ser_charAvail(void);

#endif
