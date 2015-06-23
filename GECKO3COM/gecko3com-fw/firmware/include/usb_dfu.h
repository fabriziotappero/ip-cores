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

/*********************************************************************/
/** \file     usb_dfu.h
 *********************************************************************
 * \brief     handles the standard requests according to the USB DFU 
 *            class.
 *
 * \author    Christoph Zimmermann bfh.ch
 * \date      2009-1-13
 *
*/

#ifndef _USB_DFU_H_
#define _USB_DFU_H_

#define DFU_TIMEOUT    255

/* format of bmRequestType byte */
#define	bmRT_DFU_OUT   0x21		
#define	bmRT_DFU_IN    0xA1	

/* DFU class commands */
#define	DFU_DETACH     0
#define	DFU_DNLOAD     1
#define	DFU_UPLOAD     2
#define	DFU_GETSTATUS  3
#define	DFU_CLRSTATUS  4
#define	DFU_GETSTATE   5
#define	DFU_ABORT      6

/* DFU class status return values */
#define DFU_STATUS_OK			0x00
#define DFU_STATUS_errTARGET		0x01
#define DFU_STATUS_errFILE		0x02
#define DFU_STATUS_errWRITE		0x03
#define DFU_STATUS_errERASE		0x04
#define DFU_STATUS_errCHECK_ERASED	0x05
#define DFU_STATUS_errPROG		0x06
#define DFU_STATUS_errVERIFY		0x07
#define DFU_STATUS_errADDRESS		0x08
#define DFU_STATUS_errNOTDONE		0x09
#define DFU_STATUS_errFIRMWARE		0x0a
#define DFU_STATUS_errVENDOR		0x0b
#define DFU_STATUS_errUSBR		0x0c
#define DFU_STATUS_errPOR		0x0d
#define DFU_STATUS_errUNKNOWN		0x0e
#define DFU_STATUS_errSTALLEDPKT	0x0f

/** \brief device states according to DFU class specificaton
 *
 *  this enum is used for the DFU state mashine */
enum dfu_state {
	DFU_STATE_appIDLE		= 0,
	DFU_STATE_appDETACH		= 1,
	DFU_STATE_dfuIDLE		= 2,
	DFU_STATE_dfuDNLOAD_SYNC	= 3,
	DFU_STATE_dfuDNBUSY		= 4,
	DFU_STATE_dfuDNLOAD_IDLE	= 5,
	DFU_STATE_dfuMANIFEST_SYNC	= 6,
	DFU_STATE_dfuMANIFEST		= 7,
	DFU_STATE_dfuMANIFEST_WAIT_RST	= 8,
	DFU_STATE_dfuUPLOAD_IDLE	= 9,
	DFU_STATE_dfuERROR		= 10,
};

/** Global variable for handling the timeout when after an DFU_DETACH
 *  request no USB reset follows and we continue normal operation*/
extern volatile uint8_t usb_dfu_timeout;

/** Global variable that contains our current device status */
extern volatile uint8_t usb_dfu_status;

/** Global variable that contains our current device state */
extern volatile enum dfu_state usb_dfu_state;

/** Makro to check if this setup package is a DFU request */
#define usb_dfu_request() ((wIndexL == USB_DFU_RT_INTERFACE && \
			   (bRequestType & bmRT_RECIP_INTERFACE) == bmRT_RECIP_INTERFACE) \
			   || \
                           usb_dfu_state >= DFU_STATE_dfuIDLE \
                          )

/** \brief general function to handle the DFU requests. Calls the function
 *  app_firmware_write when needed
 */
uint8_t usb_handle_dfu_packet (void);

/** \brief Provided by user application to write the firmware into the memory.
 * \return returns non-zero if it handled the command. */
uint8_t app_firmware_write (void);

#endif /* _USB_DFU_H_ */
