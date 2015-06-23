/* GECKO3COM
 *
 * Copyright (C) 2008 by
 *   ___    ____  _   _
 *  (  _`\ (  __)( ) ( )   
 *  | (_) )| (_  | |_| |   Bern University of Applied Sciences
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
/** \file     gecko3com_regs.h
 *********************************************************************
 * \brief     register and bit mask definitions for the GECKO3COM project 
 *            class.
 *
 *            Here are all board specific definitions. If you try to 
 *            port the GECKO3COM firmware to another board, start here!
 *
 * \author    Christoph Zimmermann bfh.ch
 * \date      2009-1-13
 *
*/

#ifndef _GECKO3COM_REGS_H_
#define _GECKO3COM_REGS_H_

#include "fx2regs.h"


/* ------------------------------------------------------------------------- */
#ifdef GECKO3MAIN

#define PORT_A			IOA	      /**< Port A */
#define	PORT_A_OE		OEA	      /**< Port A direction register */

#define	PORT_B			IOB	      /**< Port B */
#define	PORT_B_OE		OEB	      /**< Port B direction register */

#define	PORT_C			IOC	      /**< Port C */
#define	PORT_C_OE		OEC	      /**< Port C direction register */

/* Port GPIF CTL outputs */
#define PORT_CTL                GPIFIDLECTL   /**< GPIF control pin port */
#define PORT_CTL_OE             GPIFCTLCFG    /**< GPIF CTL port direction register */


/* define stuff for system reset */
#define RESET                   PORT_A /**< System reset signal is connected here */
#define RESET_OE		OEA    /**< Reset port direction register */
#define bmRESET                 bmBIT6 /**< bitmask to access system reset */



/* define connections for the SPI bus */
#define SPI_PORT                PORT_A /**< SPI signals are connected to this port */
#define SPI_OE		        OEA    /**< SPI port direction register */
#define bmSPI_CLK		bmBIT0 /**< bitmask for  SPI serial clock pin */
#define	bmSPI_MOSI	        bmBIT1 /**< bitmask for SPI MOSI pin, Master Out, Slave In */
#define bmSPI_MISO	        bmBIT2 /**< bitmask for SPI MISO pin, Master In, Slave Out */
#define bmSPI_MASK		(bmSPI_CLK | bmSPI_MOSI | bmSPI_MISO)/**< SPI bus pin mask */
#define bmSPI_OE_MASK		(bmSPI_CLK | bmSPI_MOSI)/**< SPI bus output pin mask */

sbit at 0x80+0 bitSPI_CLK;	       /**< \define 0x80 is the bit address of PORT A */
sbit at 0x80+1 bitSPI_MOSI;	       /**< \define Output from FX2 point of view, Master Out, Slave In */
sbit at 0x80+2 bitSPI_MISO;	       /**< \define In from FX2 point of view, Master In, Slave Out */

/* SPI related chipselect defines */
#define SPI_CS_PORT             PORT_A /**< SPI chip select signals are connected to this port */
#define SPI_CS_OE		OEA    /**< SPI chip select port direction register */
#define bmSPI_CS_FLASH		bmBIT3 /**< bitmask to enable the SPI Flash */
#define bmSPI_CS_MASK		(bmSPI_CS_FLASH)/**< SPI chip select pin mask */


/* define stuff for Xilinx FPGA configuration */

/** select FPGA vendor */
#define XILINX

#define	XILINX_DATA	        PORT_B /**< Data line port */

#define XILINX_DONE             PORT_A /**< Done signal is connected here */
#define bmXILINX_DONE	        bmBIT7 /**< bitmask to access Done */

#define XILINX_PROG_B           PORT_A /**< Prog_b signal is connected here */
#define bmXILINX_PROG_B		bmBIT5 /**< bitmask to access Prog_b */

#define XILINX_INIT_B           PORT_A /**< Init_b signal is connected here */
#define bmXILINX_INIT_B		bmBIT4 /**< bitmask to access Init_b */

#define XILINX_CCLK             GPIFIDLECTL /**< Cclk signal is connected here */
#define bmXILINX_CCLK           bmBIT0 /**< bitmask to access Cclk */

#define XILINX_RDWR_B           GPIFIDLECTL /**< Rdwr_b signal is connected here */
#define bmXILINX_RDWR_B	        bmBIT1 /**< bitmask to access Rdwr_b */

#define XILINX_CS_B             GPIFIDLECTL /**< Cs_b signal is connected here */
#define bmXILINX_CS_B	        bmBIT2 /**< bitmask to access Cs_b */

#define XILINX_BUSY             GPIFREADYSTAT /**< Busy signal is connected here */
#define bmXILINX_BUSY	        bmBIT1 /**< bitmask to access busy */


