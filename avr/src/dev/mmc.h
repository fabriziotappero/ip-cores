/************************************************************************
**
**  Copyright (C) 2006  Jesper Hansen <jesper@redegg.net> 
**  Modified for use with the IGOR Lisp machine
**
**  Interface functions for MMC/SD cards
**
**  File mmc_if.h
**
*************************************************************************
**
**  This program is free software; you can redistribute it and/or
**  modify it under the terms of the GNU General Public License
**  as published by the Free Software Foundation; either version 2
**  of the License, or (at your option) any later version.
**
**  This program is distributed in the hope that it will be useful,
**  but WITHOUT ANY WARRANTY; without even the implied warranty of
**  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
**  GNU General Public License for more details.
**
**  You should have received a copy of the GNU General Public License
**  along with this program; if not, write to the Free Software Foundation, 
**  Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
**
*************************************************************************/

/** \file mmc_if.h
    Simple MMC/SD-card functionality
*/

#ifndef __MMC_H__
#define __MMC_H__
#include "spi.h"

//The size of sectors read from SD/MMC
#define SECTOR_SIZE 512

/** @name MMC/SD Card I/O lines in SPI mode
*/
//@{
#define MMC_SCK		SPI_SCK
#define MMC_MOSI	SPI_MOSI
#define MMC_MISO	SPI_MISO
#define MMC_CS		SPI_SS_MMC
//@}



/** Helper structure.
    This simplify conversion between bytes and words.
*/
struct u16bytes
{
    uint8_t low;	//!< byte member
	uint8_t high;	//!< byte member
};

/** Helper union.
    This simplify conversion between bytes and words.
*/
union u16convert
{
    uint16_t value;			//!< for word access
	struct u16bytes bytes;	//!< for byte access
};

/** Helper structure.
    This simplify conversion between bytes and longs.
*/
struct u32bytes
{
    uint8_t byte1;	//!< byte member
	uint8_t byte2;	//!< byte member
	uint8_t byte3;	//!< byte member
	uint8_t byte4;	//!< byte member
};

/** Helper structure.
    This simplify conversion between words and longs.
*/
struct u32words
{
    uint16_t low;		//!< word member
	uint16_t high;		//!< word member
};

/** Helper union.
    This simplify conversion between bytes, words and longs.
*/
union u32convert 
{
    uint32_t value;			//!< for long access
	struct u32words words;	//!< for word access
	struct u32bytes bytes;	//!< for byte access
};

//Read a sector into the sector buffer
uint8_t read_sector_to_buffer(uint32_t lba);

//Write the sector buffer into a sector
uint8_t write_buffer_to_sector(uint32_t lba);


/** Read MMC/SD sector.
     Read a single 512 byte sector from the MMC/SD card
    \param lba	Logical sectornumber to read
    \param buffer	Pointer to buffer for received data
    \return 0 on success, -1 on error
*/
int mmc_readsector(uint32_t lba, uint8_t *buffer);

//Write MMC/SD sector
int mmc_writesector(uint32_t lba, uint8_t *buffer);

/** Init MMC/SD card.
    Initialize I/O ports for the MMC/SD interface and 
    send init commands to the MMC/SD card
    \return 0 on success, other values on error 
*/
uint8_t mmc_init(void);

#endif

