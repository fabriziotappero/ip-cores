/* -*- c++ -*- */
/* $Id: syncdelay.h 604 2014-11-16 22:33:09Z mueller $ */
/*
 * Copyright 2014- by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
 * Code was forked from USRP2 firmware (GNU Radio Project), version 3.0.2
 *
 * - original copyright and licence disclaimers -------------------------------
 * Copyright 2003 Free Software Foundation, Inc.
 * This code is part of usbjtag.
 *-----------------------------------------------------------------------------
 * 
 * This program is free software; you may redistribute and/or modify it under
 * the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 2, or at your option any later version.
 * 
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * for complete details.
 *  
 *-----------------------------------------------------------------------------
 *
 * Synchronization delay for FX2 access to specific registers
 *
 * Revision History:
 * 
 * Date         Rev Version  Comment
 * 2014-11-16   604   1.1    BUGFIX: handle triple nop properly
 * 2011-07-17   394   1.0    Initial version (from ixo-jtag/usb_jtag Rev 204)
 */

#ifndef _SYNCDELAY_H_
#define _SYNCDELAY_H_

/*
 * Magic delay required between access to certain xdata registers (TRM page 15-106).
 * For our configuration, 48 MHz FX2 / 48 MHz IFCLK, we need three cycles.  Each
 * NOP is a single cycle....
 *
 * From TRM page 15-105:
 *
 * Under certain conditions, some read and write access to the FX2 registers must
 * be separated by a "synchronization delay".  The delay is necessary only under the
 * following conditions:
 *
 *   - between a write to any register in the 0xE600 - 0xE6FF range and a write to one
 *     of the registers listed below.
 *
 *   - between a write to one of the registers listed below and a read from any register
 *     in the 0xE600 - 0xE6FF range.
 *
 *   Registers which require a synchronization delay:
 *
 *	FIFORESET			FIFOPINPOLAR
 *	INPKTEND			EPxBCH:L
 *	EPxFIFOPFH:L			EPxAUTOINLENH:L
 *	EPxFIFOCFG			EPxGPIFFLGSEL
 *	PINFLAGSAB			PINFLAGSCD
 *	EPxFIFOIE			EPxFIFOIRQ
 *	GPIFIE				GPIFIRQ
 *	UDMACRCH:L			GPIFADRH:L
 *	GPIFTRIG			EPxGPIFTRIG
 *	OUTPKTEND			REVCTL
 *	GPIFTCB3			GPIFTCB2
 *	GPIFTCB1			GPIFTCB0
 */

/*
 * FIXME ensure that the peep hole optimizer isn't screwing us
 */
#define	SYNCDELAY	NOP; NOP; NOP
#define	NOP		_asm nop; _endasm

#endif /* _SYNCDELAY_H_ */