/* define pinning of the GPIF interface RDY signals 
   accessible in the GPIFREADYSTAT register */
#define bmWRX                   bmBIT0 /**< GPIFREADYSTAT bitmask to access Write Request Xilinx */
#define bmRDYX                  bmBIT1 /**< GPIFREADYSTAT bitmask to access ReDY Xilinx */

/* define pinning of the GPIF interface CTL signals 
   accessible while the GPIF is in the IDLE state through the
   GPIFIDLECTL register */
#define bmWRU                  bmBIT1 /**< GPIFREADYSTAT bitmask to access Write Request Xilinx */
#define bmRDYU                 bmBIT2 /**< GPIFREADYSTAT bitmask to access ReDY Xilinx */

/*
 * Port A (bit addressable):
 */

/* set here the direction and initial values of the pins */

#define	bmPORT_A_OUTPUTS  (bmSPI_CLK                    \
			   | bmSPI_MOSI                 \
			   | bmSPI_CS_FLASH             \
			   | bmXILINX_PROG_B            \
			   )

#define	bmPORT_A_INITIAL   (bmXILINX_PROG_B)



/* Port B: GPIF	FD[7:0]	and used for FPGA configuration */
#define	bmPORT_B_OUTPUTS	(0xFF )
#define	bmPORT_B_INITIAL	(0x00)



/*
 * Port C (bit addressable): 
 * not available on the 56 pin EZ-USB FX2 
 * used for debuging purposes only on the GECKO3main prototype board
 */

#define	LED_PORT		PORT_C
#define	bmPC_LED0		bmBIT6		/* active low */
#define	bmPC_LED1		bmBIT7		/* active low */

#define ISR_DEBUG_PORT          PORT_C
#define bmGPIF_DONE             bmBIT0
#define bmGPIF_WF               bmBIT1
#define bmFIFO_PF               bmBIT2

sbit at 0xA0+6 bitPC_LED0;		/* 0xA0 is the bit address of PORT C */
sbit at 0xA0+7 bitPC_LED1;

#define	bmPORT_C_OUTPUTS	(bmPC_LED0			\
				 | bmPC_LED1			\
				 | bmGPIF_DONE                  \
				 | bmGPIF_WF                    \
				 | bmFIFO_PF                    \
				 )

#define	bmPORT_C_INITIAL	(bmPC_LED0 | bmPC_LED1)



/* Port D: GPIF	FD[15:8]		*/

/* Port E: not available on the 56 pin EZ-USB FX2, not used	*/



/* Port GPIF CTL outputs */
#define PORT_CTL                GPIFIDLECTL
#define PORT_CTL_OE             GPIFCTLCFG

#define	bmPORT_CTL_OUTPUTS	(0x00) // TRICTL = 0, CTL 0..2 as CMOS, Not Tristatable
#define	bmPORT_CTL_INITIAL	(bmBIT2 | bmBIT1 | bmBIT0)


#endif /* GECKO3MAIN */



/* ------------------------------------------------------------------------- */
/* not supported, only an example. only copied from USRP source code. 
 * does not work. only a guide to give you a start to port GECKO3COM to 
 * other boards using an EZ-USB FX2 device
 */

#ifdef USRP2 

/** select FPGA vendor */
#define ALTERA

/*
 * Port A (bit addressable):
 */

#define bmPA_S_CLK		bmBIT0		// SPI serial clock
#define	bmPA_S_DATA_TO_PERIPH	bmBIT1		// SPI SDI (peripheral rel name)
#define bmPA_S_DATA_FROM_PERIPH	bmBIT2		// SPI SDO (peripheral rel name)
#define bmPA_SEN_FPGA		bmBIT3		// serial enable for FPGA (active low)
#define	bmPA_SEN_CODEC_A	bmBIT4		// serial enable AD9862 A (active low)
#define	bmPA_SEN_CODEC_B	bmBIT5		// serial enable AD9862 B (active low)
//#define bmPA_FX2_2		bmBIT6		// misc pin to FPGA (overflow)
//#define bmPA_FX2_3		bmBIT7		// misc pin to FPGA (underflow)
#define	bmPA_RX_OVERRUN		bmBIT6		// misc pin to FPGA (overflow)
#define	bmPA_TX_UNDERRUN	bmBIT7		// misc pin to FPGA (underflow)


sbit at 0x80+0 bitS_CLK;		// 0x80 is the bit address of PORT A
sbit at 0x80+1 bitS_OUT;		// out from FX2 point of view
sbit at 0x80+2 bitS_IN;			// in from FX2 point of view


/* all outputs except S_DATA_FROM_PERIPH, FX2_2, FX2_3 */

