/*!
   ucecho -- uppercase conversion example for all EZ-USB devices
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

// define endpoints 2 and 4, both belong to interface 0 (in/out are from the point of view of the host)
EP_CONFIG(2,0,BULK,IN,512,2);	 
EP_CONFIG(4,0,BULK,OUT,512,2);	 

// this product string is also used for identification by the host software
#define[PRODUCT_STRING]["ucecho for EZ-USB devices"]

// include the main part of the firmware kit, define the descriptors, ...
#include[ztex.h]

void main(void)	
{
    WORD i,size;
    BYTE b;
    
// init everything
    init_USB();

    EP2CS &= ~bmBIT0;	// stall = 0
    SYNCDELAY; 
    EP4CS &= ~bmBIT0;	// stall = 0

    SYNCDELAY;		// first two packages are waste
    EP4BCL = 0x80;	// skip package, (re)arm EP4
    SYNCDELAY;
    EP4BCL = 0x80;	// skip package, (re)arm EP4

    while (1) {	
	if ( !(EP4CS & bmBIT2) ) {				// EP4 is not empty
	    size = (EP4BCH << 8) | EP4BCL;
	    if ( size>0 && size<=512 && !(EP2CS & bmBIT3)) {	// EP2 is not full
		for ( i=0; i<size; i++ ) {
		    b = EP4FIFOBUF[i];		// data from EP4 ... 
		    if ( b>=(BYTE)'a' && b<=(BYTE)'z' )	// ... is converted to uppercase ...
			b-=32;
		    EP2FIFOBUF[i] = b;		// ... and written back to EP2 buffer
		} 
		EP2BCH = size >> 8;
		SYNCDELAY; 
		EP2BCL = size & 255;		// arm EP2
	    }
	    SYNCDELAY; 
	    EP4BCL = 0x80;			// skip package, (re)arm EP4
	}
    }
}

