/* cable_usbblaster_ftdi.c - Alternate, libFTDI-based Altera USB Blaster driver 
   for the Advanced JTAG Bridge.  Originally by Xianfeng Zheng.
   Copyright (C) 2009 Xianfeng Zeng
                 2009 - 2010 Nathan Yawn, nathan.yawn@opencores.org

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
#include <unistd.h>  // for usleep()
#include <stdlib.h>  // for sleep()
#include <arpa/inet.h> // for htons()
#include <sys/time.h>
#include <time.h>
#include <string.h>

#include "ftdi.h"  // libftdi header

#include "cable_ft245.h"
#include "errcodes.h"

#define debug(...) //fprintf(stderr, __VA_ARGS__ )

jtag_cable_t ft245_cable_driver = {
    .name = "ft245",
    .inout_func = cable_ft245_inout,
    .out_func = cable_ft245_out,
    .init_func =cable_ft245_init ,
    .opt_func = cable_ft245_opt,
    .bit_out_func = cable_common_write_bit,
    .bit_inout_func = cable_common_read_write_bit,
#if 1
    .stream_out_func = cable_ft245_write_stream ,
    .stream_inout_func = cable_ft245_read_stream,
#else
    .stream_out_func = cable_common_write_stream ,
    .stream_inout_func = cable_common_read_stream,
#endif
    .flush_func = NULL,
    .opts = "p:v:",
    .help = "-p [PID] Alteranate PID for USB device (hex value)\n\t-v [VID] Alternate VID for USB device (hex value)\n",
};

// USBBlaster has a max. single transaction of 63 bytes.  We assume
// the FT245 has the same limit.
// So, size the max read and write to create 64-byte USB packets
#define USBBLASTER_MAX_WRITE 63
static uint8_t data_out_scratchpad[USBBLASTER_MAX_WRITE+1];
#define USBBLASTER_MAX_READ  62
static uint8_t data_in_scratchpad[USBBLASTER_MAX_READ+2];

// USB constants for the USB Blaster, can be changed on the command line
static uint32_t ALTERA_VID = 0X09FB;
static uint32_t ALTERA_PID = 0x6001;


static struct ftdi_context ftdic;

///////////////////////////////////////////////////////////////////////////////
/*-------------------------------------[ USB Blaster specific functions ]---*/
/////////////////////////////////////////////////////////////////////////////

//
// libusb does not work with my 3C25, but it works with libfdti.
// Following code is ported from http://www.ixo.de/info/usb_jtag/
// ZXF, 2009-10-22
//

int usb_blaster_buf_write(uint8_t *buf, int size, uint32_t* bytes_written)
{
	int retval;

	debug("ft245 usb_blaster_buf_write %02X (%d)\n", buf[0], size);

	if ((retval = ftdi_write_data(&ftdic, buf, size)) < 0) {
		*bytes_written = 0;
		printf("ftdi_write_data: %s\n", ftdi_get_error_string(&ftdic));
		return -1;
	} else {
		*bytes_written = retval;
		return 0;
	}
}

int usb_blaster_buf_read(uint8_t* buf, int size, uint32_t* bytes_read)
{
	int retval;
	int timeout = 100;
	*bytes_read = 0;

	while ((*bytes_read < size) && timeout--) {
		if ((retval = ftdi_read_data(&ftdic, buf + *bytes_read, size - *bytes_read)) < 0) {
			*bytes_read = 0;
			printf("ftdi_read_data: %s\n", ftdi_get_error_string(&ftdic));
			return -1;
		}
		*bytes_read += retval;
	}

	debug("ft245 usb_blaster_buf_read %02X (%d)\n", buf[0], *bytes_read);

	return 0;
}

/* The following code doesn't fully utilize the possibilities of the USB-Blaster. It
 * writes one byte per JTAG pin state change at a time; it doesn't even try to buffer
 * data up to the maximum packet size of 64 bytes.
 *
 * The USB-Blaster offers a byte-shift mode to transmit up to 504 data bits
 * (bidirectional) in a single USB packet. A header byte has to be sent as the first
 * byte in a packet with the following meaning:
 *
 *   Bit 7 (0x80): Must be set to indicate byte-shift mode.
 *   Bit 6 (0x40): If set, the USB-Blaster will also read data, not just write.
 *   Bit 5..0:     Define the number N of following bytes
 *
 * All N following bytes will then be clocked out serially on TDI. If Bit 6 was set,
 * it will afterwards return N bytes with TDO data read while clocking out the TDI data.
 * LSB of the first byte after the header byte will appear first on TDI.
 */

