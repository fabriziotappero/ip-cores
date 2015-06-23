/* cable_usbblaster.c - Altera USB Blaster driver for the Advanced JTAG Bridge
   Copyright (C) 2008 - 2010 Nathan Yawn, nathan.yawn@opencores.org
   
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
#include <string.h>  // for memcpy()

#include "usb.h"  // libusb header

#include "cable_usbblaster.h"
#include "utilities.h"
#include "errcodes.h"

#define debug(...) //fprintf(stderr, __VA_ARGS__ )

jtag_cable_t usbblaster_cable_driver = {
    .name = "usbblaster",
    .inout_func = cable_usbblaster_inout,
    .out_func = cable_usbblaster_out,
    .init_func = cable_usbblaster_init ,
    .opt_func = cable_usbblaster_opt,
    .bit_out_func = cable_common_write_bit,
    .bit_inout_func = cable_common_read_write_bit,
    .stream_out_func =  cable_usbblaster_write_stream,
    .stream_inout_func = cable_usbblaster_read_stream,
    .flush_func = NULL,
    .opts = "p:v:",
    .help = "-p [PID] Alteranate PID for USB device (hex value)\n\t-v [VID] Alternate VID for USB device (hex value)\n",
    };

// USB constants for the USB Blaster
// Valid endpoints: 0x81, 0x02, 0x06, 0x88
#define EP2        0x02
#define EP1        0x81

// These are the Altera defaults, but can be changed on the command line
static uint32_t ALTERA_VID = 0x09FB;
static uint32_t ALTERA_PID = 0x6001;

//#define USB_TIMEOUT 500
#define USB_TIMEOUT 10000


// Bit meanings in the command byte sent to the USB-Blaster
#define USBBLASTER_CMD_TCK 0x01
#define USBBLASTER_CMD_TMS 0x02
#define USBBLASTER_CMD_nCE 0x04  /* should be left low */
#define USBBLASTER_CMD_nCS 0x08  /* must be set for byte-shift mode reads to work */
#define USBBLASTER_CMD_TDI 0x10
#define USBBLASTER_CMD_OE  0x20  /* appears necessary to set it to make everything work */
#define USBBLASTER_CMD_READ 0x40
#define USBBLASTER_CMD_BYTESHIFT 0x80


static struct usb_device *usbblaster_device;
static usb_dev_handle *h_device;

// libusb seems to give an error if we ask for a transfer larger than 64 bytes
// USBBlaster also has a max. single transaction of 63 bytes.
// So, size the max read and write to create 64-byte USB packets (reads have 2 useless bytes prepended)
#define USBBLASTER_MAX_WRITE 63
static char data_out_scratchpad[USBBLASTER_MAX_WRITE+1];
#define USBBLASTER_MAX_READ  62
static char data_in_scratchpad[USBBLASTER_MAX_READ+2];

// Flag used to avoid unnecessary transfers
// Since clock is lowered if high (and never the other way around),
// 1 is a safe default value.
static unsigned char clock_is_high = 1;

int cable_usbblaster_open_cable(void);
void cable_usbblaster_close_cable(void);
//int cable_usbblaster_reopen_cable(void);

///////////////////////////////////////////////////////////////////////////////
/*-------------------------------------[ USB Blaster specific functions ]---*/
/////////////////////////////////////////////////////////////////////////////


static int usbblaster_start_interface(struct usb_dev_handle *xpcu)
{
  // Need to send a VENDOR request OUT, request = GET_STATUS
  // Other parameters are ignored
  if(usb_control_msg(xpcu, (USB_ENDPOINT_OUT | USB_TYPE_VENDOR), USB_REQ_GET_STATUS,
		     0, 0, NULL, 0, 1000)<0)
    {
      perror("usb_control_msg(start interface)");
      return APP_ERR_USB;
    }
  
  return APP_ERR_NONE;
}


