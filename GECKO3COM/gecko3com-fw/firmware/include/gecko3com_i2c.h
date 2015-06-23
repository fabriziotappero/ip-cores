/* GECKO3COM
 *
 * Copyright (C) 2008 by
 *   ___    ____  _   _
 *  (  _`\ (  __)( ) ( )   
 *  | (_) )| (_  | |_| |   Berne University of Applied Sciences
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

/*********************************************************************/
/** \file     gecko3com_i2c.h
 *********************************************************************
 * \brief     adresses of the I2C devices
 *
 * \author    GNUradio, Christoph Zimmermann bfh.ch
 *
*/

#ifndef INCLUDED_GECKO3COM_I2C_H
#define INCLUDED_GECKO3COM_I2C_H


#define I2C_DEV_EEPROM	0x50		/**< base adress of a I2C EEPROM:  7-bits 1010xxx */

#define	I2C_ADDR_BOOT	(I2C_DEV_EEPROM	| 0x1)  /**< adress of the Boot EEPROM */

#define I2C_DEV_IO      0x41            /**< base adress of a I2C IO expander: 7-bits 1000001 */

/** 
 * offsets into boot eeprom for configuration values
 */
/** ASCII string with the fpga type as it is in the bit file */
#define FPGA_TYPE_OFFSET        0x3FDD 
#define FPGA_TYPE_LEN           16  /**< length of the FPGA type string */

/** the JTAG chip IDCODE is a 32 bit integer stored as 0x11223344 */
#define FPGA_IDCODE_OFFSET      0x3FED 
#define FPGA_IDCODE_LEN         10  /**< length of the IDCODE string */

/** the hardware revision of this board, one char */
#define	HW_REV_OFFSET		0x3FF7  
#define SERIAL_NO_OFFSET	0x3FF8 /**< place to store the serial number */
#define SERIAL_NO_LEN		8   /**< length of the serial number string */

#endif /* INCLUDED_GECKO3COM_I2C_H */

