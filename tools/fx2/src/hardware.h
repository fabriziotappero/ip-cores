/* $Id: hardware.h 395 2011-07-17 22:02:55Z mueller $ */
/*-----------------------------------------------------------------------------
 * Hardware-dependent code for usb_jtag
 *-----------------------------------------------------------------------------
 * Copyright (C) 2007 Kolja Waschk, ixo.de
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

#ifndef _HARDWARE_H
#define _HARDWARE_H 1

extern void ProgIO_Init(void);
extern void ProgIO_Poll(void);
extern void ProgIO_Enable(void);
extern void ProgIO_Disable(void);
extern void ProgIO_Deinit(void);

extern void ProgIO_Set_State(unsigned char d);
extern unsigned char ProgIO_Set_Get_State(unsigned char d);
extern void ProgIO_ShiftOut(unsigned char x);
extern unsigned char ProgIO_ShiftInOut(unsigned char x);

#endif /* _HARDWARE_H */

