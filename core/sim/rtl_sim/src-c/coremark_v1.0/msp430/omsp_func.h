/*===========================================================================*/
/* Copyright (C) 2001 Authors                                                */
/*                                                                           */
/* This source file may be used and distributed without restriction provided */
/* that this copyright statement is not removed from the file and that any   */
/* derivative work contains the original copyright notice and the associated */
/* disclaimer.                                                               */
/*                                                                           */
/* This source file is free software; you can redistribute it and/or modify  */
/* it under the terms of the GNU Lesser General Public License as published  */
/* by the Free Software Foundation; either version 2.1 of the License, or    */
/* (at your option) any later version.                                       */
/*                                                                           */
/* This source is distributed in the hope that it will be useful, but WITHOUT*/
/* ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or     */
/* FITNESS FOR A PARTICULAR PURPOSE. See the GNU Lesser General Public       */
/* License for more details.                                                 */
/*                                                                           */
/* You should have received a copy of the GNU Lesser General Public License  */
/* along with this source; if not, write to the Free Software Foundation,    */
/* Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA        */
/*                                                                           */
/*===========================================================================*/
/*                          OMSP_FUNC HEADER FILE                            */
/*---------------------------------------------------------------------------*/
/*                                                                           */
/* Author(s):                                                                */
/*             - Olivier Girard,    olgirard@gmail.com                       */
/*                                                                           */
/*---------------------------------------------------------------------------*/
/* $Rev: 19 $                                                                */
/* $LastChangedBy: olivier.girard $                                          */
/* $LastChangedDate: 2009-08-04 23:47:15 +0200 (Tue, 04 Aug 2009) $          */
/*===========================================================================*/

//=============================================================================
// PERIPHERALS REGISTER DEFINITIONS
//=============================================================================

//----------------------------------------------------------
// SPECIAL FUNCTION REGISTERS
//----------------------------------------------------------
#define  IE1         (*(volatile unsigned char *) 0x0000)
#define  IFG1        (*(volatile unsigned char *) 0x0002)

#define  CPU_ID_LO   (*(volatile unsigned char *) 0x0004)
#define  CPU_ID_HI   (*(volatile unsigned char *) 0x0006)


//----------------------------------------------------------
// GPIOs
//----------------------------------------------------------
#define  P1IN        (*(volatile unsigned char *) 0x0020)
#define  P1OUT       (*(volatile unsigned char *) 0x0021)
#define  P1DIR       (*(volatile unsigned char *) 0x0022)
#define  P1IFG       (*(volatile unsigned char *) 0x0023)
#define  P1IES       (*(volatile unsigned char *) 0x0024)
#define  P1IE        (*(volatile unsigned char *) 0x0025)
#define  P1SEL       (*(volatile unsigned char *) 0x0026)

#define  P2IN        (*(volatile unsigned char *) 0x0028)
#define  P2OUT       (*(volatile unsigned char *) 0x0029)
#define  P2DIR       (*(volatile unsigned char *) 0x002A)
#define  P2IFG       (*(volatile unsigned char *) 0x002B)
#define  P2IES       (*(volatile unsigned char *) 0x002C)
#define  P2IE        (*(volatile unsigned char *) 0x002D)
#define  P2SEL       (*(volatile unsigned char *) 0x002E)

#define  P3IN        (*(volatile unsigned char *) 0x0018)
#define  P3OUT       (*(volatile unsigned char *) 0x0019)
#define  P3DIR       (*(volatile unsigned char *) 0x001A)
#define  P3SEL       (*(volatile unsigned char *) 0x001B)

#define  P4IN        (*(volatile unsigned char *) 0x001C)
#define  P4OUT       (*(volatile unsigned char *) 0x001D)
#define  P4DIR       (*(volatile unsigned char *) 0x001E)
#define  P4SEL       (*(volatile unsigned char *) 0x001F)

#define  P5IN        (*(volatile unsigned char *) 0x0030)
#define  P5OUT       (*(volatile unsigned char *) 0x0031)
#define  P5DIR       (*(volatile unsigned char *) 0x0032)
#define  P5SEL       (*(volatile unsigned char *) 0x0033)

#define  P6IN        (*(volatile unsigned char *) 0x0034)
#define  P6OUT       (*(volatile unsigned char *) 0x0035)
#define  P6DIR       (*(volatile unsigned char *) 0x0036)
#define  P6SEL       (*(volatile unsigned char *) 0x0037)


//----------------------------------------------------------
// WATCHDOG TIMER
//----------------------------------------------------------

// Addresses
#define  WDTCTL      (*(volatile unsigned int  *) 0x0120)

// Bit masks
#define  WDTIS0      (0x0001)
#define  WDTIS1      (0x0002)
#define  WDTSSEL     (0x0004)
#define  WDTCNTCL    (0x0008)
#define  WDTTMSEL    (0x0010)
#define  WDTNMI      (0x0020)
#define  WDTNMIES    (0x0040)
#define  WDTHOLD     (0x0080)
#define  WDTPW       (0x5A00)


//=============================================================================
// MACROS
//=============================================================================

#define STOP_WATCHDOG  WDTCTL = WDTPW | WDTHOLD

#define START_TIMER    P2OUT |= 0x02
#define STOP_TIMER     P2OUT &= 0xFD

#define COREMARK_DONE  P2OUT |= 0x80


//=============================================================================
// FUNCTIONS
//=============================================================================

//int putchar (int txdata);
unsigned long read_verilog_time ();