static int usbblaster_read_firmware_version(struct usb_dev_handle *xpcu, uint16_t *buf)
{
  if(usb_control_msg(xpcu, 0xC0, 0x90, 0, 3, (char*)buf, 2, USB_TIMEOUT)<0)
    {
      perror("usb_control_msg(0x90.0) (read_firmware_version)");
      return APP_ERR_USB;
    }
  
  // Swap endian
  *buf = htons(*buf);
  //*buf = (*buf << 8) | (*buf >> 8);
  
  return APP_ERR_NONE;
}



static int usbblaster_enumerate_bus(void)
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
    for (usbblaster_device = bus->devices; usbblaster_device; usbblaster_device = usbblaster_device->next)
    {	
      if (usbblaster_device->descriptor.idVendor  == ALTERA_VID &&
          usbblaster_device->descriptor.idProduct == ALTERA_PID) 
      {
	      flag = 1;
	      fprintf(stderr, "Found Altera USB-Blaster\n");
	      return APP_ERR_NONE;
      }
    }
    if (flag)
      break;
  }

  fprintf(stderr, "Failed to find USB-Blaster  with VID 0x%0X, PID 0x%0X\n", ALTERA_VID, ALTERA_PID);
  return APP_ERR_CABLENOTFOUND;
}


int cable_usbblaster_init(){
  int err = APP_ERR_NONE;
  
  // Process to reset the usb blaster
  if(err |= usbblaster_enumerate_bus()) {
    return err;
  }

  h_device = usb_open(usbblaster_device);
  
  if(h_device == NULL)
    {
      fprintf(stderr, "Init failed to open USB device for reset\n");
      return APP_ERR_USB;
    }
	
  if(usb_reset(h_device) != APP_ERR_NONE)
    fprintf(stderr, "Failed to reset USB Blaster\n");

  usb_close(h_device);

  // Wait for reset!!!
  sleep(1);

  // Do device initialization
  if(err |= usbblaster_enumerate_bus())
    return err;

  err = cable_usbblaster_open_cable();
  if(err != APP_ERR_NONE) return err;

  //usb_clear_halt(h_device, EP1);
  //usb_clear_halt(h_device, EP2);

  // IMPORTANT:  DO NOT SEND A REQUEST TYPE "CLASS" OR TYPE "RESERVED".  This may stall the EP.

  // Some clones need this before they will start processing IN/OUT requests
  if(usbblaster_start_interface(h_device) != APP_ERR_NONE)
    fprintf(stderr, "Failed to start remote interface\n");

  uint16_t buf;
  if(err |= usbblaster_read_firmware_version(h_device, &buf))
    {
      usb_close(h_device);
      fprintf(stderr, "Failed to read firmware version\n");
      return err;
    }
  else
    {
      printf("firmware version = 0x%04X (%u)\n", buf, buf);
    }


  // USB blaster is expecting us to read 2 bytes, which are useless to us...
  char ret[2];
  int rv = usb_bulk_read(h_device, EP1, ret, 2, USB_TIMEOUT);
  if (rv < 0){  // But if we fail, who cares?
    fprintf(stderr, "\nWarning: Failed to read post-init bytes from the EP1 FIFO (%i):\n%s", rv, usb_strerror());
  } 
 
  return APP_ERR_NONE;
}


int cable_usbblaster_out(uint8_t value)
{
  int             rv;                  // to catch return values of functions
  char out;
  int err = APP_ERR_NONE;

  // open the device, if necessary
  if(h_device == NULL) {
    rv = cable_usbblaster_open_cable();
    if(rv != APP_ERR_NONE) return rv;
  }

  out = (USBBLASTER_CMD_OE | USBBLASTER_CMD_nCS);  // Set output enable (appears necessary) and nCS (necessary for byte-shift reads)

  // Translate to USB blaster protocol
  // USB-Blaster has no TRST pin
  if(value & TCLK_BIT)
    out |= USBBLASTER_CMD_TCK;
  if(value & TDI_BIT)
    out |= USBBLASTER_CMD_TDI;
  if(value & TMS_BIT)
    out |= USBBLASTER_CMD_TMS;


  rv = usb_bulk_write(h_device, EP2, &out, 1, USB_TIMEOUT);
  if (rv != 1){
    fprintf(stderr, "\nFailed to write to the FIFO (rv = %d):\n%s", rv, usb_strerror());
    err |= APP_ERR_USB;
  }

  if(value & TCLK_BIT)
    {
      clock_is_high = 1;
    }
  else
    {
      clock_is_high = 0;
    }

  return err;
}


