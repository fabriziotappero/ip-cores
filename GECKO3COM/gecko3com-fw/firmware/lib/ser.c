/* GECKO3COM
 *
 * Copyright (C) 2008 by
 *   ___    ____  _   _
 *  (  _`\ (  __)( ) ( )   
 *  | (_) )| (_  | |_| |   Berne University of Applied Sciences
 *  |  _ <'|  _) |  _  |   School of Engineering and
 *  | (_) )| |   | | | |   Information Technology
 *  (____/'(_)   (_) (_)
 *
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details. 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/********************************************************************/
/** \file ser.c
 *********************************************************************
 * This file contains a simple interrupt driven serial driver with
 * buffer (no check for overflow!!!).
 *********************************************************************
 * \note:
 * Remember to enable all interrupts (EA=1) outside of this module!!
 ********************************************************************/

#include "fx2regs.h"
#include "ser.h"
#include "isr.h"

/** enable non blocking operation of the ser_getc function */
#define NON_BLOCKING

/** Transmit buffer write pointer */
unsigned char __xdata ser_txIndexIn;
/** Transmit butter read pointer */
unsigned char __xdata ser_txIndexOut;
/** Receive buffer write pointer */
unsigned char __xdata ser_rxIndexIn;
/** Receive buffer read pointer */
unsigned char __xdata ser_rxIndexOut;

/** Transmitt buffer */
unsigned char __xdata ser_txBuffer[0x100];
/** Receive buffer */
unsigned char __xdata ser_rxBuffer[0x100];

/** Transmitt Busy flag */
static __bit ser_txBusy;

/************************************************************************/
/**  Initializes the UART
 * Initializes the UART for the serial Port 0 with 115,2 Kbaud, 1 start,
 * 1 stop and no parity bit.
 *************************************************************************
 * \author     Christoph Zimmermann, SDCC Team
 * \date       21.Nov.2008 
 ************************************************************************/
void
ser_init(void)
{
  ES0 = 0;

  ser_txBusy     = 0;

  ser_txIndexIn  = 0;
  ser_txIndexOut = 0;
  ser_rxIndexIn  = 0;
  ser_rxIndexOut = 0;
  
  UART230 = 0x01; /*enable high speed baud rate generator, 115,2 kbaud*/

  /*T2CON = 0x30;*/ /*select timer 2 as baudrate generator*/
  /* Baudrate = 19200, oscillator frq. of my processor is 21.4772 MHz */
  /*RCAP2H = 0xFF;*/
  /*RCAP2L = 0xDD;*/
  /* enable counter */
  /*T2CON = 0x34;*/
  
  SCON0 = 0x50; /*Serial Port 0 in Mode 1 (async,1 start, 1 stop, no parity)*/

  if (TI) {
    TI = 0;
  }
  if (RI) {
    RI = 0;
  }
  
  hook_sv(SV_SERIAL_0, (unsigned short) isr_SERIAL_0);

  ES0=1;  
}

/************************************************************************/
/** \brief Interrupt service routine for RS232 handling
 * if there is data to send it copies the next char from the send buffer
 * to the uart
 * if data is received it will be copyied to the receive buffer.
 *************************************************************************
 *  \author     Christoph Zimmermann, SDCC Team
 *  \date       21.Nov.2008 
 ************************************************************************/
void
isr_SERIAL_0(void) interrupt
{
  ES0=0;

  if (RI) {
    RI = 0;
    ser_rxBuffer[ser_rxIndexIn++] = SBUF0;
  }

  if (TI) {
    TI = 0;
    if (ser_txIndexIn == ser_txIndexOut) {
      ser_txBusy = 0;
    }
    else {
      SBUF0 = ser_txBuffer[ser_txIndexOut++];
    }
  }

  ES0=1;
}

/************************************************************************/
/**  \brief sends one char over the serial line
 *************************************************************************
 * \param[in] c  character to send
 *************************************************************************
 * \author     Christoph Zimmermann, SDCC Team
 * \date       21.Nov.2008 
 ************************************************************************/
void 
ser_putc(unsigned char c)
{
  ES0=0;

  if (ser_txBusy) {
    ser_txBuffer[ser_txIndexIn++] = c;
  }
  else {
    ser_txBusy = 1;
    SBUF0 = c;
  }

  ES0=1;
}

/************************************************************************/
/**  \brief receives one char from the serial line
 *************************************************************************
 * \return  received character
 *************************************************************************
 * \author     Christoph Zimmermann, SDCC Team
 * \date       21.Nov.2008 
 ************************************************************************/
unsigned char
ser_getc(void)
{
  char tmp;

#ifdef NON_BLOCKING
  if (ser_rxIndexIn != ser_rxIndexOut) {
    tmp = ser_rxBuffer[ser_rxIndexOut++];
  }
  else {
    tmp = 0;
  }
#endif

  return(tmp);
}

/************************************************************************/
/**  \brief sends a string of characters over the serial line
 *************************************************************************
 * \param[in]  *String string to send
 *************************************************************************
 * \author     Christoph Zimmermann, SDCC Team
 * \date       21.Nov.2008 
 ************************************************************************/
void
ser_printString(char *String)
{
  while (*String) {
    ser_putc(*String++);
  }
}

/************************************************************************/
/**  \brief function to check if there is a new character to read
 *************************************************************************
 * \return  returns 1 if a new character is available else 0
 *************************************************************************
 * \author     Christoph Zimmermann, SDCC Team
 * \date       21.Nov.2008 
 ************************************************************************/
char
ser_charAvail(void)
{
  char ret = 0;

  if (ser_rxIndexIn != ser_rxIndexOut) {
    ret = 1;
  }

  return(ret);
}

/*********************End of File************************************/
