/* -*- c -*- */
/*
 * Copyright 2003 Free Software Foundation, Inc.
 * 
 * This file is part of GNU Radio
 * 
 * GNU Radio is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3, or (at your option)
 * any later version.
 * 
 * GNU Radio is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with GNU Radio; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street,
 * Boston, MA 02110-1301, USA.
 */

/*********************************************************************/
/** \file     usb_common.h
 *********************************************************************
 * \brief     basic functions to setup and enable USB functionality
 *
 *            usb_common provides the basic functions and interrupt 
 *            routines to enable USB communication and handling of all
 *            basic functions like standard requests, USB reset, 
 *            descriptor handling etc.\n
 *            When a USB Class command or a USB Vendor specific command
 *            is received usb_common calls the app_class_cmd or the 
 *            app_vendor_cmd function. These functions are not implemented
 *            here. This is done by the user programm.
 *
 * \author    GNUradio, Christoph Zimmermann bfh.ch
 *
*/

#ifndef _USB_COMMON_H_
#define _USB_COMMON_H_

/** Global variable set by SUDAV isr (USB SETUP Data Available) */ 
extern volatile bit _usb_got_SUDAV;

/** Provided by user application to handle CLASS commands.
 * \return returns non-zero if it handled the command. */
unsigned char app_class_cmd (void);

/** Provided by user application to handle VENDOR commands.
 * \return returns non-zero if it handled the command. */
unsigned char app_vendor_cmd (void);

/** Installs the interrupt handlers to handle the standard USB interrupts */ 
void usb_install_handlers (void);

/** Handles the setup package and the basic device requests like reading 
 *  descriptors, get/set confifuration etc. \n
 *  Also calls the app_class_cmd or app_vendor_cmd functions when needed. */
void usb_handle_setup_packet (void);

#ifdef USB_DFU_SUPPORT
/** Changes the interrupt handlers from runtime mode to DFU mode handlers
 *  and the oposite. */
void usb_toggle_dfu_handlers (void);
#endif

/** makro to check if new setup data is available */
#define usb_setup_packet_avail()	_usb_got_SUDAV

#endif /* _USB_COMMON_H_ */
