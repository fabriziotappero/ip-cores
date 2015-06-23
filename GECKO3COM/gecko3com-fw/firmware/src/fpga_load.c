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
/** \file     fpga_load.c
 *********************************************************************
 * \brief     functions to programm an FPGA
 *
 *            These functions handle the bit file for an Xilinx Spartan3 
 *            FPGA and programm it in parallel slave mode.
 *
 * \note      Currently only Xilinx FPGA's are supported, function stubs 
 *            to handle Altera are provided as a guide for porting. 
 *
 * \author    GNUradio team, Matthias Zurbrügg bfh.ch, 
 *            Christoph Zimmermann bfh.ch
 * \date      2009-1-13
 *
*/

#include "gecko3com_common.h"
#include "gecko3com_regs.h"
#include "fpga_load.h"
#include "delay.h"
#include "debugprint.h"

/* ------------------------------------------------------------------------- */
/* Xilinx stuff. We use slave parallel mode (select map) to configure the FPGA
 */
#ifdef XILINX

/** makro to toggle the configuration clock line */
#define toggle_cclk() { \
    XILINX_CCLK &= ~bmXILINX_CCLK;	/* bring CCLK low */		\
    XILINX_CCLK |= bmXILINX_CCLK;	/* bring CCLK high */		\
}


void init_fpga_interface(void) {

  /* IFCLK is generated internally and runs at 48 MHz; IO Pins configured as normal Ports */
  //IFCONFIG = bmIFCLKSRC | bm3048MHZ | bmIFCLKOE;
  IFCONFIG = bmIFCLKSRC | bmIFCLKOE;
  SYNCDELAY;
}


int8_t fpga_scan_file(const xdata unsigned char *p, idata uint16_t *offset, \
		       idata uint16_t *length, xdata Fpga_Info* info)
{
  static idata uint8_t string_length = 0, chars_left_to_read = 0;
  xdata uint16_t local_position = *offset;

  for(local_position; local_position < *length; local_position++) {
   
    /* information found, copy data to output array */
    if(chars_left_to_read < string_length) {
      //printf_tiny("fi: %d\n",local_position);
      info->info[chars_left_to_read++] = p[local_position];
            
      /* end of information, return successfull */
      if(chars_left_to_read == string_length) {
	//print_info("l\n");
	info->position = local_position;
	*offset = local_position+1;
	string_length = 0;
	chars_left_to_read = 0;
	return FPGA_INFO_COMPLETE;
      }
      else {
	continue; /* ignore rest of these loop, load next character */
      }
    }

    /* search for the start of the desired type of information */
    if(chars_left_to_read == 0 && p[local_position] == info->type){
      chars_left_to_read = 1;
      continue; /* ignore rest of these loop, load next character */
    }

    /* start character found, check next character if it is \0 */
    if(chars_left_to_read == 1) {
      if(p[local_position] == 0) {
	chars_left_to_read = 2;
	  
      }
      else {
	/* false alert, continue searching */
	chars_left_to_read = 0;
      }
      continue; /* ignore rest of these loop, load next character */ 
    }

    /* start of information found, copy length of following string */
    if(chars_left_to_read == 2) {
      chars_left_to_read = 0;

      if(p[local_position] > FPGA_INFO_LEN) {
	string_length = FPGA_INFO_LEN;
      }
      else {
	string_length = p[local_position];
      }

      /* exception: file length has a fixed length */
      if(info->type == FILE_LENGTH) {
	string_length = 3;
	chars_left_to_read = 1;
	info->info[0] = p[local_position];
      }
    }
    
    /* end of for loop. nothing found yet, load next character */
  }


  /* end of packet reached, no info found or not finished copying string */
  info->position = local_position;
  *offset = local_position;
  return FPGA_INFO_NOT_COMPLETE;
}