/* Simple bit banging mode:
 *
 *   Bit 7 (0x80): Must be zero (see byte-shift mode above)
 *   Bit 6 (0x40): If set, you will receive a byte indicating the state of TDO in return.
 *   Bit 5 (0x20): Unknown; for now, set to one.
 *   Bit 4 (0x10): TDI Output.
 *   Bit 3 (0x08): Unknown; for now, set to one.
 *   Bit 2 (0x04): Unknown; for now, set to one.
 *   Bit 1 (0x02): TMS Output.
 *   Bit 0 (0x01): TCK Output.
 *
 * For transmitting a single data bit, you need to write two bytes. Up to 64 bytes can be
 * combined in a single USB packet (but this is not done in the code below). It isn't
 * possible to read a data without transmitting data.
 */

#define FTDI_TCK    0
#define FTDI_TMS    1
#define FTDI_TDI    4
#define FTDI_READ   6
#define FTDI_SHMODE 7
#define FTDI_OTHERS ((1<<2)|(1<<3)|(1<<5))

void usb_blaster_write(int tck, int tms, int tdi)
{
	uint8_t buf[1];
	uint32_t count;

	debug("---- usb_blaster_write(%d,%d,%d)\n", tck,tms,tdi);

	buf[0] = FTDI_OTHERS | (tck?(1<<FTDI_TCK):0) | (tms?(1<<FTDI_TMS):0) | (tdi?(1<<FTDI_TDI):0);
	usb_blaster_buf_write(buf, 1, &count);
}

int usb_blaster_write_read(int tck, int tms, int tdi)
{
	uint8_t buf[1];
	uint32_t count;

	debug("++++ usb_blaster_write_read(%d,%d,%d)\n", tck,tms,tdi);

	buf[0] = FTDI_OTHERS | (tck?(1<<FTDI_TCK):0) | (tms?(1<<FTDI_TMS):0) | (tdi?(1<<FTDI_TDI):0) | (1<<FTDI_READ);
	usb_blaster_buf_write(buf, 1, &count);
	usb_blaster_buf_read(buf, 1, &count);
	return (buf[0]&1);
}

int usb_blaster_speed(int speed)
{
	if(ftdi_set_baudrate(&ftdic, speed)<0) {
		printf("Can't set baud rate to max: %s\n", ftdi_get_error_string(&ftdic));
		return -1;
	}

	return 0;
}

int ftdi_usb_blaster_quit(void)
{
	ftdi_usb_close(&ftdic);
	ftdi_deinit(&ftdic);

	return 0;
}

// ---------- adv_jtag_bridge interface functions ------------------
// The stream functions below *do* use the full potential of the FT245
// USB-Blaster.  Up 63 bytes can be written in a single USB transaction,
// and 62 can be read back.  It's possible that libFTDI can handle arbitrary-
// sized writes, but we break up reads and writes into single-transaction
// chunks here.
//
// The usbblaster transfers the bits in the stream in the following order:
// bit 0 of the first byte received ... bit 7 of the first byte received
// bit 0 of second byte received ... etc.
int cable_ft245_write_stream(uint32_t *stream, int len_bits, int set_last_bit) {
  int             rv;                  // to catch return values of functions
  uint32_t count;
  unsigned int bytes_to_transfer, leftover_bit_length;
  uint32_t leftover_bits;
  int bytes_remaining;
  char *xfer_ptr;
  int err = APP_ERR_NONE;

  debug("cable_ft245_write_stream(0x%X, %d, %i)\n", stream, len, set_last_bit);

  // This routine must transfer at least 8 bits.  Additionally, TMS (the last bit)
  // cannot be set by 'byte shift mode'.  So we need at least 8 bits to transfer,
  // plus one bit to send along with TMS.
  bytes_to_transfer = len_bits / 8;
  leftover_bit_length = len_bits - (bytes_to_transfer * 8);

  if((!leftover_bit_length) && set_last_bit) {
    bytes_to_transfer -= 1;
    leftover_bit_length += 8;
  }

  debug("bytes_to_transfer: %d. leftover_bit_length: %d\n", bytes_to_transfer, leftover_bit_length);

  // Not enough bits for high-speed transfer. bit-bang.
  if(bytes_to_transfer == 0) {
    return cable_common_write_stream(stream, len_bits, set_last_bit);
  }

  // Bitbang functions leave clock high.  USBBlaster assumes clock low at the start of a burst.
  err |= cable_ft245_out(0);  // Lower the clock.

  // Set leftover bits
  leftover_bits = (stream[bytes_to_transfer>>2] >> ((bytes_to_transfer & 0x3) * 8)) & 0xFF;

  debug("leftover_bits: 0x%X, LSB_first_xfer = %d\n", leftover_bits, LSB_first_xfer);
 
  bytes_remaining = bytes_to_transfer;
  xfer_ptr = (char *) stream;
  while(bytes_remaining > 0)
    {
      int bytes_this_xfer = (bytes_remaining > USBBLASTER_MAX_WRITE) ? USBBLASTER_MAX_WRITE:bytes_remaining;

      data_out_scratchpad[0] = (1<<FTDI_SHMODE) | (bytes_this_xfer & 0x3F);
      memcpy(&data_out_scratchpad[1], xfer_ptr, bytes_this_xfer);
      
      /* printf("Data packet: ");
	 for(i = 0; i <= bytes_to_transfer; i++)
	 printf("0x%X ", out[i]);
	 printf("\n"); */
      
      rv = usb_blaster_buf_write(data_out_scratchpad, bytes_this_xfer+1, &count);
      if (count != (bytes_this_xfer+1)){
	fprintf(stderr, "\nFailed to write to the FIFO (count = %d)", rv);
	err |= APP_ERR_USB;
	break;
      }

      bytes_remaining -= bytes_this_xfer;
      xfer_ptr += bytes_this_xfer;
    }

  // if we have a number of bits not divisible by 8, or we need to set TMS...
  if(leftover_bit_length != 0) {
    //printf("Doing leftovers: (0x%X, %d, %d)\n", leftover_bits, leftover_bit_length, set_last_bit);
    return cable_common_write_stream(&leftover_bits, leftover_bit_length, set_last_bit);
  }

  return err;
}


