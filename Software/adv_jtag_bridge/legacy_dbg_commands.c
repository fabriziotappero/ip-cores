/* legacy_dbg_commands.c -- JTAG protocol bridge between GDB and OpenCores debug module.
   Copyright(C) 2001 Marko Mlinar, markom@opencores.org
   Code for TCP/IP copied from gdb, by Chris Ziomkowski
   Adapted for the Advanced JTAG Bridge by Nathan Yawn, (C) 2009-2010
   
   This file was part of the OpenRISC 1000 Architectural Simulator.
   It is now also used to connect GDB to a running hardware OpenCores / OR1200
   debug unit.
   
   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 2 of the License, or
   (at your option) any later version.
   
   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.
   
   You should have received a copy of the GNU General Public License
   along with this program; if not, write to the Free Software
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA. */

#include <assert.h>
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <stdarg.h>
#include <sys/stat.h>
#include <sys/types.h>
#include <netinet/in.h>  // for htonl

#include "chain_commands.h"
#include "cable_common.h"
#include "errcodes.h"
#include "legacy_dbg_commands.h"

#define debug(...) //fprintf(stderr, __VA_ARGS__ )

#define LEGACY_CRC_POLY 0x04c11db7
#define DBG_CRC_SIZE 32

/* Crc of current read or written data.  */
static int legacy_crc_r, legacy_crc_w = 0;


/*----------------------------------------------------------------------------------*/
// Helper Functions

/* Generates new crc, sending in new bit input_bit */
static unsigned long legacy_crc_calc(unsigned long crc, int input_bit) {
  unsigned long d = (input_bit&1) ? 0xfffffff : 0x0000000;
  unsigned long crc_32 = ((crc >> 31)&1) ? 0xfffffff : 0x0000000;
  crc <<= 1;
  return crc ^ ((d ^ crc_32) & LEGACY_CRC_POLY);
}

/* Writes bitstream.  LS bit first if len < 0, MS bit first if len > 0.  */
static void legacy_write_stream(uint32_t stream, int len, int set_last_bit) {
  int i;
  uint32_t err;
  uint32_t outdata = 0;
  uint32_t datacpy = stream;

  // MSB needs to be transferred first, lower levels do LSB first.  Reverse.
  for(i = 0; i < len; i++) {
    outdata |= stream & 0x1;
    if(i < (len-1)) {
      outdata <<= 1;
      stream >>= 1;
    }
  }

  // Call the lower level, in case the driver has a high-speed transfer capability.
  // *** This always transfers LS bit first.
  err = jtag_write_stream(&outdata, len, set_last_bit);

  debug("legacy_write_stream, stream = 0x%X (0x%X), len = %d, set_last_bit = %d, ret = 0x%X\n", datacpy, outdata, len, set_last_bit, err);

  if(err != APP_ERR_NONE) {
    fprintf(stderr, "Error in legacy_write_stream: %s\n", get_err_string(err));
  }

  // The low level call does not compute
  // a CRC.  Do so here.  Remember, CRC is only calculated using data bits.
  if(len < 0) {
    fprintf(stderr, "Program error: legacy debug JTAG read with negative length!\n");
    /*
      len = -len;
      for(i = 0; i < len; i++) {
      legacy_crc_w = legacy_crc_calc(legacy_crc_w, stream&1);
      datacpy >>= 1;
      }
    */
  }
  else {
    for(i = len-1; i >= 0; i--) {
      legacy_crc_w = legacy_crc_calc(legacy_crc_w, (datacpy>>i)&1);
    }
  }

}

/* Gets bitstream.  LS bit first if len < 0, MS bit first if len > 0.  */
static uint32_t legacy_read_stream(unsigned long stream, int len, int set_last_bit) {
  int i;
  uint32_t data = 0, datacpy = 0;
  uint32_t outdata = stream;
  uint32_t indata;
  uint32_t err;

  // *** WARNING:  We assume that the input ("stream") will always be 0.
  // If it's ever not, then we probably need to reverse the bit order (as
  // is done in legacy_write_stream) before sending.

  // Call the lower level, in case the driver has a high-speed transfer capability.
  // This always transfers LS bit first.
  err = jtag_read_write_stream(&outdata, &indata, len, 0, set_last_bit);

  // Data comes from the legacy debug unit MSB first, so we need to 
  // reverse the bit order.
  for(i = 0; i < len; i++) {
    data |= indata & 0x1;
    if(i < (len-1)) {
      data <<= 1;
      indata >>= 1;
    }
  }

  datacpy = data;

  debug("legacy_read_stream: write 0x%X, read 0x%X, len %i, set_last_bit = %d\n", outdata, data, len, set_last_bit);

  if(err != APP_ERR_NONE) {
    fprintf(stderr, "Error in legacy_read_stream: %s\n", get_err_string(err));
  }

  // The low level call does not compute
  // a CRC.  Do so here.  Remember, CRC is only calculated using data bits.
  if(len < 0) {
    fprintf(stderr, "Program error: legacy debug JTAG read with negative length!\n");
    /*
      len = -len;
      for(i = 0; i < len; i++) {
      legacy_crc_w = legacy_crc_calc(legacy_crc_w, stream&1);
      stream >>= 1;
      legacy_crc_r = legacy_crc_calc(legacy_crc_r, datacpy&1);
      datacpy >>= 1;
      }
    */
     }
     else {
       for(i = len-1; i >= 0; i--) {
	 legacy_crc_w = legacy_crc_calc(legacy_crc_w, (stream>>i)&1);
	 legacy_crc_r = legacy_crc_calc(legacy_crc_r, (datacpy>>i)&1);
       }
     }

  return data;
}

