/* chain_commands.c -- JTAG protocol bridge between GDB and Advanced debug module.
   Copyright(C) 2008 - 2010 Nathan Yawn, nyawn@opencores.net
   based on code from jp2 by Marko Mlinar, markom@opencores.org
   
   This file contains functions which perform mid-level transactions
   on a JTAG, such as setting a value in the TAP IR
   or doing a burst write on the JTAG chain.
   
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
   Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA. 
*/



#include <stdio.h>
#include <stdlib.h>  // for malloc()
#include <unistd.h>  // for usleep()
//#include <pthread.h>  // for mutexes

#include "chain_commands.h"  // For the return error codes
#include "altera_virtual_jtag.h"  // hardware-specifg defines for the Altera Virtual JTAG interface
#include "cable_common.h"         // low-level JTAG IO routines
#include "adv_dbg_commands.h"  // for the kludge in tap_reset()
#include "errcodes.h"

#define debug(...) //fprintf(stderr, __VA_ARGS__ )

// How many tries before an abort
#define NUM_SOFT_RETRIES 0

// for the klugde in tap_reset()
extern int current_reg_idx[DBG_MAX_MODULES];

/* Currently selected scan chain in the debug unit - just to prevent unnecessary
   transfers. */
int current_chain = -1;
int desired_chain = -1;

// wait for 100ms
#define JTAG_RETRY_WAIT() usleep(100000);

// Retry data
int soft_retry_no = 0;
//static int hard_retry_no = 0;

// Configuration data
int global_IR_size = 0;
int global_IR_prefix_bits = 0;
int global_IR_postfix_bits = 0;
int global_DR_prefix_bits = 0;
int global_DR_postfix_bits = 0;
unsigned int global_jtag_cmd_debug = 0;        // Value to be shifted into the TAP IR to select the debug unit (unused for virtual jtag)
unsigned char global_altera_virtual_jtag = 0;  // Set true to use virtual jtag mode
unsigned int vjtag_cmd_vir = ALTERA_CYCLONE_CMD_VIR;  // virtual IR-shift command for altera devices, may be configured on command line
unsigned int vjtag_cmd_vdr = ALTERA_CYCLONE_CMD_VDR; // virtual DR-shift, ditto
unsigned char global_xilinx_bscan = 0;  // Set true if the hardware uses a Xilinx BSCAN_* device.


///////////////////////////////////////////////////////////////////////
// Configuration

void config_set_IR_size(int size) {
  global_IR_size = size;
}

void config_set_IR_prefix_bits(int bits) {
  global_IR_prefix_bits = bits;
}

void config_set_IR_postfix_bits(int bits) {
  global_IR_postfix_bits = bits;
}

void config_set_DR_prefix_bits(int bits) {
  global_DR_prefix_bits = bits;
}

void config_set_DR_postfix_bits(int bits) {
  global_DR_postfix_bits = bits;
}

void config_set_debug_cmd(unsigned int cmd) {
  global_jtag_cmd_debug = cmd;
}

void config_set_alt_vjtag(unsigned char enable) {
  global_altera_virtual_jtag = (enable) ? 1:0;
}

// At present, all devices which support virtual JTAG use the same VIR/VDR
// commands.  But, if they ever change, these can be changed on the command line.
void config_set_vjtag_cmd_vir(unsigned int cmd) {
  vjtag_cmd_vir = cmd;
}

void config_set_vjtag_cmd_vdr(unsigned int cmd) {
  vjtag_cmd_vdr = cmd;
}

void config_set_xilinx_bscan(unsigned char enable) {
  global_xilinx_bscan = (enable) ? 1:0;
}

//////////////////////////////////////////////////////////////////////
// Functions which operate on the JTAG TAP


/* Resets JTAG - Writes TRST=1, and TRST=0.  Sends 8 TMS to put the TAP
 * in test_logic_reset mode, for good measure.
 */
int tap_reset(void) {
  int i;
  int err = APP_ERR_NONE;

  debug("\nreset(");
  err |= jtag_write_bit(0);
  JTAG_RETRY_WAIT();
  /* In case we don't have TRST reset it manually */
  for(i = 0; i < 8; i++) err |= jtag_write_bit(TMS);
  err |= jtag_write_bit(TRST);  // if TRST not supported, this puts us in test logic/reset
  JTAG_RETRY_WAIT();
  err |= jtag_write_bit(0);  // run test / idle
  debug(")\n");

  // Reset data on current module/register selections
  current_chain = -1;

  // (this is only for the adv. debug i/f...bit of a kludge)
  for(i = 0; i < DBG_MAX_MODULES; i++)
    current_reg_idx[i] = -1;

  return err;
}

  // Set the IR with the DEBUG command, one way or the other
