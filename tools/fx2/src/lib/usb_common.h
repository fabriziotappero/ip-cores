/* -*- c++ -*- */
/* $Id: usb_common.h 395 2011-07-17 22:02:55Z mueller $ */
/*-----------------------------------------------------------------------------
 * Common USB code for FX2
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

#ifndef _USB_COMMON_H_
#define _USB_COMMON_H_

#define	bRequestType	SETUPDAT[0]
#define	bRequest	SETUPDAT[1]
#define	wValueL		SETUPDAT[2]
#define	wValueH		SETUPDAT[3]
#define	wIndexL		SETUPDAT[4]
#define	wIndexH		SETUPDAT[5]
#define	wLengthL	SETUPDAT[6]
#define	wLengthH	SETUPDAT[7]

#define MSB(x)	(((unsigned short) x) >> 8)
#define LSB(x)	(((unsigned short) x) & 0xff)

extern volatile bit _usb_got_SUDAV;

// Provided by user application to report device status.
// returns non-zero if it handled the command.
unsigned char app_get_status (void);
// Provided by user application to handle VENDOR commands.
// returns non-zero if it handled the command.
unsigned char app_vendor_cmd (void);

void usb_install_handlers (void);
void usb_handle_setup_packet (void);

#define usb_setup_packet_avail()	_usb_got_SUDAV

#endif /* _USB_COMMON_H_ */
