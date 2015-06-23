/* dbg_api.c -- JTAG protocol bridge between GDB and Advanced debug module.
   Copyright(C) 2009 - 2011 Nathan Yawn, nyawn@opencores.net
   based on code from jp2 by Marko Mlinar, markom@opencores.org
   
   This file contains API functions which may be called from the GDB
   interface server.  These functions call the appropriate hardware-
   specific functions for the advanced debug interface or the legacy
   debug interface, depending on which is selected.
   
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
#include <pthread.h>  // for mutexes
#include <arpa/inet.h>  // for ntohl()

#include "adv_dbg_commands.h"
#include "legacy_dbg_commands.h"
#include "cable_common.h"
#include "errcodes.h"

#define debug(...) //fprintf(stderr, __VA_ARGS__ )

#define DBG_HW_ADVANCED 1
#define DBG_HW_LEGACY   2
#ifdef __LEGACY__
#define DEBUG_HARDWARE DBG_HW_LEGACY
#else
#define DEBUG_HARDWARE  DBG_HW_ADVANCED
#endif

pthread_mutex_t dbg_access_mutex = PTHREAD_MUTEX_INITIALIZER;

/* read a word from wishbone */
int dbg_wb_read32(uint32_t adr, uint32_t *data) {
  int err;
  pthread_mutex_lock(&dbg_access_mutex);

  if(DEBUG_HARDWARE == DBG_HW_ADVANCED)
    {
      if ((err = adbg_select_module(DC_WISHBONE)))
	{
	  cable_flush();
	  pthread_mutex_unlock(&dbg_access_mutex);
	  return err;
	}
      err = adbg_wb_burst_read(4, 1, adr, (void *)data); // All WB reads / writes are bursts
    }
  else if(DEBUG_HARDWARE == DBG_HW_LEGACY)
    {
      if (APP_ERR_NONE == (err = legacy_dbg_set_chain(DC_WISHBONE)))
	if (APP_ERR_NONE == (err = legacy_dbg_command(0x6, adr, 4)))
	  err = legacy_dbg_go((unsigned char*)data, 4, 1);
      *data = ntohl(*data);
    }
  cable_flush();
  pthread_mutex_unlock(&dbg_access_mutex);
  return err;
}

/* write a word to wishbone */
int dbg_wb_write32(uint32_t adr, uint32_t data) {
  int err;
  pthread_mutex_lock(&dbg_access_mutex);

  if(DEBUG_HARDWARE == DBG_HW_ADVANCED)
    {
      if ((err = adbg_select_module(DC_WISHBONE)))
	{
	  cable_flush();
	  pthread_mutex_unlock(&dbg_access_mutex);
	  return err;
	}
      err = adbg_wb_burst_write((void *)&data, 4, 1, adr);
    }
  else if(DEBUG_HARDWARE == DBG_HW_LEGACY)
    {
      data = ntohl(data);
      if (APP_ERR_NONE == (err = legacy_dbg_set_chain(DC_WISHBONE)))
	if (APP_ERR_NONE == (err = legacy_dbg_command(0x2, adr, 4)))
	  err = legacy_dbg_go((unsigned char*)&data, 4, 0);  
    }
  cable_flush();
  pthread_mutex_unlock(&dbg_access_mutex);
  return err;
}

// write a word to wishbone
// Never actually called from the GDB interface
int dbg_wb_write16(uint32_t adr, uint16_t data) {
  int err;
  pthread_mutex_lock(&dbg_access_mutex);

  if(DEBUG_HARDWARE == DBG_HW_ADVANCED)
    {
      if ((err = adbg_select_module(DC_WISHBONE)))
	{
	  cable_flush();
	  pthread_mutex_unlock(&dbg_access_mutex);
	  return err;
	}  
      err = adbg_wb_burst_write((void *)&data, 2, 1, adr);
    }
  else if(DEBUG_HARDWARE == DBG_HW_LEGACY)
    {
        data = ntohs(data);
	if (APP_ERR_NONE == (err = legacy_dbg_set_chain(DC_WISHBONE)))
	  if (APP_ERR_NONE == (err = legacy_dbg_command(0x1, adr, 2)))
	    err = legacy_dbg_go((unsigned char*)&data, 2, 0);
    }
  cable_flush();
  pthread_mutex_unlock(&dbg_access_mutex);
  return err;
}

