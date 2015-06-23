/* cable_xpc_dlc9.c - Xilinx Platform Cable (DLC9) driver for the Advanced JTAG Bridge
   Copyright (C) 2008 - 2010 Nathan Yawn, nathan.yawn@opencores.org
   Copyright (C) 2008 Kolja Waschk (UrJTAG project)

   CPLD mode for burst transfers added by:
	   Copyright (C) 2011 Raul Fajardo, rfajardo@opencores.org
   adapted from xc3sprog/ioxpc.cpp:
	   Copyright (C) 2009-2011 Uwe Bonnes bon@elektron.ikp.physik.tu-darmstadt.de

This program is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 2 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program; if not, write to the Free Software
Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA. */


#include <stdio.h>
#include <sys/types.h>
#include <stdlib.h>  // for sleep()
#include <errno.h>
#include <string.h>

#include "usb.h"  // libusb header

#include "cable_xpc_dlc9.h"
#include "utilities.h"
#include "errcodes.h"

/*
 * The dynamic switch between FX2 and CPLD modes works fine. If a switch is required, the functions:
 * 		static int cable_xpcusb_fx2_init();
 * 		static int cable_xpcusb_cpld_init();
 * can be called. The variable cpld_ctrl can tell if the CPLD is active (1) or FX2 (0).
 *
 * The functions accessing the cable in this driver always check the cpld_ctrl variable and adapt the
 * cable mode accordingly.
 *
 * Therefore, we can arbitrarily define bit and stream functionality from different modes without
 * concern. Out_func and inout_func are not provided under CPLD mode because it always complete
 * a bit transfer by toggling the clock twice 0-1-0 providing a write and a read.
 *
 * When using stream functionality of the CPLD, and bit functionality of FX2, also cable_common_read_write_bit
 * works. The cable_xpcusb_read_write_bit is not necessary then. However, it is still necessary when using:
 * 			cable_common_write_stream
 * 			cable_common_read_stream
 */

#define debug(...) //fprintf(stderr, __VA_ARGS__ )

//#define CLASSIC
#define CPLDBITFUNC

#ifdef CLASSIC
jtag_cable_t dlc9_cable_driver = {
    .name ="xpc_usb" ,
    .inout_func = cable_xpcusb_inout,
    .out_func = cable_xpcusb_out,
    .init_func = cable_xpcusb_init,
    .opt_func = cable_xpcusb_opt,
    .bit_out_func = cable_common_write_bit,
    .bit_inout_func = cable_xpcusb_read_write_bit,
    .stream_out_func = cable_common_write_stream,
    .stream_inout_func = cable_common_read_stream,
    .flush_func = NULL,
    .opts = "",
    .help = "no options\n",
   };
#else
jtag_cable_t dlc9_cable_driver = {
    .name ="xpc_usb" ,
    .inout_func = cable_xpcusb_inout,
    .out_func = cable_xpcusb_out,
    .init_func = cable_xpcusb_init,
    .opt_func = cable_xpcusb_opt,
#ifdef CPLDBITFUNC
    .bit_out_func = cable_xpcusb_cpld_write_bit,
    .bit_inout_func = cable_xpcusb_cpld_readwrite_bit,
#else
    .bit_out_func = cable_common_write_bit,
    .bit_inout_func = cable_common_read_write_bit,
#endif
    .stream_out_func = cable_xpcusb_write_stream,
    .stream_inout_func = cable_xpcusb_readwrite_stream,
    .flush_func = NULL,
    .opts = "",
    .help = "no options\n",
   };
#endif

#define USB_TIMEOUT 500

// USB constants for the DLC9
#define XPCUSB_VID  0x3fd
#define XPCUSB_PID  0x08

// Bit meanings in the command byte sent to the DLC9
// DLC9 has no TRST bit
#define XPCUSB_CMD_TDI 0x01
#define XPCUSB_CMD_TDO 0x01
#define XPCUSB_CMD_TMS 0x02
#define XPCUSB_CMD_TCK 0x04
#define XPCUSB_CMD_PROG 0x08

/*
 * send max 4096 bytes to CPLD
 * this is equal to 8192 TDI plus 8192 TDO bits
 */
