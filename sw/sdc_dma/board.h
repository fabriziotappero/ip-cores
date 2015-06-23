/*$$HEADER*/
/******************************************************************************/
/*                                                                            */
/*                    H E A D E R   I N F O R M A T I O N                     */
/*                                                                            */
/******************************************************************************/

// Project Name                   : Development Board Debugger Example 
// File Name                      : board.h
// Prepared By                    : jb
// Project Start                  : 2009-01-01


/*$$COPYRIGHT NOTICE*/
/******************************************************************************/
/*                                                                            */
/*                      C O P Y R I G H T   N O T I C E                       */
/*                                                                            */
/******************************************************************************/

// Copyright (c) ORSoC 2009 All rights reserved.

// The information in this document is the property of ORSoC.
// Except as specifically authorized in writing by ORSoC, the receiver of
// this document shall keep the information contained herein confidential and
// shall protect the same in whole or in part thereof from disclosure and
// dissemination to third parties. Disclosure and disseminations to the receiver's
// employees shall only be made on a strict need to know basis.


/*$$DESCRIPTION*/
/******************************************************************************/
/*                                                                            */
/*                           D E S C R I P T I O N                            */
/*                                                                            */
/******************************************************************************/

// This file contains definitions for the FPGA board used.

/*$$CHANGE HISTORY*/
/******************************************************************************/
/*                                                                            */
/*                         C H A N G E  H I S T O R Y                         */
/*                                                                            */
/******************************************************************************/

// Date   Version Description
//------------------------------------------------------------------------
// 090101	1.0	First version				jb

/*$$DEFINES*/
/******************************************************************************/
/*                                                                            */
/*                            D E F I N E S                                   */
/*                                                                            */
/******************************************************************************/

/******************************************************************************/
/*                    S Y S T E M  C L O C K  F R E Q .                       */
/******************************************************************************/
#define IN_CLK 25000000 // 25MHz

/******************************************************************************/
/*                            S D R A M                                       */
/******************************************************************************/

//#define SDRAM_BASE            0x00000000
//#define SDRAM_SIZE            0x02000000 // 32-MByte
//#define SDRAM_END             SDRAM_BASE + SDRAM_SIZE - 1

/******************************************************************************/
/*                               G P I O                                      */
/******************************************************************************/
// Not present in the current design
/*
#define GPIO_BASE     0x9A000000  // General purpose IO base address
#define RGPIO_IN      0x0     // GPIO input data
#define RGPIO_OUT     0x4     // GPIO output data 
#define RGPIO_OE      0x8     // GPIO output enable
#define RGPIO_INTE    0xC     // GPIO interrupt enable
#define RGPIO_PTRIG   0x10    // Type of event that triggers an IRQ
#define RGPIO_AUX     0x14    // 
#define RGPIO_CTRL    0x18    // GPIO control register
#define RGPIO_INTS    0x1C    // Interupt status
#define RGPIO_ECLK    0x20    // Enable gpio_eclk to latch RGPIO_IN
#define RGPIO_NEC     0x24    // Select active edge of gpio_eclk
*/
/******************************************************************************/
/*                               U A R T                                      */
/******************************************************************************/
//#define UART_BAUD_RATE 	19200
#define UART_BAUD_RATE 	115200
#define UART_BASE  	    0x90000000
#define UART_IRQ        19

/******************************************************************************/
/*                               SD_CONTROLLER                                   */
/******************************************************************************/
#define SD_CONTROLLER_BASE 	0xa0000000
	


/*$$TYPEDEFS*/
/******************************************************************************/
/*                                                                            */
/*                             T Y P E D E F S                                */
/*                                                                            */
/******************************************************************************/

#ifdef INCLUDED_FROM_C_FILE

  #define LOAD_INFO_STR 

  typedef struct load_info
   {
    unsigned long boardtype;         // 
    unsigned long decompressed_crc;  // Filled in by ext. program for generating SRecord file
    unsigned long compressed_crc;    // Filled in by ext. program for generating SRecord file
    unsigned long decompressed_size; // Filled in by ext. program for generating SRecord file
    unsigned long compressed_size;   // Filled in by ext. program for generating SRecord file
    unsigned long extra_pad[23];     // Extra padding
    unsigned char boardName[12];     //
    unsigned char caaName[20];       //
    unsigned char caaRev[8];         //
    unsigned char addInfo[16];       //

   } LOAD_INFO;


  typedef unsigned char   BYTE;                           /* 8 bits */
  typedef unsigned short  WORD;                           /* 16 bits */
  typedef unsigned long   LONG_WORD;                      /* 32 bits */
 
#endif

#ifndef REG
  #define REG register
#endif

