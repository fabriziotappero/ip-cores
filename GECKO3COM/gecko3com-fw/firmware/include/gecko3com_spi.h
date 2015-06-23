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
/** \file     gecko3com_spi.h
 *********************************************************************
 * \brief     definitions for the SPI flash file handling 
 *            (length of file slots etc.)
 *
 * \author    Christoph Zimmermann bfh.ch
 *
*/

#ifndef INCLUDED_GECKO3COM_SPI_H
#define INCLUDED_GECKO3COM_SPI_H

#include "spi_flash.h"

#define start_adress_slot0(flash_drv) 0x00 /**< Start adress of the first fpga configuration file in the spi flash */
#define start_adress_slot1(flash_drv) flash_drv.capacity >> 1 /**< Start adress of the second fpga configuration file in the spi flash */



#endif /* INCLUDED_GECKO3COM_SPI_H */
