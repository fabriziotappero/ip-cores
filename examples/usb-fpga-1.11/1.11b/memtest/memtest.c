/*!
   memtest -- DDR SDRAM FIFO for testing memory on ZTEX USB-FPGA Module 1.11b
   Copyright (C) 2009-2011 ZTEX GmbH.
   http://www.ztex.de

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License version 3 as
   published by the Free Software Foundation.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, see http://www.gnu.org/licenses/.
!*/

#include[ztex-conf.h]	// Loads the configuration macros, see ztex-conf.h for the available macros
#include[ztex-utils.h]	// include basic functions

// 1024 (instead of 512) byte bulk transferns. 
// According to USB standard they are invalid but usually supported and 25% faster.
//#define[fastmode]

#ifdef[fastmode]
// configure endpoint 2, in, quad buffered, 1024 bytes, interface 0
EP_CONFIG(2,0,BULK,IN,1024,4);
#else
// configure endpoint 2, in, quad buffered, 512 bytes, interface 0
EP_CONFIG(2,0,BULK,IN,512,4);
#endif

// select ZTEX USB FPGA Module 1.11 as target  (required for FPGA configuration)
IDENTITY_UFM_1_11(10.12.0.0,0);	 

// this product string is also used for identification by the host software
#define[PRODUCT_STRING]["memtest example for UFM 1.11"]

// 0 : counter mode; 1: shift pattern mode 
__xdata BYTE mode = 0;

// this is called automatically after FPGA configuration
#define[POST_FPGA_CONFIG][POST_FPGA_CONFIG
	IOA0 = 1;				// reset on
	OEA |= bmBIT0 | bmBIT3;
	if ( mode ) IOA3 = 1;

	EP2CS &= ~bmBIT0;			// clear stall bit
    
	REVCTL = 0x3;
	SYNCDELAY; 

	IFCONFIG = bmBIT7 | bmBIT5 | 3;	        // internel 30MHz clock, drive IFCLK ouput, slave FIFO interface
	SYNCDELAY; 
	EP2FIFOCFG = bmBIT3 | bmBIT0;           // AOTUOIN, WORDWIDE
	SYNCDELAY;
    
#ifdef[fastmode]
	EP2AUTOINLENH = 4;                 	// 1024 bytes 
#else	
	EP2AUTOINLENH = 2;                 	// 512 bytes 
#endif	
	SYNCDELAY;
	EP2AUTOINLENL = 0;
	SYNCDELAY;

	FIFORESET = 0x80;			// reset FIFO
	SYNCDELAY;
	FIFORESET = 2;
	SYNCDELAY;
	FIFORESET = 0x00;
	SYNCDELAY;

	FIFOPINPOLAR = 0;
	SYNCDELAY; 
	PINFLAGSAB = 0;
	SYNCDELAY; 
	PINFLAGSCD = 0;
	SYNCDELAY; 

	IOA0 = 0;				// reset off
]

// set the test pattern
ADD_EP0_VENDOR_COMMAND((0x60,,
	mode = SETUPDAT[2];
,,
	NOP;
));;

// include the main part of the firmware kit, define the descriptors, ...
#include[ztex.h]

void main(void)	
{
    init_USB();
    
    while (1) {	
    }
}

