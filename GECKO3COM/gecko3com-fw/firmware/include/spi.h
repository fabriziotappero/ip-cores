/* -*- c++ -*- */
/*
 * Copyright 2004 Free Software Foundation, Inc.
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

/************************************************************/
/** \file    spi.h
 *************************************************************
 *  \brief SPI bus functions 
 *   
 *  \details Library to communicate with SPI devices
 *
 *  \author  GNU Radio team
 *
 *  \note to use this SPI library you have to define the following 
 *        keywords in your pinmapping header file. For GECKO3COM
 *        this is the "gecko3com_regs.h" file. \n
 *        \li SPI_PORT, SPI signals are connected to this port
 *        \li SPI_OE, SPI port direction register
 *        \li bmSPI_CLK, bitmask for  SPI serial clock pin
 *        \li bmSPI_MOSI, bitmask for SPI MOSI pin, Master Out, Slave In
 *        \li bmSPI_MISO, bitmask for SPI MISO pin, Master In, Slave Out
 *        \li bitSPI_CLK, bitadress of the SPI CLK pin
 *        \li bitSPI_MOSI, bitadress of the SPI MOSI pin
 *        \li bitSPI_MISO, bitadress of the SPI MISO pin
 *        \li SPI_CS_PORT, SPI chip select signals are connected to this port
 *        \li bmSPI_CS_FLASH, bitmask to enable the SPI Flash
 *        \li bmSPI_CS_MASK, bit mask to select the SPI chip select pins
 */

#ifndef INCLUDED_SPI_H
#define INCLUDED_SPI_H

#include "gecko3com_regs.h"


/*
 * SPI_FMT_* goes in wIndexL
 */
#define bmSPI_FORMAT	         0x80   /**< bitmask to work on the format */
#  define	bmSPI_FORMAT_LSB 0x80	/**< least signficant bit first */
#  define	bmSPI_FORMAT_MSB 0x00   /**< most significant bit first */
#define	bmSPI_HEADER      	 0x60   /**< bits to select the header bytes */
#  define	bmSPI_HEADER_0	 0x00	/**< 0 header bytes */
#  define	bmSPI_HEADER_1	 0x20	/**< 1 header byte */
#  define	bmSPI_HEADER_2	 0x40	/**< 2 header bytes */


/** one time call to init SPI subsystem */
void init_spi (void);		

/** \brief basic function to read data from the SPI bus
 * \param[in]  header_hi high byte of the header to send
 * \param[in]  header_lo low byte of the header to send
 * \param[in]  enables bitmask with the correct device selected
 * \param[in]  format bitmask byte to select byte order 
 *             and number of header bytes
 * \param[out] *buf pointer to a buffer to write the received data in it
 * \param[in]  len number of bytes to be read from bus
 *
 * \return returns non-zero if successful, else 0 */
unsigned char
spi_read (unsigned char header_hi, unsigned char header_lo,
	  unsigned char enables, unsigned char format,
	  xdata unsigned char *buf, unsigned char len);

/** \brief basic function to write data to the SPI bus
 * \param[in] header_hi high byte of the header to send
 * \param[in] header_lo low byte of the header to send
 * \param[in] enables bitmask with the correct device selected
 * \param[in] format bitmask byte to select byte order 
 *            and number of header bytes
 * \param[in] *buf pointer to a buffer which holds the data to send
 * \param[in] len number of bytes to be written to the bus
 *
 * \return returns non-zero if successful, else 0 */
unsigned char
spi_write (unsigned char header_hi, unsigned char header_lo,
	   unsigned char enables, unsigned char format,
	   const xdata unsigned char *buf, unsigned char len);


#endif /* INCLUDED_SPI_H */
