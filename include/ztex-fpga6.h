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
    FPGA support for ZTEX USB FPGA Modules 2.13 and 2.16
*/    

#ifndef[ZTEX_FPGA_H]
#define[ZTEX_FPGA_H]

#define[@CAPABILITY_FPGA;]

__xdata BYTE fpga_checksum;         // checksum
__xdata DWORD fpga_bytes;           // transfered bytes
__xdata BYTE fpga_init_b;           // init_b state (should be 222 after configuration)
__xdata BYTE fpga_flash_result;     // result of automatic fpga configuarion from Flash

__xdata BYTE fpga_conf_initialized; // 123 if initialized
__xdata BYTE OOEC;

/* *********************************************************************
   ***** reset_fpga ****************************************************
   ********************************************************************* */
static void reset_fpga () {
    OEE = bmBIT7;
    IOE = 0;
    wait(1);
    OEE = 0;
    fpga_conf_initialized = 0;
}

/* *********************************************************************
   ***** init_fpga *****************************************************
   ********************************************************************* */
static void init_fpga () {
    if ( (IOE & bmBIT0) == 0 ) {
	// ensure that FPGA is in a proper configuration mode
	OEE = bmBIT7;
	IOE = 0;
	wait(1);
    }
    OEE = 0;
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
    PORTCCFG = 0;
    PORTECFG = 0;

    OOEC = OEC;
    fpga_conf_initialized = 123;

    OEC &= ~( bmBIT7 | bmBIT4);		// in: MOSI, MISO
    OEC |= bmBIT6;               	// out: CCLK
    IOC6 = 1;
//  in:       INIT_B  DONE 
//  OEE &= ~( bmBIT1 | bmBIT0 );
//  out:     CM0      CM1   RESET_N     CSI     RDWR
    OEE = bmBIT3 | bmBIT4 | bmBIT7 | bmBIT2 | bmBIT5;
    IOE = bmBIT3;
    
    wait(2);
    IOE = bmBIT3 | bmBIT7;		// ready for configuration
    IOC6 = 0;
    
    k=0;
    while (!(IOE & bmBIT1) && k<65535)
	k++;

    fpga_init_b = (IOE & bmBIT1) ? 200 : 100;
    fpga_bytes = 0;
    fpga_checksum = 0;
}    

/* *********************************************************************
   ***** post_fpga_config **********************************************
   ********************************************************************* */
static void post_fpga_config () {
    POST_FPGA_CONFIG
}

/* *********************************************************************
   ***** finish_fpga_configuration *************************************
   ********************************************************************* */
static void finish_fpga_configuration () {
    BYTE w;
    fpga_init_b += (IOE & bmBIT1) ? 22 : 11;

    for ( w=0; w<64; w++ ) {
        IOC6 = 1; IOC6 = 0; 
    }
    IOE |= bmBIT2;		// CSI = 1
    IOC6 = 1; IOC6 = 0;
    IOC6 = 1; IOC6 = 0;
    IOC6 = 1; IOC6 = 0;
    IOC6 = 1; IOC6 = 0;

    OEE = 0;
    OEC = OOEC;
    if ( IOE & bmBIT0 )  {
	post_fpga_config();
    }
}    

/* *********************************************************************
   ***** EP0 vendor request 0x30 ***************************************
   ********************************************************************* */
