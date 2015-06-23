/* -*- c++ -*- */
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

#ifndef _ISR_H_
#define _ISR_H_

/************************************************************************/
/** \file isr.h
 *************************************************************************
 * \brief	routines for managing interrupt services routines
 *
 * The FX2 has three discrete sets of interrupt vectors.
 * The first set is the standard 8051 vector (13 8-byte entries).
 * The second set is USB interrupt autovector (32 4-byte entries).
 * The third set is the FIFO/GPIF autovector (14 4-byte entries).
 *
 * Since all the code we're running in the FX2 is ram based, we
 * forego the typical "initialize the interrupt vectors at link time"
 * strategy, in favor of calls at run time that install the correct
 * pointers to functions.
 *
 * \author       GNU Radio
 */

/*
 * Standard Vector numbers
 */

#define	SV_INT_0		0x03  /**< INT0 Pin */
#define	SV_TIMER_0		0x0b  /**< Timer 0 Overflow */
#define	SV_INT_1		0x13  /**< INT1 Pin */
#define	SV_TIMER_1		0x1b  /**< Timer 1 Overflow */
#define	SV_SERIAL_0		0x23  /**< USART 0 Rx & Tx */
#define	SV_TIMER_2		0x2b  /**< Timer 2 Overflow */
#define	SV_RESUME		0x33  /**< WAKEUP / WU2 Pin or USB Resume */
#define	SV_SERIAL_1		0x3b  /**< USART 1 Rx & Tx */
#define	SV_INT_2		0x43  /**< (INT_2) points at USB autovector */
#define	SV_I2C			0x4b  /**< I2C Bus */
#define	SV_INT_4		0x53  /**< (INT_4) points at FIFO/GPIF autovector */
#define	SV_INT_5		0x5b  /**< INT5 Pin */
#define	SV_INT_6		0x63  /**< INT6 Pin */

#define	SV_MIN			SV_INT_0
#define	SV_MAX			SV_INT_6

/*
 * USB Auto Vector numbers
 */

#define	UV_SUDAV		0x00  /**< SETUP Data Available */
#define	UV_SOF			0x04  /**< Start of Frame (or Microframe) */
#define	UV_SUTOK		0x08  /**< Setup Token Received */
#define	UV_SUSPEND		0x0c  /**< USB Suspend request */
#define	UV_USBRESET		0x10  /**< Bus Reset */
#define	UV_HIGHSPEED		0x14  /**< Entered high speed operation */
#define	UV_EP0ACK		0x18  /**< EZ-USB ACK'd the CONTROL Handshake */
#define	UV_SPARE_1C		0x1c  
#define	UV_EP0IN		0x20  /**< EP0-IN ready to be loaded with data */
#define	UV_EP0OUT		0x24  /**< EP0-OUT has USB data */
#define	UV_EP1IN		0x28  /**< EP1-IN ready to be loaded with data */
#define	UV_EP1OUT		0x2c  /**< EP1-OUT has USB data */
#define	UV_EP2			0x30  /**< IN: buffer available. OUT: buffer has data */
#define	UV_EP4			0x34  /**< IN: buffer available. OUT: buffer has data */
#define	UV_EP6			0x38  /**< IN: buffer available. OUT: buffer has data */
#define	UV_EP8			0x3c  /**< IN: buffer available. OUT: buffer has data */
#define	UV_IBN			0x40  /**< IN-Bulk-NAK (any IN endpoint) */
#define	UV_SPARE_44		0x44
#define	UV_EP0PINGNAK		0x48  /**< EP0 OUT was Pinged and it NAK'd */
#define	UV_EP1PINGNAK		0x4c  /**< EP1 OUT was Pinged and it NAK'd */
#define	UV_EP2PINGNAK		0x50  /**< EP2 OUT was Pinged and it NAK'd */
#define	UV_EP4PINGNAK		0x54  /**< EP4 OUT was Pinged and it NAK'd */
#define	UV_EP6PINGNAK		0x58  /**< EP6 OUT was Pinged and it NAK'd */
#define	UV_EP8PINGNAK		0x5c  /**< EP8 OUT was Pinged and it NAK'd */
#define	UV_ERRLIMIT		0x60  /**< Bus errors exceeded the programmed limit */
#define	UV_SPARE_64		0x64  
#define	UV_SPARE_68		0x68
#define	UV_SPARE_6C		0x6c
#define	UV_EP2ISOERR		0x70  /**< ISO EP2 OUT PID sequence error */
#define	UV_EP4ISOERR		0x74  /**< ISO EP4 OUT PID sequence error */
#define	UV_EP6ISOERR		0x78  /**< ISO EP6 OUT PID sequence error */
#define	UV_EP8ISOERR		0x7c  /**< ISO EP8 OUT PID sequence error */

