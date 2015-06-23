//-----------------------------------------------------------------
//                       USB Device Core
//                           V0.1
//                     Ultra-Embedded.com
//                       Copyright 2014
//
//               Email: admin@ultra-embedded.com
//
//                       License: LGPL
//-----------------------------------------------------------------
//
// Copyright (C) 2013 - 2014 Ultra-Embedded.com
//
// This source file may be used and distributed without         
// restriction provided that this copyright statement is not    
// removed from the file and that any derivative work contains  
// the original copyright notice and the associated disclaimer. 
//
// This source file is free software; you can redistribute it   
// and/or modify it under the terms of the GNU Lesser General   
// Public License as published by the Free Software Foundation; 
// either version 2.1 of the License, or (at your option) any   
// later version.
//
// This source is distributed in the hope that it will be       
// useful, but WITHOUT ANY WARRANTY; without even the implied   
// warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR      
// PURPOSE.  See the GNU Lesser General Public License for more 
// details.
//
// You should have received a copy of the GNU Lesser General    
// Public License along with this source; if not, write to the 
// Free Software Foundation, Inc., 59 Temple Place, Suite 330, 
// Boston, MA  02111-1307  USA
//-----------------------------------------------------------------
#include <stdio.h>
#include "usb_uart.h"
#include "usb_cdc.h"
#include "usb_hw.h"
#include "timer.h"

//-----------------------------------------------------------------
// CDC serial demo
//-----------------------------------------------------------------
int main(void)
{
    // Force detach
    usbhw_attach(0);
    timer_sleep(100);

    // USB init
    usb_init(0, cdc_process_request);
    usb_uart_init();

    usbhw_attach(1);

    while (1)
    {
        usbhw_service();

        // Loopback
        if (usb_uart_haschar())
            usb_uart_putchar(usb_uart_getchar());
    }

    return 0;
}
