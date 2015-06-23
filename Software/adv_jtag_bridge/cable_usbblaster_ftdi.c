/* cable_usbblaster_ftdi.c - Alternate, libFTDI-basede Altera USB Blaster driver 
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

#include "ftdi.h"  // libftdi header

#include "cable_common.h"
#include "errcodes.h"

#warning Compiling alternate (FTDI-based) USB-Blaster driver -- LOW SPEED!

#define debug(...) //fprintf(stderr, __VA_ARGS__ )

// USB constants for the USB Blaster
#define ALTERA_VID 0x09FB
#define ALTERA_PID 0x6001

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

	debug("usb_blaster_buf_write %02X (%d)\n", buf[0], size);

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

	debug("usb_blaster_buf_read %02X (%d)\n", buf[0], *bytes_read);

	return 0;
}

/* The following code doesn't fully utilize the possibilities of the USB-Blaster. It
 * writes one byte per JTAG pin state change at a time; it doesn't even try to buffer
 * data up to the maximum packet size of 64 bytes.
 *
 * Actually, the USB-Blaster offers a byte-shift mode to transmit up to 504 data bits
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

int cable_usbblaster_out(uint8_t value)
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

int cable_usbblaster_inout(uint8_t value, uint8_t *in_bit)
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

int usb_blaster_speed(int speed)
{
	if(ftdi_set_baudrate(&ftdic, speed)<0) {
		printf("Can't set baud rate to max: %s\n", ftdi_get_error_string(&ftdic));
		return -1;
	}

	return 0;
}

int cable_usbblaster_init(void)
{
	uint8_t  latency_timer;

	printf("'usb_blaster' interface using libftdi\n");

	if (ftdi_init(&ftdic) < 0) {
                printf("ftdi_init failed!");
		return -1;
	}

	/* context, vendor id, product id */
	if (ftdi_usb_open(&ftdic, ALTERA_VID, ALTERA_PID) < 0) {
		printf("unable to open ftdi device: %s\n", ftdic.error_str);
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

int ftdi_usb_blaster_quit(void)
{
	ftdi_usb_close(&ftdic);
	ftdi_deinit(&ftdic);

	return 0;
}


/* Puts bitstream via bit-bang.  Copied directly from cable_common.c, for function-level compatibility
 * with the standard / high-speed usbblaster driver.
 */
int cable_usbblaster_write_stream(uint32_t *stream, int len_bits, int set_last_bit) {
  int i;
  int index = 0;
  int bits_this_index = 0;
  uint8_t out;
  int err = APP_ERR_NONE;

  debug("writeSrrm%d(", len_bits);
  for(i = 0; i < len_bits - 1; i++) {
    out = (stream[index] >> bits_this_index) & 1;
    err |= cable_write_bit(out);
    debug("%i", out);
    bits_this_index++;
    if(bits_this_index >= 32) {
      index++;
      bits_this_index = 0;
    }
  }
  
  out = (stream[index] >>(len_bits - 1)) & 0x1;
  if(set_last_bit) out |= TMS;
  err |= cable_write_bit(out);
  debug("%i)\n", out);
  return err;
}

/* Gets bitstream via bit-bang.  Copied directly from cable_common.c, for function-level compatibility
 * with the standard / high-speed usbblaster driver.
 */
int cable_usbblaster_read_stream(uint32_t *outstream, uint32_t *instream, int len_bits, int set_last_bit) {
  int i;
  int index = 0;
  int bits_this_index = 0;
  uint8_t inval, outval;
  int err = APP_ERR_NONE;

  instream[0] = 0;

  debug("readStrm%d(", len_bits);
  for(i = 0; i < (len_bits - 1); i++) {      
    outval = (outstream[index] >> bits_this_index) & 0x1;
    err |= cable_read_write_bit(outval, &inval);
    debug("%i", inval);
    instream[index] |= (inval << bits_this_index);
    bits_this_index++;
    if(bits_this_index >= 32) {
      index++;
      bits_this_index = 0;
      instream[index] = 0;  // It's safe to do this, because there's always at least one more bit
    }   
  }
  
  if (set_last_bit)
    outval = ((outstream[index] >> (len_bits - 1)) & 1) | TMS;
  else
    outval = (outstream[index] >> (len_bits - 1)) & 1; 
  
  err |= cable_read_write_bit(outval, &inval);
  debug("%i", inval);
  instream[index] |= (inval << bits_this_index);  

  debug(") = 0x%lX\n", instream[0]);
  
  return err;
}




int cable_usbblaster_opt(int c, char *str)
{
  fprintf(stderr, "Unknown parameter '%c'\n", c);
  return APP_ERR_BAD_PARAM;
}


