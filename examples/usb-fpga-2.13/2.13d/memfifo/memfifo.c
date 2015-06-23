/*!
   memfifo -- implementation of EZ-USB slave FIFO's (input and output) a FIFO using the DDR3 SDRAM for ZTEX USB-FPGA Modules 2.13
   Copyright (C) 2009-2014 ZTEX GmbH.
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

// configure endpoint 2, in, quad buffered, 512 bytes, interface 0
EP_CONFIG(2,0,BULK,IN,512,4);

// configure endpoint 6, out, double buffered, 512 bytes, interface 0
EP_CONFIG(6,0,BULK,OUT,512,4);

// select ZTEX USB FPGA Module 1.15 as target  (required for FPGA configuration)
IDENTITY_UFM_2_13(10.17.0.0,0);	 

// this product string is also used for identification by the host software
#define[PRODUCT_STRING]["memfifo for UFM 2.13"]

// enables high speed FPGA configuration via EP6
ENABLE_HS_FPGA_CONF(6);

// enable Flash support
ENABLE_FLASH;

#define[MT_RESET][IOA7]
#define[MT_MODE0][IOA0]
#define[MT_MODE1][IOA1]

// this is called automatically after FPGA configuration
#define[POST_FPGA_CONFIG][POST_FPGA_CONFIG
    reset ();
]

// set mode
ADD_EP0_VENDOR_COMMAND((0x80,,
	IOA = SETUPDAT[2] & 3;
,,
	NOP;
));;

// reset
ADD_EP0_VENDOR_COMMAND((0x81,,
	reset();
,,
	NOP;
));;

void reset () {
	OEA = bmBIT0 | bmBIT1 | bmBIT7;
	OEB = 0;
	OED = 0;
	MT_RESET = 1;
	MT_MODE0 = 0;
	MT_MODE1 = 0;
	
	EP2CS &= ~bmBIT0;			// clear stall bit
	EP6CS &= ~bmBIT0;			// clear stall bit

	IFCONFIG = bmBIT7 | bmBIT6 | bmBIT5 | 3;  // internal 48MHz clock, drive IFCLK output, slave FIFO interface
//	IFCONFIG = bmBIT7 | bmBIT5 | 3;  	  // internal 30MHz clock, drive IFCLK output, slave FIFO interface
	SYNCDELAY; 
                     
	REVCTL = 0x1;
	SYNCDELAY; 

	FIFORESET = 0x80;			// reset FIFO ...
	SYNCDELAY;
	FIFORESET = 2;				// ... for EP 2
	SYNCDELAY;
	FIFORESET = 0x00;
	SYNCDELAY;
	FIFORESET = 6;				// ... for EP 6
	SYNCDELAY;
	FIFORESET = 0x00;
	SYNCDELAY;

	EP2FIFOCFG = bmBIT0; 
	SYNCDELAY;
	EP2FIFOCFG = bmBIT3 | bmBIT0;           // EP2: AUTOIN, WORDWIDE
	SYNCDELAY;
	EP2AUTOINLENH = 2;                 	// 512 bytes 
	SYNCDELAY;
	EP2AUTOINLENL = 0;
	SYNCDELAY;

	EP6FIFOCFG = bmBIT0;         		
	SYNCDELAY;
	EP6FIFOCFG = bmBIT4 | bmBIT0;           // EP6: 0 -> 1 transition of AUTOOUT bit arms the FIFO, WORDWIDE
	SYNCDELAY;

	FIFOPINPOLAR = 0;
	SYNCDELAY; 
	PINFLAGSAB = 0xca;			// FLAGA: EP6: EF; FLAGB: EP2 FF
	SYNCDELAY; 

	wait(2);
	MT_RESET = 0;
}


// include the main part of the firmware kit, define the descriptors, ...
#include[ztex.h]

void main(void)	
{
    init_USB();
    
    while (1) {	
    }
}


