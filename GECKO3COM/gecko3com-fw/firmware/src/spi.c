/* -*- c++ -*- */
/*
 * Copyright 2004,2006 Free Software Foundation, Inc.
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
/** \file    spi.c
 *************************************************************
 *  \brief   SPI bus functions 
 *   
 *  \details Library to communicate with SPI devices
 *
 *  \author  GNU Radio guys
 */

#include "spi.h"
#include "debugprint.h"

#if 0
/*
static unsigned char
count_bits8 (unsigned char v)
{
  static unsigned char count4[16] = {
    0,	// 0
    1,	// 1
    1,	// 2
    2,	// 3
    1,	// 4
    2,	// 5
    2,	// 6
    3,	// 7
    1,	// 8
    2,	// 9
    2,	// a
    3,	// b
    2,	// c
    3,	// d
    3,	// e
    4	// f
  };
  return count4[v & 0xf] + count4[(v >> 4) & 0xf];
}
*/
#else

 /** \brief internal helper function to count the number of active (1) bits in a byte */
static unsigned char
count_bits8 (unsigned char v)
{
  unsigned char count = 0;
  if (v & (1 << 0)) count++;
  if (v & (1 << 1)) count++;
  if (v & (1 << 2)) count++;
  if (v & (1 << 3)) count++;
  if (v & (1 << 4)) count++;
  if (v & (1 << 5)) count++;
  if (v & (1 << 6)) count++;
  if (v & (1 << 7)) count++;
  return count;
}
#endif


static void
setup_enables (unsigned char enables)
{
  // Software eanbles are active high.
  // Hardware enables are active low.

  if(count_bits8(enables) > 1) {
    print_info("too many enables acitve\n");
    return;
  }
  else {
    enables &= bmSPI_CS_MASK;
    SPI_CS_PORT |= bmSPI_CS_MASK;   //disable all chipselect signals
    SPI_CS_PORT &= ~enables;
  }
}

/** \brief disables all devices on the SPI bus */
#define disable_all()	setup_enables (0)

void
init_spi (void)
{
  disable_all ();		/* disable all devs	  */
  bitSPI_MOSI = 0;		/* idle state has CLK = 0 */
}
static void
write_byte_msb (unsigned char v);

static void
write_bytes_msb (const xdata unsigned char *buf, unsigned char len);

static void
read_bytes_msb (xdata unsigned char *buf, unsigned char len);

  
// returns non-zero if successful, else 0
unsigned char
spi_read (unsigned char header_hi, unsigned char header_lo,
	  unsigned char enables, unsigned char format,
	  xdata unsigned char *buf, unsigned char len)
{
  if (count_bits8 (enables) > 1)
    return 0;		// error, too many enables set

  setup_enables (enables);
  /*
  if (format & bmSPI_FMT_LSB){		// order: LSB
#if 1
    return 0;		// error, not implemented
#else
    switch (format & bmSPI_HEADER){
    case SPI_HEADER_0:
      break;
    case bmSPI_HEADER_1:
      write_byte_lsb (header_lo);
      break;
    case bmSPI_HEADER_2:
      write_byte_lsb (header_lo);
      write_byte_lsb (header_hi);
      break;
    default:
      return 0;		// error
    }
    if (len != 0)
      read_bytes_lsb (buf, len);
#endif
  }

  else {		// order: MSB
  */
    switch (format & bmSPI_HEADER){
    case bmSPI_HEADER_0:
      break;
    case bmSPI_HEADER_1:
      write_byte_msb (header_lo);
      break;
    case bmSPI_HEADER_2:
      write_byte_msb (header_hi);
      write_byte_msb (header_lo);
      break;
    default:
      return 0;		// error
    }
    if (len != 0)
      read_bytes_msb (buf, len);
    //}

  disable_all ();
  return 1;		// success
}


// returns non-zero if successful, else 0
unsigned char
spi_write (unsigned char header_hi, unsigned char header_lo,
	   unsigned char enables, unsigned char format,
	   const xdata unsigned char *buf, unsigned char len)
{
  setup_enables (enables);

  /*  if (format & bmSPI_FORMAT_LSB){		// order: LSB
#if 1
    return 0;		// error, not implemented
#else
    switch (format & bmSPI_HEADER){
    case bmSPI_HEADER_0:
      break;
    case bmSPI_HEADER_1:
      write_byte_lsb (header_lo);
      break;
    case bmSPI_HEADER_2:
      write_byte_lsb (header_lo);
      write_byte_lsb (header_hi);
      break;
    default:
      return 0;		// error
    }
    if (len != 0)
      write_bytes_lsb (buf, len);
#endif
  }

  else {		// order: MSB
  */
    switch (format & bmSPI_HEADER){
    case bmSPI_HEADER_0:
      break;
    case bmSPI_HEADER_1:
      write_byte_msb (header_lo);
      break;
    case bmSPI_HEADER_2:
      write_byte_msb (header_hi);
      write_byte_msb (header_lo);
      break;
    default:
      return 0;		// error
    }
    if (len != 0)
      write_bytes_msb (buf, len);
    //}

  disable_all ();
  return 1;		// success
}