int tap_enable_debug_module(void)
{
  uint32_t data;
 int err = APP_ERR_NONE;

  if(global_altera_virtual_jtag) {
    /* Set for virtual IR shift */
    err |= tap_set_ir(vjtag_cmd_vir);  // This is the altera virtual IR scan command
    err |= jtag_write_bit(TMS); /* SELECT_DR SCAN */
    err |= jtag_write_bit(0); /* CAPTURE_DR */
    err |= jtag_write_bit(0); /* SHIFT_DR */
    
    /* Select debug scan chain in  virtual IR */
    data = (0x1<<ALT_VJTAG_IR_SIZE)|ALT_VJTAG_CMD_DEBUG;
    err |= jtag_write_stream(&data, (ALT_VJTAG_IR_SIZE+1), 1);  // EXIT1_DR
    err |= jtag_write_bit(TMS); /* UPDATE_DR */
    err |= jtag_write_bit(0); /* IDLE */ 

    // This is a command to set an altera device to the "virtual DR shift" command
    err |= tap_set_ir(vjtag_cmd_vdr);
  }
  else {
    /* select debug scan chain and stay in it forever */
    err |= tap_set_ir(global_jtag_cmd_debug);
  }

  return err;
}

/* Moves a value into the TAP instruction register (IR)
 * Includes adjustment for scan chain IR length.
 */
uint32_t *ir_chain = NULL;

int tap_set_ir(int ir) {
  int chain_size;
  int chain_size_words;
  int i;
  int startoffset, startshift;
  int err = APP_ERR_NONE;
  
  // Adjust desired IR with prefix, postfix bits to set other devices in the chain to BYPASS
  chain_size = global_IR_size + global_IR_prefix_bits + global_IR_postfix_bits;
  chain_size_words = (chain_size/32)+1;

  if(ir_chain == NULL)  { // We have no way to know in advance how many bits there are in the combined IR register
    ir_chain = (uint32_t *) malloc(chain_size_words * sizeof(uint32_t));
    if(ir_chain == NULL)
      return APP_ERR_MALLOC;
  }

  for(i = 0; i < chain_size_words; i++)
    ir_chain[i] = 0xFFFFFFFF;  // Set all other devices to BYPASS

  // Copy the IR value into the output stream
  startoffset = global_IR_postfix_bits/32;
  startshift = (global_IR_postfix_bits - (startoffset*32));
  ir_chain[startoffset] &= (ir << startshift);
  ir_chain[startoffset] |= ~(0xFFFFFFFF << startshift);  // Put the 1's back in the LSB positions
  ir_chain[startoffset] |= (0xFFFFFFFF << (startshift + global_IR_size));  // Put 1's back in MSB positions, if any 
  if((startshift + global_IR_size) > 32) { // Deal with spill into the next word
    ir_chain[startoffset+1] &= ir >> (32-startshift);
    ir_chain[startoffset+1] |= (0xFFFFFFFF << (global_IR_size - (32-startshift)));  // Put the 1's back in the MSB positions
  }

  // Do the actual JTAG transaction
  debug("Set IR 0x%X\n", ir);
  err |= jtag_write_bit(TMS); /* SELECT_DR SCAN */
  err |= jtag_write_bit(TMS); /* SELECT_IR SCAN */

  err |= jtag_write_bit(0); /* CAPTURE_IR */
  err |= jtag_write_bit(0); /* SHIFT_IR */   

  /* write data, EXIT1_IR */
  debug("Setting IR, size %i, IR_size = %i, pre_size = %i, post_size = %i, data 0x%X\n", chain_size, global_IR_size, global_IR_prefix_bits, global_IR_postfix_bits, ir);
  err |= cable_write_stream(ir_chain, chain_size, 1);  // Use cable_ call directly (not jtag_), so we don't add DR prefix bits
  debug("Done setting IR\n");

  err |= jtag_write_bit(TMS); /* UPDATE_IR */
  err |= jtag_write_bit(0); /* IDLE */  
  current_chain = -1;
  return err;
}


// This assumes we are in the IDLE state, and we want to be in the SHIFT_DR state.
int tap_set_shift_dr(void)
{
  int err = APP_ERR_NONE;

  err |= jtag_write_bit(TMS); /* SELECT_DR SCAN */
  err |= jtag_write_bit(0); /* CAPTURE_DR */
  err |= jtag_write_bit(0); /* SHIFT_DR */

  return err;
}

// This transitions from EXIT1 to IDLE.  It should be the last thing called
// in any debug unit transaction.
int tap_exit_to_idle(void)
{
  int err = APP_ERR_NONE;

  err |= jtag_write_bit(TMS); /* UPDATE_DR */
  err |= jtag_write_bit(0); /* IDLE */

  return err;
}