#define CPLD_MAX_BYTES (1<<12)

/*
 * Buffer has to hold 8192 bits for write, each 2 bytes hold 4 bits for write, so this has to be 4096
 * Buffer has to hold 8192 bits for read, each byte holds 8 bits for read, so this has to be 1024
 * Therefore, buffer size -> CPLD_MAX_BYTES
 */
typedef struct
{
  int in_bits;
  int out_bits;
  uint8_t buf[CPLD_MAX_BYTES];
}  xpc_ext_transfer_state_t;


static struct usb_device *device = NULL;
static usb_dev_handle *h_device = NULL;
static int cpld_ctrl = 0;

static const uint32_t endianess_test = 1;
#define is_bigendian() ( (*(uint8_t*)&endianess_test) == 0 )

static int cable_xpcusb_open_cable(void);
static void cable_xpcusb_close_cable(void);
static int cable_xpcusb_fx2_init();
static int cable_xpcusb_cpld_init();




///////////////////////////////////////////////////////////////////////////////
/*----- Functions for the Xilinx Platform Cable USB (Model DLC9)            */
/////////////////////////////////////////////////////////////////////////////

static int xpcu_request_28(struct usb_dev_handle *xpcu, int value)
{
    /* Typical values seen during autodetection of chain configuration: 0x11, 0x12 */

    if(usb_control_msg(xpcu, 0x40, 0xB0, 0x0028, value, NULL, 0, 1000)<0)
    {
        perror("usb_control_msg(0x28.x)");
        return -1;
    }

    return 0;
}

static int xpcu_select_gpio(struct usb_dev_handle *xpcu, int chain)
{
  if(usb_control_msg(xpcu, 0x40, 0xB0, 0x0052, chain, NULL, 0, USB_TIMEOUT)<0)
    {
      fprintf(stderr, "Error sending usb_control_msg(0x52.x) (select gpio)\n");
      return APP_ERR_USB;
    }

  return APP_ERR_NONE;
}

static int xpcu_write_gpio(struct usb_dev_handle *xpcu, uint8_t bits)
{
    if(usb_control_msg(xpcu, 0x40, 0xB0, 0x0030, bits, NULL, 0, 1000)<0)
    {
        perror("usb_control_msg(0x30.0x00) (write port E)");
        return -1;
    }

    return 0;
}


static int xpcu_read_cpld_version(struct usb_dev_handle *xpcu, uint16_t *buf)
{
    if(usb_control_msg(xpcu, 0xC0, 0xB0, 0x0050, 0x0001, (char*)buf, 2, 1000)<0)
    {
        perror("usb_control_msg(0x50.1) (read_cpld_version)");
        return -1;
    }
    return 0;
}


static int xpcu_read_firmware_version(struct usb_dev_handle *xpcu, uint16_t *buf)
{
    if(usb_control_msg(xpcu, 0xC0, 0xB0, 0x0050, 0x0000, (char*)buf, 2, 1000)<0)
    {
        perror("usb_control_msg(0x50.0) (read_firmware_version)");
        return -1;
    }

    return 0;
}

static int xpcu_output_enable(struct usb_dev_handle *xpcu, int enable)
{
    if(usb_control_msg(xpcu, 0x40, 0xB0, enable ? 0x18 : 0x10, 0, NULL, 0, 1000)<0)
    {
        perror("usb_control_msg(0x10/0x18)");
        return -1;
    }

    return 0;
}

/*
 *   === A6 transfer (TDI/TMS/TCK/RDO) ===
 *
 *   Vendor request 0xA6 initiates a quite universal shift operation. The data
 *   is passed directly to the CPLD as 16-bit words.
 *
 *   The argument N in the request specifies the number of state changes/bits.
 *
 *   State changes are described by the following bulk write. It consists
 *   of ceil(N/4) little-endian 16-bit words, each describing up to 4 changes.
 *   (see xpcusb_add_bit_for_ext_transfer)
 *
 *   After the bulk write, if any of the bits 12..15 was set in any word
 *   (see xpcusb_add_bit_for_ext_transfer), a bulk_read shall follow to collect
 *   the TDO data.
 */