int cable_ft245_read_stream(uint32_t *outstream, uint32_t *instream, int len_bits, int set_last_bit) {
  int             rv;                  // to catch return values of functions
  uint32_t count;
  unsigned int bytes_received = 0, total_bytes_received = 0;
  unsigned int bytes_to_transfer, leftover_bit_length;
  uint32_t leftover_bits, leftovers_received = 0;
  unsigned char i;  
  int bytes_remaining;
  char *xfer_ptr;
  int retval = APP_ERR_NONE;

  debug("cable_usbblaster_read_stream(0x%X, %d, %i)\n", outstream[0], len_bits, set_last_bit);

  // This routine must transfer at least 8 bits.  Additionally, TMS (the last bit)
  // cannot be set by 'byte shift mode'.  So we need at least 8 bits to transfer,
  // plus one bit to send along with TMS.
  bytes_to_transfer = len_bits / 8;
  leftover_bit_length = len_bits - (bytes_to_transfer * 8);

  if((!leftover_bit_length) && set_last_bit) {
    bytes_to_transfer -= 1;
    leftover_bit_length += 8;
  }

  debug("RD bytes_to_transfer: %d. leftover_bit_length: %d\n", bytes_to_transfer, leftover_bit_length);

  // Not enough bits for high-speed transfer. bit-bang.
  if(bytes_to_transfer == 0) {
    return cable_common_read_stream(outstream, instream, len_bits, set_last_bit);
  }

  // Bitbang functions leave clock high.  USBBlaster assumes clock low at the start of a burst.
  // Lower the clock.
  retval |= cable_ft245_out(0);

  // Zero the input, since we add new data by logical-OR
  for(i = 0; i < (len_bits/32); i++)  instream[i] = 0;
  if(len_bits % 32)                   instream[i] = 0;

  // Set leftover bits
  leftover_bits = (outstream[bytes_to_transfer>>2] >> ((bytes_to_transfer & 0x3) * 8)) & 0xFF;
  debug("leftover_bits: 0x%X\n", leftover_bits);

  // Transfer the data.  USBBlaster has a max transfer size of 64 bytes.
  bytes_remaining = bytes_to_transfer;
  xfer_ptr = (char *) outstream;
  total_bytes_received = 0;
  while(bytes_remaining > 0)
    {
      int bytes_this_xfer = (bytes_remaining > USBBLASTER_MAX_READ) ? USBBLASTER_MAX_READ:bytes_remaining;
      data_out_scratchpad[0] = (1<<FTDI_SHMODE) | (1<<FTDI_READ) | (bytes_this_xfer & 0x3F);
      memcpy(&data_out_scratchpad[1], xfer_ptr, bytes_this_xfer);

      /* debug("Data packet: ");
	 for(i = 0; i <= bytes_to_transfer; i++) debug("0x%X ", data_out_scratchpad[i]);
	 debug("\n"); */

      rv = usb_blaster_buf_write(data_out_scratchpad, bytes_this_xfer+1, &count);
      if (count != (bytes_this_xfer+1)){
	fprintf(stderr, "\nFailed to write to the EP2 FIFO (count = %d)\n", count);
	return APP_ERR_USB;
      }

      // receive the response
      // libFTDI removes the excess 0x31 0x60 chars for us.
      int retries = 0;
      bytes_received = 0;
      do {
	debug("stream read, bytes_this_xfer = %i, bytes_received = %i\n", bytes_this_xfer, bytes_received);
	rv = usb_blaster_buf_read(data_in_scratchpad, (bytes_this_xfer-bytes_received), &count);
	if (rv < 0){
	  fprintf(stderr, "\nFailed to read stream from the EP1 FIFO (%i)\n", rv);
	  return APP_ERR_USB;
	}

	/* debug("Read %i bytes: ", rv);
	   for(i = 0; i < rv; i++)
	   debug("0x%X ", data_in_scratchpad[i]);
	   debug("\n"); */
	
	if(count > 0) retries = 0;
	else retries++;
	
	/* Put the received bytes into the return stream.  Works for either endian. */
	for(i = 0; i < count; i++) {
	  // Do size/type promotion before shift.  Must cast to unsigned, else the value may be
	  // sign-extended through the upper 16 bits of the uint32_t.
	  uint32_t tmp = (unsigned char) data_in_scratchpad[i];
	  instream[(total_bytes_received+i)>>2] |= (tmp << ((i & 0x3)*8));
	}

	bytes_received += count;
	total_bytes_received += count;
      }
      while((bytes_received < bytes_this_xfer) && (retries < 15));

      bytes_remaining -= bytes_this_xfer;
      xfer_ptr += bytes_this_xfer;
    }

  // if we have a number of bits not divisible by 8
  if(leftover_bit_length != 0) {
    debug("Doing leftovers: (0x%X, %d, %d)\n", leftover_bits, leftover_bit_length, set_last_bit);
    retval |= cable_common_read_stream(&leftover_bits, &leftovers_received, leftover_bit_length, set_last_bit);
    instream[bytes_to_transfer>>2] |= (leftovers_received & 0xFF) << (8*(bytes_to_transfer & 0x3));
  }

  return retval;
}


