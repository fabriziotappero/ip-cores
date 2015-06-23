/*!
   debug -- debug helper example
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

// thin initializes the debug helper with a 32 messages stack and 4 bytes per message
ENABLE_DEBUG(32,3);

// this product string is also used for identification by the host software
#define[PRODUCT_STRING]["debug for EZ-USB devices"]

// include the main part of the firmware kit, define the descriptors, ...
#include[ztex.h]

void main(void)	
{
    WORD i;
    BYTE b;
    
// init everything
    init_USB();
    
    i=0;
    while (1) {	

	debug_msg_buf[0] = i;		// write second counter to the message buffer
	debug_msg_buf[1] = i >> 8;
	debug_add_msg();		// add the message to the stack
	i+=1;

	for (b=0; b<100; b++) {		// 100 x 10ms
	    debug_stack_ptr[2] = b;	// write the 10ms tick number to the current message in stack
	    wait(10);			// wait 10ms
	}
    }
}