static int xpcu_shift(struct usb_dev_handle *xpcu, int reqno, int bits, int in_len, uint8_t *in, int out_len, uint8_t *out )
{
    if(usb_control_msg(xpcu, 0x40, 0xB0, reqno, bits, NULL, 0, 1000)<0)
    {
        perror("usb_control_msg(x.x) (shift)");
        return -1;
    }

#if VERBOSE
	{
	int i;
    printf("\n###\n");
    printf("reqno = %02X\n", reqno);
    printf("bits    = %d\n", bits);
    printf("in_len  = %d, in_len*2  = %d\n", in_len, in_len * 2);
    printf("out_len = %d, out_len*8 = %d\n", out_len, out_len * 8);

    printf("a6_display(\"%02X\", \"", bits);
    for(i=0;i<in_len;i++) printf("%02X%s", in[i], (i+1<in_len)?",":"");
    printf("\", ");
	}
#endif

    if(usb_bulk_write(xpcu, 0x02, (char*)in, in_len, 1000)<0)
    {
        fprintf(stderr, "\nusb_bulk_write error(shift): %s\n", strerror(errno));
        fprintf(stderr, "Burst length: %d\n", in_len);
        return -1;
    }

    if(out_len > 0 && out != NULL)
    {
      if(usb_bulk_read(xpcu, 0x86, (char*)out, out_len, 1000)<0)
      {
        printf("\nusb_bulk_read error(shift): %s\n", strerror(errno));
        return -1;
      }
    }

#if VERBOSE
	{
	int i;
    printf("\"");
    for(i=0;i<out_len;i++) printf("%02X%s", out[i], (i+1<out_len)?",":"");
    printf("\")\n");
	}
#endif
 
    return 0;
}

/*
 *   Bit 0: Value for first TDI to shift out.
 *   Bit 1: Second TDI.
 *   Bit 2: Third TDI.
 *   Bit 3: Fourth TDI.
 *
 *   Bit 4: Value for first TMS to shift out.
 *   Bit 5: Second TMS.
 *   Bit 6: Third TMS.
 *   Bit 7: Fourth TMS.
 *
 *   Bit 8: Whether to raise/lower TCK for first bit.
 *   Bit 9: Same for second bit.
 *   Bit 10: Third bit.
 *   Bit 11: Fourth bit.
 *
 *   Bit 12: Whether to read TDO for first bit
 *   Bit 13: Same for second bit.
 *   Bit 14: Third bit.
 *   Bit 15: Fourth bit.
 *   */
static void xpcusb_add_bit_for_ext_transfer(xpc_ext_transfer_state_t *xts, uint8_t toggle_tclk, uint8_t tms, uint8_t tdi, uint8_t sample_tdo)
{
	int bit_idx = (xts->in_bits & 3);
	int buf_idx = (xts->in_bits - bit_idx) >> 1;

	debug("add_bit, in = %i, bit_idx = %i, buf_idx = %i\n", tdi, bit_idx, buf_idx);

	if(bit_idx == 0)
	{
		xts->buf[buf_idx] = 0;
		xts->buf[buf_idx+1] = 0;
	}

	xts->in_bits++;

	if(tdi) xts->buf[buf_idx] |= (0x01<<bit_idx);

	if(tms) xts->buf[buf_idx] |= (0x10<<bit_idx);

	if ( toggle_tclk )	xts->buf[buf_idx+1] |= (0x01<<bit_idx);

	if(sample_tdo)
	{
		xts->buf[buf_idx+1] |= (0x10<<bit_idx);
		xts->out_bits++;
	}
}

/*
 *   TDO data is shifted in from MSB to LSB and transferred 32-bit little-endian.
 *   In a "full" word with 32 TDO bits, the earliest one reached bit 0.
 *   The earliest of 31 bits however would be bit 1. A 17 bit transfer has the LSB
 *   as the MSB of uint16_t[0], other bits are in uint16_t[1].
 *
 *   However, if the last packet is smaller than 16, only 2 bytes are transferred.
 *   If there's only one TDO bit, it arrives as the MSB of the 16-bit word, uint16_t[0].
 *   uint16_t[1] is then skipped.
 *
 *   For full 32 bits blocks, the data is aligned. The last non 32-bits block arrives
 *   non-aligned and has to be re-aligned. Half-words (16-bits) transfers have to be
 *   re-aligned too.
 */