////////////////////////////////////////////////////////////////////
// Operations to read / write data over JTAG


/* Writes TCLK=0, TRST=1, TMS=bit1, TDI=bit0
   and    TCLK=1, TRST=1, TMS=bit1, TDI=bit0
*/
int jtag_write_bit(uint8_t packet) {
  debug("Wbit(%i)\n", packet);
  return cable_write_bit(packet);
}

int jtag_read_write_bit(uint8_t packet, uint8_t *in_bit) {
  int retval = cable_read_write_bit(packet, in_bit);
  debug("RWbit(%i,%i)", packet, *in_bit);
  return retval;
}

// This automatically adjusts for the DR length (other devices on scan chain)
// when the set_TMS flag is true.
int jtag_write_stream(uint32_t *out_data, int length_bits, unsigned char set_TMS)
{
  int i;
  int err = APP_ERR_NONE;

  if(!set_TMS)
    err |= cable_write_stream(out_data, length_bits, 0);
  else if(global_DR_prefix_bits == 0)
    err |= cable_write_stream(out_data, length_bits, 1);
  else {
    err |= cable_write_stream(out_data, length_bits, 0);
    // It could be faster to do a cable_write_stream for all the prefix bits (if >= 8 bits),
    // but we'd need a data array of unknown (and theoretically unlimited)
    // size to hold the 0 bits to write.  TODO:  alloc/realloc one.
    for(i = 0; i < (global_DR_prefix_bits-1); i++)
      err |= jtag_write_bit(0);
    err |= jtag_write_bit(TMS);
  }
  return err;
}

// When set_TMS is true, this function insures the written data is in the desired position (past prefix bits)
// before sending TMS.  When 'adjust' is true, this function insures that the data read in accounts for postfix
// bits (they are shifted through before the read starts).
int jtag_read_write_stream(uint32_t *out_data, uint32_t *in_data, int length_bits, unsigned char adjust, unsigned char set_TMS)
{
  int i;
  int err = APP_ERR_NONE;

  if(adjust && (global_DR_postfix_bits > 0)) {
    // It would be faster to do a cable_write_stream for all the postfix bits,
    // but we'd need a data array of unknown (and theoretically unlimited)
    // size to hold the '0' bits to write.
    for(i = 0; i < global_DR_postfix_bits; i++)
      err |= cable_write_bit(0);
  }

  // If there are both prefix and postfix bits, we may shift more bits than strictly necessary.
  // If we shifted out the data while burning through the postfix bits, these shifts could be subtracted
  // from the number of prefix shifts.  However, that way leads to madness.
  if(!set_TMS)
    err |= cable_read_write_stream(out_data, in_data, length_bits, 0);  
  else if(global_DR_prefix_bits == 0)
    err |= cable_read_write_stream(out_data, in_data, length_bits, 1);  
  else {
    err |= cable_read_write_stream(out_data, in_data, length_bits, 0); 
    // It would be faster to do a cable_write_stream for all the prefix bits,
    // but we'd need a data array of unknown (and theoretically unlimited)
    // size to hold the '0' bits to write.
    for(i = 0; i < (global_DR_prefix_bits-1); i++)
      err |= jtag_write_bit(0);
    err |= jtag_write_bit(TMS);
  }
  return err;
}



// This function attempts to determine the structure of the JTAG chain
// It can determine how many devices are present.
// If the devices support the IDCODE command, it will be read and stored.
// There is no way to automatically determine the length of the IR registers - 
// this must be read from a BSDL file, if IDCODE is supported.
// When IDCODE is not supported, IR length of the target device must be entered on the command line.

