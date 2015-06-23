/***********************************************************
 *  Gecko3 SoC HW/SW Development Board
 *   ___    ___   _   _
 *  (  _`\ (  __)( ) ( )   
 *  | (_) )| (   | |_| |   Berne University of Applied Sciences
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

/************************************************************/
/** \file    gecko3com_commands.h
 *************************************************************
 *  \brief   Commands used by GECKO3COM
 *   
 *           Here are the definitions of the commands interpreted
 *           by the GECKO3COM firmware.
 *           Mainly these are IEEE488 messages used with the USB
 *           Test and Measurement Class (TMC).
 *           We implemented also a few vendor specific USB commands
 *           to write the serial number and the FPGA type.
 *
 *  \author  Christoph Zimmermann bfh.ch
 *  \date    17.09.2007 first version
 *
 */

#ifndef _GECKO3COM_COMMANDS_H_
#define _GECKO3COM_COMMANDS_H_

#include <gecko3com_interfaces.h>

#define	MAX_EP0_PKTSIZE	      64	/**< max size of EP0 packet on FX2 */

/* ----------------------------------------------------------------
 *			Vendor bmRequestType's
 * --------------------------------------------------------------*/

/** bmRequestType for a IN vendor specific command */
#define	VRT_VENDOR_IN			0xC0  

/** bmRequestType for a OUT vendor specific command */
#define	VRT_VENDOR_OUT			0x40

/* ----------------------------------------------------------------
 *			  GECKO3COM Vendor Requests
 *
 * Note that Cypress reserves [0xA0,0xAF].
 * 0xA0 is the firmware load function.
 * --------------------------------------------------------------*/


/* IN commands */

/* #define	VRQ_GET_STATUS			0x80 */
						

/* OUT commands */

#define	VRQ_SET_SERIAL			0x01   /**< set serial number */

#define	VRQ_SET_HW_REV			0x02   /**< set hardware revision */

#define	VRQ_SET_FPGA_TYPE		0x03   /**< set fpga type */	

#define	VRQ_SET_FPGA_IDCODE		0x04   /**< set fpga jtag idcode */


#endif /* _GECKO3COM_COMMANDS_H_ */
