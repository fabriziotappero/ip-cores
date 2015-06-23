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
#include <string.h>
#include "usb_hw.h"
#include "usb_cdc.h"
#include "usb_device.h"
#include "usb_uart.h"
#include "usb_log.h"
#include "timer.h"

//-----------------------------------------------------------------
// Defines:
//-----------------------------------------------------------------
#define USB_UART_TX_TIMEOUT             100

//-----------------------------------------------------------------
// Locals:
//-----------------------------------------------------------------
static int _tx_count;
static int _rx_count;

//-----------------------------------------------------------------
// usb_uart_init:
//-----------------------------------------------------------------
void usb_uart_init(void)
{
    _tx_count = 0;
    _rx_count = 0;

    cdc_init();
}
//-----------------------------------------------------------------
// usb_uart_haschar:
//-----------------------------------------------------------------
int usb_uart_haschar(void)
{
    if (_rx_count == 0)
    {
        if (usbhw_is_rx_ready(CDC_ENDPOINT_BULK_OUT))
        {
            _rx_count = usbhw_get_rx_count(CDC_ENDPOINT_BULK_OUT);

            // ZLP received? Clear rx status
            if (_rx_count == 0)
                usbhw_clear_rx_ready(CDC_ENDPOINT_BULK_OUT);
        }
    }
    return (_rx_count != 0);
}
//-----------------------------------------------------------------
// usb_uart_getchar:
//-----------------------------------------------------------------
int usb_uart_getchar(void)
{
    int data = -1;

    // Some data is ready?
    if (usb_uart_haschar())
    {
        // Get a byte
        data = (int)usbhw_get_rx_byte(CDC_ENDPOINT_BULK_OUT);
        _rx_count--;

        // All data received, clear rx status
        if (_rx_count == 0) 
            usbhw_clear_rx_ready(CDC_ENDPOINT_BULK_OUT);
    }

    return  data;
}
//-----------------------------------------------------------------
// usb_uart_getblock:
//-----------------------------------------------------------------
int usb_uart_getblock(unsigned char *data, int max_length)
{
    int count;

    // Block until some data is ready
    while (!usb_uart_haschar())
        ;

    // Limit to buffer size or amount ready
    if (_rx_count > max_length)
        count = max_length;
    else
        count = _rx_count;

    usbhw_get_rx_data(CDC_ENDPOINT_BULK_OUT, data, count);
    _rx_count -= count;

    // All data received, clear rx status
    if (_rx_count == 0) 
        usbhw_clear_rx_ready(CDC_ENDPOINT_BULK_OUT);

    return count;
}
//-----------------------------------------------------------------
// usb_uart_putchar:
//-----------------------------------------------------------------
int usb_uart_putchar(char data)
{
    if (data == '\n')
        usb_uart_putchar('\r');

    // Wait until space available (or timeout)
    t_time tS = timer_now();
    while (!usbhw_has_tx_space(CDC_ENDPOINT_BULK_IN))
    {
        if (timer_diff(timer_now(), tS) > USB_UART_TX_TIMEOUT)
            return 0;
    }

    // Load byte into tx buffer
    usbhw_write_tx_byte(CDC_ENDPOINT_BULK_IN, data);
    _tx_count++;

    // Flush on buffer full or end of line
    if ( _tx_count >= EP2_MAX_PACKET_SIZE || data == '\n') 
        usb_uart_flush();

    return (int)data;
}
//-----------------------------------------------------------------
// usb_uart_flush:
//-----------------------------------------------------------------
void usb_uart_flush(void)
{
    // If some data present in output buffer
    if (_tx_count)
    {
        // Enable tx to start on next IN transfer
        usbhw_start_tx(CDC_ENDPOINT_BULK_IN);

        // If multiple of endpoint size, send ZLP
        if ( _tx_count == EP2_MAX_PACKET_SIZE )
        {
            t_time tS = timer_now();

            // Wait for TX ready and then send ZLP
            while (!usbhw_has_tx_space(CDC_ENDPOINT_BULK_IN))
            {
                if (timer_diff(timer_now(), tS) > USB_UART_TX_TIMEOUT)
                {
                    log_printf(USBLOG_ERR, "UART: Flush timeout\n");
                    return ;
                }
            }

            usbhw_load_tx_buffer(CDC_ENDPOINT_BULK_IN, 0, 0);
        }

        _tx_count = 0;
    }
}