// ----------------------------------------------------------------

static void
write_byte_msb (unsigned char v)
{
  v = (v << 1) | (v >> 7);	// rotate left (MSB into bottom bit)
  bitSPI_MOSI = v & 0x1;
  bitSPI_CLK = 1;
  bitSPI_CLK = 0;

  v = (v << 1) | (v >> 7);	// rotate left (MSB into bottom bit)
  bitSPI_MOSI = v & 0x1;
  bitSPI_CLK = 1;
  bitSPI_CLK = 0;

  v = (v << 1) | (v >> 7);	// rotate left (MSB into bottom bit)
  bitSPI_MOSI = v & 0x1;
  bitSPI_CLK = 1;
  bitSPI_CLK = 0;

  v = (v << 1) | (v >> 7);	// rotate left (MSB into bottom bit)
  bitSPI_MOSI = v & 0x1;
  bitSPI_CLK = 1;
  bitSPI_CLK = 0;

  v = (v << 1) | (v >> 7);	// rotate left (MSB into bottom bit)
  bitSPI_MOSI = v & 0x1;
  bitSPI_CLK = 1;
  bitSPI_CLK = 0;

  v = (v << 1) | (v >> 7);	// rotate left (MSB into bottom bit)
  bitSPI_MOSI = v & 0x1;
  bitSPI_CLK = 1;
  bitSPI_CLK = 0;

  v = (v << 1) | (v >> 7);	// rotate left (MSB into bottom bit)
  bitSPI_MOSI = v & 0x1;
  bitSPI_CLK = 1;
  bitSPI_CLK = 0;

  v = (v << 1) | (v >> 7);	// rotate left (MSB into bottom bit)
  bitSPI_MOSI = v & 0x1;
  bitSPI_CLK = 1;
  bitSPI_CLK = 0;
}

static void
write_bytes_msb (const xdata unsigned char *buf, unsigned char len)
{
  while (len-- != 0){
    write_byte_msb (*buf++);
  }
}

#if 0
/*
 * This is incorrectly compiled by SDCC 2.4.0
 */
/*static unsigned char
read_byte_msb (void)
{
  unsigned char v = 0;

  bitSPI_CLK = 1;
  v |= bitSPI_MISO;
  bitSPI_CLK = 0;

  v = v << 1;
  bitSPI_CLK = 1;
  v |= bitSPI_MISO;
  bitSPI_CLK = 0;

  v = v << 1;
  bitSPI_CLK = 1;
  v |= bitSPI_MISO;
  bitSPI_CLK = 0;

  v = v << 1;
  bitSPI_CLK = 1;
  v |= bitSPI_MISO;
  bitSPI_CLK = 0;

  v = v << 1;
  bitSPI_CLK = 1;
  v |= bitSPI_MISO;
  bitSPI_CLK = 0;

  v = v << 1;
  bitSPI_CLK = 1;
  v |= bitSPI_MISO;
  bitSPI_CLK = 0;

  v = v << 1;
  bitSPI_CLK = 1;
  v |= bitSPI_MISO;
  bitSPI_CLK = 0;

  v = v << 1;
  bitSPI_CLK = 1;
  v |= bitSPI_MISO;
  bitSPI_CLK = 0;

  return v;
  } */
#else
static unsigned char
read_byte_msb (void) _naked
{
  _asm
	clr	a

	setb	_bitSPI_CLK
        mov	c, _bitSPI_MISO
	rlc	a
	clr	_bitSPI_CLK

	setb	_bitSPI_CLK
        mov	c, _bitSPI_MISO
	rlc	a
	clr	_bitSPI_CLK

	setb	_bitSPI_CLK
        mov	c, _bitSPI_MISO
	rlc	a
	clr	_bitSPI_CLK

	setb	_bitSPI_CLK
        mov	c, _bitSPI_MISO
	rlc	a
	clr	_bitSPI_CLK

	setb	_bitSPI_CLK
        mov	c, _bitSPI_MISO
	rlc	a
	clr	_bitSPI_CLK

	setb	_bitSPI_CLK
        mov	c, _bitSPI_MISO
	rlc	a
	clr	_bitSPI_CLK

	setb	_bitSPI_CLK
        mov	c, _bitSPI_MISO
	rlc	a
	clr	_bitSPI_CLK

	setb	_bitSPI_CLK
        mov	c, _bitSPI_MISO
	rlc	a
	clr	_bitSPI_CLK

	mov	dpl,a
	ret
  _endasm;
}
#endif

static void
read_bytes_msb (xdata unsigned char *buf, unsigned char len)
{
  while (len-- != 0){
    *buf++ = read_byte_msb ();
  }
}

