/* -*- c++ -*- */
/*
 * Copyright 2003 Free Software Foundation, Inc.
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
/** \file         i2c.h
 *************************************************************************
 *  \brief        read and write functions for the i2c bus 
 *  
 *  \author       GNU Radio
 *
 *  \warning      This functions are blocking functions, so you have to wait
 *                until the transfer is finished!
 */

#ifndef _I2C_H_
#define _I2C_H_

/**
 * i2c read function. reads a block of data with the length len
 *
 * \param[in] addr device adress on the i2c bus
 * \param[out] buf result buffer, contains the readed data when successful 
 * \param[in] len length of the block to read 
 * \return returns non-zero if successful, else 0
 */
unsigned char i2c_read (unsigned char addr, xdata unsigned char *buf, unsigned char len);

/**
 * i2c write function. writes a block of data with the length len
 *
 * \param[in] addr device adress on the i2c bus
 * \param[in] buf data buffer, contains the data to be written 
 * \param[in] len length of the block to write 
 * \return returns non-zero if successful, else 0
 */
unsigned char i2c_write (unsigned char addr, xdata const unsigned char *buf, unsigned char len);

#endif /* _I2C_H_ */