uint8_t fpga_load_begin(void)
{
  idata uint8_t i;

  /* enable autopointer 0 */
  AUTOPTRSETUP = bmAPTREN | bmAPTR1INC;

  /* CS_B, RDWR_B should be high after board initialization
   * but when something went wrong during fpga config the state is unknown */
  if(!(XILINX_CS_B | bmXILINX_CS_B) || !(XILINX_RDWR_B | bmXILINX_RDWR_B)) {
    /* bring first RDWR_B high to signal ABORT to the FPGA */
    XILINX_RDWR_B |= bmXILINX_RDWR_B;
    
    /* toggle CCLK four times more to complete the abort sequenze  */
    for(i=0; i<4; i++) {
      toggle_cclk();
    }
    XILINX_CS_B |= bmXILINX_CS_B;
  }

  /* bring Prog_B low brings the device in the initalisation mode */
  XILINX_PROG_B &= ~bmXILINX_PROG_B;   
  udelay(100);                        // and hold it there
  
  /* bring Prog_B bit high */
  XILINX_PROG_B |= bmXILINX_PROG_B;

  /* if Init_B goes high the device is in the configuration load mode */
  for(i=0;i<50;i++) {
    if(XILINX_INIT_B & bmXILINX_INIT_B) {
    //if(1) { /* this line is needed for LA tests, uncomment this and comment the line befor */
      
      /* bring CS_B, RDWR_B low */
      XILINX_RDWR_B &= ~bmXILINX_RDWR_B;
      XILINX_CS_B &= ~bmXILINX_CS_B;   	
      
      return 1;
    }
    mdelay(1);
  }

  /* FPGA not ready to configure */
  return 0;
}


uint8_t fpga_load_xfer(xdata unsigned char *p, idata uint16_t *offset, \
		       idata uint16_t *bytecount)
{
  idata uint16_t local_count;
  uint8_t local_data;

  //printf_tiny("off %d ",local_count);
  //printf_tiny("c %d\n",*bytecount);

  local_count = *offset;

  /* setup  autopointer source adress from parameter p and the offset */
  AUTOPTRH1 = ((uintptr_t)p >> 8);
  AUTOPTRL1 = ((uintptr_t)p & 0xFF);
  AUTOPTRH1 += (local_count >> 8);
  AUTOPTRL1 += (local_count & 0xFF);

  /* setup a for loop to send the data to the fpga data port */  
  for(local_count; local_count < *bytecount; local_count++ ) {
    //XILINX_DATA = AUTODAT1;		// drive Data Port with data
    local_data = AUTODAT1;
    XILINX_DATA = local_data;

    toggle_cclk();

    //printf_tiny("0x%x ",local_data);
    
    /* no need for us because we are way to slow that a busy occours */
    /* loop while busy is true */
    /*while((XILINX_BUSY & bmXILINX_BUSY) ==  bmXILINX_BUSY) {
      // if FPGA busy, toggle CCLK
      toggle_cclk();
    }
    */ 
  }

  *offset += *bytecount;
  return 1;
}


/*
 * check for successful load...
 */
uint8_t
fpga_load_end(void)
{
  idata uint8_t i;

  /* toggle CCLK four times more to complete the startup sequenze  */
  for(i=0; i<4; i++) {		
    toggle_cclk();
  }

  /* bring CS_B, RDWR_B high */
  XILINX_CS_B |= bmXILINX_CS_B;	
  XILINX_RDWR_B |= bmXILINX_RDWR_B;
  
  if(!fpga_done()) {
    /* if not DONE, an error occoured during configuration */
    //print_err("fin.\n");
    return 0; 
  }

  return 1;
}
#endif /* XILINX */


/* ------------------------------------------------------------------------- */
/* Altera stuff. only copied from USRP source code. does not work. only a 
 * guide to give you a start to port GECKO3COM to other boards using Altera
 * devices
 */

#ifdef ALTERA
/*
 * setup altera FPGA serial load (PS).
 *
 * On entry:
 *	don't care
 *
 * On exit:
 *	ALTERA_DCLK    = 0
 *	ALTERA_NCONFIG = 1
 *	ALTERA_NSTATUS = 1 (input)
 */
