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
/** \file    gecko3-util.h
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

#ifndef _GECKO3_UTIL_H_
#define _GECKO3_UTIL_H_


#define GECKO3COM_VID         0x0547
#define GECKO3COM_PID         0x0002

#define GECKO3COM_IF          1
#define TIMEOUT               500

#define FPGA_TYPE_LEN           16
#define FPGA_IDCODE_LEN         10   /* the JTAG chip IDCODE is a 32 bit integer but stored as 0x11223344 */
#define SERIAL_NO_LEN		8

/* bit masks for the Flags variable */
#define FL_SET_SERIAL         0x01
#define	FL_SET_HW_REV	      0x02
#define	FL_SET_FPGA_TYPE      0x04	
#define	FL_SET_FPGA_IDCODE    0x08


/* ----------------------------------------------------------------
 *			Vendor bmRequestType's
 * --------------------------------------------------------------*/

#define	VRT_VENDOR_IN			0xC0
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

#define	VRQ_SET_SERIAL			0x01	

#define	VRQ_SET_HW_REV			0x02

#define	VRQ_SET_FPGA_TYPE		0x03	

#define	VRQ_SET_FPGA_IDCODE		0x04	


#define	bmRT_DIR_MASK		(0x1 << 7)
#define	bmRT_DIR_IN		(1 << 7)
#define	bmRT_DIR_OUT		(0 << 7)

#define	bmRT_TYPE_MASK		(0x3 << 5)
#define	bmRT_TYPE_STD		(0 << 5)
#define	bmRT_TYPE_CLASS		(1 << 5)
#define	bmRT_TYPE_VENDOR	(2 << 5)
#define	bmRT_TYPE_RESERVED	(3 << 5)

#define	bmRT_RECIP_MASK		(0x1f << 0)
#define	bmRT_RECIP_DEVICE	(0 << 0)
#define	bmRT_RECIP_INTERFACE	(1 << 0)
#define	bmRT_RECIP_ENDPOINT	(2 << 0)
#define	bmRT_RECIP_OTHER	(3 << 0)


/* standard request codes (bRequest) */

#define	RQ_GET_STATUS		0
#define	RQ_CLEAR_FEATURE	1
#define	RQ_RESERVED_2		2
#define	RQ_SET_FEATURE		3
#define	RQ_RESERVED_4		4
#define	RQ_SET_ADDRESS		5
#define	RQ_GET_DESCR		6
#define	RQ_SET_DESCR		7
#define	RQ_GET_CONFIG		8
#define	RQ_SET_CONFIG		9
#define	RQ_GET_INTERFACE       10
#define	RQ_SET_INTERFACE       11
#define	RQ_SYNCH_FRAME	       12

/* standard descriptor types */

#define	DT_DEVICE		1
#define	DT_CONFIG		2
#define	DT_STRING		3
#define	DT_INTERFACE		4
#define	DT_ENDPOINT		5
#define	DT_DEVQUAL		6
#define	DT_OTHER_SPEED		7
#define	DT_INTERFACE_POWER	8

/* standard feature selectors */

#define	FS_ENDPOINT_HALT	0	/* recip: endpoint */
#define	FS_DEV_REMOTE_WAKEUP	1	/* recip: device */
#define	FS_TEST_MODE		2	/* recip: device */

/* Get Status device attributes */

#define	bmGSDA_SELF_POWERED	0x01
#define	bmGSDA_REM_WAKEUP	0x02

#endif /* _GECKO3_UTIL_H_ */
