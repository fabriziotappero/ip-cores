/*!
   lightshow -- lightshow on Experimental Board 1.10
   Copyright (C) 2009-2010 ZTEX e.K.
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

#include <avr/io.h>

#define F_CPU 32000000UL
#include <util/delay.h>

typedef uint8_t byte;

int main(void)	
{
    // enable 32.768 kHz, 32 MHz, 2 Mhz clocks
    asm volatile (
	"ldi r24,0xd8" "\n\t"
	"ldi r23,7" "\n\t"
	"out 0x34,r24" "\n\t"
	"sts 0x50,r23"
	::: "r24", "r23" 
    ); 
    
    // wait until clocks are ready
    while ( (OSC.STATUS & 7) != 7 ) { }

    // enable run time configuration of 32 MHz and 2 MHz clocks; select 32 MHz clock as system clock
    asm volatile (
	"ldi r24,0xd8" "\n\t"
	"ldi r23,1" "\n\t"
	"out 0x34,r24" "\n\t"
	"sts 0x60,r23" "\n\t"
	"out 0x34,r24" "\n\t"
	"sts 0x68,r23" "\n\t"
	"out 0x34,r24" "\n\t"
	"sts 0x40,r23"
	::: "r24", "r23" 
    ); 

    // disable JTAG at portb
    asm volatile (
	"ldi r24,0xd8" "\n\t"
	"ldi r23,1" "\n\t"
	"out 0x34,r24" "\n\t"
	"sts 0x96,r23" "\n\t"
	::: "r24", "r23" 
    ); 

    // clock output to PD7
    PORTCFG.CLKEVOUT = 2;
    PORTD.DIR = 128;
    
    PORTJ.DIR = 0;	// input: 4 LED's
    PORTH.DIR = 0;	// input: 8 LED's
    PORTD.DIR |= 15;	// output: 4 LED's
    PORTF.DIR = 255;	// output: 8 LED's
    
    while (1) {	
	PORTD.OUT = PORTJ.IN;
	PORTF.OUT = PORTH.IN;
    }
}

