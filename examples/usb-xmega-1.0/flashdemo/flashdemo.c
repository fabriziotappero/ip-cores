/*!
   flashdemo -- demo for Flash memory access from firmware and host software for ZTEX USB-XMEGA Module 1.0
   Copyright (C) 2009-2011 ZTEX GmbH.
   http://www.ztex.de

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License version 3 as
   published by the Free Software Foundation.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, see http://www.gnu.org/licenses/.
!*/

#include[ztex-conf.h]	// Loads the configuration macros, see ztex-conf.h for the available macros
#include[ztex-utils.h]	// include basic functions and variables

// select ZTEX USB-XMEGA Module 1.0 as target
IDENTITY_UXM_1_0(10.30.0.0,0);	 

// enable Flash support
ENABLE_FLASH;

// this product string is also used for identification by the host software
#define[PRODUCT_STRING]["Flash demo for UXM 1.0"]

__code char flash_string[] = "Hello World!";

// include the main part of the firmware kit, define the descriptors, ...
#include[ztex.h]

void main(void)	
{
    __xdata DWORD sector;

    init_USB();						// init everything

    if ( flash_enabled ) {
	flash_read_init( 0 ); 				// prepare reading sector 0
	flash_read((__xdata BYTE*) &sector, 4); 	// read the number of last sector 
	flash_read_finish(flash_sector_size - 4);	// dummy-read the rest of the sector + finish read operation

	sector++;
	if ( sector > flash_sectors || sector == 0 ) {
	    sector = 1;
	}

	flash_write_init( 0 ); 					// prepare writing sector 0
	flash_write((__xdata BYTE*) &sector, 4); 		// write the current sector number
	flash_write_finish_sector(flash_sector_size - 4);	// dummy-write the rest of the sector + CRC
	flash_write_finish();					// finish write operation

	flash_write_init( sector ); 						// prepare writing sector sector
	flash_write((__xdata BYTE*) flash_string, sizeof(flash_string)); 	// write the string 
	flash_write_finish_sector(flash_sector_size - sizeof(flash_string));	// dummy-write the rest of the sector + CRC
	flash_write_finish();							// finish write operation
    }

    while (1) {	}					//  twiddle thumbs
}

