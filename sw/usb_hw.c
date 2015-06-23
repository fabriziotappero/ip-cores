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
#include "usb_hw.h"
#include "usb_log.h"
#include "hardware.h"

//-----------------------------------------------------------------
// Defines:
//-----------------------------------------------------------------
#define USB_FUNC_CTRL       (*((volatile unsigned int*) (USB_FUNC_BASE + 0x00)))
    #define USB_FUNC_CTRL_ADDR_SET     (1 << 8)
    #define USB_FUNC_CTRL_ADDR_MASK    (0x7F)
    #define USB_FUNC_CTRL_ADDR_SHIFT    0
    #define USB_FUNC_CTRL_INT_EN_TX    (1 << 9)
    #define USB_FUNC_CTRL_INT_EN_RX    (1 << 10)
    #define USB_FUNC_CTRL_INT_EN_SOF   (1 << 11)
    #define USB_FUNC_CTRL_PULLUP_EN    (1 << 12)
#define USB_FUNC_STAT       (*((volatile unsigned int*) (USB_FUNC_BASE + 0x00)))
    #define USB_STAT_BUS_RST         (1 << 18)
    #define USB_LINESTATE_RXN        (1 << 17)
    #define USB_LINESTATE_RXP        (1 << 16)
    #define USB_FUNC_FRAME_COUNT       0x07FF

#define USB_FUNC_EP(x)      (*((volatile unsigned int*) (USB_FUNC_BASE + 0x04 + (4 * x))))
#define USB_FUNC_EP0        (*((volatile unsigned int*) (USB_FUNC_BASE + 0x04)))
#define USB_FUNC_EP1        (*((volatile unsigned int*) (USB_FUNC_BASE + 0x08)))
#define USB_FUNC_EP2        (*((volatile unsigned int*) (USB_FUNC_BASE + 0x0C)))
#define USB_FUNC_EP3        (*((volatile unsigned int*) (USB_FUNC_BASE + 0x10)))
    #define USB_EP_TX_READY         (1 << 16)
    #define USB_EP_COUNT_MASK       0xFFFF
    #define USB_EP_RX_AVAIL         (1 << 17)
    #define USB_EP_RX_SETUP         (1 << 18)
    #define USB_EP_RX_ACK           (1 << 18)
    #define USB_EP_RX_CRC_ERR       (1 << 19)
    #define USB_EP_STALL            (1 << 20)
    #define USB_EP_TX_FLUSH         (1 << 21)

#define USB_FUNC_EP_DATA(x)      (*((volatile unsigned int*) (USB_FUNC_BASE + 0x20 + (4 * x))))
#define USB_FUNC_EP0_DATA        (*((volatile unsigned int*) (USB_FUNC_BASE + 0x20)))
#define USB_FUNC_EP1_DATA        (*((volatile unsigned int*) (USB_FUNC_BASE + 0x24)))
#define USB_FUNC_EP2_DATA        (*((volatile unsigned int*) (USB_FUNC_BASE + 0x28)))
#define USB_FUNC_EP3_DATA        (*((volatile unsigned int*) (USB_FUNC_BASE + 0x2C)))

#define USB_FUNC_ENDPOINTS      4

#define MIN(a,b)                ((a)<=(b)?(a):(b))

//-----------------------------------------------------------------
// Locals:
//-----------------------------------------------------------------
static unsigned int _tx_count[USB_FUNC_ENDPOINTS];
static int _configured;
static int _attached;
static int _endpoint_stalled[USB_FUNC_ENDPOINTS];
static FUNC_PTR _func_bus_reset;
static FUNC_PTR _func_setup;
static FUNC_PTR _func_ctrl_out;
static unsigned int _pullup_enable;
static unsigned int _ctrl_reg;

