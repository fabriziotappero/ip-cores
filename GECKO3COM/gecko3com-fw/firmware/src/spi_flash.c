/* GECKO3COM
 *
 * Copyright (C) 2008 by
 *   ___    ___   _   _
 *  (  _`\ (  __)( ) ( )   
 *  | (_) )| (   | |_| |   Berne University of Applied Sciences
 *  |  _ <'|  _) |  _  |   School of Engineering and
 *  | (_) )| |   | | | |   Information Technology
 *  (____/'(_)   (_) (_)
 *
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details. 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
/************************************************************/
/** \file    spi_flash.c
 *************************************************************
 *  \author  Christoph Zimmermann
 *  \date    Date of creation: 17.09.2007
 *  \brief C code for the spi-flash Library 
 *
 *  \details Library to access the SPI Flash devices from ST 
 *	   Microelectronics (now Numonyx) or Spansion.
 *	   Supported densities:
 *	   8, 16, 32 Mbit
 *
 *   \date 17.09.2007 first version, based on the m25p16.h header file 
 *   \date 24. june 2009 code size optimization for the GECKO3COM firmware
 *
 */
#include "spi_flash.h"
#include "spi.h"
#include "debugprint.h"
#include "stdint.h"


SPI_flash xdata flash_dr;


 /** \brief Internal: Helper function to count the number of active (1) bits in a byte */
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


static void
setup_enables (unsigned char enables)
{
  // Software enables are active high.
  // Hardware enables are active low.

  if(count_bits8(enables) > 1) {
    //print_error("en\n");
    return;
  }
  else {
    bitSPI_CLK = 0; //make shure spi_clk is low before we activate a device
    SPI_OE |= bmSPI_OE_MASK;  //activate spi bus
    enables &= bmSPI_CS_MASK;
    SPI_CS_PORT |= bmSPI_CS_MASK;   //disable all chipselect signals
    SPI_CS_PORT &= ~enables;
    //SPI_CS_OE |= enables;
    SPI_CS_OE |= bmSPI_CS_MASK;
  }
}

  //    setup_enables (0); SPI_CS_PORT |= bmSPI_CS_MASK; \						\
/** disables all SPI devices and sets the SPI and SPI CS signals to tri-state */
/*#define disable_all()	{	 \
    setup_enables (0);           \
    SPI_CS_OE &= ~bmSPI_CS_MASK; \
    SPI_OE &= ~bmSPI_OE_MASK;    \
    }*/

#define disable_all()	{			\
    SPI_CS_PORT |= bmSPI_CS_MASK;		\
    SPI_CS_OE &= ~bmSPI_CS_MASK;		\
    SPI_OE &= ~bmSPI_OE_MASK;			\
  }


/** \brief Internal: Writes one byte to the SPI bus
 *
 * \param[in] data to write to the bus
 */
static void
write_byte_msb (unsigned char v);


/** \brief Internal: Writes a block of data to the SPI bus
 *
 * \param[in] pointer to a buffer to read the data from
 * \param[in] length of the data to read
 */
static void
write_bytes_msb (const xdata unsigned char *buf, unsigned char len);


/** \brief Internal: Reads a block of data from the SPI bus
 *
 * \param[in] pointer to a buffer to write the data to
 * \param[in] length of the data to read
 */
static void
read_bytes_msb (xdata unsigned char *buf, unsigned char len);


/** \brief Internal: Writes a block of data in reversed order to the SPI bus
 *
 * \param[in] pointer to a buffer to read the data from
 * \param[in] length of the data to read
 */
static void
write_bytes_msb_reversed (const xdata unsigned char *buf, unsigned char len);


/** \brief Checks if the SPI flash is busy */
int8_t spiflash_is_busy(xdata SPI_flash *flashPtr) {
  xdata uint8_t buffer[2];
  
  if(flashPtr->isBusy) {
    //ask flash if still busy;
    setup_enables(bmSPI_CS_FLASH);

    write_byte_msb(RDSR);
    read_bytes_msb(buffer, 2);

    disable_all();
        
    if((buffer[1] & 1) == 1) {
      return 1;
    }
    else {
      flashPtr->isBusy = 0;
    }
  }
  
  return 0;
}