int cable_ft245_out(uint8_t value)
{
	int    tck = 0;
	int    tms = 0;
	int    tdi = 0; 

	// Translate to USB blaster protocol
	// USB-Blaster has no TRST pin
	if(value & TCLK_BIT)
		tck = 1;
	if(value & TDI_BIT)
		tdi = 1;;
	if(value & TMS_BIT)
		tms = 1;

	usb_blaster_write(tck, tms, tdi);

	return 0;
}

int cable_ft245_inout(uint8_t value, uint8_t *in_bit)
{
	int    tck = 0;
	int    tms = 0;
	int    tdi = 0; 

	// Translate to USB blaster protocol
	// USB-Blaster has no TRST pin
	if(value & TCLK_BIT)
		tck = 1;
	if(value & TDI_BIT)
		tdi = 1;
	if(value & TMS_BIT)
		tms = 1;

	*in_bit = usb_blaster_write_read(tck, tms, tdi);

	return 0;
}

int cable_ft245_init(void)
{
	uint8_t  latency_timer;

	printf("'usb_blaster' interface using libftdi\n");

	if (ftdi_init(&ftdic) < 0) {
                printf("ftdi_init failed!");
		return -1;
	}

	/* context, vendor id, product id */
	if (ftdi_usb_open(&ftdic, ALTERA_VID, ALTERA_PID) < 0) {
		printf("unable to open ftdi device with VID 0x%0X, PID 0x%0X: %s\n", ALTERA_VID, ALTERA_PID, ftdic.error_str);
		return -1;
	}

	if (ftdi_usb_reset(&ftdic) < 0) {
		printf("unable to reset ftdi device\n");
		return -1;
	}

	if (ftdi_set_latency_timer(&ftdic, 2) < 0) {
		printf("unable to set latency timer\n");
		return -1;
	}

	if (ftdi_get_latency_timer(&ftdic, &latency_timer) < 0) {
		printf("unable to get latency timer\n");
		return -1;
	} else {
		printf("current latency timer: %i\n", latency_timer);
	}

	ftdi_disable_bitbang(&ftdic);

	usb_blaster_speed(300000);

	return 0;
}

jtag_cable_t *cable_ft245_get_driver(void)
{
  return &ft245_cable_driver; 
}


int cable_ft245_opt(int c, char *str)
{
  uint32_t newvid;
  uint32_t newpid;

  switch(c) {
  case 'p':
    if(!sscanf(str, "%x", &newpid)) {
      fprintf(stderr, "p parameter must have a hex number as parameter\n");
      return APP_ERR_BAD_PARAM;
    }
    else {
      ALTERA_PID = newpid;
    }
    break;

  case 'v':
    if(!sscanf(str, "%x", &newvid)) {
      fprintf(stderr, "v parameter must have a hex number as parameter\n");
      return APP_ERR_BAD_PARAM;
    }
    else {
      ALTERA_VID = newvid;
    }
    break;

  default:
    fprintf(stderr, "Unknown parameter '%c'\n", c);
    return APP_ERR_BAD_PARAM;
  }
  return APP_ERR_NONE;
}


