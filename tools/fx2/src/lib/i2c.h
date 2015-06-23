/* -*- c++ -*- */
/* $Id: i2c.h 395 2011-07-17 22:02:55Z mueller $ */
/*-----------------------------------------------------------------------------
 * I2C read/write functions for FX2
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

#ifndef _I2C_H_
#define _I2C_H_

// returns non-zero if successful, else 0
unsigned char i2c_read (unsigned char addr, xdata unsigned char *buf, unsigned char len);

// returns non-zero if successful, else 0
unsigned char i2c_write (unsigned char addr, xdata const unsigned char *buf, unsigned char len);

#endif /* _I2C_H_ */