#define	UV_MIN			UV_SUDAV
#define	UV_MAX			UV_EP8ISOERR

/*
 * FIFO/GPIF Auto Vector numbers
 */

#define	FGV_EP2PF		0x00  /**< Endpoint 2 Programmable Flag */
#define	FGV_EP4PF		0x04  /**< Endpoint 4 Programmable Flag */
#define	FGV_EP6PF		0x08  /**< Endpoint 6 Programmable Flag */
#define	FGV_EP8PF		0x0c  /**< Endpoint 8 Programmable Flag */
#define	FGV_EP2EF		0x10  /**< Endpoint 2 Empty Flag */
#define	FGV_EP4EF		0x14  /**< Endpoint 4 Empty Flag */
#define	FGV_EP6EF		0x18  /**< Endpoint 6 Empty Flag */
#define	FGV_EP8EF		0x1c  /**< Endpoint 8 Empty Flag */
#define	FGV_EP2FF		0x20  /**< Endpoint 2 Full Flag */
#define	FGV_EP4FF		0x24  /**< Endpoint 4 Full Flag */
#define	FGV_EP6FF		0x28  /**< Endpoint 6 Full Flag */
#define	FGV_EP8FF		0x2c  /**< Endpoint 8 Full Flag */
#define	FGV_GPIFDONE		0x30  /**< GPIF Operation Complete */
#define	FGV_GPIFWF		0x34  /**< GPIF Waveform */

#define	FGV_MIN			FGV_EP2PF
#define	FGV_MAX			FGV_GPIFWF


/**
 * \brief Hook standard interrupt vector.
 *
 * \param[in] vector_number is from the SV_<foo> list above.
 * \param[in] addr is the address of the interrupt service routine.
 */
void hook_sv (unsigned char vector_number, unsigned short addr);

/**
 * \brief Hook usb interrupt vector.
 *
 * \param[in] vector_number is from the UV_<foo> list above.
 * \param[in] addr is the address of the interrupt service routine.
 */
void hook_uv (unsigned char vector_number, unsigned short addr);

/**
 * \brief Hook fifo/gpif interrupt vector.
 *
 * \param[in] vector_number is from the FGV_<foo> list above.
 * \param[in] addr is the address of the interrupt service routine.
 */
void hook_fgv (unsigned char vector_number, unsigned short addr);

/**
 * One time call to enable autovectoring for both USB and FIFO/GPIF
 */
void setup_autovectors (void);


/**
 * Makro to clear the pending USB interrrupt
 *
 * \warning Must be called in each usb interrupt handler
 */
#define	clear_usb_irq()			\
	EXIF &= ~bmEXIF_USBINT;		\
	INT2CLR = 0

/**
 * Makro to clear the pending FIFO/GPIF interrupt
 *
 * \warning Must be called in each fifo/gpif interrupt handler
 */
#define	clear_fifo_gpif_irq()		\
	EXIF &= ~bmEXIF_IE4;		\
	INT4CLR = 0

#endif /* _ISR_H_ */
