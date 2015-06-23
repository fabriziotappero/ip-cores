/************************************************************************
**
**  Copyright (C) 2006  Jesper Hansen <jesper@redegg.net> 
**  Modified and extended with write supportfor use with the IGOR Lisp machine
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

/** \file mmc_if.c
	Simple MMC/SD-card functionality
*/


#include <avr/io.h>
#include <inttypes.h>
#include <stdio.h>
#include "mmc.h"
#include <device.h>

igordev_read_fn_t mmc_recv;
igordev_write_fn_t mmc_send;
igordev_init_fn_t mmcdevice_init;
igordev_flush_fn_t mmc_flush;

struct igordev igordev_mmc = {
	.init = mmcdevice_init,
	.read = mmc_recv,
	.write = mmc_send,
	.flush = mmc_flush,
	.read_status = 0,
	.write_status = 0,
	.priv = NULL
};

//LBA of the most recently read sector
int32_t buffered_lba = -1;

//Used to store the most recently read sector
uint8_t sectorbuffer[512];

//Initialize igordev
void mmcdevice_init()
{
	igordev_mmc.read_status = igordev_mmc.write_status = IDEV_STATUS_OK;
	igordev_mmc.id = (CAN_READ | CAN_WRITE | ADDR_READ | ADDR_WRITE |
	    (DEVTYPE_STORAGE << DEVTYPE_OFFSET));

	mmc_init();
}

/* Write data on the memory card. All transfers are done in sectors of 512 
 * bytes, so this function will first read the sector from the card, replace the
 * modified bytes, and write the sector back.
 */
uint8_t
mmc_send(uint64_t addr, uint8_t *data, uint8_t num)
{

	//LBA of the sector we want to read
	uint32_t lba = addr/SECTOR_SIZE;
	
	//Byte position within the sector
	uint16_t byte_addr = addr-SECTOR_SIZE*lba;
	
	//Read the sector that will be overwritten
	if (read_sector_to_buffer(lba) != 0) {
		//Write error
		igordev_mmc.write_status = IDEV_STATUS_ERROR;
		return 0;
	}

	uint64_t i;

	//Fill the sector with new data
	for (i = byte_addr; i < byte_addr + num && i < SECTOR_SIZE; i++) {
		sectorbuffer[i] = *data;
		data++;
	}

	//Write the modified sector back
	if (write_buffer_to_sector(lba) != 0) {
		//Read error
		igordev_mmc.write_status = IDEV_STATUS_ERROR;
		return 0;
	}
	
	//Repeat if data spans two sectors
	if (byte_addr + num > SECTOR_SIZE) {
		
		//Read the new sector
		if (read_sector_to_buffer(lba+1) != 0) {
			//Read error
			igordev_mmc.write_status = IDEV_STATUS_ERROR;
			return i - byte_addr;
		}
		
		//Store the remaining bytes
		uint8_t j;
		for (j = 0; j < byte_addr + num - SECTOR_SIZE; j++) {
			sectorbuffer[j] = *data;
			data++;
		}

		//Write the modified sector back
		if (write_buffer_to_sector(lba+1) != 0) {
			//Write error
			igordev_mmc.write_status = IDEV_STATUS_ERROR;
			return i - byte_addr;
		}
		
		igordev_mmc.write_status = IDEV_STATUS_OK;
		return j + i - addr;
	}
	
	igordev_mmc.write_status = IDEV_STATUS_OK;
	return (i - addr) ;
}

/* Read data from the memory card. All transfers are done in sectors of 512 
 * bytes, so this function will first read the sector from the card, extract
 * the requested bytes and write them to the given data buffer.
 */
uint8_t
mmc_recv(uint64_t addr, uint8_t *data, uint8_t num)
{

	//LBA of the sector we want to read
	uint32_t lba = addr/SECTOR_SIZE;
	
	//Byte position within the sector
	uint16_t byte_addr = addr-SECTOR_SIZE*lba;

	//Read the sector
	if (read_sector_to_buffer(lba) != 0) {
		//Read error
		igordev_mmc.read_status = IDEV_STATUS_ERROR;
		return 0;
	}

	uint64_t i;

	//Loop through the sector data and store only the bytes that we want
	//for (i = byte_addr; i < byte_addr + num && i < SECTOR_SIZE; i++) {
	//	*data++ = sectorbuffer[i];
	for (i = byte_addr; i < byte_addr + num && i < SECTOR_SIZE; i++) {
		*data = sectorbuffer[i];
		data++;
	}
	
	if (byte_addr + num > SECTOR_SIZE) {
		//We didn't get all of the data in the first go,
		//so we must continue reading on the next sector
		
		//Read the new sector
		if (read_sector_to_buffer(lba+1) != 0) {
			//Read error
			igordev_mmc.read_status = IDEV_STATUS_ERROR;
			return i - byte_addr;
		}
		
		//Store the remaining bytes
		uint8_t j;
		for (j = 0; j < byte_addr + num - SECTOR_SIZE; j++) {
			*data = sectorbuffer[j];
			data++;
		}
		
		igordev_mmc.read_status = IDEV_STATUS_OK;
		return j + i - addr;
	}
	
	igordev_mmc.read_status = IDEV_STATUS_OK;
	return (i - addr) ;
}

//Read a sector into the sector buffer
uint8_t read_sector_to_buffer(uint32_t lba)
{
	if (buffered_lba != lba) {
		if (mmc_readsector(lba, sectorbuffer) != 0) {
			//We have a read error

			//The buffered sector may be corrupted,
			//so we make sure it's invalidated
			buffered_lba = -1;

			return 1;

		} else { //Successful read
			buffered_lba = lba;
			return 0;
		}
	}
	return 0;
}