// write a word to wishbone
// Never actually called from the GDB interface
int dbg_wb_write8(uint32_t adr, uint8_t data) {
  int err;
  pthread_mutex_lock(&dbg_access_mutex);

  if(DEBUG_HARDWARE == DBG_HW_ADVANCED)
    {
      if ((err = adbg_select_module(DC_WISHBONE)))
	{
	  cable_flush();
	  pthread_mutex_unlock(&dbg_access_mutex);
	  return err;
	}
      err = adbg_wb_burst_write((void *)&data, 1, 1, adr);
    }
  else if(DEBUG_HARDWARE == DBG_HW_LEGACY)
    {
        if (APP_ERR_NONE == (err = legacy_dbg_set_chain(DC_WISHBONE)))
	  if (APP_ERR_NONE == (err = legacy_dbg_command(0x0, adr, 1)))
	    err = legacy_dbg_go((unsigned char*)&data, 1, 0);
    }
  cable_flush();
  pthread_mutex_unlock(&dbg_access_mutex);
  return err;
}


int dbg_wb_read_block32(uint32_t adr, uint32_t *data, int len) {
  int err;

  if(!len)
    return APP_ERR_NONE;  // GDB may issue a 0-length transaction to test if a feature is supported

  pthread_mutex_lock(&dbg_access_mutex);
  if(DEBUG_HARDWARE == DBG_HW_ADVANCED)
    {
      if ((err = adbg_select_module(DC_WISHBONE)))
	{
	  cable_flush();
	  pthread_mutex_unlock(&dbg_access_mutex);
	  return err;
	}
      err = adbg_wb_burst_read(4, len, adr, (void *)data);  // 'len' is words.
    }
  else if(DEBUG_HARDWARE == DBG_HW_LEGACY)
    {
      int i;
      int bytelen = len<<2;
      if (APP_ERR_NONE == (err = legacy_dbg_set_chain(DC_WISHBONE)))
	if (APP_ERR_NONE == (err = legacy_dbg_command(0x6, adr, bytelen)))
	  if (APP_ERR_NONE == (err = legacy_dbg_go((unsigned char*)data, bytelen, 1))) // 'len' is words, call wants bytes
	    for (i = 0; i < len; i ++) data[i] = ntohl(data[i]);   
    }
  cable_flush();
  pthread_mutex_unlock(&dbg_access_mutex);
  return err;
}


// Never actually called from the GDB interface
int dbg_wb_read_block16(uint32_t adr, uint16_t *data, int len) {
  int err;

  if(!len)
    return APP_ERR_NONE;  // GDB may issue a 0-length transaction to test if a feature is supported

  pthread_mutex_lock(&dbg_access_mutex);
  if(DEBUG_HARDWARE == DBG_HW_ADVANCED)
    {
      if ((err = adbg_select_module(DC_WISHBONE)))
	{
	  cable_flush();
	  pthread_mutex_unlock(&dbg_access_mutex);
	  return err;
	}
      err = adbg_wb_burst_read(2, len, adr, (void *)data);  // 'len' is 16-bit halfwords
    }
  else if(DEBUG_HARDWARE == DBG_HW_LEGACY)
    {
      int i;
      int bytelen = len<<1;
      if (APP_ERR_NONE == (err = legacy_dbg_set_chain(DC_WISHBONE)))
	if (APP_ERR_NONE == (err = legacy_dbg_command(0x5, adr, bytelen)))
	  if (APP_ERR_NONE == (err = legacy_dbg_go((unsigned char*)data, bytelen, 1)))  // 'len' is halfwords, call wants bytes
	    for (i = 0; i < len; i ++) data[i] = ntohs(data[i]); 
    }
  cable_flush();
  pthread_mutex_unlock(&dbg_access_mutex);
  return err;
}

// Never actually called from the GDB interface
int dbg_wb_read_block8(uint32_t adr, uint8_t *data, int len) {
  int err;

  if(!len)
    return APP_ERR_NONE;  // GDB may issue a 0-length transaction to test if a feature is supported

  pthread_mutex_lock(&dbg_access_mutex);
  if(DEBUG_HARDWARE == DBG_HW_ADVANCED)
    {
      if ((err = adbg_select_module(DC_WISHBONE)))
	{
	  cable_flush();
	  pthread_mutex_unlock(&dbg_access_mutex);
	  return err;
	}
      err = adbg_wb_burst_read(1, len, adr, (void *)data);  // *** is 'len' bits or words?? Call wants words...
    }
  else if(DEBUG_HARDWARE == DBG_HW_LEGACY)
    {
      if (APP_ERR_NONE == (err = legacy_dbg_set_chain(DC_WISHBONE)))
	if (APP_ERR_NONE == (err = legacy_dbg_command(0x4, adr, len)))
	  err = legacy_dbg_go((unsigned char*)data, len, 1);
    }
  cable_flush();
  pthread_mutex_unlock(&dbg_access_mutex);
  return err;
}


