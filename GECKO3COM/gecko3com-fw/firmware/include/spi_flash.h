/***********************************************************
 *  Gecko3 SoC HW/SW Development Board
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
/** \file    spi_flash.h
 *************************************************************
 *  \author  Christoph Zimmermann
 *  \date    Date of creation: 17.09.2007
 *  \brief   Headerfile for the spi-flash Library 
 *   
 *  \details Library to access the SPI Flash devices from ST 
 *	     Microelectronics (now Numonyx) or Spansion.
 *	     Supported densities:
 *	     8, 16, 32 Mbit
 *
 *  \note to use this SPI/SPI Flash library you have to define the following 
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
 *
 *   \date 17.09.2007 first version
 *
 */

#ifndef _SPI_FLASH_H_ /* prevent circular inclusions */
#define _SPI_FLASH_H_

#include <stdint.h>
//#include "spi.h"

/**************************** Type Definitions *******************************/

/** 
 * \brief This typedef contains configuration information for the device.
 */
typedef struct
{
  uint32_t maxAdress;		/**< highest available adress */
  uint32_t capacity;		/**< memory capacity in bytes */
  uint16_t pages;		/**< number of available pages */
  uint8_t  sectors;	        /**< number of available sectors */ 
  uint8_t isBusy;		/**< acivity indicator */
} SPI_flash;


#define FLASH_WRITE_BUFFER_SIZE 0x100   /**< Write Buffer = 256 bytes */

#define SPIFLASH_SECTOR_LENGTH 0x10000 /**< Length of one sector in the flash, needed for erasing */
#define SECTORS_PER_SLOT 16 /**< Number of sectors used for each configuration file slot */

#define MANUFACTURER_STM 0x20		/**< id of ST microelectronics */
#define MEMTYPE_STM 0x20		/**< Memory type of M25PXX */
#define MEMCAPACITY_8MBIT_STM 0x14	/**< 8 MBit memory capacity */
#define MEMCAPACITY_16MBIT_STM 0x15	/**< 16 MBit memory capacity */
#define MEMCAPACITY_32MBIT_STM 0x16	/**< 32 MBit memory capacity */

#define MANUFACTURER_SPA 0x01		/**< id of SPANSION */
#define MEMTYPE_SPA 0x02		/**< Memory type of S25FLXX */
#define MEMCAPACITY_8MBIT_SPA 0x13	/**< 8 MBit memory capacity */
#define MEMCAPACITY_16MBIT_SPA 0x14	/**< 16 MBit memory capacity */
#define MEMCAPACITY_32MBIT_SPA 0x15	/**< 32 MBit memory capacity */


#define MAXADRESS_8MBIT 0x0FFFFF             /**< 8 Mbit device highest usable Adress */
#define FLASH_SIZE_8MBIT (0x0100000)         /**< Total 8 Mbit device size in Bytes */
#define FLASH_PAGE_COUNT_8MBIT (0x01000)     /**< Total 8 Mbit device size in Pages */
#define FLASH_SECTOR_COUNT_8MBIT (0x10)      /**< Total 8 Mbit device size in Sectors */

#define MAXADRESS_16MBIT 0x1FFFFF            /**< 16 Mbit device highest usable Adress */
#define FLASH_SIZE_16MBIT (0x0200000)        /**< Total 16 Mbit device size in Bytes */
#define FLASH_PAGE_COUNT_16MBIT (0x02000)    /**< Total 16 Mbit device size in Pages */
#define FLASH_SECTOR_COUNT_16MBIT (0x20)     /**< Total 16 Mbit device size in Sectors */

#define MAXADRESS_32MBIT 0x3FFFFF               /**< 32 Mbit device highest usable Adress */
#define FLASH_SIZE_32MBIT (0x0400000)           /**< Total 32 Mbit device size in Bytes */
#define FLASH_PAGE_COUNT_32MBIT (0x04000)       /**< Total 32 Mbit device size in Pages */
#define FLASH_SECTOR_COUNT_32MBIT (0x40)        /**< Total 32 Mbit device size in Sectors */

  /* Return Codes */
#define GOOD	0                 /**< anything ok */
#define BAD		1         /**< error */
#define NOINSTANCE	99        /**< no device found */
#define UNSUPPORTED_TYPE	5 /**< a device was found but it is not supported */
#define OVERFLOW	10        /**< an overflow occoured */


  /* flash memory opcodes */
