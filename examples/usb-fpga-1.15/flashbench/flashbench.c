/*!
   flashbench -- Flash memory benchmark for ZTEX USB-FPGA Module 1.15
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

// select ZTEX USB FPGA Module 1.15 as target  (required for FPGA configuration)
IDENTITY_UFM_1_15(10.13.0.0,0);	 

// this product string is also used for identification by the host software
#define[PRODUCT_STRING]["flashbench for UFM 1.15"]

// enable Flash support
ENABLE_FLASH;

// include the main part of the firmware kit, define the descriptors, ...
#include[ztex.h]

void main(void)	
{
    init_USB();		// init everything ...
    
    while (1) {	}	// ... and twiddle thumbs
}