// write a block to wishbone 
int dbg_wb_write_block32(uint32_t adr, uint32_t *data, int len) {
  int err;

  if(!len)
    return APP_ERR_NONE;  // GDB may issue a 0-length transaction to test if a feature is supported

  pthread_mutex_lock(&dbg_access_mutex);
  if(DEBUG_HARDWARE == DBG_HW_ADVANCED)
    {
      if ((err = adbg_select_module(DC_WISHBONE)))
	{
	  cable_flush();
	  pthread_mutex_unlock(&dbg_access_mutex);
	  return err;
	}
      err = adbg_wb_burst_write((void *)data, 4, len, adr);  // 'len' is words.
    }
  else if(DEBUG_HARDWARE == DBG_HW_LEGACY)
    {
      int i;
      int bytelen = len << 2;
      for (i = 0; i < len; i ++) data[i] = ntohl(data[i]);
      if (APP_ERR_NONE == (err = legacy_dbg_set_chain(DC_WISHBONE)))
	if (APP_ERR_NONE == (err = legacy_dbg_command(0x2, adr, bytelen)))
	  err = legacy_dbg_go((unsigned char*)data, bytelen, 0);  // 'len' is words, call wants bytes 
    }
  cable_flush();
  pthread_mutex_unlock(&dbg_access_mutex);
  return err;
}


// write a block to wishbone
// Never actually called from the GDB interface
int dbg_wb_write_block16(uint32_t adr, uint16_t *data, int len) {
  int err;

  if(!len)
    return APP_ERR_NONE;  // GDB may issue a 0-length transaction to test if a feature is supported

  pthread_mutex_lock(&dbg_access_mutex);
  if(DEBUG_HARDWARE == DBG_HW_ADVANCED)
    {
      if ((err = adbg_select_module(DC_WISHBONE)))
	{
	  cable_flush();
	  pthread_mutex_unlock(&dbg_access_mutex);
	  return err;
	}
      err = adbg_wb_burst_write((void *)data, 2, len, adr);  // 'len' is (half)words
    }
  else if(DEBUG_HARDWARE == DBG_HW_LEGACY)
    {
      int i;
      int bytelen = len<<1;
      for (i = 0; i < len; i ++) data[i] = ntohs(data[i]);
      if (APP_ERR_NONE == (err = legacy_dbg_set_chain(DC_WISHBONE)))
	if (APP_ERR_NONE == (err = legacy_dbg_command(0x1, adr, bytelen)))
	  err = legacy_dbg_go((unsigned char*)data, bytelen, 0);  // 'len' is 16-bit halfwords, call wants bytes  
    }
  cable_flush();
  pthread_mutex_unlock(&dbg_access_mutex);
  return err;
}

// write a block to wishbone
int dbg_wb_write_block8(uint32_t adr, uint8_t *data, int len) {
  int err;

  if(!len)
    return APP_ERR_NONE;  // GDB may issue a 0-length transaction to test if a feature is supported

  pthread_mutex_lock(&dbg_access_mutex);
  if(DEBUG_HARDWARE == DBG_HW_ADVANCED)
    {
      if ((err = adbg_select_module(DC_WISHBONE)))
	{
	  cable_flush();
	  pthread_mutex_unlock(&dbg_access_mutex);
	  return err;
	}
      err = adbg_wb_burst_write((void *)data, 1, len, adr);  // 'len' is in words...
    }
  else if(DEBUG_HARDWARE == DBG_HW_LEGACY)
    {
      if (APP_ERR_NONE == (err = legacy_dbg_set_chain(DC_WISHBONE)))
	if (APP_ERR_NONE == (err = legacy_dbg_command(0x0, adr, len)))
	  err = legacy_dbg_go((unsigned char*)data, len, 0); 
    }
  cable_flush();
  pthread_mutex_unlock(&dbg_access_mutex);
  return err;
}