static int xpcusb_do_ext_transfer(xpc_ext_transfer_state_t *xts, uint32_t * tdostream)
{
    int i, r;
    int in_len, out_len;
    int shift, bit_num, bit_val;
    uint32_t aligned_32bitwords, aligned_bytes;
    uint32_t out_done;

    //cpld expects data (tdi) to be in 16 bit words
    in_len = 2 * (xts->in_bits >> 2);
    if ((xts->in_bits & 3) != 0) in_len += 2;

    //cpld returns the read data (tdo) in 32 bit words
    out_len = 2 * (xts->out_bits >> 4);
    if ((xts->out_bits & 15) != 0) out_len += 2;

    r = xpcu_shift (h_device, 0xA6, xts->in_bits, in_len, xts->buf, out_len, xts->buf);

    if(r >= 0 && xts->out_bits > 0 && tdostream != NULL)
    {
        aligned_32bitwords = xts->out_bits/32;
        aligned_bytes = aligned_32bitwords*4;
        if ( is_bigendian() )								//these data is aligned as little-endian
        {
        	for (i=0; i<aligned_bytes; i++)
        	{
        		if ( i%4 == 0 )
        			tdostream[i/4] = 0;
        		tdostream[i/4] |= xts->buf[i] << (i%4)*8;
        	}
        }
        else
        	memcpy(tdostream, xts->buf, aligned_bytes);		//these data is already little-endian

        out_done = aligned_bytes*8;

        //This data is not aligned
        if (xts->out_bits % 32)
        {
            shift =  xts->out_bits % 16;		//we can also receive a 16-bit word in which case
            if (shift)							//the MSB starts in the least significant 16 bit word
                shift = 16 - shift;				//and it shifts the same way for 32 bit if
												//out_bits > 16 and ( shift = 32 - out_bits % 32 )

            debug("out_done %d shift %d\n", out_done, shift);
            for (i= aligned_bytes*8; i <xts->out_bits; i++)
            {
                bit_num = i + shift;
                bit_val = xts->buf[bit_num/8] & (1<<(bit_num%8));
                if(!(out_done % 32))
                	tdostream[out_done/32] = 0;
                if (bit_val)
                	tdostream[out_done/32] |= (1<<(out_done%32));
                out_done++;
            }
        }
    }
  
  xts->in_bits = 0;
  xts->out_bits = 0;
  
  return r;
}



int cable_xpcusb_out(uint8_t value)
{
	int             rv;                  // to catch return values of functions
	//usb_dev_handle *h_device;            // handle on the ubs device
	uint8_t out;

	// open the device, if necessary
	if(h_device == NULL) {
		rv = cable_xpcusb_open_cable();
		if(rv != APP_ERR_NONE) return rv;
	}

	if ( cpld_ctrl )
	{
		rv = cable_xpcusb_fx2_init();
		if ( rv != APP_ERR_NONE) return rv;
	}

	// send the buffer
	// Translate to USB blaster protocol
	out = 0;
	if(value & TCLK_BIT)
		out |= XPCUSB_CMD_TCK;
	if(value & TDI_BIT)
		out |= XPCUSB_CMD_TDI;
	if(value & TMS_BIT)
		out |= XPCUSB_CMD_TMS;

	out |= XPCUSB_CMD_PROG;  // Set output PROG (always necessary)

	rv = usb_control_msg(h_device, 0x40, 0xB0, 0x0030, out, NULL, 0, USB_TIMEOUT);
	if (rv < 0){
		fprintf(stderr, "\nFailed to send a write control message (rv = %d):\n%s\n", rv, usb_strerror());
		cable_xpcusb_close_cable();
		return APP_ERR_USB;
	}

	return APP_ERR_NONE;
}