uint8_t 
fpga_load_begin(void)
{
  ALTERA_CONFIG &= ~bmALTERA_BITS;		// clear all bits (NCONFIG low)
  udelay (40);					// wait 40 us
  ALTERA_CONFIG |= bmALTERA_NCONFIG;	// set NCONFIG high

  if (UC_BOARD_HAS_FPGA){
    // FIXME should really cap this loop with a counter so we
    //   don't hang forever on a hardware failure.
    while ((USRP_ALTERA_CONFIG & bmALTERA_NSTATUS) == 0) // wait for NSTATUS to go high
      ;
  }

  // ready to xfer now

  return 1;
}

/*
 * clock out the low bit of bits.
 *
 * On entry:
 *	ALTERA_DCLK    = 0
 *	ALTERA_NCONFIG = 1
 *	ALTERA_NSTATUS = 1 (input)
 *
 * On exit:
 *	ALTERA_DCLK    = 0
 *	ALTERA_NCONFIG = 1
 *	ALTERA_NSTATUS = 1 (input)
 */

static void 
clock_out_config_byte(const uint8_t bits) _naked
{
    _asm
	mov	a, dpl
	
	rrc	a
	mov	_bitALTERA_DATA0,c
	setb	_bitALTERA_DCLK
	clr	_bitALTERA_DCLK
	
	rrc	a
	mov	_bitALTERA_DATA0,c
	setb	_bitALTERA_DCLK
	clr	_bitALTERA_DCLK
	
	rrc	a
	mov	_bitALTERA_DATA0,c
	setb	_bitALTERA_DCLK
	clr	_bitALTERA_DCLK
	
	rrc	a
	mov	_bitALTERA_DATA0,c
	setb	_bitALTERA_DCLK
	clr	_bitALTERA_DCLK
	
	rrc	a
	mov	_bitALTERA_DATA0,c
	setb	_bitALTERA_DCLK
	clr	_bitALTERA_DCLK
	
	rrc	a
	mov	_bitALTERA_DATA0,c
	setb	_bitALTERA_DCLK
	clr	_bitALTERA_DCLK
	
	rrc	a
	mov	_bitALTERA_DATA0,c
	setb	_bitALTERA_DCLK
	clr	_bitALTERA_DCLK
	
	rrc	a
	mov	_bitALTERA_DATA0,c
	setb	_bitALTERA_DCLK
	clr	_bitALTERA_DCLK
	
	ret	

    _endasm;
}

static void
clock_out_bytes(const uint8_t bytecount,
		 uint8_t xdata *p)
{
  while (bytecount-- > 0)
    clock_out_config_byte (*p++);
}

/*
 * Transfer block of bytes from packet to FPGA serial configuration port
 *
 * On entry:
 *	ALTERA_DCLK    = 0
 *	ALTERA_NCONFIG = 1
 *	ALTERA_NSTATUS = 1 (input)
 *
 * On exit:
 *	ALTERA_DCLK    = 0
 *	ALTERA_NCONFIG = 1
 *	ALTERA_NSTATUS = 1 (input)
 */
uint8_t
fpga_load_xfer(const xdata uint8_t *p, const uint8_t bytecount)
{
  clock_out_bytes (bytecount, p);
  return 1;
}

/*
 * check for successful load...
 */
uint8_t
fpga_load_end(void)
{
  uint8_t status = ALTERA_CONFIG;

  if (!UC_BOARD_HAS_FPGA)			// always true if we don't have FPGA
    return 1;

  if ((status & bmALTERA_NSTATUS) == 0)		// failed to program
    return 0;

  if ((status & bmALTERA_CONF_DONE) == bmALTERA_CONF_DONE)
    return 1;					// everything's cool

  // I don't think this should happen.  It indicates that
  // programming is still in progress.

  return 0;
}

#endif /* ALTERA */
