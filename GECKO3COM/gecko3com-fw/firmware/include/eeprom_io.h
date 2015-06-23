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
/** \file         eeprom_io.h
 *************************************************************************
 *  \brief        read and write functions for i2c eeproms
 *  
 *  \author       GNU Radio
 *
 *  \date         2009-01-05  zac1 write function now uses pagewrite
 */

#ifndef INCLUDED_EEPROM_IO_H
#define INCLUDED_EEPROM_IO_H

/**
 * eeprom read function. reads a block of data with the length len starting from the adress eeprom_offset
 *
 * \param[in] eeprom_offset memory startadress to start reading from
 * \param[out] buf result buffer, contains the readed data when successful 
 * \param[in] len length of the block to read 
 * \return returns non-zero if successful, else 0
 */
uint8_t eeprom_read (uint16_t eeprom_offset, xdata uint8_t *buf, uint8_t len);

/**
 * eeprom write function. writes a block of data with the length len starting from the adress eeprom_offset
 *
 * \param[in] eeprom_offset memory startadress to start reading from
 * \param[in] buf data buffer, contains the data to be written 
 * \param[in] len length of the block to write 
 * \return returns non-zero if successful, else 0
 */
//uint8_t eeprom_write (idata uint8_t i2c_addr, idata uint16_t eeprom_offset,
//	      const xdata uint8_t *buf, uint8_t len);
uint8_t eeprom_write (uint16_t eeprom_offset, const xdata uint8_t *buf, \
		      uint8_t len);

#endif /* INCLUDED_EEPROM_IO_H */