//////////////////////////////////////////////////////////////////////////
// Actual operations on the legacy debug unit

/* Sets scan chain.  */
int legacy_dbg_set_chain(int chain) {
  int status, crc_generated, legacy_crc_read;
  desired_chain = chain;

try_again:
  if (current_chain == chain) return APP_ERR_NONE;
  current_chain = -1;
  debug("\nset_chain %i\n", chain);
  tap_set_shift_dr();    /* SHIFT_DR */ 
  
  /* write data, EXIT1_DR */
  legacy_crc_w = 0xffffffff;
  legacy_write_stream(((chain & 0xf) | (1<<DC_SIZE)), DC_SIZE + 1, 0);
  legacy_write_stream(legacy_crc_w, DBG_CRC_SIZE, 0);

  legacy_crc_r = 0xffffffff;
  status = legacy_read_stream(0, DC_STATUS_SIZE, 0);
  crc_generated = legacy_crc_r;
  legacy_crc_read = legacy_read_stream(0, DBG_CRC_SIZE, 1);

  debug("Status/CRC read / CRC generated: %x %x %x\n", status, legacy_crc_read, crc_generated);
  /* CRCs must match, otherwise retry */
  if (legacy_crc_read != crc_generated) {
    if (retry_do()) goto try_again;
    else return APP_ERR_CRC;
  }
  /* we should read expected status value, otherwise retry */
  if (status != 0) {
    if (retry_do()) goto try_again;
    else return APP_ERR_BAD_PARAM;
  }

  /* reset retry counter */
  retry_ok();
  tap_exit_to_idle();  // Transition the TAP back to state IDLE  
  current_chain = chain;

  debug("Successfully set chain to %i\n", current_chain);
  return APP_ERR_NONE;
}

/* sends out a command with 32bit address and 16bit length, if len >= 0 */
int legacy_dbg_command(int type, unsigned long adr, int len) {
  int status, crc_generated, legacy_crc_read;

try_again:
  legacy_dbg_set_chain(desired_chain);
  debug("\ncomm %i\n", type);

  /***** WRITEx *****/
  tap_set_shift_dr();  /* SHIFT_DR */ 
  
  /* write data, EXIT1_DR */
  legacy_crc_w = 0xffffffff;
  legacy_write_stream(((DI_WRITE_CMD & 0xf) | (0<<DC_SIZE)), DC_SIZE + 1, 0);
  legacy_write_stream(type, 4, 0);
  legacy_write_stream(adr, 32, 0);
  assert(len > 0);
  legacy_write_stream(len - 1, 16, 0);
  legacy_write_stream(legacy_crc_w, DBG_CRC_SIZE, 0);

  legacy_crc_r = 0xffffffff;  
  status = legacy_read_stream(0, DC_STATUS_SIZE, 0);
  crc_generated = legacy_crc_r;
  legacy_crc_read = legacy_read_stream(0, DBG_CRC_SIZE, 1);

  /* CRCs must match, otherwise retry */
  if (legacy_crc_read != crc_generated) {
    if (retry_do()) goto try_again;
    else return APP_ERR_CRC;
  }
  /* we should read expected status value, otherwise retry */
  if (status != 0) {
    if (retry_do()) goto try_again;
    else return APP_ERR_BAD_PARAM;
  }

  tap_exit_to_idle();  // Transition the TAP back to state IDLE

  /* reset retry counter */
  retry_ok();
  return APP_ERR_NONE;
}