/* read a register from cpu0.  This is assumed to be an OR32 CPU, with 32-bit regs. */
int dbg_cpu0_read(uint32_t adr, uint32_t *data) {
  int err;
  pthread_mutex_lock(&dbg_access_mutex);

  if(DEBUG_HARDWARE == DBG_HW_ADVANCED)
    {
      if ((err = adbg_select_module(DC_CPU0)))
	{
	  cable_flush();
	  pthread_mutex_unlock(&dbg_access_mutex);
	  return err;
	}
      err = adbg_wb_burst_read(4, 1, adr, (void *) data); // All CPU register reads / writes are bursts
    }
  else if(DEBUG_HARDWARE == DBG_HW_LEGACY)
    {
      if (APP_ERR_NONE == (err = legacy_dbg_set_chain(DC_CPU0)))
	if (APP_ERR_NONE == (err = legacy_dbg_command(0x6, adr, 4)))
	  if (APP_ERR_NONE == (err = legacy_dbg_go((unsigned char*)data, 4, 1)))
	    *data = ntohl(*data);
    }
  cable_flush();
  pthread_mutex_unlock(&dbg_access_mutex);
  debug("dbg_cpu_read(), addr 0x%X, data[0] = 0x%X\n", adr, data[0]);
  return err;
}

/* read multiple registers from cpu0.  This is assumed to be an OR32 CPU, with 32-bit regs. */
int dbg_cpu0_read_block(uint32_t adr, uint32_t *data, int count) {
  int err;

  if(DEBUG_HARDWARE == DBG_HW_ADVANCED)
    {
      pthread_mutex_lock(&dbg_access_mutex);
      if ((err = adbg_select_module(DC_CPU0)))
	{
	  cable_flush();
	  pthread_mutex_unlock(&dbg_access_mutex);
	  return err;
	}
      err = adbg_wb_burst_read(4, count, adr, (void *) data); // All CPU register reads / writes are bursts
      cable_flush();
      pthread_mutex_unlock(&dbg_access_mutex);
    }
  else if(DEBUG_HARDWARE == DBG_HW_LEGACY)
    {
      int i;
      unsigned long readaddr = adr;
      err = APP_ERR_NONE;
      for(i = 0; i < count; i++) {
	err |= dbg_cpu0_read(readaddr++, &data[i]);
      }
    }

  debug("dbg_cpu_read_block(), addr 0x%X, count %i, data[0] = 0x%X\n", adr, count, data[0]);
  return err;
}

/* write a cpu register to cpu0.  This is assumed to be an OR32 CPU, with 32-bit regs. */
int dbg_cpu0_write(uint32_t adr, uint32_t data) {
  int err;
  pthread_mutex_lock(&dbg_access_mutex);

  if(DEBUG_HARDWARE == DBG_HW_ADVANCED)
    {
      if ((err = adbg_select_module(DC_CPU0))) 
	{
	  cable_flush();
	  pthread_mutex_unlock(&dbg_access_mutex);
	  return err;
	}
      err = adbg_wb_burst_write((void *)&data, 4, 1, adr);
    }
  else if(DEBUG_HARDWARE == DBG_HW_LEGACY)
    {
      data = ntohl(data);
      if (APP_ERR_NONE == (err = legacy_dbg_set_chain(DC_CPU0)))
	if (APP_ERR_NONE == (err = legacy_dbg_command(0x2, adr, 4)))
	  err = legacy_dbg_go((unsigned char*)&data, 4, 0);  
    }
  debug("cpu0_write, adr 0x%X, data 0x%X, ret %i\n", adr, data, err);
  cable_flush();
  pthread_mutex_unlock(&dbg_access_mutex);
  return err;
}

/* write multiple cpu registers to cpu0.  This is assumed to be an OR32 CPU, with 32-bit regs. */
int dbg_cpu0_write_block(uint32_t adr, uint32_t *data, int count) {
  int err;
  
  if(DEBUG_HARDWARE == DBG_HW_ADVANCED)
    {
      pthread_mutex_lock(&dbg_access_mutex);
      if ((err = adbg_select_module(DC_CPU0)))
	{
	  cable_flush();
	  pthread_mutex_unlock(&dbg_access_mutex);
	  return err;
	}
      err = adbg_wb_burst_write((void *)data, 4, count, adr);
      cable_flush();
      pthread_mutex_unlock(&dbg_access_mutex);
    }
  else if(DEBUG_HARDWARE == DBG_HW_LEGACY)
    {
      int i;
      unsigned long writeaddr = adr;
      err = APP_ERR_NONE;
      for(i = 0; i < count; i++) {
	err |= dbg_cpu0_write(writeaddr++, data[i]);
      }
    }
  debug("cpu0_write_block, adr 0x%X, data[0] 0x%X, count %i, ret %i\n", adr, data[0], count, err);
 
  return err;
}