int cable_usbblaster_inout(uint8_t value, uint8_t *in_bit)
{
  int             rv;                  // to catch return values of functions
  char ret[3] = {0,0,0};               // Two useless bytes (0x31,0x60) always precede the useful byte
  char out;

  out = (USBBLASTER_CMD_OE | USBBLASTER_CMD_nCS);  // Set output enable (?) and nCS (necessary for byte-shift reads)
  out |=  USBBLASTER_CMD_READ;

  // Translate to USB blaster protocol
  // USB-Blaster has no TRST pin
  if(value & TCLK_BIT)
    out |= USBBLASTER_CMD_TCK;
  if(value & TDI_BIT)
    out |= USBBLASTER_CMD_TDI;
  if(value & TMS_BIT)
    out |= USBBLASTER_CMD_TMS;

  // open the device, if necessary
  if(h_device == NULL) {
    rv = cable_usbblaster_open_cable();
    if(rv != APP_ERR_NONE) return rv;
  }

  // Send a read request
  rv = usb_bulk_write(h_device, EP2, &out, 1, USB_TIMEOUT);
  if (rv != 1){
    fprintf(stderr, "\nFailed to write a read request to the EP2 FIFO:\n%s", usb_strerror());
    cable_usbblaster_close_cable();
    return APP_ERR_USB;
  }

  if(value & TCLK_BIT)
    {
      clock_is_high = 1;
    }
  else
    {
      clock_is_high = 0;
    }

  // receive the response
  // Sometimes, we do a read but just get the useless 0x31,0x60 chars...
  // retry until we get a 3rd byte (with real data), for a reasonable number of retries.
  int retries = 0;
  do {
    rv = usb_bulk_read(h_device, EP1, ret, 3, USB_TIMEOUT);
    if (rv < 0){
      fprintf(stderr, "\nFailed to read from the EP1 FIFO (%i):\n%s", rv, usb_strerror());
      cable_usbblaster_close_cable();
      return APP_ERR_USB;
    }

    // fprintf(stderr, "Read %i bytes: 0x%X, 0x%X, 0x%X\n", rv, ret[0], ret[1], ret[2]);
    retries++;
  }
  while((rv < 3) && (retries < 20));

  *in_bit = (ret[2] & 0x01); /* TDO is bit 0.  USB-Blaster may also set bit 1. */
  return APP_ERR_NONE;
}


