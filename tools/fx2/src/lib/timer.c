/* -*- c++ -*- */
/* $Id: timer.c 395 2011-07-17 22:02:55Z mueller $ */
/*-----------------------------------------------------------------------------
 * Timer handling for FX2
 *-----------------------------------------------------------------------------
 * Code taken from USRP2 firmware (GNU Radio Project), version 3.0.2,
 * Copyright 2003 Free Software Foundation, Inc.
 *-----------------------------------------------------------------------------
 * This code is part of usbjtag. usbjtag is free software; you can redistribute
 * it and/or modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of the License,
 * or (at your option) any later version. usbjtag is distributed in the hope
 * that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.  You should have received a
 * copy of the GNU General Public License along with this program in the file
 * COPYING; if not, write to the Free Software Foundation, Inc., 51 Franklin
 * St, Fifth Floor, Boston, MA  02110-1301  USA
 *-----------------------------------------------------------------------------
 */

#include "timer.h"
#include "fx2regs.h"
#include "isr.h"

/*
 * Arrange to have isr_tick_handler called at 100 Hz.
 *
 * The cpu clock is running at 48e6.  The input to the timer
 * is 48e6 / 12 = 4e6.
 *
 * We arrange to have the timer overflow every 40000 clocks == 100 Hz
 */

#define	RELOAD_VALUE	((unsigned short) -40000)

void 
hook_timer_tick (unsigned short isr_tick_handler)
{
  ET2 = 0;			// disable timer 2 interrupts
  hook_sv (SV_TIMER_2, isr_tick_handler);
  
  RCAP2H = RELOAD_VALUE >> 8;	// setup the auto reload value
  RCAP2L = RELOAD_VALUE & 0xFF;

  T2CON = 0x04;			// interrupt on overflow; reload; run
  ET2 = 1;			// enable timer 2 interrupts
}