/* write a debug unit cpu module register 
 * Since OR32 debug module has only 1 register,
 * adr is ignored (for now) */
int dbg_cpu0_write_ctrl(uint32_t adr, uint8_t data) {
  int err = APP_ERR_NONE;
  uint32_t dataword = data;
  pthread_mutex_lock(&dbg_access_mutex);

  if(DEBUG_HARDWARE == DBG_HW_ADVANCED)
    {
      if ((err = adbg_select_module(DC_CPU0))) {
	printf("Failed to set chain to 0x%X\n", DC_CPU0);
	cable_flush();
	pthread_mutex_unlock(&dbg_access_mutex);
	return err;
      }
      if((err = adbg_ctrl_write(DBG_CPU0_REG_STATUS, &dataword, 2))) {
	printf("Failed to write chain to 0x%X control reg 0x%X\n", DC_CPU0,DBG_CPU0_REG_STATUS );  // Only 2 bits: Reset, Stall
	cable_flush();
	pthread_mutex_unlock(&dbg_access_mutex);
	return err;
      }
    }
  else if(DEBUG_HARDWARE == DBG_HW_LEGACY)
    {
      if (APP_ERR_NONE == (err = legacy_dbg_set_chain(DC_CPU0)))
	err = legacy_dbg_ctrl(data & 2, data &1);
    }
  debug("cpu0_write_ctrl(): set reg to 0x%X\n", data);
  cable_flush();
  pthread_mutex_unlock(&dbg_access_mutex);
  return err;
}


/* read a register from cpu module of the debug unit. 
 * Currently, there is only 1 register, so we do not need to select it, adr is ignored
 */
int dbg_cpu0_read_ctrl(uint32_t adr, uint8_t *data) {
  int err = APP_ERR_NONE;
  uint32_t dataword;
  pthread_mutex_lock(&dbg_access_mutex);

  // reset is bit 1, stall is bit 0 in *data
  if(DEBUG_HARDWARE == DBG_HW_ADVANCED)
    {
      if ((err = adbg_select_module(DC_CPU0))) {
	printf("Failed to set chain to 0x%X\n", DC_CPU0);
	cable_flush();
	pthread_mutex_unlock(&dbg_access_mutex);
	return err;
      }
      if ((err = adbg_ctrl_read(DBG_CPU0_REG_STATUS, &dataword, 2))) {
	printf("Failed to read chain 0x%X control reg 0x%X\n", DC_CPU0, DBG_CPU0_REG_STATUS);
	cable_flush();
	pthread_mutex_unlock(&dbg_access_mutex);
	return err;
      }
      *data = dataword;
    }
  else if(DEBUG_HARDWARE == DBG_HW_LEGACY)
    {
      int r, s;
      if (APP_ERR_NONE == (err = legacy_dbg_set_chain(DC_CPU0)))
	err = legacy_dbg_ctrl_read(&r, &s);
      *data = (r << 1) | s;
      debug("api cpu0 read ctrl: r = %i, s = %i, data = %i\n", r, s, *data);
    }
  cable_flush();
  pthread_mutex_unlock(&dbg_access_mutex);
  return err;
}

// CPU1 Functions.  Note that 2 CPUs are not currently supported by GDB, so these are never actually
// called from the GDB interface.  They are included for completeness and future use.
// read a register from cpu1
int dbg_cpu1_read(uint32_t adr, uint32_t *data)
 {
  int err;
  pthread_mutex_lock(&dbg_access_mutex);

  if(DEBUG_HARDWARE == DBG_HW_ADVANCED)
    {
      if ((err = adbg_select_module(DC_CPU1)))
	{
	  cable_flush();
	  pthread_mutex_unlock(&dbg_access_mutex);
	  return err;
	}
      err = adbg_wb_burst_read(4, 1, adr, (void *) data); // All CPU register reads / writes are bursts
    }
  else if(DEBUG_HARDWARE == DBG_HW_LEGACY)
    {
      if (APP_ERR_NONE == (err = legacy_dbg_set_chain(DC_CPU1)))
	if (APP_ERR_NONE == (err = legacy_dbg_command(0x6, adr, 4)))
	  err = legacy_dbg_go((unsigned char*)data, 4, 1);
      *data = ntohl(*data); 
    }
  cable_flush();
  pthread_mutex_unlock(&dbg_access_mutex);
  return err;
}