#define ALLOC_SIZE 64
#define MAX_DEVICES 1024
int jtag_enumerate_chain(uint32_t **id_array, int *num_devices)
{
  uint32_t invalid_code = 0x7f;  // Shift this out, we know we're done when we get it back
  const unsigned int done_code = 0x3f;  // invalid_code is altered, we keep this for comparison (minus the start bit)
  int devindex = 0;  // which device we are currently trying to detect
  uint32_t tempID;
  uint32_t temp_manuf_code;
  uint32_t temp_rest_code;
  uint8_t start_bit = 0;
  uint32_t *idcodes;
  int reallocs = 0;
  int err = APP_ERR_NONE;

  // Malloc a reasonable number of entries, we'll expand if we must.  Linked lists are overrated.
  idcodes = (uint32_t *) malloc(ALLOC_SIZE*sizeof(uint32_t));
  if(idcodes == NULL) { 
    printf("Failed to allocate memory for device ID codes!\n"); 
    return APP_ERR_MALLOC;
  }

  // Put in SHIFT-DR mode
  err |= jtag_write_bit(TMS); /* SELECT_DR SCAN */
  err |= jtag_write_bit(0); /* CAPTURE_DR */
  err |= jtag_write_bit(0); /* SHIFT_DR */

  printf("Enumerating JTAG chain...\n");

  // Putting a limit on the # of devices supported has the useful side effect
  // of insuring we still exit in error cases (we never get the 0x7f manuf. id)
  while(devindex < MAX_DEVICES) {
    // get 1 bit. 0 = BYPASS, 1 = start of IDCODE
    err |= jtag_read_write_bit(invalid_code&0x01, &start_bit);
    invalid_code >>= 1;

    if(start_bit == 0) {
      if(devindex >= (ALLOC_SIZE << reallocs)) {  // Enlarge the memory array if necessary, double the size each time
	idcodes = (uint32_t *) realloc(idcodes, (ALLOC_SIZE << ++reallocs)*sizeof(uint32_t));
	if(idcodes == NULL) { 
	  printf("Failed to allocate memory for device ID codes during enumeration!\n"); 
	  return APP_ERR_MALLOC;
	}
      }
      idcodes[devindex] = -1;
      devindex++;
    }
    else {
      // get 11 bit manufacturer code
      err |= jtag_read_write_stream(&invalid_code, &temp_manuf_code, 11, 0, 0);
      invalid_code >>= 11;
      
      if(temp_manuf_code != done_code) {
	// get 20 more bits, rest of ID
	err |= jtag_read_write_stream(&invalid_code, &temp_rest_code, 20, 0, 0);
	invalid_code >>= 20;
	tempID = (temp_rest_code << 12) | (temp_manuf_code << 1) | 0x01;
	if(devindex >= (ALLOC_SIZE << reallocs)) {  // Enlarge the memory array if necessary, double the size each time
	  idcodes = (uint32_t *) realloc(idcodes, (ALLOC_SIZE << ++reallocs)*sizeof(unsigned long));
	  if(idcodes == NULL) { 
	    printf("Failed to allocate memory for device ID codes during enumeration!\n"); 
	    return APP_ERR_MALLOC;
	  }
	}
	idcodes[devindex] = tempID;
	devindex++;
      } else {
	break;
      }
    }

    if(err)  // Don't try to keep probing if we get a comm. error
      return err;
  }

  if(devindex >= MAX_DEVICES)
    printf("WARNING: maximum supported devices on JTAG chain (%i) exceeded.\n", MAX_DEVICES);

  // Put in IDLE mode
  err |= jtag_write_bit(TMS); /* EXIT1_DR */
  err |= jtag_write_bit(TMS); /* UPDATE_DR */
  err |= jtag_write_bit(0); /* IDLE */ 

  *id_array = idcodes;
  *num_devices = devindex;

  return err;
}



int jtag_get_idcode(uint32_t cmd, uint32_t *idcode)
{
  uint32_t data_out = 0;
  int err = APP_ERR_NONE;
  unsigned char saveconfig = global_altera_virtual_jtag;
  global_altera_virtual_jtag = 0; // We want the actual IDCODE, not the virtual device IDCODE

  err |= tap_set_ir(cmd);
  err |= tap_set_shift_dr();
  err |= jtag_read_write_stream(&data_out, idcode, 32, 1, 1);       /* EXIT1_DR */

  if(err)
    printf("Error getting ID code!\n");

  // Put in IDLE mode
  err |= jtag_write_bit(TMS); /* UPDATE_DR */
  err |= jtag_write_bit(0); /* IDLE */ 

  global_altera_virtual_jtag = saveconfig;
  return err;
}


/////////////////////////////////////////////////////////////////
// Helper functions

/* counts retries and returns zero if we should abort */
/* TODO: dynamically adjust timings */
int retry_do() {
  int err = APP_ERR_NONE;

  if (soft_retry_no >= NUM_SOFT_RETRIES) {
      return 0;

      // *** TODO:  Add a 'hard retry', which re-initializes the cable, re-enumerates the bus, etc.

  } else { /* quick reset */
    if(err |= tap_reset()) {
      printf("Error %s while resetting for retry.\n", get_err_string(err)); 
      return 0;
    }

    // Put us back into DEBUG mode
    if(err |= tap_enable_debug_module()) {
      printf("Error %s enabling debug module during retry.\n", get_err_string(err)); 
      return 0;
    }

    soft_retry_no++;
    printf("Retry...\n");
  }

  return 1;
}

/* resets retry counter */
void retry_ok() {
  soft_retry_no = 0;
}

