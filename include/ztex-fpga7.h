/*!
   ZTEX Firmware Kit for EZ-USB FX2 Microcontrollers
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

/*
    FPGA support for ZTEX USB FPGA Modules 2.01 and 2.04
*/    

#ifndef[ZTEX_FPGA_H]
#define[ZTEX_FPGA_H]

#define[@CAPABILITY_FPGA;]

__xdata BYTE fpga_checksum;         // checksum
__xdata DWORD fpga_bytes;           // transfered bytes
__xdata BYTE fpga_init_b;           // init_b state (should be 222 after configuration)
__xdata BYTE fpga_flash_result;     // result of automatic fpga configuarion from Flash

__xdata BYTE fpga_conf_initialized; // 123 if initialized
__xdata BYTE OOEA;

/* *********************************************************************
   ***** reset_fpga ****************************************************
   ********************************************************************* */
static void reset_fpga () {
    OEE = (OEE & ~bmBIT6) | bmBIT7;
    IOE = IOE & ~bmBIT7;
    wait(1);
    IOE = IOE | bmBIT7;
    fpga_conf_initialized = 0;
}

/* *********************************************************************
   ***** init_fpga *****************************************************
   ********************************************************************* */
static void init_fpga () {
    IOE = IOE | bmBIT7;
    OEE = (OEE & ~bmBIT6) | bmBIT7;
    if ( ! (IOE & bmBIT6) ) {
	// ensure that FPGA is in a proper configuration mode
	IOE = IOE & ~bmBIT7;			// PROG_B = 0
	OEA = (OEA & bmBIT2 ) | bmBIT4 | bmBIT5 | bmBIT6;
	IOA = (IOA & bmBIT2 ) | bmBIT5;
	wait(1);
	IOE = IOE | bmBIT7;			// PROG_B = 1

    }
    fpga_conf_initialized = 0;
}

/* *********************************************************************
   ***** init_fpga_configuration ***************************************
   ********************************************************************* */
static void init_fpga_configuration () {
    unsigned short k;

    {
	PRE_FPGA_RESET
    }

    IFCONFIG = bmBIT7;
    SYNCDELAY; 
    PORTACFG = 0;
    PORTCCFG = 0;

    OOEA = OEA;
    fpga_conf_initialized = 123;

    OEA &= bmBIT2;			// only unsed PA bit

    OEE = (OEE & ~bmBIT6) | bmBIT7;
    IOE = IOE & ~bmBIT7;		// PROG_B = 0

    //     CSI      M0       M1       RDWR
    OEA |= bmBIT1 | bmBIT4 | bmBIT5 | bmBIT6;
    IOA = ( IOA & bmBIT2 ) | bmBIT1 | bmBIT5;
    wait(5);

    IOE = IOE | bmBIT7;			// PROG_B = 1
    IOA1 = 0;  	  			// CS = 0

    k=0;
    while (!IOA7 && k<65535)
	k++;

    //     CCLK 
    OEA |= bmBIT0;			// ready for configuration

    fpga_init_b = IOA7 ? 200 : 100;
    fpga_bytes = 0;
    fpga_checksum = 0;
}    

/* *********************************************************************
   ***** post_fpga_confog **********************************************
   ********************************************************************* */
static void post_fpga_config () {
    POST_FPGA_CONFIG
}

/* *********************************************************************
   ***** finish_fpga_configuration *************************************
   ********************************************************************* */
static void finish_fpga_configuration () {
    BYTE w;
    fpga_init_b += IOA7 ? 22 : 11;

    for ( w=0; w<64; w++ ) {
        IOA0 = 1; IOA0 = 0; 
    }
    IOA1 = 1;
    IOA0 = 1; IOA0 = 0;
    IOA0 = 1; IOA0 = 0;
    IOA0 = 1; IOA0 = 0;
    IOA0 = 1; IOA0 = 0;

    OEA = OOEA;
    if ( IOE & bmBIT6 )  {
	post_fpga_config();
    }
}    


/* *********************************************************************
   ***** EP0 vendor request 0x30 ***************************************
   ********************************************************************* */
