/* -*- c++ -*- */
/* $Id: fx2utils.c 395 2011-07-17 22:02:55Z mueller $ */
/*-----------------------------------------------------------------------------
 * FX2 specific subroutines
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

#include "fx2utils.h"
#include "fx2regs.h"
#include "delay.h"

void
fx2_stall_ep0 (void)
{
  EP0CS |= bmEPSTALL;
}

void
fx2_reset_data_toggle (unsigned char ep)
{
  TOGCTL = ((ep & 0x80) >> 3 | (ep & 0x0f));
  TOGCTL |= bmRESETTOGGLE;
}

void
fx2_renumerate (void)
{
  USBCS |= bmDISCON | bmRENUM;

  // mdelay (1500);		// FIXME why 1.5 seconds?
  mdelay (250);			// FIXME why 1.5 seconds?
  
  USBIRQ = 0xff;		// clear any pending USB irqs...
  EPIRQ =  0xff;		//   they're from before the renumeration

  EXIF &= ~bmEXIF_USBINT;

  USBCS &= ~bmDISCON;		// reconnect USB
}