//-----------------------------------------------------------------
// usbhw_init:
//-----------------------------------------------------------------
void usbhw_init(FUNC_PTR bus_reset, FUNC_PTR on_setup, FUNC_PTR on_out)
{
    int i;

    for (i=0;i<USB_FUNC_ENDPOINTS;i++)
    {
        _tx_count[i] = 0;
        _endpoint_stalled[i] = 0;
    }
    
    _configured = 0;
    _attached = 0;

    _ctrl_reg = 0;

    _func_bus_reset = bus_reset;
    _func_setup = on_setup;
    _func_ctrl_out = on_out;

    USB_FUNC_EP0 = USB_EP_RX_ACK | USB_EP_TX_FLUSH;
    USB_FUNC_EP1 = USB_EP_RX_ACK | USB_EP_TX_FLUSH;
    USB_FUNC_EP2 = USB_EP_RX_ACK | USB_EP_TX_FLUSH;
    USB_FUNC_EP3 = USB_EP_RX_ACK | USB_EP_TX_FLUSH;
}
//-----------------------------------------------------------------
// usbhw_service:
//-----------------------------------------------------------------
void usbhw_service(void)
{
    unsigned int status;

    // Bus reset event
    if (USB_FUNC_STAT & USB_STAT_BUS_RST)
    {
        // Ack bus reset by writing to CTRL register
        USB_FUNC_CTRL = _ctrl_reg;

        _configured = 0;

        log_printf(USBLOG_HW_RESET, " DEVICE: BUS RESET\n");

        if (_func_bus_reset)
            _func_bus_reset();
    }

    status = USB_FUNC_EP0;

    // SETUP packet received (EP0)
	if (status & USB_EP_RX_SETUP)
	{
        log_printf(USBLOG_HW_CTRL, "USB: SETUP packet received\n");

        if (_func_setup)
            _func_setup();

        log_printf(USBLOG_HW_CTRL, "USB: SETUP packet processed\n");
	}
    // OUT data received on EP0
	else if (status & USB_EP_RX_AVAIL)
	{
        log_printf(USBLOG_HW_CTRL, "USB: OUT packet received on EP0\n");

        if (_func_ctrl_out)
            _func_ctrl_out();
	}
}
//-----------------------------------------------------------------
// usbhw_attach:
//-----------------------------------------------------------------
void usbhw_attach(int state)
{
    // Pull up D+ to Vdd
	if ( state )
	{
        log_printf(USBLOG_HW_CTRL, " DEVICE: ATTACH\n");
		_attached = 1;
        _ctrl_reg |= USB_FUNC_CTRL_PULLUP_EN;
        USB_FUNC_CTRL = _ctrl_reg;
	}
    // Disconnect pull-up to disconnect from bus
	else
	{
        log_printf(USBLOG_HW_CTRL, " DEVICE: DETACH\n");
		_attached = 0;
        _ctrl_reg &= ~USB_FUNC_CTRL_PULLUP_EN;
        USB_FUNC_CTRL = _ctrl_reg;
	}
}
//-----------------------------------------------------------------
// usbhw_is_configured:
//-----------------------------------------------------------------
int usbhw_is_configured(void)
{
    return _configured;
}
//-----------------------------------------------------------------
// usbhw_is_attached:
//-----------------------------------------------------------------
int usbhw_is_attached(void)
{
    return _attached;
}
//-----------------------------------------------------------------
// usbhw_set_configured:
//-----------------------------------------------------------------
void usbhw_set_configured(int configured)
{
    _configured = configured;
}
//-----------------------------------------------------------------
// usbhw_set_address:
//-----------------------------------------------------------------
void usbhw_set_address(unsigned char addr)
{
    USB_FUNC_CTRL = (_attached ? USB_FUNC_CTRL_PULLUP_EN : 0) | 
                    USB_FUNC_CTRL_ADDR_SET | ((addr & USB_FUNC_CTRL_ADDR_MASK) >> USB_FUNC_CTRL_ADDR_SHIFT);
}
//-----------------------------------------------------------------
// usbhw_is_endpoint_stalled:
//-----------------------------------------------------------------
int usbhw_is_endpoint_stalled(unsigned char endpoint)
{
	return _endpoint_stalled[endpoint];
}
//-----------------------------------------------------------------
// usbhw_clear_endpoint_stall:
//-----------------------------------------------------------------
void usbhw_clear_endpoint_stall(unsigned char endpoint)
{
    _endpoint_stalled[endpoint] = 0;
    USB_FUNC_EP(endpoint) = 0;
}
//-----------------------------------------------------------------
// usbhw_set_endpoint_stall:
//-----------------------------------------------------------------
void usbhw_set_endpoint_stall(unsigned char endpoint)
{
    _endpoint_stalled[endpoint] = 1;
    USB_FUNC_EP(endpoint) = USB_EP_STALL;
}
//-----------------------------------------------------------------
// usbhw_is_rx_ready: Is some receive data ready on an endpoint?
//-----------------------------------------------------------------
int usbhw_is_rx_ready(unsigned char endpoint)
{
    return (USB_FUNC_EP(endpoint) & USB_EP_RX_AVAIL) ? 1 : 0;
}
//-----------------------------------------------------------------
// usbhw_get_rx_count: Get amount of data waiting in endpoint
//-----------------------------------------------------------------
int usbhw_get_rx_count(unsigned char bEndp)
{
    int count = USB_FUNC_EP(bEndp) & USB_EP_COUNT_MASK;

    // Received data count includes CRC
    if (count >= 2)
        return count - 2;
    else
        return 0;
}
//-----------------------------------------------------------------
// usbhw_get_rx_data: Read data from endpoint & clear full flag
//-----------------------------------------------------------------
int usbhw_get_rx_data(unsigned char endpoint, unsigned char *data, int max_len)
{
    int i;
	int bytes_ready;
	int bytes_read = 0;

    // Received data count includes CRC
    bytes_ready = USB_FUNC_EP(endpoint) & USB_EP_COUNT_MASK;
    if (bytes_ready >= 2)
        bytes_ready -= 2;

    // Limit data read to buffer size
	bytes_read = MIN(bytes_ready, max_len);

	for (i=0;i<bytes_read;i++)
	{
		*data++ = (unsigned char) USB_FUNC_EP_DATA(endpoint);
    }

    // Allow more data to be received
	usbhw_clear_rx_ready( endpoint );

    // Return number of bytes read
	return bytes_read;
}
//-----------------------------------------------------------------
// usbhw_get_rx_byte: Read byte from endpoint
//-----------------------------------------------------------------
unsigned char usbhw_get_rx_byte(unsigned char endpoint)
{
	return (unsigned char)USB_FUNC_EP_DATA(endpoint);
}
//-----------------------------------------------------------------
// usbhw_clear_rx_ready: Clear Rx data ready flag
//-----------------------------------------------------------------
void usbhw_clear_rx_ready(unsigned char endpoint)
{
    log_printf(USBLOG_HW_DATA, "USB: Clear endpoint buffer (Rx %d)\n", USB_FUNC_EP(endpoint) & USB_EP_COUNT_MASK);
    USB_FUNC_EP(endpoint) = USB_EP_RX_ACK;
}
//-----------------------------------------------------------------
// usbhw_has_tx_space: Is there space in the tx buffer
//-----------------------------------------------------------------
int usbhw_has_tx_space(unsigned char endpoint)
{
    return (USB_FUNC_EP(endpoint) & USB_EP_TX_READY) ? 0 : 1;
}
//-----------------------------------------------------------------
// usbhw_load_tx_buffer: Load tx buffer & start transfer (non-blocking) 
//-----------------------------------------------------------------
int usbhw_load_tx_buffer(unsigned char endpoint, unsigned char *data, int count)
{
	int i;

	for (i=0;i<count;i++)
		USB_FUNC_EP_DATA(endpoint) = *data++;

    // Start transmit
    USB_FUNC_EP(endpoint) = USB_EP_TX_READY | count;

    log_printf(USBLOG_HW_DATA, " USB: Tx %d\n", count);

	return count;
}
//-----------------------------------------------------------------
// usbhw_write_tx_byte: Write a byte to Tx buffer (don't send yet)
//-----------------------------------------------------------------
void usbhw_write_tx_byte(unsigned char endpoint, unsigned char data)
{
    // If FIFO should be empty
    if (_tx_count[endpoint] == 0 &&
        !(USB_FUNC_EP(endpoint) & USB_EP_TX_READY))
    {
        // (Shouldn't need this) Flush Tx FIFO
        USB_FUNC_EP(endpoint) = USB_EP_TX_FLUSH;
    }

    USB_FUNC_EP_DATA(endpoint) = (unsigned int) data;
    _tx_count[endpoint]++;
}
//-----------------------------------------------------------------
// usbhw_start_tx: Start a tx packet with data loaded into endpoint
//-----------------------------------------------------------------
void usbhw_start_tx(unsigned char endpoint)
{
    // Initiate TX
    USB_FUNC_EP(endpoint) = USB_EP_TX_READY | _tx_count[endpoint];
    log_printf(USBLOG_HW_DATA, " USB: Tx %d\n", _tx_count[endpoint]);

	_tx_count[endpoint] = 0;
}
//-----------------------------------------------------------------
// usbhw_control_endpoint_stall:
//-----------------------------------------------------------------
void usbhw_control_endpoint_stall(void)
{
    log_printf(USBLOG_HW_CTRL, " DEVICE: Error, send EP stall!\n");
    USB_FUNC_EP0 = USB_EP_STALL;
}
//-----------------------------------------------------------------
// usbhw_control_endpoint_ack:
//-----------------------------------------------------------------
void usbhw_control_endpoint_ack(void)
{
	USB_FUNC_EP0 = USB_EP_TX_READY;
    log_printf(USBLOG_HW_DATA, " USB: Tx [ZLP/ACK]\n");

    while (!usbhw_has_tx_space(0))
        ;
}
//-----------------------------------------------------------------
// usbhw_get_frame_number:
//-----------------------------------------------------------------
unsigned short usbhw_get_frame_number(void)
{
    return (unsigned short)(USB_FUNC_STAT & USB_FUNC_FRAME_COUNT);
}