ADD_EP0_VENDOR_REQUEST((0x30,,		// get FPGA state
    MEM_COPY1(fpga_checksum,EP0BUF+1,7);    

    if ( IOE & bmBIT0 )  {
	EP0BUF[0] = 0; 	 		// FPGA configured 
    }
    else {
        EP0BUF[0] = 1;			// FPGA unconfigured 
        OEE = 0;
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
void fpga_send_ep0() {			// send FPGA configuration data
    BYTE oOEB;
    oOEB = OEB;
    OEB = 255;
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
	mov	_IOB,a			// 2
	setb	_IOC6			// 2
	add 	a,r1			// 1
	mov 	r1,a                    // 1
	clr	_IOC6                   // 2
	djnz	r2, 010001$		// 4

	mov	dptr,#_fpga_checksum
	mov	a,r1
	movx	@dptr,a
	
010000$:
    	__endasm; 
    OEB = oOEB;
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


#ifdef[HS_FPGA_CONF_EP]

#ifeq[HS_FPGA_CONF_EP][2]
#elifeq[HS_FPGA_CONF_EP][4]
#elifeq[HS_FPGA_CONF_EP][6]
#elifneq[HS_FPGA_CONF_EP][8]
#error[`HS_FPGA_CONF_EP' is not defined correctly. Valid values are: `2', `4', `6', `8'.]
#endif

#define[@CAPABILITY_HS_FPGA;]

/* *********************************************************************
   ***** EP0 vendor request 0x33 ***************************************
   ********************************************************************* */
ADD_EP0_VENDOR_REQUEST((0x33,,		// get high speed fpga configuration endpoint and interface 
    EP0BUF[0] = HS_FPGA_CONF_EP;	// endpoint
    EP0BUF[1] = EPHS_FPGA_CONF_EP_INTERFACE; // interface
    EP0BCH = 0;
    EP0BCL = 2;
,,));;


/* *********************************************************************
   ***** EP0 vendor command 0x34 ***************************************
   ********************************************************************* */
// FIFO write wave form
const char __xdata GPIF_WAVE_DATA_HSFPGA_24MHZ[32] =     
{ 
/* LenBr */ 0x01,     0x88,     0x01,     0x01,     0x01,     0x01,     0x01,     0x07,
/* Opcode*/ 0x02,     0x07,     0x02,     0x02,     0x02,     0x02,     0x02,     0x00,
/* Output*/ 0x20,     0x00,     0x00,     0x00,     0x00,     0x00,     0x00,     0x20,
/* LFun  */ 0x00,     0x36,     0x00,     0x00,     0x00,     0x00,     0x00,     0x3F,
};                     

const char __xdata GPIF_WAVE_DATA_HSFPGA_12MHZ[32] =     
{ 
/* LenBr */ 0x02,     0x01,     0x90,     0x01,     0x01,     0x01,     0x01,     0x07,
/* Opcode*/ 0x02,     0x02,     0x07,     0x02,     0x02,     0x02,     0x02,     0x00,
/* Output*/ 0x20,     0x00,     0x00,     0x00,     0x00,     0x00,     0x00,     0x20,
/* LFun  */ 0x00,     0x00,     0x36,     0x00,     0x00,     0x00,     0x00,     0x3F,
};                     


void init_cpld_fpga_configuration() {
    IFCONFIG = bmBIT7 | bmBIT6 | 2;	// Internal source, 48MHz, GPIF

    GPIFREADYCFG = 0;
    GPIFCTLCFG = 0x0; 
    GPIFIDLECS = 0;
    GPIFIDLECTL = 4;
    GPIFWFSELECT = 0x4E;
    GPIFREADYSTAT = 0;

    MEM_COPY1(GPIF_WAVE_DATA_HSFPGA_24MHZ,GPIF_WAVE3_DATA,32);

    FLOWSTATE = 0;
    FLOWLOGIC = 0x10;
    FLOWEQ0CTL = 0;
    FLOWEQ1CTL = 0;
    FLOWHOLDOFF = 0;
    FLOWSTB = 0;
    FLOWSTBEDGE = 0;
    FLOWSTBHPERIOD = 0;

    REVCTL = 0x1;				// reset fifo
    SYNCDELAY; 
    FIFORESET = 0x80;
    SYNCDELAY;
    FIFORESET = HS_FPGA_CONF_EP;
    SYNCDELAY;
    FIFORESET = 0x0;
    SYNCDELAY; 

    EPHS_FPGA_CONF_EPFIFOCFG = 0;		// config fifo
    SYNCDELAY; 
    EPHS_FPGA_CONF_EPFIFOCFG = bmBIT4 | 0;
    SYNCDELAY;
    EPHS_FPGA_CONF_EPGPIFFLGSEL = 1;
    SYNCDELAY;

    GPIFTCB3 = 1;				// abort after at least 14*65536 transactions
    SYNCDELAY;
    GPIFTCB2 = 0;
    SYNCDELAY;
    GPIFTCB1 = 0;
    SYNCDELAY;
    GPIFTCB0 = 0;
    SYNCDELAY;
    
    EPHS_FPGA_CONF_EPGPIFTRIG = 0xff;		// arm fifos
    SYNCDELAY;
    
    OEC &= ~bmBIT6;				// disable CCLK output
    IOE = bmBIT4 | bmBIT7;		        // HS config mode
}


ADD_EP0_VENDOR_COMMAND((0x34,,			// init fpga configuration
    init_fpga_configuration();

    EPHS_FPGA_CONF_EPCS &= ~bmBIT0;		// clear stall bit

    GPIFABORT = 0xFF;				// abort pendig 

    init_cpld_fpga_configuration();
    
,,));;


/* *********************************************************************
   ***** EP0 vendor command 0x35 ***************************************
   ********************************************************************* */
ADD_EP0_VENDOR_COMMAND((0x35,,		// finish fpga configuration
    IOE = bmBIT3 | bmBIT7;		
    OEC |= bmBIT6;               	// out: CCLK

    GPIFABORT = 0xFF;
    SYNCDELAY;
    IFCONFIG &= 0xf0;
    SYNCDELAY;

    finish_fpga_configuration();
,,));;

#endif  // HS_FPGA_CONF_EP

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
#define[SPI_CS][IOSPI_PORTSPI_BIT_CS]
#define[SPI_PORT][C]
#define[SPI_BIT_DO][4]
#define[SPI_BIT_CS][5]
#define[SPI_BIT_CLK][6]
#define[SPI_BIT_DI][7]

BYTE fpga_configure_from_flash( BYTE force) {
    BYTE c;
    WORD i;
    
    if ( ( force == 0 ) && ( IOE & bmBIT0 ) ) {
	fpga_flash_result = 1;
	return 1;
    }

    fpga_flash_result = 0;
    
    c = OESPI_PORT;
    OESPI_PORT &= ~( bmBITSPI_BIT_CS | bmBITSPI_BIT_DI | bmBITSPI_BIT_CLK );	// disable SPI outputs

    {
	PRE_FPGA_RESET
    }

// reset FPGA and start configuration from flash
//  out:     CM0      CM1   RESET_N     CSI     RDWR
    OEE = bmBIT3 | bmBIT4 | bmBIT7;
    IOE = 0;
    wait(1);
    IOE = bmBIT7;

// wait up to 10s for CS going high
    wait(10);
    for (i=0; (IOE & bmBIT1) && (SPI_CS==0) && i<10000; i++ ) { 
	wait(1);
    }

    wait(1);

    if ( IOE & bmBIT0 )  {
	post_fpga_config();
    }
    else {
	IOE =  bmBIT3 | bmBIT4;	// leave master SPI config mode
	wait(1);
	fpga_flash_result = 4;
    }
    OEE = 0;
    
    OESPI_PORT = c;
    SPI_CS = 1;
    
    return fpga_flash_result;
}

#include[ztex-fpga-flash2.h]

#endif


#endif  /*ZTEX_FPGA_H*/
