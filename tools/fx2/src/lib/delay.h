/* -*- c++ -*- */
/* $Id: delay.h 395 2011-07-17 22:02:55Z mueller $ */
/*-----------------------------------------------------------------------------
 * Delay routines
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

#ifndef _DELAY_H_
#define _DELAY_H_

/*
 * delay for approximately usecs microseconds
 * Note limit of 255 usecs.
 */
void udelay (unsigned char usecs);

/*
 * delay for approximately msecs milliseconds
 */
void mdelay (unsigned short msecs);


#endif /* _DELAY_H_ */