int cable_xpcusb_inout(uint8_t value, uint8_t *inval)
{
	int rv;                  // to catch return values of functions
	//usb_dev_handle *h_device;            // handle on the usb device
	char ret = 0;
	uint8_t out;

	// open the device, if necessary
	if(h_device == NULL) {
		rv = cable_xpcusb_open_cable();
		if(rv != APP_ERR_NONE) return rv;
	}

	if ( cpld_ctrl )
	{
		rv = cable_xpcusb_fx2_init();
		if ( rv != APP_ERR_NONE) return rv;
	}

	// Translate to USB blaster protocol
	out = 0;
	if(value & TCLK_BIT)
		out |= XPCUSB_CMD_TCK;
	if(value & TDI_BIT)
		out |= XPCUSB_CMD_TDI;
	if(value & TMS_BIT)
		out |= XPCUSB_CMD_TMS;

	out |= XPCUSB_CMD_PROG;  // Set output PROG (always necessary)

	// Send the output
	rv = usb_control_msg(h_device, 0x40, 0xB0, 0x0030, out, NULL, 0, USB_TIMEOUT);
	if (rv < 0){
		fprintf(stderr, "\nFailed to send a write control message (rv = %x):\n%s\n", rv, usb_strerror());
		cable_xpcusb_close_cable();
		return APP_ERR_USB;
	}

	// receive the response
	rv = usb_control_msg(h_device, 0xC0, 0xB0, 0x0038, 0, (char*)&ret, 1, USB_TIMEOUT);
	if (rv < 0){
		fprintf(stderr, "\nFailed to execute a read control message:\n%s\n", usb_strerror());
		cable_xpcusb_close_cable();
		return APP_ERR_USB;
	}

	if(ret & XPCUSB_CMD_TDO)
		*inval = 1;
	else
		*inval = 0;

	return APP_ERR_NONE;
}

// Xilinx couldn't be like everyone else.  Oh, no.
// For some reason, "set data/drop TCK" then "read data/raise TCK" won't work.
// So we have our very own bit read/write function.  @whee.
int cable_xpcusb_read_write_bit(uint8_t packet_out, uint8_t *bit_in) {
	uint8_t data = TRST_BIT;  //  TRST is active low, don't clear unless /set/ in 'packet'
	int err = APP_ERR_NONE;

	/* Write data, drop clock */
	if(packet_out & TDO) data |= TDI_BIT;
	if(packet_out & TMS) data |= TMS_BIT;
	if(packet_out & TRST) data &= ~TRST_BIT;

	err |= cable_xpcusb_inout(data, bit_in);  // read in bit, set data, drop clock
	err |= cable_xpcusb_out(data|TCLK_BIT);  // clk hi

	return err;
}


int cable_xpcusb_cpld_write_bit(uint8_t value)
{
	uint32_t out;
	out = (value & TDO) ? 1:0;
	return cable_xpcusb_write_stream(&out, 1, value & TMS);
}

int cable_xpcusb_cpld_readwrite_bit(uint8_t value, uint8_t *inval)
{
	int r;
	uint32_t out;
	uint32_t in;
	out = (value & TDO) ? 1:0;
	r = cable_xpcusb_readwrite_stream(&out, &in, 1, value & TMS);
	if ( r < 0 )
		return r;
	*inval = in & 0x1;
	return APP_ERR_NONE;
}

int cable_xpcusb_write_stream(uint32_t *outstream, int len_bits, int set_last_bit)
{
    return cable_xpcusb_readwrite_stream(outstream, NULL, len_bits, set_last_bit);
}

/*
 *   Care has to be taken that the number of bits to be transferred
 *   is NOT a multiple of 4. The CPLD doesn't seem to handle that well.
 */