/** \brief Initalizes the values in the SPI_flash struct after reading 
 *  the device ID */
int8_t init_spiflash(xdata SPI_flash *flashPtr) {

  uint8_t xdata flashID[3];
  uint8_t *idPtr = flashID;
  int8_t  xdata memsize;
  uint32_t xdata maxAdress;
  uint32_t xdata capacity;
  uint16_t xdata pages;
  uint8_t  xdata sectors;


  /* init SPI */
  disable_all ();		/* disable all devs	  */
  bitSPI_MOSI = 0;		/* idle state has CLK = 0 */

  ptrCheck(flashPtr);
  
  setup_enables(bmSPI_CS_FLASH);
  write_byte_msb(RDID);
  read_bytes_msb (flashID, 3);
  disable_all();

  if(*idPtr == MANUFACTURER_STM || *idPtr == MANUFACTURER_SPA) {
    idPtr++;
    if(*idPtr == MEMTYPE_STM) {
      memsize = 0;
    }
    else if(*idPtr == MEMTYPE_SPA) {
      memsize = 1;
    }
    else {
      return UNSUPPORTED_TYPE;
    }

    idPtr++;
    memsize += *idPtr;
    

    switch(memsize) {
      case MEMCAPACITY_32MBIT_STM :
	maxAdress = MAXADRESS_32MBIT;
	capacity = FLASH_SIZE_32MBIT;
	pages = FLASH_PAGE_COUNT_32MBIT;
	sectors = FLASH_SECTOR_COUNT_32MBIT;
	break;
      case MEMCAPACITY_16MBIT_STM :
	maxAdress = MAXADRESS_16MBIT;
	capacity = FLASH_SIZE_16MBIT;
	pages = FLASH_PAGE_COUNT_16MBIT;
	sectors = FLASH_SECTOR_COUNT_16MBIT;
	break;	
      case MEMCAPACITY_8MBIT_STM :
	maxAdress = MAXADRESS_8MBIT;
	capacity = FLASH_SIZE_8MBIT;
	pages = FLASH_PAGE_COUNT_8MBIT;
	sectors = FLASH_SECTOR_COUNT_8MBIT;
	break;
      default :
	return UNSUPPORTED_TYPE;					
    }

    flashPtr->maxAdress = maxAdress;
    flashPtr->capacity = capacity;
    flashPtr->pages = pages;
    flashPtr->sectors = sectors;
    
    return GOOD;
  }
  else {
    return UNSUPPORTED_TYPE;
    /* debug stuff: */
    //return *idPtr;
  }	
}


/** \brief Reads data from the SPI flash */
int8_t spiflash_read(xdata SPI_flash *flashPtr, xdata uint32_t *adress, xdata uint8_t *buffer, const uint16_t length) {
  
  //adrCheck(flashPtr, adress, length);

  while(spiflash_is_busy(flashPtr));

  //print_info("r\n");

  /* we do a bit dirty programming here:
   * the adress of the device is only 24bit long, so we misuse the upper 8bits 
   * to send the read command to the spi flash. 
   * this avoids more complicated constructs. */
  *adress &= 0x00FFFFFF; 
  *adress |= 0x03000000; //set the upper 8bit to the READ command

  /*printf_tiny("ad: %x,",((uint8_t*)adress)[2]);
  printf_tiny("%x,",((uint8_t*)adress)[1]);
  printf_tiny("%x\n",((uint8_t*)adress)[0]);
  */

  setup_enables(bmSPI_CS_FLASH);

  write_bytes_msb_reversed((uint8_t*)adress, 4);
  if (length != 0) {
    read_bytes_msb (buffer, length);
  }

  disable_all();

  return 1;
}