#define WREN 0x06         /**< Flash Opcode: Write Enable */
#define WRDI 0x04         /**< Flash Opcode: Write Disable */
#define RDID 0x9F         /**< Flash Opcode: Read Identification */
#define RDSR 0x05         /**< Flash Opcode: Read Status Register */
#define WRSR 0x01         /**< Flash Opcode: Write Status Register */
#define READ 0x03         /**< Flash Opcode: Read Data bytes */
#define FAST_READ 0x0B    /**< Flash Opcode: Read Data bytes at higher speed */
#define PP 0x02           /**< Flash Opcode: Page Programm */
#define SE 0xD8           /**< Flash Opcode: Sector Erase */
#define BE 0xC7           /**< Flash Opcode: Bulk Erase */
#define DP 0xB9           /**< Flash Opcode: Deep Power-down */
#define RES 0xAB          /**< Flash Opcode: Release from Deep Power-down */


/***************** Macros (Inline Functions) Definitions *********************/

/** \brief check if it is a sane pointer
 *  \param[in] ptr pointer to a SPI_flash struct 
 */
#define ptrCheck(ptr)            \
    {                            \
        if (ptr == 0)      	 \
        {                        \
            return NOINSTANCE;   \
        }                        \
    }


/** \brief check if a overflow would occour with the given parameters 
 *
 * \param[in] flashPtr pointer to a initialized SPI_flash struct
 * \param[in] adr adress somewhere in the flash
 * \param[in] byteCount number of bytes to process
 * \exception breaks the operations and returns the OVERFLOW error code
 */
#define adrCheck(flashPtr, adr, byteCount)            		\
    {                            				\
        if (adr + byteCount >= flashPtr->maxAdress)  	        \
        {                        				\
            return OVERFLOW;   					\
        }                        				\
    }



/** returns the start adress of the sector that belongs to this adress
 * \param[in] adr adress somewhere in the flash 
 */
#define sectorStart(adr) ((adr) & 0xFFFF0000)


/** returns the end adress of the sector that belongs to this adress
 * \param[in] adr adress somewhere in the flash 
 */
#define sectorEnd(adr) ((adr) | 0x0000FFFF)	


/** returns the start adress of the page that belongs to this adress
 * \param[in] adr adress somewhere in the flash 
 */
#define pageStart(adr) ((adr) & 0xFFFFFF00)


/** returns the end adress of the page that belongs to this adress
 * \param[in] adr adress somewhere in the flash
 */
#define pageEnd(adr) ((adr) | 0x000000FF)	 

/** This struct contains all the needed information about the detected flash
 *  chip (limits, memory structure,...) to work with it. 
 *  Is filled during init */
extern SPI_flash xdata flash_dr;

/************************** Function Prototypes ******************************/

/** \brief Checks if the SPI flash is busy
 *
 * \param[in] flashPtr pointer to an SPI_flash struct
 * \return    returns non-zero if SPI flash is busy, else 0
 */
int8_t spiflash_is_busy(xdata SPI_flash *flashPtr);


/** \brief Initalizes the values in the SPI_flash struct after reading 
 *  the device ID
 *
 * \param[in] flashPtr pointer to an uninitialized SPI_flash struct
 * \return returns GOOD (0) or an Error Code (non-zero)
 */
int8_t init_spiflash(xdata SPI_flash *flashPtr);


/** \brief Reads data from the SPI flash
 *
 * \param[in]  flashPtr pointer to an SPI_flash struct
 * \param[in]  *adress pointer to the flash start adress to read from
 * \param[out] *buffer pointer to a buffer to write the data into
 * \param[in]  length length of the data to read
 * \return     returns non-zero if successful, else 0
 */
int8_t spiflash_read(xdata SPI_flash *flashPtr, xdata uint32_t *adress, \
		     xdata uint8_t *buffer, const idata uint16_t length);


/** \brief deletes the whole SPI flash
 *
 * \param[in] *flashPtr pointer to an SPI_flash struct
 * \return    returns non-zero if successful, else 0
 */
int8_t spiflash_erase_bulk(xdata SPI_flash *flashPtr);


/** \brief deletes one sector (64 kbyte) of the SPI flash
 *
 * \param[in] *flashPtr flashPtr pointer to an SPI_flash struct
 * \param[in] *adress pointer to the flash adress in the sector to be erased
 * \return    returns non-zero if successful, else 0
 */
int8_t spiflash_erase(xdata SPI_flash *flashPtr, xdata uint32_t *adress);


/** \brief Writes data to the SPI flash
 *
 * This write function handles if you write data over the page adress
 * boundary. It splits it into seperate page program commands.
 * \note Don't forget to erase a sector before you try to write to it!
 *
 * \param[in] *flashPtr pointer to an SPI_flash struct
 * \param[in] *adress pointer to the flash start adress to 
 *            write to
 * \param[out] *buffer pointer to a buffer to write the data into
 * \param[in] length of the data to read
 * \return    returns non-zero if successful, else 0
 */
int8_t spiflash_write(xdata SPI_flash *flashPtr, xdata uint32_t *adress, xdata uint8_t *buffer, uint16_t length);


#endif /* _SPI_FLASH_H_ */