// The usbblaster transfers the bits in the stream in the following order:
// bit 0 of the first byte received ... bit 7 of the first byte received
// bit 0 of second byte received ... etc.
int cable_usbblaster_write_stream(uint32_t *stream, int len_bits, int set_last_bit) {
  int             rv;                  // to catch return values of functions
  unsigned int bytes_to_transfer, leftover_bit_length;
  uint32_t leftover_bits;
  int bytes_remaining;
  char *xfer_ptr;
  int err = APP_ERR_NONE;

  debug("cable_usbblaster_write_stream(0x%X, %d, %i)\n", stream, len, set_last_bit);

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
  if(clock_is_high)
    {
      err |= cable_usbblaster_out(0);  // Lower the clock.
    }

  // Set leftover bits
  leftover_bits = (stream[bytes_to_transfer>>2] >> ((bytes_to_transfer & 0x3) * 8)) & 0xFF;

  debug("leftover_bits: 0x%X, LSB_first_xfer = %d\n", leftover_bits, LSB_first_xfer);

  // open the device, if necessary
  if(h_device == NULL) {
    rv = cable_usbblaster_open_cable();
    if(rv != APP_ERR_NONE) return rv;
  }
 
  bytes_remaining = bytes_to_transfer;
  xfer_ptr = (char *) stream;
  while(bytes_remaining > 0)
    {
      int bytes_this_xfer = (bytes_remaining > USBBLASTER_MAX_WRITE) ? USBBLASTER_MAX_WRITE:bytes_remaining;

      data_out_scratchpad[0] = USBBLASTER_CMD_BYTESHIFT | (bytes_this_xfer & 0x3F);
      memcpy(&data_out_scratchpad[1], xfer_ptr, bytes_this_xfer);
      
      /* printf("Data packet: ");
	 for(i = 0; i <= bytes_to_transfer; i++)
	 printf("0x%X ", out[i]);
	 printf("\n"); */
      
      rv = usb_bulk_write(h_device, EP2, data_out_scratchpad, bytes_this_xfer+1, USB_TIMEOUT);
      if (rv != (bytes_this_xfer+1)){
	fprintf(stderr, "\nFailed to write to the FIFO (rv = %d):\n%s", rv, usb_strerror());
	err |= APP_ERR_USB;
	break;
      }

      bytes_remaining -= bytes_this_xfer;
      xfer_ptr += bytes_this_xfer;
    }

  clock_is_high = 0;

  // if we have a number of bits not divisible by 8, or we need to set TMS...
  if(leftover_bit_length != 0) {
    //printf("Doing leftovers: (0x%X, %d, %d)\n", leftover_bits, leftover_bit_length, set_last_bit);
    return cable_common_write_stream(&leftover_bits, leftover_bit_length, set_last_bit);
  }

  return err;
}


int cable_usbblaster_read_stream(uint32_t *outstream, uint32_t *instream, int len_bits, int set_last_bit) {
  int             rv;                  // to catch return values of functions
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
  if(clock_is_high)
    {
      // Lower the clock.
      retval |= cable_usbblaster_out(0);
    }

  // Zero the input, since we add new data by logical-OR
  for(i = 0; i < (len_bits/32); i++)  instream[i] = 0;
  if(len_bits % 32)                   instream[i] = 0;

  // Set leftover bits
  leftover_bits = (outstream[bytes_to_transfer>>2] >> ((bytes_to_transfer & 0x3) * 8)) & 0xFF;
  debug("leftover_bits: 0x%X\n", leftover_bits);

  // open the device, if necessary
  if(h_device == NULL) {
    rv = cable_usbblaster_open_cable();
    if(rv != APP_ERR_NONE) return rv;
  }

  // Transfer the data.  USBBlaster has a max transfer size of 64 bytes.
  bytes_remaining = bytes_to_transfer;
  xfer_ptr = (char *) outstream;
  total_bytes_received = 0;
  while(bytes_remaining > 0)
    {
      int bytes_this_xfer = (bytes_remaining > USBBLASTER_MAX_READ) ? USBBLASTER_MAX_READ:bytes_remaining;
      data_out_scratchpad[0] = USBBLASTER_CMD_BYTESHIFT | USBBLASTER_CMD_READ | (bytes_this_xfer & 0x3F);
      memcpy(&data_out_scratchpad[1], xfer_ptr, bytes_this_xfer);

      /* debug("Data packet: ");
	 for(i = 0; i <= bytes_to_transfer; i++) debug("0x%X ", data_out_scratchpad[i]);
	 debug("\n"); */

      rv = usb_bulk_write(h_device, EP2, data_out_scratchpad, bytes_this_xfer+1, USB_TIMEOUT);
      if (rv != (bytes_this_xfer+1)){
	fprintf(stderr, "\nFailed to write to the EP2 FIFO (rv = %d):\n%s", rv, usb_strerror());
	cable_usbblaster_close_cable();
	return APP_ERR_USB;
      }

      // receive the response
      // Sometimes, we do a read but just get the useless 0x31,0x60 chars...
      // retry until we get at least 3 bytes (with real data), for a reasonable number of retries.
      int retries = 0;
      bytes_received = 0;
      do {
	debug("stream read, bytes_this_xfer = %i, bytes_received = %i\n", bytes_this_xfer, bytes_received);
	rv = usb_bulk_read(h_device, EP1, data_in_scratchpad, (bytes_this_xfer-bytes_received)+2, USB_TIMEOUT);
	if (rv < 0){
	  fprintf(stderr, "\nFailed to read stream from the EP1 FIFO (%i):\n%s", rv, usb_strerror());
	  cable_usbblaster_close_cable();
	  return APP_ERR_USB;
	}

	/* debug("Read %i bytes: ", rv);
	   for(i = 0; i < rv; i++)
	   debug("0x%X ", data_in_scratchpad[i]);
	   debug("\n"); */
	
	if(rv > 2) retries = 0;
	else retries++;
	
	/* Put the received bytes into the return stream.  Works for either endian. */
	for(i = 0; i < (rv-2); i++) {
	  // Do size/type promotion before shift.  Must cast to unsigned, else the value may be
	  // sign-extended through the upper 16 bits of the uint32_t.
	  uint32_t tmp = (unsigned char) data_in_scratchpad[2+i];
	  instream[(total_bytes_received+i)>>2] |= (tmp << ((i & 0x3)*8));
	}

	bytes_received += (rv-2);
	total_bytes_received += (rv-2);
      }
      while((bytes_received < bytes_this_xfer) && (retries < 15));

      bytes_remaining -= bytes_this_xfer;
      xfer_ptr += bytes_this_xfer;
    }

  clock_is_high = 0;

  // if we have a number of bits not divisible by 8
  if(leftover_bit_length != 0) {
    debug("Doing leftovers: (0x%X, %d, %d)\n", leftover_bits, leftover_bit_length, set_last_bit);
    retval |= cable_common_read_stream(&leftover_bits, &leftovers_received, leftover_bit_length, set_last_bit);
    instream[bytes_to_transfer>>2] |= (leftovers_received & 0xFF) << (8*(bytes_to_transfer & 0x3));
  }

  return retval;
}