int cable_xpcusb_readwrite_stream(uint32_t *outstream, uint32_t *instream, int len_bits, int set_last_bit)
{
	int i;
	int ret = APP_ERR_NONE;
	uint32_t bitval;
	xpc_ext_transfer_state_t xts;
	uint8_t tms, tdi, sample_tdo, toggle_clock;

	// open the device, if necessary
	if(h_device == NULL) {
		ret = cable_xpcusb_open_cable();
		if(ret != APP_ERR_NONE) return ret;
	}

	if ( !cpld_ctrl )
	{
		ret = cable_xpcusb_cpld_init();
		if ( ret != APP_ERR_NONE) return ret;
	}

	debug("cable_xpcusb_write_stream(), len_bits = 0x%X, set_last_bit = %i\n", len_bits, set_last_bit);

	xts.in_bits = 0;
	xts.out_bits = 0;

	tms = 0;
	tdi = 0;
	toggle_clock = 1;
	sample_tdo = 1;		//automatically ignored if xts.out == NULL

	for (i = 0; i < len_bits && ret == APP_ERR_NONE; i++)
	{
		if ( outstream )
			bitval = outstream[i/32] & (1<<(i%32));
		else
			bitval = 0;

		tms = ( i == len_bits - 1 ) ? set_last_bit:0;
		tdi = bitval ? 1:0;

		debug("Adding bit for transfer, bitval = %i, set_tms = %i\n", tdi, tms);
		xpcusb_add_bit_for_ext_transfer(&xts, toggle_clock, tms, tdi, sample_tdo);

		if ( xts.in_bits == (2*CPLD_MAX_BYTES - 1) )
		{
			debug("Reached %i bits, doing transfer\n", (2*CPLD_MAX_BYTES - 1));
			ret = xpcusb_do_ext_transfer(&xts, instream);
		}
	}

	if((xts.in_bits > 0) && (ret == APP_ERR_NONE))
	{
		/* CPLD doesn't like multiples of 4; add one dummy bit */
		if((xts.in_bits & 3) == 0)
		{
			debug("Adding dummy bit\n");
			xpcusb_add_bit_for_ext_transfer(&xts, 0, 0, 0, 0);
		}
		debug("Doing final transfer of sequence\n");
		ret = xpcusb_do_ext_transfer(&xts, instream);
	}

	if(ret != APP_ERR_NONE)
	{
		fprintf(stderr, "Cable will block until next power reset\n");
		fprintf(stderr, "Closing connection to cable.\n");
		cable_xpcusb_close_cable();
		fprintf(stderr, "Aborting adv_jtag_bridge.\n");
		exit(1);
	}

	return ret;
}


static int cable_xpcusb_open_cable(void)
{
	int if_not_claimed = 1;
	timeout_timer timer;

	fprintf(stderr, "XPC USB driver opening cable\n");
	// open the device (assumes 'device' has already been set/populated)
	h_device = usb_open(device);
	if (h_device == NULL){
		fprintf(stderr, "XPC USB driver failed to open device\n");
		return APP_ERR_USB;
	}

	// set the configuration
	if (usb_set_configuration(h_device, device->config->bConfigurationValue))
	{
		usb_close(h_device);
		h_device = NULL;
		fprintf(stderr, "XPC USB driver failed to set configuration\n");
		return APP_ERR_USB;
	}

	if ( create_timer(&timer) )
	{
	      fprintf(stderr, "Failed to create timer\n");
	      // fall back to infinite wait
	      while (usb_claim_interface(h_device, device->config->interface->altsetting->bInterfaceNumber));
	}
	else
	{

	      while (if_not_claimed && !timedout(&timer) )
	          if_not_claimed = usb_claim_interface(h_device, device->config->interface->altsetting->bInterfaceNumber);

	    if ( timedout(&timer) )
	    {
		fprintf(stderr, "Claiming interface timed out...\n");
		return APP_ERR_USB;
	    }
	}

	return APP_ERR_NONE;
}


static void cable_xpcusb_close_cable(void)
{
  fprintf(stderr, "XPC USB driver closing cable\n");
  if(h_device != NULL) {
    // release the interface cleanly
    if (usb_release_interface(h_device, device->config->interface->altsetting->bInterfaceNumber)){
      fprintf(stderr, "Warning: failed to release usb interface\n");
    }
  
    // close the device
    usb_close(h_device);
    h_device = NULL;
  }

  return;
}

int cable_xpcusb_opt(int c, char *str)
{
    fprintf(stderr, "Unknown parameter '%c'\n", c);
    return APP_ERR_BAD_PARAM;
}

jtag_cable_t *cable_xpcusb_get_driver(void)
{
  return &dlc9_cable_driver; 
}