ADD_EP0_VENDOR_REQUEST((0x30,,		// get FPGA state
    MEM_COPY1(fpga_checksum,EP0BUF+1,7);    

    OEE = (OEE & ~bmBIT6) | bmBIT7;
    if ( IOE & bmBIT6 )  {
	EP0BUF[0] = 0; 	 		// FPGA configured 
    }
    else {
        EP0BUF[0] = 1;			// FPGA unconfigured 
	reset_fpga();			// prepare FPGA for configuration
     }
//    EP0BUF[8] = 0;			// bit order for bitstream in Flash memory: non-swapped
    EP0BUF[8] = 1;			// bit order for bitstream in Flash memory: swapped
    
    EP0BCH = 0;
    EP0BCL = 9;
,,));;


/* *********************************************************************
   ***** EP0 vendor command 0x31 ***************************************
   ********************************************************************* */
ADD_EP0_VENDOR_COMMAND((0x31,,reset_fpga();,,));;	// reset FPGA


/* *********************************************************************
   ***** EP0 vendor command 0x32 ***************************************
   ********************************************************************* */
void fpga_send_ep0() {
    BYTE oOEC;
    oOEC = OEC;
    OEC = 255;
    fpga_bytes += ep0_payload_transfer;
    __asm
	mov	dptr,#_EP0BCL
	movx	a,@dptr
	jz 	010000$
  	mov	r2,a
	mov 	_AUTOPTRL1,#(_EP0BUF)
	mov 	_AUTOPTRH1,#(_EP0BUF >> 8)
	mov 	_AUTOPTRSETUP,#0x07
	mov	dptr,#_fpga_checksum
	movx 	a,@dptr
	mov 	r1,a
	mov	dptr,#_XAUTODAT1
010001$:
	movx	a,@dptr			// 2
	mov	_IOC,a			// 2
	setb	_IOA0			// 2
	add 	a,r1			// 1
	mov 	r1,a                    // 1
	clr	_IOA0                   // 2
	djnz	r2, 010001$		// 4

	mov	dptr,#_fpga_checksum
	mov	a,r1
	movx	@dptr,a
	
010000$:
    	__endasm; 
    OEC = oOEC;
    if ( EP0BCL<64 ) {
    	finish_fpga_configuration();
    } 
}

ADD_EP0_VENDOR_COMMAND((0x32,,		// send FPGA configuration data
    if ( fpga_conf_initialized != 123 )
	init_fpga_configuration();
,,
    fpga_send_ep0();
));;


#ifeq[FLASH_BITSTREAM_ENABLED][1]
/* *********************************************************************
   ***** fpga_configure_from_flash *************************************
   ********************************************************************* */
/* 
    Configure the FPGA using a bitstream from flash.
    If force == 0 a already configured FPGA is not re-configured.
    Return values:
	0 : Configuration successful
	1 : FPGA already configured
	4 : Configuration error
*/
BYTE fpga_configure_from_flash( BYTE force ) {
//    BYTE c,d;
    WORD i;
    
    if ( ( force == 0 ) && ( IOE & bmBIT6 ) ) {
	fpga_flash_result = 1;
	return 1;
    }

    fpga_flash_result = 0;

    IFCONFIG = bmBIT7;
    SYNCDELAY; 
    PORTACFG = 0;
    PORTCCFG = 0;

//    c = OEA;
    OEA &= bmBIT2;			// only unsed PA bit
    
//    d = OEC;
    OEC &= ~bmBIT0;

    OEE = (OEE & ~bmBIT6) | bmBIT7;
    IOE = IOE & ~bmBIT7;		// PROG_B = 0

    //     M0       M1
    OEA |= bmBIT4 | bmBIT5;
    IOA = ( IOA & bmBIT2 ) | bmBIT4;
    wait(1);

    IOE = IOE | bmBIT7;			// PROG_B = 1

// wait up to 4s for CS going high
    wait(20);
    for (i=0; IOA7 && (!IOA1) && i<4000; i++ ) { 
	wait(1);
    }

    wait(1);

    if ( IOE & bmBIT6 )  {
//	IOA = ( IOA & bmBIT2 ) | bmBIT3;
	post_fpga_config();
//	OEC = d;
//	OEA = c;
    }
    else {
	init_fpga();
	fpga_flash_result = 4;
    } 

    return fpga_flash_result;
}

#include[ztex-fpga-flash2.h]

#endif

#endif  /*ZTEX_FPGA_H*/