/** \brief deletes one sector (64 kbyte) of the SPI flash */
int8_t spiflash_erase(xdata SPI_flash *flashPtr, xdata uint32_t *adress) {
  while(spiflash_is_busy(flashPtr));

  setup_enables(bmSPI_CS_FLASH);
  write_byte_msb(WREN);
  disable_all();

  /* we do a bit dirty programming here:
   * the adress of the device is only 24bit long, so we misuse the upper 8bits 
   * to send the read command to the spi flash. 
   * this avoids more complicated constructs. */
  *adress &= 0x00FFFFFF; 
  *adress |= 0xD8000000; //set the upper 8bit to the SE (sector erase) command

  //print_info("e\n");  

  setup_enables(bmSPI_CS_FLASH);
  write_bytes_msb_reversed((uint8_t*)adress, 4);
  disable_all();

  flashPtr->isBusy = 1;

  return 1;  
}


/** \brief deletes the whole SPI flash */
int8_t spiflash_erase_bulk(xdata SPI_flash *flashPtr) {
  while(spiflash_is_busy(flashPtr));
  setup_enables(bmSPI_CS_FLASH);
  write_byte_msb(WREN);
  disable_all();

  setup_enables(bmSPI_CS_FLASH);
  write_byte_msb(BE);
  disable_all();
  
  flashPtr->isBusy = 1;

  return 1;
}


/** \brief Writes data to the SPI flash */
int8_t spiflash_write(xdata SPI_flash *flashPtr, xdata uint32_t *adress, \
		      xdata uint8_t *buffer, uint16_t length) {

  xdata uint16_t writeableBytes;
  
  while(length > 0) {

    while(spiflash_is_busy(flashPtr));
	
    setup_enables(bmSPI_CS_FLASH);
    write_byte_msb(WREN);
    disable_all();	
      
    writeableBytes = (uint16_t)(pageEnd(*adress)-*adress);
    writeableBytes ++;
    
    if(length > writeableBytes) {
      length -= writeableBytes;  
    }
    else {
      writeableBytes = length;
      length = 0;
    }

    //print_info("w\n");
    //printf_tiny("%d\n",writeableBytes);    

    /* we do a bit dirty programming here:
     * the adress of the device is only 24bit long, so we misuse the upper 8bits
     * to send the read command to the spi flash. 
     * this avoids more complicated constructs. */
    *adress &= 0x00FFFFFF; 
    *adress |= 0x02000000; //set the upper 8bit to the PP (page programm) command
    
    /*printf_tiny("ad: %x,",((uint8_t*)adress)[3]);
    printf_tiny("%x,",((uint8_t*)adress)[2]);
    printf_tiny("%x,",((uint8_t*)adress)[1]);
    printf_tiny("%x\n",((uint8_t*)adress)[0]);
    */
    setup_enables(bmSPI_CS_FLASH);
    write_bytes_msb_reversed((uint8_t*)adress, 4);  //send the adress
    
    /* the write_bytes_msb function can loop maximum 255 times, but a page is 256 long... */
    write_byte_msb(buffer[0]);
    buffer++;
    write_bytes_msb(buffer, writeableBytes-1);  //...thats why we split this to two writes
    disable_all();
    
    *adress += writeableBytes;
    buffer += writeableBytes;
    buffer--;      //adjust it because we incremented it once during the write

    flashPtr->isBusy = 1;
  }
  
  return 1;
}

/* ----------------------------------------------------------------
 * Internal functions 
 */
static void
write_byte_msb (unsigned char v)
{
  //printf_tiny("0x%x",v);
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
    //printf_tiny("0x%x, ",*buf);
    write_byte_msb (*buf++);
  }
}

static void
write_bytes_msb_reversed (const xdata unsigned char *buf, unsigned char len)
{
  while (len-- != 0){
    //printf_tiny("0x%x, ",buf[len]);
    write_byte_msb (buf[len]);
  }
}

/** \brief Internal: Reads one byte from the SPI bus
 *
 * \return data read from the bus
 */
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