static int xpcusb_enumerate_bus(void)
{
  int             flag;  // for USB bus scanning stop condition
  struct usb_bus *bus;   // pointer on the USB bus
  
  // board detection
  usb_init();
  usb_find_busses();
  usb_find_devices();

  flag = 0;
  
  for (bus = usb_get_busses(); bus; bus = bus->next)
  {
    for (device = bus->devices; device; device = device->next)
    {	
      if (device->descriptor.idVendor  == XPCUSB_VID &&
          device->descriptor.idProduct == XPCUSB_PID) 
      {
	      flag = 1;
	      fprintf(stderr, "Found Xilinx Platform Cable USB (DLC9)\n");
	      return APP_ERR_NONE;
      }
    }
    if (flag)
      break;
  }

  fprintf(stderr, "Failed to find Xilinx Platform Cable USB\n");
  return APP_ERR_CABLENOTFOUND;
}



static int xpcu_common_init( struct usb_dev_handle *xpcu )
{
    int r;

    r = xpcu_request_28(xpcu, 0x11);
    if (r>=0)
    	r = xpcu_write_gpio(xpcu, 8);

    if (r<0)
    	cable_xpcusb_close_cable();

    return r;
}


static int cable_xpcusb_fx2_init()
{
	int r;

	r = xpcu_select_gpio(h_device, 0);
	if ( r < 0 ) fprintf(stderr, "Error setting FX2 mode\n");
	cpld_ctrl = 0;

	return APP_ERR_NONE;
}

static int cable_xpcusb_cpld_init()
{
	int r;
	uint8_t zero[2] = {0,0};

	r = xpcu_request_28(h_device, 0x11);
	if (r >= 0) r = xpcu_output_enable(h_device, 1);
	else fprintf(stderr, "First xpcu_request_28 failed!\n");
	if (r >= 0) r = xpcu_shift(h_device, 0xA6, 2, 2, zero, 0, NULL);
	else fprintf(stderr, "xpcu_output_enable failed!\n");
	if (r >= 0) r = xpcu_request_28(h_device, 0x12);
	else fprintf(stderr, "xpcu_shift for init failed!\n");
	if(r < 0) fprintf(stderr, "second xpcu_request_28 failed!\n");

	cpld_ctrl = 1;

	return APP_ERR_NONE;
}


int cable_xpcusb_init()
{
	int r = APP_ERR_NONE;
    uint16_t buf;
	// Process to reset the XPC USB (DLC9)
	if(r |= xpcusb_enumerate_bus()) {
		return r;
	}

	//usb_dev_handle *
	h_device = usb_open(device);

	if(h_device == NULL)
	{
		fprintf(stderr, "Init failed to open USB device for reset\n");
		return APP_ERR_USB;
	}

	if(usb_reset(h_device) != APP_ERR_NONE)
		fprintf(stderr, "Failed to reset XPC-USB\n");

	usb_close(h_device);
	h_device = NULL;

	// Wait for reset!!!
	sleep(1);

	// Do device initialization
	if(r |= xpcusb_enumerate_bus())
		return r;

	r = cable_xpcusb_open_cable();
	if ( r )
	{
		fprintf(stderr, "Open cable failed\n");
		return APP_ERR_USB;
	}

	r = xpcu_common_init(h_device);

    /* Read firmware version (constant embedded in firmware) */

    if (r>=0) r = xpcu_read_firmware_version(h_device, &buf);
    if (r>=0)
    {
        printf("firmware version = 0x%04X (%u)\n", buf, buf);
    }

    /* Read CPLD version (via GPIF) */

    if (r>=0) r = xpcu_read_cpld_version(h_device, &buf);
    if (r>=0)
    {
        printf("cable CPLD version = 0x%04X (%u)\n", buf, buf);
        if(buf == 0)
        {
            printf("Warning: version '0' can't be correct. Please try resetting the cable\n");
            r = -1;
        }
    }

    if (r<0)
    	cable_xpcusb_close_cable();

    r = cable_xpcusb_cpld_init();
    if (r<0)
    	cable_xpcusb_close_cable();

	return r;
}