jtag_cable_t *cable_usbblaster_get_driver(void)
{
  return &usbblaster_cable_driver; 
}

int cable_usbblaster_opt(int c, char *str)
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


int cable_usbblaster_open_cable(void)
{
  int if_not_claimed = 1;
  timeout_timer timer;

  // open the device
  h_device = usb_open(usbblaster_device);
  if (h_device == NULL){
	fprintf(stderr, "USBBlaster driver failed to open device\n");
	return APP_ERR_USB;
  }
 
  // set the configuration
  if (usb_set_configuration(h_device, usbblaster_device->config->bConfigurationValue))
  {
	usb_close(h_device);
	h_device = NULL;
	fprintf(stderr, "USBBlaster driver failed to set configuration\n");
	return APP_ERR_USB;
  }

  // wait until device is ready
  if ( create_timer(&timer) )
    {
      fprintf(stderr, "Failed to create timer\n");
      // fall back to infinite wait
      while (usb_claim_interface(h_device, usbblaster_device->config->interface->altsetting->bInterfaceNumber));
    }
  else
    {
      while (if_not_claimed && !timedout(&timer) )
	if_not_claimed = usb_claim_interface(h_device, usbblaster_device->config->interface->altsetting->bInterfaceNumber);

      if ( timedout(&timer) )
	{
	  fprintf(stderr, "Claiming interface timed out...\n");
	  return APP_ERR_USB;
	}
    }

  return APP_ERR_NONE;
}


void cable_usbblaster_close_cable(void)
{
  if(h_device != NULL) {
    // release the interface cleanly
    if (usb_release_interface(h_device, usbblaster_device->config->interface->altsetting->bInterfaceNumber)){
      fprintf(stderr, "Warning: failed to release usb interface\n");
    }
  
    // close the device
    usb_close(h_device);
    h_device = NULL;
  }

  return;
}

/*
int cable_usbblaster_reopen_cable(void)
{
  cable_usbblaster_close_cable();
  return cable_usbblaster_open_cable();
}
*/
