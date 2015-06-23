/* $Id: eeprom.c 395 2011-07-17 22:02:55Z mueller $ */
/*-----------------------------------------------------------------------------
 * FTDI EEPROM emulation
 *-----------------------------------------------------------------------------
 * Copyright (C) 2007 Kolja Waschk, ixo.de
 *-----------------------------------------------------------------------------
 * This code is part of usbjtag. usbjtag is free software; you can redistribute
 * it and/or modify it under the terms of the GNU General Public License as
 * published by the Free Software Foundation; either version 2 of the License,
 * or (at your option) any later version. usbjtag is distributed in the hope
 * that it will be useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.  You should have received a
 * copy of the GNU General Public License along with this program in the file
 * COPYING; if not, write to the Free Software Foundation, Inc., 51 Franklin
 * St, Fifth Floor, Boston, MA  02110-1301  USA
 *-----------------------------------------------------------------------------
 */

#include "eeprom.h"
#include "usb_descriptors.h"

xdata unsigned char eeprom[128];

extern xdata char dscr_vidpidver[6];
extern xdata char dscr_attrpow[2];
extern xdata char dscr_usbver[2];
extern xdata char dscr_strorder[4];
extern xdata char str1[];
extern xdata char str2[];
extern xdata char str3[];

static unsigned char ee_ptr;
static unsigned short ee_cksum;

void eeprom_append(unsigned char nb)
{
  unsigned char pree_ptr = ee_ptr & ~1;
  if(pree_ptr != ee_ptr)
  {
    ee_cksum = ee_cksum ^((unsigned short)nb << 8);
    ee_cksum = ee_cksum ^ eeprom[pree_ptr];
    ee_cksum = (ee_cksum << 1) | (ee_cksum >> 15);
  };
  eeprom[ee_ptr++] = nb;
}

void eeprom_init(void)
{
  char j,sofs;
  ee_ptr = 0;
  ee_cksum = 0xAAAA;

  eeprom_append(0x00);
  eeprom_append(0x00);
  for(j=0;j<6;j++) eeprom_append(dscr_vidpidver[j]);
  for(j=0;j<2;j++) eeprom_append(dscr_attrpow[j]);
  eeprom_append(0x1C);
  eeprom_append(0x00);
  for(j=0;j<2;j++) eeprom_append(dscr_usbver[j]);
  sofs = 0x80 + ee_ptr + 6;
  eeprom_append(sofs);
  eeprom_append(str1[0]);
  sofs += str1[0];
  eeprom_append(sofs);
  eeprom_append(str2[0]);
  sofs += str2[0];
  eeprom_append(sofs);
  eeprom_append(str3[0]);
  for(j=0;j<str1[0];j++) eeprom_append(str1[j]);
  for(j=0;j<str2[0];j++) eeprom_append(str2[j]);
  for(j=0;j<str3[0];j++) eeprom_append(str3[j]);
  for(j=0;j<4;j++) eeprom_append(dscr_strorder[j]);
  while(ee_ptr < 126) eeprom_append(0);
  eeprom[126] = ee_cksum&0xFF;
  eeprom[127] = (ee_cksum>>8)&0xFF;
}