/* writes a ctrl reg */
int legacy_dbg_ctrl(int reset, int stall) {
  int status, crc_generated, legacy_crc_read;

try_again:
  legacy_dbg_set_chain(desired_chain);
  debug("\nctrl\n");

  /***** WRITEx *****/
  tap_set_shift_dr(); /* SHIFT_DR */
  
  /* write data, EXIT1_DR */
  legacy_crc_w = 0xffffffff;
  legacy_write_stream(((DI_WRITE_CTRL & 0xf) | (0<<DC_SIZE)), DC_SIZE + 1, 0);
  legacy_write_stream(reset, 1, 0);
  legacy_write_stream(stall, 1, 0);
  legacy_write_stream(0, 32, 0); // legacy_write_stream() has a max size of 32 bits, we need 50
  legacy_write_stream(0, 18, 0);
  legacy_write_stream(legacy_crc_w, DBG_CRC_SIZE, 0);

  legacy_crc_r = 0xffffffff;  
  status = legacy_read_stream(0, DC_STATUS_SIZE, 0);
  crc_generated = legacy_crc_r;
  legacy_crc_read = legacy_read_stream(0, DBG_CRC_SIZE, 1);

  /* CRCs must match, otherwise retry */
  debug("did ctrl: %x %x %x\n", status, legacy_crc_read, crc_generated);
  if (legacy_crc_read != crc_generated) {
    if (retry_do()) goto try_again;
    else return APP_ERR_CRC;
  }
  /* we should read expected status value, otherwise retry */
  if (status != 0) {
    if (retry_do()) goto try_again;
    else return APP_ERR_BAD_PARAM;
  }
  
  tap_exit_to_idle();  // Transition the TAP back to state IDLE

  /* reset retry counter */
  retry_ok();
  return APP_ERR_NONE;
}


/* reads control register */
int legacy_dbg_ctrl_read(int *reset, int *stall) {
  int status, crc_generated, legacy_crc_read;

  try_again:
  legacy_dbg_set_chain(desired_chain);
  debug("\nctrl_read\n");

  tap_set_shift_dr(); /* SHIFT_DR */ 
  
  /* write data, EXIT1_DR */
  legacy_crc_w = 0xffffffff;
  legacy_write_stream(DI_READ_CTRL | (0<<DC_SIZE), DC_SIZE + 1, 0);
  legacy_write_stream(legacy_crc_w, DBG_CRC_SIZE, 0);

  legacy_crc_r = 0xffffffff;
  *reset = legacy_read_stream(0, 1, 0);
  *stall = legacy_read_stream(0, 1, 0);
  legacy_read_stream(0, 32, 0);  // legacy_read_stream() has a max size of 32 bits, we need 50
  legacy_read_stream(0, 18, 0);
  status = legacy_read_stream(0, DC_STATUS_SIZE, 0);
  crc_generated = legacy_crc_r;
  legacy_crc_read = legacy_read_stream(0, DBG_CRC_SIZE, 1);
  
  /* CRCs must match, otherwise retry */
  debug("read ctrl: %x %x %x.  reset = %i, stall = %i\n", status, legacy_crc_read, crc_generated, *reset, *stall);
  if (legacy_crc_read != crc_generated) {
    if (retry_do()) goto try_again;
    else return APP_ERR_CRC;
  }
  /* we should read expected status value, otherwise retry */
  if (status != 0) {
    if (retry_do()) goto try_again;
    else return APP_ERR_BAD_PARAM;
  }

  tap_exit_to_idle();  // Transition the TAP back to state IDLE

  /* reset retry counter */
  retry_ok();
  return APP_ERR_NONE;
}
/* issues a burst read/write */
int legacy_dbg_go(unsigned char *data, unsigned short len, int read) {
  int status, crc_generated, legacy_crc_read;
  int i;

  //try_again:
  // No point in re-trying without sending the command again first...

  legacy_dbg_set_chain(desired_chain);
  debug("\ngo len = %d\n", len);

  tap_set_shift_dr(); /* SHIFT_DR */ 
  
  /* write data, EXIT1_DR */
  legacy_crc_w = 0xffffffff;
  legacy_write_stream(DI_GO | (0<<DC_SIZE), DC_SIZE + 1, 0);
  if (!read) {
    /* reverse byte ordering, since we must send in big endian */
    for (i = 0; i < len; i++)
      legacy_write_stream(data[i], 8, 0);
  }
  legacy_write_stream(legacy_crc_w, DBG_CRC_SIZE, 0);

  legacy_crc_r = 0xffffffff;

  if (read) {
    /* reverse byte ordering, since we must send in big endian */
    for (i = 0; i < len; i++)
      data[i] = legacy_read_stream(0, 8, 0);
  }
  status = legacy_read_stream(0, DC_STATUS_SIZE, 0);
  crc_generated = legacy_crc_r;
  legacy_crc_read = legacy_read_stream(0, DBG_CRC_SIZE, 1);
  
  /* CRCs must match, otherwise retry */
  debug("%x %x %x\n", status, legacy_crc_read, crc_generated);
  if (legacy_crc_read != crc_generated) {
    //if (retry_do()) goto try_again;
    //else 
    return APP_ERR_CRC;
  }
  /* we should read expected status value, otherwise retry */
  if (status != 0) {
    //if (retry_do()) goto try_again;
    //else 
    return status;
  }

  tap_exit_to_idle();  // Transition the TAP back to state IDLE

  /* reset retry counter */
  retry_ok();
  return APP_ERR_NONE;
}

