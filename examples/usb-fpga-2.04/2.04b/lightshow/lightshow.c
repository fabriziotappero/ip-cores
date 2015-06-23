/*!
   lightshow -- light show with LED's on the Debug board for ZTEX USB-FPGA Module 2.04b
   Copyright (C) 2009-2014 ZTEX GmbH.
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
#include[ztex-utils.h]	// include basic functions

// select ZTEX USB FPGA Module 2.04 as target (required for FPGA configuration)
IDENTITY_UFM_2_04(10.19.0.0,0);	 

// this product string is also used for identification by the host software
#define[PRODUCT_STRING]["lightshow example for UFM 2.04"]

ENABLE_FLASH;
ENABLE_FLASH_BITSTREAM;

// this is called automatically after FPGA configuration
#define[POST_FPGA_CONFIG][POST_FPGA_CONFIG
//    OEE = ~bmBIT6;
//    OEB = 0;
]

// include the main part of the firmware kit, define the descriptors, ...
#include[ztex.h]

void main(void)	
{
// init everything
    init_USB();

//    IOE = fpga_flash_result | bmBIT7;
    OEE = ~bmBIT6;
    OEB = 0;

    while (1) {	
	IOE = IOB | bmBIT7;
    }
}
