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
/** \file     gecko3com_common.c
 *********************************************************************
 * \brief     common defines and prototypes for GECKO3COM
 *
 * \author    GNUradio, Christoph Zimmermann bfh.ch
 * \date      
 *
*/

#include "gecko3com_common.h"
#include "delay.h"

volatile uint8_t flLOCAL;
volatile uint8_t flLED;

void
init_gecko3com (void)
{
  CPUCS = bmCLKSPD1;	/* CPU runs @ 48 MHz */
  CKCON = 0;		/* MOVX takes 2 cycles */


  /* configure IO ports. */
#ifdef PORT_A
  PORT_A = bmPORT_A_INITIAL;	/* Port A initial state */
  PORT_A_OE = bmPORT_A_OUTPUTS;	/* Port A direction register */
#endif

#ifdef PORT_B
  PORT_B = bmPORT_B_INITIAL;	/* Port B initial state */
  PORT_B_OE = bmPORT_B_OUTPUTS;	/* Port B direction register */
#endif

#ifdef PORT_C
  PORT_C = bmPORT_C_INITIAL;	/* Port C initial state */
  PORT_C_OE = bmPORT_C_OUTPUTS;	/* Port C direction register */
#endif

#ifdef PORT_E
  PORT_E = bmPORT_E_INITIAL;	/* Port E initial state */
  PORT_E_OE = bmPORT_E_OUTPUTS;	/* Port E direction register */
#endif

#ifdef PORT_CTL
  PORT_CTL = bmPORT_CTL_INITIAL;    /* Port GPIF CTL outputs initial state */
  PORT_CTL_OE = bmPORT_CTL_OUTPUTS; /* Port GPIF CTL outputs direction register */
#endif

  /* ------------------------------------------------------------------------ */
  /* Initialize USB interface. Configures endpoints, resets FIFOs and sets 
   * packet size according to the connection (USB 1.1 or 2.0)
   */

  REVCTL = bmDYN_OUT | bmENH_PKT;	  /* highly recommended by docs */
  SYNCDELAY;
  
  /* configure end points */

  /* EP1OUTCFG = bmVALID | bmBULK;				SYNCDELAY; */
  EP1OUTCFG = 0;            				SYNCDELAY;
  /* EP1INCFG  = bmVALID | bmBULK | bmIN;			SYNCDELAY; */
  EP1INCFG  = 0;                 			SYNCDELAY;

  EP2CFG    = bmVALID | bmBULK | bmQUADBUF;             SYNCDELAY;	/* 512 quad bulk OUT */
  EP4CFG    = 0;					SYNCDELAY;	/* disabled */
  EP6CFG    = bmVALID | bmBULK | bmQUADBUF | bmIN;	SYNCDELAY;	/* 512 quad bulk IN */
  EP8CFG    = 0;					SYNCDELAY;	/* disabled */

  /* reset FIFOs */

  FIFORESET = bmNAKALL;					SYNCDELAY;
  FIFORESET = 2;					SYNCDELAY;
  /* FIFORESET = 4;					SYNCDELAY; */
  FIFORESET = 6;					SYNCDELAY;
  /* FIFORESET = 8;					SYNCDELAY; */
  FIFORESET = 0;					SYNCDELAY;
  

/* prime the pump */
  EP0BCH = 0;			SYNCDELAY;
  EP0BCL = 0;			SYNCDELAY;
  OUTPKTEND = bmSKIP | 2;       SYNCDELAY; /* because we use quad buffering */ 
  OUTPKTEND = bmSKIP | 2;       SYNCDELAY; /* we have to flush all for  */ 
  OUTPKTEND = bmSKIP | 2;       SYNCDELAY; /* buffers before use */
  OUTPKTEND = bmSKIP | 2;       SYNCDELAY;

  /* configure end point FIFOs */
  EP2FIFOCFG = bmWORDWIDE;	                SYNCDELAY;
  EP6FIFOCFG = bmWORDWIDE;		        SYNCDELAY;

 

  /* set autoout length for EP2 and autoin length for EP6 */
  if(USBCS & bmHSM){
    EP6AUTOINLENH = (512) >> 8;	   SYNCDELAY;  /* this is the length for */
    EP6AUTOINLENL = (512) & 0xff;  SYNCDELAY;  /* high speed */
  }
  else {
    EP6AUTOINLENH = 0;	  SYNCDELAY;  /* this is the length for full speed */
    EP6AUTOINLENL = 64;   SYNCDELAY;
  }
}

void
gecko3com_system_reset(void)
{
  /* resets are normaly active low, so we first set RESET to 0 */
  RESET &= ~bmRESET;

  /* enable reset output */
  RESET_OE |= bmRESET;

  mdelay(1);

  /* disable reset output */
  RESET |= bmRESET;
  RESET_OE &= ~bmRESET;
}

void
set_led_0 (const uint8_t on)
{
  if (!on)			/* active low */
    LED_PORT |= bmPC_LED0;
  else
    LED_PORT &= ~bmPC_LED0;
}

void 
set_led_1 (const uint8_t on)
{
  if (!on)			/* active low */
    LED_PORT |= bmPC_LED1;
  else
    LED_PORT &= ~bmPC_LED1;
}

void
toggle_led_0 (void)
{
  LED_PORT ^= bmPC_LED0;
}

void
toggle_led_1 (void)
{
  LED_PORT ^= bmPC_LED1;
}

/** unused function on GECKO3COM */
void
set_sleep_bits (uint8_t bits, uint8_t  mask)
{
  /* NOP on GECKO3COM */
}

void 
init_io_ext (void)
{
  xdata uint8_t cmd[2];
  cmd[0] = 0x03;		       /* write to configuration register */
  cmd[1] = 0x01;		       /* set Bit 0 (LSB) as input and Bit */
  i2c_write(I2C_DEV_IO, cmd, 2);       /* 1,2 as output, others be irrelevant */
}

void
set_led_ext (const uint8_t color)
{
  xdata uint8_t cmd[2];
  cmd[0] = 0x01;	       	       /* write to output port register */
  cmd[1] = color;		       /* set LED */
  i2c_write(I2C_DEV_IO, cmd, 2);
  flLED = ~LEDS_OFF;
}

uint8_t 
get_switch (void)
{
  xdata uint8_t cmd[1];
  
  cmd[0] = 0x00;		/* set command byte to input port register */

  i2c_write(I2C_DEV_IO, cmd, 1);
  
  i2c_read(I2C_DEV_IO, cmd, 1);
  
  if((cmd[0] & 0x01) == 1){	/* only bit 0 in the input register is used */
    return 1;
  }
  
  return 0;
}
