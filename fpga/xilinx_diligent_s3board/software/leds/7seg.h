/*
*********************************************************************************************************
*
* Multiplexed LED Display Driver
* Reference: Jean J. Labrosse, Embedded Systems Building Blocks
*
* Filename : LED.C
* Programmer : John Leung (www.TechToys.com.hk)
* Remarks : Modified for PIC16-LEDSTK1
* Date : First version 1.0 on 19th Nov 2004
* Language : CCS C complier for PIC mid-range MCU, PCM version 3.170, under MPLAB IDE 7.01
* Hardware : PCB 11OCT2004.001, MCU is Microchip's PIC16F877a
* History : Modified for PIC16-LEDSTK1 dated 12 Jan 2006
*********************************************************************************************************
* DESCRIPTION
*
* This module provides an interface to a multiplexed "7-segments x N digits" LED matrix.
*
* To use this driver:
*
* 1) To use this module, the following parameters under define (LED.H):
*
* DISP_N_DIG The total number of segments to display, inc. dp status
* DISP_N_SS The total number of seven-segment digits, e.g "0" "1" "2" is 3-digit
* DISP_PORT1_DIG The address of the DIGITS output port
* DISP_PORT_SEG The address of the SEGMENTS output port
* first_dig_msk The first digit mask for selecting the most significant digit
*
* 2) Allocate a hardware timer which will interrupt the CPU at a rate of at least:
*
* DISP_N_DIG * 60 (Hz)
*
*********************************************************************************************************
*/
#ifndef _7SEG_H
#define _7SEG_H

/*
*********************************************************************************************************
* CONSTANTS
*********************************************************************************************************
*/
#include "omsp_system.h"

typedef unsigned char INT8U;
typedef unsigned int  INT16U;

// Four-Digit, Seven-Segment LED Display driver
#define DIGIT0        (*(volatile unsigned char *)  0x0090)
#define DIGIT1        (*(volatile unsigned char *)  0x0091)
#define DIGIT2        (*(volatile unsigned char *)  0x0092)
#define DIGIT3        (*(volatile unsigned char *)  0x0093)

#define DIGIT_NR         4 /* Total number of seven-segment digits */

/*
*********************************************************************************************************
* FUNCTION PROTOTYPES
*********************************************************************************************************
*/

void DispStr(INT8U offset, INT8U *s); //API to display an ASCII string


#endif // _7SEG_H
