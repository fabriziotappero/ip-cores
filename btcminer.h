/*!
   btcminer -- BTCMiner for ZTEX USB-FPGA Modules: EZ-USB FX2 firmware
   Copyright (C) 2011-2012 ZTEX GmbH
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

// configure endpoints 2 (used for high speed configuration)
EP_CONFIG(2,0,BULK,OUT,512,2);	 

// select target board
#ifndef[TARGET_BOARD]
#define[TARGET_BOARD][1.15]
#endif

#ifeq[TARGET_BOARD][1.15y]
IDENTITY_UFM_1_15Y(10.15.1.2,0);	 
#else
IDENTITY_UFM_1_15(10.13.1.1,0);	 
ENABLE_UFM_1_15X_DETECTION;
#define[select_num][0]
#endif

// enables high speed FPGA configuration, use EP 2
ENABLE_HS_FPGA_CONF(2);


// this product string is also used for identification by the host software
#define[PRODUCT_STRING]["btcminer for ZTEX FPGA Modules"]

#define[WATCHDOG_TIMEOUT][(300*100)]

#ifndef[F_M1]
#define[F_M1][800]
#endif

#ifndef[F_DIV]
#define[F_DIV][6]
#endif

#ifndef[F_MIN_MULT]
#define[F_MIN_MULT][13]
#endif

#ifeq[TARGET_BOARD][1.15y]
#define[WR_CLK][IOA0]
#define[RD_CLK][IOC6]
#define[PLL_STOP][IOC5]
#define[OEA_MASK][bmBIT0]
#define[OEC_MASK][bmBIT6 | bmBIT5]
#else
#define[WR_CLK][IOA6]
#define[RD_CLK][IOC1]
#define[PLL_STOP][IOC2]
#define[OEA_MASK][bmBIT6]
#define[OEC_MASK][bmBIT1 | bmBIT2]
#endif


// !!!!! currently NUM_NONCES must not be larger than 2 !!!!!

__xdata BYTE stopped[NUMBER_OF_FPGAS];
__xdata WORD watchdog_cnt;

#define[PRE_FPGA_RESET][PRE_FPGA_RESET
    OEC |= bmBIT4;
    IOC4 = 1;			// reset clocks
#ifeq[TARGET_BOARD][1.15]
    CPUCS &= ~bmBIT1;		// stop clock
#endif
]

#define[POST_FPGA_CONFIG][POST_FPGA_CONFIG
    IOC4 = 1;
    PLL_STOP = 1;
    OEC = bmBIT0 | bmBIT2 | bmBIT4 | OEC_MASK;
    stopped[select_num] = 1;
    
#ifeq[TARGET_BOARD][1.15]
    CPUCS |= bmBIT1;		// start clock
    wait(20);
#endif
    IOC4 = 0;
    
    OEA = bmBIT2 | bmBIT4 | bmBIT5 | bmBIT7 | OEA_MASK;
    IOA = 0;
    OEB = 0;
    OED = 255;

#ifeq[TARGET_BOARD][1.15]
    if ( is_ufm_1_15x ) {
	OEA |= bmBIT0;
	IOA0 = 1;
    }
#endif

    wait(50);

    set_freq(0);
//    set_freq(F_MULT);
]


#ifeq[TARGET_BOARD][1.15]
__xdata BYTE prev_gn1, prev_gn2;
#else
__xdata BYTE OLD_IOC[NUMBER_OF_FPGAS];
#define[PRE_FPGA_SELECT][PRE_FPGA_SELECT
    OLD_IOC[prev_select_num] = IOC;
    IOC = OLD_IOC[select_num];
]
#endif

/* *********************************************************************
   ***** descriptor ****************************************************
   ********************************************************************* */
__code BYTE BitminerDescriptor[] = 
{   
    5,				// 0, version number
    NUM_NONCES-1,		// 1, number of nonces - 1
    (OFFS_NONCES+10000)&255,	// 2, ( nonce offset + 10000 ) & 255
    (OFFS_NONCES+10000)>>8,	// 3, ( nonce offset + 10000 ) >> 8
    F_M1 & 255,			// 4, frequency @ F_MULT=1 / 10kHz (LSB)
    F_M1 >> 8,			// 5, frequency @ F_MULT=1 / 10kHz (MSB)
    F_MULT-1,			// 6, frequency multiplier - 1 (default)
    F_MAX_MULT-1,		// 7, max frequency multiplier - 1 
    (HASHES_PER_CLOCK-1) & 255, // 8, (hashes_per_clck/128-1 ) & 266 
    (WORD)(HASHES_PER_CLOCK-1) >> 8,  // 9, (hashes_per_clck/128-1 ) >> 8 
    EXTRA_SOLUTIONS,		// 10, number of extra solutions
    
};
__code char bitfileString[] = BITFILE_STRING;
__code BYTE bitFileStringTerm = 0;


/* *********************************************************************
   ***** set_freq ******************************************************
   ********************************************************************* */
#define[PROGEN][IOA5]
#define[PROGCLK][IOA2]
#define[PROGDATA][IOA4]