//Write the sector buffer into a sector
uint8_t write_buffer_to_sector(uint32_t lba)
{
	if (mmc_writesector(lba, sectorbuffer) != 0) {
		//We have a write error

		//Invalidate the buffered sector
		buffered_lba = -1;

		return 1;

	} else { //Successful write
		buffered_lba = lba;
		return 0;
	}
}

/** Hardware SPI I/O. 
	\param byte Data to send over SPI bus
	\return Received data from SPI bus
*/
uint8_t spi_byte(uint8_t byte)
{
	SPDR = byte;
	while(!(SPSR & (1<<SPIF)))
	{}
	return SPDR;
}



/** Send a command to the MMC/SD card.
	\param command	Command to send
	\param px	Command parameter 1
	\param py	Command parameter 2
*/
void mmc_send_command(uint8_t command, uint16_t px, uint16_t py)
{
	register union u16convert r;

	SPI_PORT &= ~(1 << MMC_CS);	// enable CS

	spi_byte(0xff);			// dummy byte

	spi_byte(command | 0x40);

	r.value = px;
	spi_byte(r.bytes.high);	// high byte of param x
	spi_byte(r.bytes.low);	// low byte of param x

	r.value = py;
	spi_byte(r.bytes.high);	// high byte of param y
	spi_byte(r.bytes.low);	// low byte of param y

	spi_byte(0x95);	// correct CRC for first command in SPI.
			// After that CRC is ignored, so no problem with
			// always sending 0x95

	spi_byte(0xff);	// ignore return byte
}


/** Get Token.
	Wait for and return a non-ff token from the MMC/SD card
	\return The received token or 0xFF if timeout
*/
uint8_t mmc_get(void)
{
	uint16_t i = 0xffff;
	uint8_t b = 0xff;

	while ((b == 0xff) && (--i)) 
	{
		b = spi_byte(0xff);
	}
	return b;

}

/** Get Datatoken.
	Wait for and return a data token from the MMC/SD card
	\return The received token or 0xFF if timeout
*/
uint8_t mmc_datatoken(void)
{
	uint16_t i = 0xffff;
	uint8_t b = 0xff;

	while ((b != 0xfe) && (--i)) 
	{
		b = spi_byte(0xff);
	}
	return b;
}


/** Finish Clocking and Release card.
	Send 10 clocks to the MMC/SD card
	and release the CS line 
*/
void mmc_clock_and_release(void)
{
	uint8_t i;

	// SD cards require at least 8 final clocks
	for(i=0;i<10;i++)
		spi_byte(0xff);	

	SPI_PORT |= (1 << MMC_CS);	// release CS
}



/** Read MMC/SD sector.
	 Read a single 512 byte sector from the MMC/SD card
	\param lba	Logical sectornumber to read
	\param buffer	Pointer to buffer for received data
	\return 0 on success, -1 on error
*/
int mmc_readsector(uint32_t lba, uint8_t *buffer)
{
	uint16_t i;

	// send read command and logical sector address
	mmc_send_command(17,(lba>>7) & 0xffff, (lba<<9) & 0xffff);

	if (mmc_datatoken() != 0xfe)		// if no valid token
	{
		mmc_clock_and_release();	// cleanup and	
		return -1;			// return error code
	}

	for (i=0;i<512;i++)			// read sector data
		*buffer++ = spi_byte(0xff);

	spi_byte(0xff);				// ignore dummy checksum
	spi_byte(0xff);				// ignore dummy checksum

	mmc_clock_and_release();		// cleanup

	return 0;				// return success
}

//Write MMC/SD sector
int mmc_writesector(uint32_t lba, uint8_t *buffer)
{
	uint16_t i;

	// send write command and logical sector address
	mmc_send_command(24,(lba>>7) & 0xffff, (lba<<9) & 0xffff);

	spi_byte(0xfe);				//Send data token

	for (i=0;i<512;i++)			//Send sector data
		spi_byte(*buffer++);

	spi_byte(0xff);				//Send dummy 16-bit checksum
	spi_byte(0xff);

	if ((mmc_get() & 0x0f) != 0x05) {	//Receive response token
		mmc_clock_and_release();
		return -1;			//Write error
	}

	while (spi_byte(0xff) == 0x00) {
		//Wait for the card to finish writing, this can take
		//a very long time, i.e. several hundred milliseconds
	}

	mmc_clock_and_release();		//Cleanup

	return 0;				//Return success
}




/** Init MMC/SD card.
	Initialize I/O ports for the MMC/SD interface and 
	send init commands to the MMC/SD card
	\return 0 on success, other values on error 
*/
uint8_t mmc_init(void)
{
//Run configure_spi() to setup the SPI port before initializing MMC.
	
	int i;

	for(i=0;i<10;i++)	// send 8 clocks while card power stabilizes
		spi_byte(0xff);

	mmc_send_command(0,0,0);	// send CMD0 - reset card

	if (mmc_get() != 1)			// if no valid response code
	{
		mmc_clock_and_release();
		return 1;  			// card cannot be detected
	}

	//
	// send CMD1 until we get a 0 back, indicating card is done initializing 
	//
	i = 0xffff;				// max timeout
	while ((spi_byte(0xff) != 0) && (--i))	// wait for it
	{
		mmc_send_command(1,0,0);	// send CMD1 - activate card init
	}

	mmc_clock_and_release();		// clean up

	if (i == 0)				// if we timed out above
		return 2;			// return failure code

	return 0;
}

void
mmc_flush(void) {}