// write a cpu register
int dbg_cpu1_write(uint32_t adr, uint32_t data) 
{
  int err;
  pthread_mutex_lock(&dbg_access_mutex);

  if(DEBUG_HARDWARE == DBG_HW_ADVANCED)
    {
  if ((err = adbg_select_module(DC_CPU0)))
    {
      cable_flush();
      pthread_mutex_unlock(&dbg_access_mutex);
      return err;
    }
  err = adbg_wb_burst_write((void *)&data, 4, 1, adr);
    }
  else if(DEBUG_HARDWARE == DBG_HW_LEGACY)
    {
      data = ntohl(data);
      if (APP_ERR_NONE == (err = legacy_dbg_set_chain(DC_CPU1)))
	if (APP_ERR_NONE == (err = legacy_dbg_command(0x2, adr, 4)))
	  err = legacy_dbg_go((unsigned char*)&data, 4, 0);
    }
  cable_flush();
  pthread_mutex_unlock(&dbg_access_mutex);
  return err;
}


// write a debug unit cpu module register
int dbg_cpu1_write_ctrl(uint32_t adr, uint8_t data) {
   int err;
  uint32_t dataword = data;
  pthread_mutex_lock(&dbg_access_mutex);

  if(DEBUG_HARDWARE == DBG_HW_ADVANCED)
    {
      if ((err = adbg_select_module(DC_CPU1))) {
	printf("Failed to set chain to 0x%X\n", DC_CPU1);
	cable_flush();
	pthread_mutex_unlock(&dbg_access_mutex);
	return err;
      }
      if((err = adbg_ctrl_write(DBG_CPU1_REG_STATUS, &dataword, 2))) {
	printf("Failed to write chain to 0x%X control reg 0x%X\n", DC_CPU1,DBG_CPU0_REG_STATUS );  // Only 2 bits: Reset, Stall
	cable_flush();
	pthread_mutex_unlock(&dbg_access_mutex);
	return err;
      }
    }
  else if(DEBUG_HARDWARE == DBG_HW_LEGACY)
    {
      if (APP_ERR_NONE == (err = legacy_dbg_set_chain(DC_CPU1)))
	err = legacy_dbg_ctrl(data & 2, data & 1);
    }
  cable_flush();
  pthread_mutex_unlock(&dbg_access_mutex);
  return err;
}


// read a debug unit cpu module register
int dbg_cpu1_read_ctrl(uint32_t adr, uint8_t *data) {
  int err;
  uint32_t dataword;
  pthread_mutex_lock(&dbg_access_mutex);

  // reset is bit 1, stall is bit 0 in *data

  if(DEBUG_HARDWARE == DBG_HW_ADVANCED)
    {
      if ((err = adbg_select_module(DC_CPU1))) {
	printf("Failed to set chain to 0x%X\n", DC_CPU1);
	cable_flush();
	pthread_mutex_unlock(&dbg_access_mutex);
	return err;
      }
      if ((err = adbg_ctrl_read(DBG_CPU1_REG_STATUS, &dataword, 2))) {
	printf("Failed to read chain 0x%X control reg 0x%X\n", DC_CPU0, DBG_CPU1_REG_STATUS);
	cable_flush();
	pthread_mutex_unlock(&dbg_access_mutex);
	return err;
      }
     *data = dataword;
    }
  else if(DEBUG_HARDWARE == DBG_HW_LEGACY)
    {
      int r, s;
      if (APP_ERR_NONE == (err = legacy_dbg_set_chain(DC_CPU1)))
	err = legacy_dbg_ctrl_read(&r, &s);
      *data = (r << 1) | s; 
    }
  cable_flush();
  pthread_mutex_unlock(&dbg_access_mutex);
  return err;
}

int dbg_serial_sndrcv(unsigned int *bytes_to_send, const uint8_t *data_to_send, unsigned int *bytes_received, uint8_t *data_received) {
  int err; 

  pthread_mutex_lock(&dbg_access_mutex);

  if ((err = adbg_select_module(DC_JSP))) {
    printf("Failed to set chain to 0x%X\n", DC_JSP);
    cable_flush();
    pthread_mutex_unlock(&dbg_access_mutex);
    return err;
  }
 
  err = adbg_jsp_transact(bytes_to_send, data_to_send, bytes_received, data_received);
 
  cable_flush();
  pthread_mutex_unlock(&dbg_access_mutex);
  
  return err;
}