void set_freq ( BYTE f ) {
    BYTE b,i;
    
    if ( f < F_MIN_MULT-1 )
	f = F_MIN_MULT-1;

    if ( f > F_MAX_MULT-1 )
	f = F_MAX_MULT-1;

    PROGEN = 1;

    PROGDATA = 1;
    PROGCLK = 1;
    PROGCLK = 0;

    PROGDATA = 0;
    PROGCLK = 1;
    PROGCLK = 0;
    
    b = F_DIV - 1;
    for ( i=0; i<8; i++ ) {
	PROGDATA = b & 1;
	PROGCLK = 1;
	PROGCLK = 0;
	b = b >> 1;
    }

    PROGEN = 0;
    
    PROGCLK = 1;
    PROGCLK = 0;
    PROGCLK = 1;
    PROGCLK = 0;
    PROGCLK = 1;
    PROGCLK = 0;
    
// load D
    PROGEN = 1;

    PROGDATA = 1;
    PROGCLK = 1;
    PROGCLK = 0;

    PROGCLK = 1;
    PROGCLK = 0;

    b = f;
    for ( i=0; i<8; i++ ) {
	PROGDATA = b & 1;
	PROGCLK = 1;
	PROGCLK = 0;
	b = b >> 1;
    }

    PROGEN = 0;
    
    PROGCLK = 1;
    PROGCLK = 0;
    PROGCLK = 1;
    PROGCLK = 0;
    PROGCLK = 1;
    PROGCLK = 0;

// GO
    PROGDATA = 0;
    
    PROGEN = 1;

    PROGCLK = 1;
    PROGCLK = 0;
    
    PROGEN = 0;

    _asm
	mov r1,#50
011000$:
	mov r2,#0
011001$:
	setb _PROGCLK
	clr _PROGCLK
	setb _PROGCLK
	clr _PROGCLK
	setb _PROGCLK
	clr _PROGCLK
	setb _PROGCLK
	clr _PROGCLK
	djnz r2, 011001$
	djnz r1, 011000$
    __endasm;
}    

   
/* *********************************************************************
   ***** EP0 vendor command 0x80 ***************************************
   ********************************************************************* */
// write data to FPGA
void ep0_write_data () {
    BYTE b;
    
    IOC0 = 1;    // reset on
    for ( b=0; b<EP0BCL; b++ ) {
	IOD = EP0BUF[b];
	RD_CLK = !RD_CLK;
    }
    IOC0 = 0;    // reset off
#ifeq[TARGET_BOARD][1.15]
    prev_gn1 = 0;
    prev_gn2 = 0;
#endif    
}

ADD_EP0_VENDOR_COMMAND((0x80,,				
    watchdog_cnt = 0;

    if ( stopped[select_num] ) {
	PLL_STOP = 0;
	wait(100);
	stopped[select_num]=0;
    }
,,
    ep0_write_data();
));; 


/* *********************************************************************
   ***** EP0 vendor request 0x81 ***************************************
   ********************************************************************* */
// read data from FPGA
void ep0_read_data () {
    BYTE b;
    for ( b=0; b<ep0_payload_transfer; b++ ) {
	EP0BUF[b] = IOB;
	WR_CLK = !WR_CLK;
    }
#ifeq[TARGET_BOARD][1.15]
    prev_gn1 = EP0BUF[0];
#endif    
    EP0BCH = 0;
    EP0BCL = ep0_payload_transfer;
}

// read date from FPGA
ADD_EP0_VENDOR_REQUEST((0x81,,
    IOA7 = 1;	// write start signal
    IOA7 = 0;
    ep0_read_data ();
,,
    ep0_read_data ();
));;


/* *********************************************************************
   ***** EP0 vendor request 0x82 ***************************************
   ********************************************************************* */
// send descriptor
ADD_EP0_VENDOR_REQUEST((0x82,,
    MEM_COPY1(BitminerDescriptor,EP0BUF,64);
    EP0BCH = 0;
    EP0BCL = SETUPDAT[6];
,,
));;


/* *********************************************************************
   ***** EP0 vendor command 0x83 ***************************************
   ********************************************************************* */
// set frequency
ADD_EP0_VENDOR_COMMAND((0x83,,
    PLL_STOP = 1;
    set_freq(SETUPDAT[2]);
    wait(20);
    PLL_STOP = 0;
    stopped[select_num] = 0;
    watchdog_cnt = 0;
,,
    NOP;
));; 


/* *********************************************************************
   ***** EP0 vendor command 0x84 ***************************************
   ********************************************************************* */
// suspend
ADD_EP0_VENDOR_COMMAND((0x84,,
    stopped[select_num] = 1;
    PLL_STOP = 1;
,,
    NOP;
));; 


// include the main part of the firmware kit, define the descriptors, ...
#include[ztex.h]

void main(void)	
{
    BYTE b, c;
// init everything
    init_USB();

    watchdog_cnt = 1;
    for ( b = 0; b<NUMBER_OF_FPGAS; b++ ) {
	stopped[b] = 1;
    }
    
#ifeq[TARGET_BOARD][1.15]
    c = 0;
    prev_gn1 = 0;
    prev_gn2 = 0;
#endif
    
    while (1) {	
    
	wait(10);

#ifeq[TARGET_BOARD][1.15]
        if ( is_ufm_1_15x ) {
	    if ( prev_gn1 != prev_gn2 ) {
		c = 25;
		prev_gn2 = prev_gn1;
	    }
	    IOA0 = ( stopped[0] || c>0 ) ? 1 : 0;
	    if ( c > 0 ) c--;
	}
		
#endif

	watchdog_cnt += 1;
	if ( watchdog_cnt == WATCHDOG_TIMEOUT ) {
#ifeq[TARGET_BOARD][1.15]
	    stopped[0] = 1;
	    PLL_STOP = 1;
#else	    
	    c = select_num;
	    for ( b = 0; b<NUMBER_OF_FPGAS; b++ ) {
		select_fpga(b);
		stopped[b] = 1;
		PLL_STOP = 1;
	    }
	    select_fpga(c);
#endif
	}
    }
}
