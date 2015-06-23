/* -*- c++ -*- */
/*
 * Copyright 2006 Free Software Foundation, Inc.
 * 
 * This file is part of GNU Radio
 * 
 * GNU Radio is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 3, or (at your option)
 * any later version.
 * 
 * GNU Radio is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with GNU Radio; see the file COPYING.  If not, write to
 * the Free Software Foundation, Inc., 51 Franklin Street,
 * Boston, MA 02110-1301, USA.
 */

/************************************************************************/
/** \file         eeprom_io.c
 *************************************************************************
 *  \brief        read and write functions for i2c eeproms
 *  
 *  \author       GNU Radio
 */

#include <stdint.h>
#include <stdio.h>
#include "gecko3com_i2c.h" /* in this file are the device adresses defined */
#include "eeprom_io.h"
#include "i2c.h"
#include "delay.h"
#include "debugprint.h"

#define EEPROM_HIGH_ADDR 0x3FFF /**< highest available addres, length */
#define PAGE_LEN  0x40          /**< lenght of a memory page */
/** bit mask to get the corresponding page start adress */
#define PAGE_START_MASK 0xFFC0  
/** bit mask to select the adress inside a memory page */
#define PAGE_MASK 0x003F        


/* returns non-zero if successful, else 0 */
uint8_t eeprom_read (uint16_t eeprom_offset, xdata uint8_t *buf, uint8_t len)
{
  /* We setup a random read by first doing a "zero byte write".
     Writes carry an address.  Reads use an implicit address. */

  static xdata uint8_t cmd[2];
  cmd[0] = eeprom_offset>>8;
  cmd[1] = eeprom_offset & 0xFF;
  if (!i2c_write(I2C_ADDR_BOOT, cmd, 2))
    return 0;

  return i2c_read(I2C_ADDR_BOOT, buf, len);
}


/* returns non-zero if successful, else 0 */
//uint8_t eeprom_write (idata uint8_t i2c_addr, idata uint16_t eeprom_offset,
//	      const xdata uint8_t *buf, uint8_t len)
uint8_t eeprom_write (uint16_t eeprom_offset, const xdata uint8_t *buf, \
		      uint8_t len)
{
  uint8_t i = 0, byte_count;
  static xdata uint8_t cmd[66];
  
  if(eeprom_offset > EEPROM_HIGH_ADDR){
    return 0;
  }
  //print_info("w\n");
  while (len > 0){
    
    if(eeprom_offset + len > (eeprom_offset & PAGE_START_MASK) + PAGE_LEN){
      byte_count = PAGE_LEN - (eeprom_offset & PAGE_MASK);
    }
    else if(len < PAGE_LEN){
      byte_count = len;
    }
    else {
      byte_count = PAGE_LEN;
    }
    
    cmd[0] = eeprom_offset>>8;
    cmd[1] = eeprom_offset & 0xFF;
    
    for(i=0; i < byte_count;i++) {
      cmd[i+2] = buf[i];
    }
    
    if (!i2c_write(I2C_ADDR_BOOT, cmd, byte_count+2))
      return 0;
    
    len -= byte_count;
    eeprom_offset += byte_count;
    mdelay(8);		/* delay 8ms worst case write time */
  }
  return 1;
}