#define	bmPORT_A_OUTPUTS  (bmPA_S_CLK			\
			   | bmPA_S_DATA_TO_PERIPH	\
			   | bmPA_SEN_FPGA		\
			   | bmPA_SEN_CODEC_A		\
			   | bmPA_SEN_CODEC_B		\
			   )

#define	bmPORT_A_INITIAL   (bmPA_SEN_FPGA | bmPA_SEN_CODEC_A | bmPA_SEN_CODEC_B)


/* Port B: GPIF	FD[7:0]			*/

/*
 * Port C (bit addressable):
 *    5:1 FPGA configuration
 */

#define	PORT_C			IOC		// Port C
#define	PORT_C_OE		OEC		// Port C direction register

#define	ALTERA_CONFIG	        PORT_C

#define	bmPC_nRESET		bmBIT0		// reset line to codecs (active low)
#define bmALTERA_DATA0		bmBIT1
#define bmALTERA_NCONFIG	bmBIT2
#define bmALTERA_DCLK		bmBIT3

#define bmALTERA_CONF_DONE	bmBIT4
#define bmALTERA_NSTATUS	bmBIT5
#define	bmPC_LED0		bmBIT6		// active low
#define	bmPC_LED1		bmBIT7		// active low

sbit at 0xA0+1 bitALTERA_DATA0;		// 0xA0 is the bit address of PORT C
sbit at 0xA0+3 bitALTERA_DCLK;


#define	bmALTERA_BITS		(bmALTERA_DATA0			\
				 | bmALTERA_NCONFIG		\
				 | bmALTERA_DCLK		\
				 | bmALTERA_CONF_DONE		\
				 | bmALTERA_NSTATUS)

#define	bmPORT_C_OUTPUTS	(bmPC_nRESET			\
				 | bmALTERA_DATA0 		\
				 | bmALTERA_NCONFIG		\
				 | bmALTERA_DCLK		\
				 | bmPC_LED0			\
				 | bmPC_LED1			\
				 )

#define	bmPORT_C_INITIAL	(bmPC_LED0 | bmPC_LED1)


#define	LED_PORT		PORT_C
#define	bmLED0			bmPC_LED0
#define	bmLED1			bmPC_LED1


/* Port D: GPIF	FD[15:8]		*/

/* Port E: not bit addressible		*/

#define	PORT_E			IOE		// Port E
#define	PORT_E_OE		OEE		// Port E direction register

#define bmPE_PE0		bmBIT0		// GPIF debug output
#define	bmPE_PE1		bmBIT1		// GPIF debug output
#define	bmPE_PE2		bmBIT2		// GPIF debug output
#define	bmPE_FPGA_CLR_STATUS	bmBIT3		// misc pin to FPGA (clear status)
#define	bmPE_SEN_TX_A		bmBIT4		// serial enable d'board TX A (active low)
#define	bmPE_SEN_RX_A		bmBIT5		// serial enable d'board RX A (active low)
#define	bmPE_SEN_TX_B		bmBIT6		// serial enable d'board TX B (active low)
#define bmPE_SEN_RX_B		bmBIT7		// serial enable d'board RX B (active low)


#define	bmPORT_E_OUTPUTS	(bmPE_FPGA_CLR_STATUS	\
				 | bmPE_SEN_TX_A 	\
				 | bmPE_SEN_RX_A	\
				 | bmPE_SEN_TX_B	\
				 | bmPE_SEN_RX_B	\
				 )


#define	bmPORT_E_INITIAL	(bmPE_SEN_TX_A 		\
				 | bmPE_SEN_RX_A	\
				 | bmPE_SEN_TX_B	\
				 | bmPE_SEN_RX_B	\
				 )

/*
 * FPGA output lines that are tied to FX2 RDYx inputs.
 * These are readable using GPIFREADYSTAT.
 */
#define	bmFPGA_HAS_SPACE		bmBIT0	// usbrdy[0] has room for 512 byte packet
#define	bmFPGA_PKT_AVAIL		bmBIT1	// usbrdy[1] has >= 512 bytes available
// #define	bmTX_UNDERRUN			bmBIT2  // usbrdy[2] D/A ran out of data
// #define	bmRX_OVERRUN			bmBIT3	// usbrdy[3] A/D ran out of buffer

/*
 * FPGA input lines that are tied to the FX2 CTLx outputs.
 *
 * These are controlled by the GPIF microprogram...
 */
// WR					bmBIT0	// usbctl[0]
// RD					bmBIT1	// usbctl[1]
// OE					bmBIT2	// usbctl[2]

#endif /* USRP2 */


#endif /* _GECKO3COM_REGS_H_ */
