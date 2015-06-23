/*!
   lightshow -- lightshow on ZTEX USB-FPGA Module 1.2 plus Experimental Board 1.10
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
#include[ztex-utils.h]	// include basic functions

IDENTITY_UFM_1_2(10.11.0.0,0);	 
EXTENSION_EXP_1_10;

// this product string is also used for identification by the host software
#define[PRODUCT_STRING]["lightshow for EXP-1.10"]

// include the main part of the firmware kit, define the descriptors, ...
#include[ztex.h]

void main(void)	
{
// init everything
    init_USB();

    while ( 1 ) {
    }
}

