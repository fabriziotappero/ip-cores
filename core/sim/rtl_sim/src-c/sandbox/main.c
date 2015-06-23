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
/*                                 SANDBOX                                   */
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

#include "omsp_system.h"

volatile char shift_direction = 0x01;  // Global variable
 
int main(void) {

    WDTCTL = WDTPW | WDTHOLD;          // Disable watchdog timer

    P2DIR  = 0xff;                     // Port 2.0-2.7 = output
    P2OUT  = shift_direction;          // Initialize Port 2

    P1DIR  = 0x00;                     // Port 1.0-1.7 = input
    P1IE   = 0x01;                     // Port 1.0 interrupt enabled
    P1IES  = 0x00;                     // Port 1.0 interrupt edge selection (0=pos 1=neg)
    P1IFG  = 0x00;                     // Clear all Port 1 interrupt flags (just in case)
   
    eint();                            // Enable interrupts
 
    while (1) {
      if (P2OUT == 0x00) {
	P2OUT = shift_direction;

      } else if (shift_direction == 0x01) {
	P2OUT = (P2OUT << 1);

      } else {
	P2OUT = (P2OUT >> 1);
      }
    }
}
 
 // Port1 Interrupt Service Routine using msp430-gcc
interrupt(PORT1_VECTOR) port1_isr(void) {
   if (P1IFG & 0x01) {
     shift_direction ^=  0x81;
     P1IFG           &= ~0x01;         // Clear Port 1.0 interrupt flag
   }
} 
