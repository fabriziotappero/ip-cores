/* cable_ft2232.c - FT2232 based cable driver for the Advanced JTAG Bridge
   Copyright (C) 2008 Arnim Laeuger, arniml@opencores.org
   Copyright (C) 2009 José Ignacio Villar, jose@dte.us.es
   
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


#include <time.h>
#include <sys/time.h>
#include <fcntl.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <unistd.h>
#include <ftdi.h>

#include "cable_ft2232.h"
#include "errcodes.h"
int debug = 0;

#define debug(...) //fprintf(stderr, __VA_ARGS__ )

jtag_cable_t ft2232_cable_driver = {
    .name = "ft2232",
    .inout_func = NULL,
    .out_func = NULL,
    .init_func = cable_ftdi_init,
    .opt_func = cable_ftdi_opt,
    .bit_out_func = cable_ftdi_write_bit,
    .bit_inout_func = cable_ftdi_read_write_bit,
    .stream_out_func = cable_ftdi_write_stream,
    .stream_inout_func = cable_ftdi_read_stream,
    .flush_func = cable_ftdi_flush,
    .opts = "p:v:",
    .help = "-p [PID] Alteranate PID for USB device (hex value)\n\t-v [VID] Alternate VID for USB device (hex value)\n",
};

usbconn_t * usbconn_ftdi_connect();
int my_ftdi_write_data(struct ftdi_context *ftdi, unsigned char *buf, int size);
char *my_ftdi_get_error_string (struct ftdi_context *ftdi);
int my_ftdi_read_data(struct ftdi_context *ftdi, unsigned char *buf, int size);
int my_ftdi_usb_open_desc(struct ftdi_context *ftdi, int vendor, int product, const char* description, const char* serial);
void my_ftdi_deinit(struct ftdi_context *ftdi);
int my_ftdi_usb_purge_buffers(struct ftdi_context *ftdi);
int my_ftdi_usb_purge_rx_buffer(struct ftdi_context *ftdi);
int my_ftdi_usb_purge_tx_buffer(struct ftdi_context *ftdi);
int my_ftdi_usb_reset(struct ftdi_context *ftdi);
int my_ftdi_set_latency_timer(struct ftdi_context *ftdi, unsigned char latency);
int my_ftdi_set_baudrate(struct ftdi_context *ftdi, int baudrate);
int my_ftdi_read_data_set_chunksize(struct ftdi_context *ftdi, unsigned int chunksize);
int my_ftdi_write_data_set_chunksize(struct ftdi_context *ftdi, unsigned int chunksize);
int my_ftdi_set_event_char(struct ftdi_context *ftdi, unsigned char eventch, unsigned char enable);
int my_ftdi_set_error_char(struct ftdi_context *ftdi, unsigned char errorch, unsigned char enable);
int my_ftdi_set_bitmode(struct ftdi_context *ftdi, unsigned char bitmask, unsigned char mode);
int my_ftdi_usb_close(struct ftdi_context *ftdi);

static int usbconn_ftdi_common_open( usbconn_t *conn);
static void usbconn_ftdi_free( usbconn_t *conn );
static int seq_purge(struct ftdi_context *ftdic, int purge_rx, int purge_tx);
static int seq_reset(struct ftdi_context *ftdic);
static int usbconn_ftdi_flush( ftdi_param_t *params );
static int usbconn_ftdi_read( usbconn_t *conn, uint8_t *buf, int len );
static int usbconn_ftdi_write( usbconn_t *conn, uint8_t *buf, int len, int recv );
static int usbconn_ftdi_mpsse_open( usbconn_t *conn );
static int usbconn_ftdi_close(usbconn_t *conn);

usbconn_driver_t usbconn_ft2232_mpsse_driver = {
	"ftdi-mpsse",
	usbconn_ftdi_connect,
	usbconn_ftdi_free,
	usbconn_ftdi_mpsse_open,
	usbconn_ftdi_close,
	usbconn_ftdi_read,
	usbconn_ftdi_write
};

usbconn_cable_t usbconn_ft2232_mpsse_CableID2= {
  "CableID2",         /* cable name */
  "CableID2",         /* string pattern, not used */
  "ftdi-mpsse",       /* default usbconn driver */
  0x0403,             /* VID */
  0x6010              /* PID */
};

static usbconn_t *ft2232_device;



/// ----------------------------------------------------------------------------------------------
/// libftdi wrappers for debugging purposes.
/// ----------------------------------------------------------------------------------------------

void print_buffer(unsigned char *buf, int size) {
	int i=0;
	for(i=0; i<size; i++)
		printf("[MYDBG]\tBUFFER[%d] = %02x\n", i, buf[i]);

}

int my_ftdi_write_data(struct ftdi_context *ftdi, unsigned char *buf, int size) {
	debug("[MYDBG] ftdi_write_data(ftdi, buf=BUFFER[%d], size=%d);\n", size, size);
	if(debug > 1) print_buffer(buf, size);
	return ftdi_write_data(ftdi, buf, size);
}

char *my_ftdi_get_error_string (struct ftdi_context *ftdi) {
	debug("[MYDBG] ftdi_get_error_string(ftdi);\n");
	return ftdi_get_error_string (ftdi);
}

int my_ftdi_read_data(struct ftdi_context *ftdi, unsigned char *buf, int size) {
	int ret = 0;
	debug("[MYDBG] ftdi_read_data(ftdi, buf=BUFFER[%d], size=%d);\n", size, size);
	ret = ftdi_read_data(ftdi, buf, size);
	if(debug) print_buffer(buf, size);
	return ret;
}

int my_ftdi_usb_open_desc(struct ftdi_context *ftdi, int vendor, int product, const char* description, const char* serial) {
	debug("[MYDBG] ftdi_usb_open_desc(ftdi, vendor=%d, product=%d, description=DESCRIPTION, serial=SERIAL);\n", vendor, product);
	return ftdi_usb_open_desc(ftdi, vendor, product, description, serial);
}

void my_ftdi_deinit(struct ftdi_context *ftdi) {
	debug("[MYDBG] ftdi_deinit(ftdi);\n");
	ftdi_deinit(ftdi);
}

int my_ftdi_usb_purge_buffers(struct ftdi_context *ftdi) {
	debug("[MYDBG] ftdi_usb_purge_buffers(ftdi);\n");
	return ftdi_usb_purge_buffers(ftdi);
}

int my_ftdi_usb_purge_rx_buffer(struct ftdi_context *ftdi) {
	debug("[MYDBG] ftdi_usb_purge_rx_buffer(ftdi);\n");
	return ftdi_usb_purge_rx_buffer(ftdi);
}

int my_ftdi_usb_purge_tx_buffer(struct ftdi_context *ftdi) {
	debug("[MYDBG] ftdi_usb_purge_tx_buffer(ftdi);\n");
	return ftdi_usb_purge_tx_buffer(ftdi);
}

int my_ftdi_usb_reset(struct ftdi_context *ftdi) {
	debug("[MYDBG] ftdi_usb_reset(ftdi);\n");
	return ftdi_usb_reset(ftdi);
}

int my_ftdi_set_latency_timer(struct ftdi_context *ftdi, unsigned char latency) {
	debug("[MYDBG] ftdi_set_latency_timer(ftdi, latency=0x%02x);\n", latency);
	return ftdi_set_latency_timer(ftdi, latency);
}

int my_ftdi_set_baudrate(struct ftdi_context *ftdi, int baudrate) {
	debug("[MYDBG] ftdi_set_baudrate(ftdi, baudrate=%d);\n", baudrate);
	return ftdi_set_baudrate(ftdi, baudrate);
}

int my_ftdi_read_data_set_chunksize(struct ftdi_context *ftdi, unsigned int chunksize) {
	debug("[MYDBG] ftdi_read_data_set_chunksize(ftdi, chunksize=%u);\n", chunksize);
	return ftdi_read_data_set_chunksize(ftdi, chunksize);
}

int my_ftdi_write_data_set_chunksize(struct ftdi_context *ftdi, unsigned int chunksize) {
	debug("[MYDBG] ftdi_write_data_set_chunksize(ftdi, chunksize=%u);\n", chunksize);
	return ftdi_write_data_set_chunksize(ftdi, chunksize);
}

int my_ftdi_set_event_char(struct ftdi_context *ftdi, unsigned char eventch, unsigned char enable) {
	debug("[MYDBG] ftdi_set_event_char(ftdi, eventch=0x%02x, enable=0x%02x);\n", eventch, enable);
	return ftdi_set_event_char(ftdi, eventch, enable);
}

int my_ftdi_set_error_char(struct ftdi_context *ftdi, unsigned char errorch, unsigned char enable) {
	debug("[MYDBG] ftdi_set_error_char(ftdi, errorch=0x%02x, enable=0x%02x);\n", errorch, enable);
	return ftdi_set_error_char(ftdi, errorch, enable);
}

int my_ftdi_set_bitmode(struct ftdi_context *ftdi, unsigned char bitmask, unsigned char mode) {
	debug("[MYDBG] ftdi_set_bitmode(ftdi, bitmask=0x%02x, mode=0x%02x);\n", bitmask, mode);
	return ftdi_set_bitmode(ftdi, bitmask, mode);
}

int my_ftdi_usb_close(struct ftdi_context *ftdi) {
	debug("[MYDBG] ftdi_usb_close(ftdi);\n");
	return ftdi_usb_close(ftdi);
}



/// ----------------------------------------------------------------------------------------------
/// USBconn FTDI MPSSE subsystem
/// ----------------------------------------------------------------------------------------------


static int usbconn_ftdi_common_open(usbconn_t *conn) {
	ftdi_param_t *params = conn->params;
	struct ftdi_context * ftdic = params->ftdic;
	int error;

	printf("Initializing USB device\n");
  
	if ((error = my_ftdi_usb_open_desc(ftdic, conn->cable->vid, conn->cable->pid, NULL, NULL))) {
		if      (error == -1) printf("usb_find_busses() failed\n");
		else if (error == -2) printf("usb_find_devices() failed\n");
		else if (error == -3) printf("usb device not found with VID 0x%0X, PID 0x%0X\n", conn->cable->vid, conn->cable->pid);
		else if (error == -4) printf("unable to open device\n");
		else if (error == -5) printf("unable to claim device\n");
		else if (error == -6) printf("reset failed\n");
		else if (error == -7) printf("set baudrate failed\n");
		else if (error == -8) printf("get product description failed\n");
		else if (error == -9) printf("get serial number failed\n");
		else if (error == -10) printf("unable to close device\n");

		my_ftdi_deinit(ftdic);
		ftdic = NULL;

		printf("Can't open FTDI usb device\n"); 
		return(-1);
	}

	return 0;
}

static int seq_purge(struct ftdi_context *ftdic, int purge_rx, int purge_tx) {
	int r = 0;
	unsigned char buf;

	if ((r = my_ftdi_usb_purge_buffers( ftdic )) < 0)
		printf("my_ftdi_usb_purge_buffers() failed\n");
	if (r >= 0) if ((r = my_ftdi_read_data( ftdic, &buf, 1 )) < 0)
		printf("my_ftdi_read_data() failed\n");

	return r < 0 ? -1 : 0;
}

static int seq_reset(struct ftdi_context *ftdic) {

	if (my_ftdi_usb_reset( ftdic ) < 0) {
		printf("my_ftdi_usb_reset() failed\n");
		return -1;
	}

	if(seq_purge(ftdic, 1, 1) < 0)
		return -1;

	return 0;
}

static int usbconn_ftdi_flush( ftdi_param_t *params )
	{
	int xferred;
	int recvd = 0;

	if (!params->ftdic)
		return -1;

	if (params->send_buffered == 0)
		return 0;

	if ((xferred = my_ftdi_write_data( params->ftdic, params->send_buf, params->send_buffered )) < 0)
		printf("my_ftdi_write_data() failed\n");

	if (xferred < params->send_buffered) {
		printf("Written fewer bytes than requested.\n");
		return -1;
	}

	params->send_buffered = 0;

	/* now read all scheduled receive bytes */
	if (params->to_recv) {
		if (params->recv_write_idx + params->to_recv > params->recv_buf_len) {
			/* extend receive buffer */
			params->recv_buf_len = params->recv_write_idx + params->to_recv;
			if (params->recv_buf)
				params->recv_buf = (uint8_t *)realloc( params->recv_buf, params->recv_buf_len );
		}

		if (!params->recv_buf) {
			printf("Receive buffer does not exist.\n");
			return -1;
		}

		while (recvd == 0)
			if ((recvd = my_ftdi_read_data( params->ftdic, &(params->recv_buf[params->recv_write_idx]), params->to_recv )) < 0)
				printf("Error from my_ftdi_read_data()\n");

		if (recvd < params->to_recv)
			printf("Received less bytes than requested.\n");

		params->to_recv -= recvd;
		params->recv_write_idx += recvd;
	}

	debug("[MYDBG] FLUSHING xferred=%u\n", xferred);
	return xferred < 0 ? -1 : xferred;
}

static int usbconn_ftdi_read( usbconn_t *conn, uint8_t *buf, int len ) {
	ftdi_param_t *params = conn->params;
	int cpy_len;
	int recvd = 0;

	if (!params->ftdic)
		return -1;

	/* flush send buffer to get all scheduled receive bytes */
	if (usbconn_ftdi_flush( params ) < 0)
		return -1;

	if (len == 0)
		return 0;

	/* check for number of remaining bytes in receive buffer */
	cpy_len = params->recv_write_idx - params->recv_read_idx;
	if (cpy_len > len)
		cpy_len = len;
	len -= cpy_len;

	if (cpy_len > 0) {
		/* get data from the receive buffer */
		memcpy( buf, &(params->recv_buf[params->recv_read_idx]), cpy_len );
		params->recv_read_idx += cpy_len;
		if (params->recv_read_idx == params->recv_write_idx)
			params->recv_read_idx = params->recv_write_idx = 0;
	}

	if (len > 0) {
		/* need to get more data directly from the device */
		while (recvd == 0)
			if ((recvd = my_ftdi_read_data( params->ftdic, &(buf[cpy_len]), len )) < 0)
				printf("Error from my_ftdi_read_data()\n");
	}	
	debug("[MYDBG] READ cpy_len=%u ; len=%u\n", cpy_len, len);
	return recvd < 0 ? -1 : cpy_len + len;
}

static int usbconn_ftdi_write( usbconn_t *conn, uint8_t *buf, int len, int recv ) {

	ftdi_param_t *params = conn->params;
	int xferred = 0;

	if (!params->ftdic)
		return -1;

	/* this write function will try to buffer write data
	   buffering will be ceased and a flush triggered in two cases. */

	/* Case A: max number of scheduled receive bytes will be exceeded
	   with this write
	   Case B: max number of scheduled send bytes has been reached */
	if ((params->to_recv + recv > FTDI_MAXRECV) || ((params->send_buffered > FTDX_MAXSEND) && (params->to_recv == 0)))
		xferred = usbconn_ftdi_flush(params);

	if (xferred < 0)
		return -1;

	/* now buffer this write */
	if (params->send_buffered + len > params->send_buf_len) {
		params->send_buf_len = params->send_buffered + len;
		if (params->send_buf)
			params->send_buf = (uint8_t *)realloc( params->send_buf, params->send_buf_len);
	}

	if (params->send_buf) {
		memcpy( &(params->send_buf[params->send_buffered]), buf, len );
		params->send_buffered += len;
		if (recv > 0)
			params->to_recv += recv;

		if (recv < 0) {
			/* immediate write requested, so flush the buffered data */
			xferred = usbconn_ftdi_flush( params );
		}

		debug("[MYDBG] WRITE inmediate=%s ; xferred=%u ; len=%u\n", ((recv < 0) ? "TRUE" : "FALSE"), xferred, len);
		return xferred < 0 ? -1 : len;
	}
	else {
		printf("Send buffer does not exist.\n");
		return -1;
	}
}

static int usbconn_ftdi_mpsse_open( usbconn_t *conn ) {
	ftdi_param_t *params = conn->params;
	struct ftdi_context *ftdic = params->ftdic;
	
	int r = 0;

	if (usbconn_ftdi_common_open(conn) < 0) {
		printf("Connection failed\n");
		return -1;
	}

	/* This sequence might seem weird and containing superfluous stuff.
	   However, it's built after the description of JTAG_InitDevice
	   Ref. FTCJTAGPG10.pdf
	   Intermittent problems will occur when certain steps are skipped. */

	r = seq_reset( ftdic );
	if (r >= 0)
		r = seq_purge( ftdic, 1, 0 );

	if (r >= 0)
		if ((r = my_ftdi_write_data_set_chunksize( ftdic, FTDX_MAXSEND_MPSSE )) < 0)
			puts( my_ftdi_get_error_string( ftdic ) );

	if (r >= 0)
		if ((r = my_ftdi_read_data_set_chunksize( ftdic, FTDX_MAXSEND_MPSSE )) < 0)
			puts( my_ftdi_get_error_string( ftdic ) );

	/* set a reasonable latency timer value
	   if this value is too low then the chip will send intermediate result data
	   in short packets (suboptimal performance) */
	if (r >= 0)
		if ((r = my_ftdi_set_latency_timer( ftdic, 16 )) < 0)
			printf("my_ftdi_set_latency_timer() failed\n");

	if (r >= 0)
		if ((r = my_ftdi_set_bitmode( ftdic, 0x0b, BITMODE_MPSSE )) < 0)
			printf("my_ftdi_set_bitmode() failed\n");

	if (r >= 0)
		if ((r = my_ftdi_usb_reset( ftdic )) < 0)
			printf("my_ftdi_usb_reset() failed\n");

	if (r >= 0) 
		r = seq_purge( ftdic, 1, 0 );

	/* set TCK Divisor */
	if (r >= 0) {
		uint8_t buf[3] = {TCK_DIVISOR, 0x00, 0x00};
		r = usbconn_ftdi_write( conn, buf, 3, 0 );
	}

	/* switch off loopback */
	if (r >= 0) {
		uint8_t buf[1] = {LOOPBACK_END};
		r = usbconn_ftdi_write( conn, buf, 1, 0 );
	}

	if (r >= 0)
		r = usbconn_ftdi_read( conn, NULL, 0 );

	if (r >= 0)
		if ((r = my_ftdi_usb_reset( ftdic )) < 0)
			printf("my_ftdi_usb_reset() failed\n");

	if (r >= 0)
		r = seq_purge( ftdic, 1, 0 );

	if (r < 0) {
		ftdi_usb_close( ftdic );
		ftdi_deinit( ftdic );
		/* mark ftdi layer as not initialized */
		params->ftdic = NULL;
	}

	return r < 0 ? -1 : 0;
}

static int usbconn_ftdi_close(usbconn_t *conn) {
	ftdi_param_t *params = conn->params;

	if (params->ftdic) {
		my_ftdi_usb_close(params->ftdic);
		my_ftdi_deinit(params->ftdic);
		params->ftdic = NULL;
	}

	return 0;
}

static void usbconn_ftdi_free( usbconn_t *conn )
{
  ftdi_param_t *params = conn->params;

  if (params->send_buf) free( params->send_buf );
  if (params->recv_buf) free( params->recv_buf );
  if (params->ftdic)    free( params->ftdic );
  if (params->serial)   free( params->serial );

  free( conn->params );
  free( conn );
}

usbconn_t * usbconn_ftdi_connect() {

	usbconn_t *conn            = malloc( sizeof( usbconn_t ) );
	ftdi_param_t *params       = malloc( sizeof( ftdi_param_t ) );
	struct ftdi_context *ftdic = malloc( sizeof( struct ftdi_context ) );

	if (params) {
		params->send_buf_len   = FTDX_MAXSEND;
		params->send_buffered  = 0;
		params->send_buf       = (uint8_t *) malloc( params->send_buf_len );
		params->recv_buf_len   = FTDI_MAXRECV;
		params->to_recv        = 0;
		params->recv_write_idx = 0;
		params->recv_read_idx  = 0;
		params->recv_buf       = (uint8_t *) malloc( params->recv_buf_len );
	}

	if (!conn || !params || !ftdic || !params->send_buf || !params->recv_buf) {
		printf("Can't allocate memory for ftdi context structures\n");

		if (conn) free( conn );
		if (params) free( params );
		if (ftdic) free( ftdic );
		if (params->send_buf) free( params->send_buf );
		if (params->recv_buf) free( params->recv_buf );
		return NULL;
	}

	conn->driver = &usbconn_ft2232_mpsse_driver;
	conn->cable  = &usbconn_ft2232_mpsse_CableID2;

	ftdi_init( ftdic );
	params->ftdic  = ftdic;
	params->pid    = conn->cable->pid;
	params->vid    = conn->cable->vid;
	params->serial = NULL;

	conn->params = params;

	printf("Structs successfully initialized\n");

	/* do a test open with the specified cable paramters,
	   alternatively we could use libusb to detect the presence of the
	   specified USB device 	*/
	if (usbconn_ftdi_common_open(conn) != 0) {
		printf("Connection failed\n");
		usbconn_ftdi_free(conn);
		printf("Freeing structures.\n");
		return NULL;
	}

	my_ftdi_usb_close( ftdic );

	printf("Connected to libftdi driver.\n");

	return conn;
}



/// ----------------------------------------------------------------------------------------------
/// High level functions to generate Tx/Rx commands
/// ----------------------------------------------------------------------------------------------

int cable_ft2232_write_bytes(usbconn_t *conn, unsigned char *buf, int len, int postread) {

	int cur_command_size;
	int max_command_size;
	int cur_chunk_len;
	int recv;
	int xferred;
	int i;
	unsigned char *mybuf;

	if(len == 0)
		return 0;
	debug("write_bytes(length=%d, postread=%s)\n", len, ((postread > 0) ? "TRUE" : "FALSE"));
	recv = 0;
	max_command_size = min(len, 65536)+3;
	mybuf = (unsigned char *) malloc( max_command_size );

	/// Command OPCODE: write bytes
	mybuf[0] = MPSSE_DO_WRITE | MPSSE_LSB | MPSSE_WRITE_NEG;
	if(postread) // if postread is enabled it will buffer incoming bytes
		mybuf[0] = mybuf[0] | MPSSE_DO_READ;

	// We divide the transmitting stream of bytes in chunks with a maximun length of 65536 bytes each.
	while(len > 0) {
		cur_chunk_len = min(len, 65536);
		len = len - cur_chunk_len;
		cur_command_size = cur_chunk_len + 3;

		/// Low and High bytes of the length field
		mybuf[1] = (unsigned char) ( cur_chunk_len - 1);
		mybuf[2] = (unsigned char) ((cur_chunk_len - 1) >> 8);

		debug("\tOPCODE:  0x%x\n", mybuf[0]);
		debug("\tLENGTL:  0x%02x\n", mybuf[1]);
		debug("\tLENGTH:  0x%02x\n", mybuf[2]);

		/// The rest of the command is filled with the bytes that will be transferred
		memcpy(&(mybuf[3]), buf, cur_chunk_len );
		buf = buf + cur_chunk_len;
		for(i = 0; i< cur_chunk_len; i++)
			if(debug>1) debug("\tBYTE%3d: 0x%02x\n", i, mybuf[3+i]);

		/// Finally we can ransmit the command
		xferred = usbconn_ftdi_write( conn, mybuf, cur_command_size, (postread ? cur_chunk_len : 0) );
		if(xferred != cur_command_size)
			return -1;

		// If OK, the update the number of incoming bytes that are being buffered for a posterior read
		if(postread)
			recv = recv + cur_chunk_len;
	}
	debug("\tPOSTREAD: %u bytes\n", recv);

	// Returns the number of buffered incoming bytes
	return recv;
}

int cable_ft2232_write_bits(usbconn_t *conn, unsigned char *buf, int len, int postread, int with_tms)
{
	int max_command_size;
	int max_chunk_len;
	int cur_chunk_len;
	int recv;
	int xferred;
	int i;
	unsigned char *mybuf;

	if(len == 0)
		return 0;

	max_command_size = 3;
	mybuf = (unsigned char *) malloc( max_command_size );

	if(!with_tms) {
		/// Command OPCODE: write bits (can write up to 8 bits in a single command)
		max_chunk_len = 8;
		mybuf[0] = MPSSE_DO_WRITE | MPSSE_LSB | MPSSE_WRITE_NEG | MPSSE_BITMODE;
	} 
	else {
		/// Command OPCODE: 0x4B write bit with tms (can write up to 1 bits in a single command)
		max_chunk_len = 1;
		mybuf[0] = MPSSE_WRITE_TMS|MPSSE_LSB|MPSSE_BITMODE|MPSSE_WRITE_NEG;
	}

	if(postread) // (OPCODE += 0x20) if postread is enabled it will buffer incoming bits
		mybuf[0] = mybuf[0] | MPSSE_DO_READ;

	// We divide the transmitting stream of bytes in chunks with a maximun length of max_chunk_len bits each.
	i=0;
	recv = 0;
	while(len > 0) {
		cur_chunk_len = min(len, max_chunk_len);
		len = len - cur_chunk_len;

		/// Bits length field
		mybuf[1] = (unsigned char) ( cur_chunk_len - 1);

		debug("\tOPCODE:  0x%x\n", mybuf[0]);
		debug("\tLENGTH:  0x%02x\n", mybuf[1]);

		if(!with_tms) {
			/// The last byte of the command is filled with the bits that will be transferred
			debug("\tDATA[%d]  0x%02x\n", (i/8), buf[i/8]);
			mybuf[2] = buf[i/8];
			i=i+8;
		}
		else {
			//TODO: seleccionar el bit a transmitir
			mybuf[2] = 0x01 | ((buf[(i/8)] >> (i%8)) << 7);
			i++;
		}

		debug("\tBYTE%3d: 0x%02x\n", i, mybuf[2]);

		/// Finally we can transmmit the command
		xferred = usbconn_ftdi_write( conn, mybuf, max_command_size, (postread ? 1 : 0) );
		if(xferred != max_command_size)
			return -1;

		// If OK, the update the number of incoming bytes that are being buffered for a posterior read
		if(postread) 
			recv = recv + 1;
	}
	debug("\tPOSTREAD: %u bytes\n", recv);

	return recv;
}

int cable_ft2232_read_packed_bits(usbconn_t *conn, uint8_t *buf, int packet_len, int bits_per_packet, int offset)
{
	unsigned char *mybuf;
	unsigned char dst_mask;
	unsigned char src_mask;
	int row_offset;
	int dst_row;
	int dst_col;
	int src_row;
	int src_col;
	int i;
	int r;

	if(packet_len == 0 || bits_per_packet == 0)
		return 0;

	mybuf = (unsigned char *) malloc( packet_len );
	if((r=usbconn_ftdi_read( conn, mybuf, packet_len )) < 0) {
		debug("Read failed\n");
		return -1;
	}

	if(bits_per_packet < 8) {
		for(i=0; i < packet_len; i++){ // rotate bits to the left side
//			debug("[MYDBG] unaligned bits[%d]=%02x\n", i, mybuf[i]);			
			mybuf[i] = (mybuf[i] >> (8-bits_per_packet));
//			debug("[MYDBG]   aligned bits[%d]=%02x\n", i, mybuf[i]);
		}
		for(i=offset; i < (packet_len*bits_per_packet+offset); i++) {
			dst_row = i / 8;
			dst_col = i % 8;
			src_row = (i-offset) / bits_per_packet;
			src_col = (i-offset) % bits_per_packet;
			dst_mask = ~(1 << dst_col);
			src_mask = (1 << src_col);
//			debug("[MYDBG] i=%4d dst[%3d][%3d] dst_mask=%02x dst_val=%02x dst_masked=%02x\n", i, dst_row, dst_col, dst_mask, buf[dst_row], (buf[dst_row] & dst_mask));
//			debug("[MYDBG] i=%4d src[%3d][%3d] src_mask=%02x src_val=%02x src_masked=%02x\n", i, src_row, src_col, src_mask, mybuf[src_row], (mybuf[src_row] & src_mask));
			if(dst_col >= src_col)
				buf[dst_row] = (buf[dst_row] & dst_mask) | ((mybuf[src_row] & src_mask) << (dst_col - src_col));
			else
				buf[dst_row] = (buf[dst_row] & dst_mask) | ((mybuf[src_row] & src_mask) >> (dst_col - src_col));
		}
			
	} 
	else if(bits_per_packet == 8){
		row_offset = offset / 8;
//		debug("[MYDBG] Row offset=%d\n", row_offset);
		memcpy( &(buf[row_offset]), mybuf, packet_len);
	}
	else {
		return -1;
	}

//	debug("read_bits()-> %x\n", *buf);
	return ((r < 1) ? -1 : 0);
}

int cable_ft2232_write_stream(usbconn_t *conn, unsigned char *buf, int len, int postread, int with_tms) {
	int len_bytes;
	int len_bits;
	int len_tms_bits;
	unsigned char mybuf;

	len_tms_bits = ((with_tms) ? 1 : 0);
	len_bytes = ((len -len_tms_bits) / 8);
	len_bits  = ((len -len_tms_bits) % 8);

	debug("[MYDBG] cable_ft2232_write_stream(len=%d postread=%d tms=%d) = %d bytes %dbits %dtms_bits\n", len, postread, with_tms, len_bytes, len_bits, len_tms_bits);

	if(len_bytes > 0)
		cable_ft2232_write_bytes(conn, buf, len_bytes, postread);

	if(len_bits > 0)
		cable_ft2232_write_bits(conn, &(buf[len_bytes]), len_bits, postread, 0);

	if(len_tms_bits > 0) {
		mybuf = (buf[len_bytes] >> len_bits);
		cable_ft2232_write_bits(conn, &mybuf, 1, postread, 1);
	}

	return 0;
}

int cable_ft2232_read_stream(usbconn_t *conn, unsigned char *buf, int len, int with_tms) {
	int len_bytes;
	int len_bits;
	int len_tms_bits;

	len_tms_bits = ((with_tms) ? 1 : 0);
	len_bytes = ((len -len_tms_bits) / 8);
	len_bits  = ((len -len_tms_bits) % 8);

	debug("[MYDBG] cable_ft2232_read_stream(len=%d tms=%d) = %d bytes %dbits %dtms_bits\n", len, with_tms, len_bytes, len_bits, len_tms_bits);

	if(len_bytes > 0)
		cable_ft2232_read_packed_bits(conn, buf, len_bytes, 8, 0);

	if(len_bits > 0)
		cable_ft2232_read_packed_bits(conn, buf, 1, len_bits, (len_bytes * 8));

	if(len_tms_bits > 0)
		cable_ft2232_read_packed_bits(conn, buf, 1, 1, (len_bits + (len_bytes * 8)));

	return 0;
}



/// ----------------------------------------------------------------------------------------------
/// Advanced Jtag debugger driver interface.
/// ----------------------------------------------------------------------------------------------

jtag_cable_t *cable_ftdi_get_driver(void)
{
  return &ft2232_cable_driver; 
}

int cable_ftdi_init() {
	int err = APP_ERR_NONE;
	int res = 0;
	unsigned char  *buf = malloc(10);

	ft2232_device = usbconn_ftdi_connect();

	if((res = usbconn_ftdi_mpsse_open(ft2232_device)) != 0)
		err |= APP_ERR_USB;
	printf("Open MPSSE mode returned: %s\n", ((res != 0) ? "FAIL" : "OK") );

	ftdi_param_t *params = ft2232_device->params;
	//struct ftdi_context * ftdic = params->ftdic;

	buf[0]= SET_BITS_LOW;  // Set value & direction of ADBUS lines
	buf[1]= 0x00;          // values
	buf[2]= 0x1b;          // direction (1 == output)
	buf[3]= TCK_DIVISOR;
	buf[4]= 0x01;
	buf[5]= 0x00;
        buf[6]= SET_BITS_HIGH;
	buf[7]= ~0x04;
	buf[8]= 0x04;
	buf[9]= SEND_IMMEDIATE;
	if(usbconn_ftdi_write( ft2232_device , buf, 10, 0) != 10) {
		err |= APP_ERR_USB;
		printf("Initial write failed\n");
	}

	usbconn_ftdi_flush( params );

	return err;
}

int cable_ftdi_close() {
	usbconn_ftdi_close(ft2232_device);
	usbconn_ftdi_free(ft2232_device);
	
	return APP_ERR_NONE;
}

int cable_ftdi_flush() {
	ftdi_param_t *params = ft2232_device->params;
	usbconn_ftdi_flush( params );

	return APP_ERR_NONE;
}

int cable_ftdi_write_bit(uint8_t packet) {
	int err = APP_ERR_NONE;
	unsigned char buf;
	int tms;

	buf = ((packet & TDO) ? 0x01 : 0x00);
	tms = ((packet & TMS) ? 1 : 0);

	if(cable_ft2232_write_stream(ft2232_device, &buf, 1, 0, tms) < 0)
		err |= APP_ERR_COMM;

	cable_ftdi_flush();

	return err;
	
}

int cable_ftdi_read_write_bit(uint8_t packet_out, uint8_t *bit_in) {

	int err = APP_ERR_NONE;
	unsigned char buf;
	int tms;

	buf = ((packet_out & TDO) ? 0x01 : 0x00);
	tms = ((packet_out & TMS) ? 1 : 0);

	if(cable_ft2232_write_stream(ft2232_device, &buf, 1, 1, tms) < 0)
		err = APP_ERR_COMM;

	if(cable_ft2232_read_stream(ft2232_device, ((unsigned char *)bit_in), 1, tms) < 0)
		err = APP_ERR_COMM;
	
	return err;
}

int cable_ftdi_write_stream(uint32_t *stream, int len_bits, int set_last_bit) {
	int err = APP_ERR_NONE;

	if(cable_ft2232_write_stream(ft2232_device, ((unsigned char *)stream), len_bits, 0, set_last_bit) < 0)
		err |= APP_ERR_COMM;

	cable_ftdi_flush();

	return err;
}

int cable_ftdi_read_stream(uint32_t *outstream, uint32_t *instream, int len_bits, int set_last_bit) {
	int err = APP_ERR_NONE;
	if(cable_ft2232_write_stream(ft2232_device, ((unsigned char *)outstream), len_bits, 1, set_last_bit) < 0)
		err |= APP_ERR_COMM;
	if(cable_ft2232_read_stream(ft2232_device, ((unsigned char *)instream), len_bits, set_last_bit) < 0)
		err |= APP_ERR_COMM;

	return err;
}

int cable_ftdi_opt(int c, char *str) {
  uint32_t newvid;
  uint32_t newpid;

  switch(c) {
  case 'p':
    if(!sscanf(str, "%x", &newpid)) {
      fprintf(stderr, "p parameter must have a hex number as parameter\n");
      return APP_ERR_BAD_PARAM;
    }
    else {
      usbconn_ft2232_mpsse_CableID2.pid = newpid;
    }
    break;

  case 'v':
    if(!sscanf(str, "%x", &newvid)) {
      fprintf(stderr, "v parameter must have a hex number as parameter\n");
      return APP_ERR_BAD_PARAM;
    }
    else {
      usbconn_ft2232_mpsse_CableID2.vid = newvid;
    }
    break;

  default:
    fprintf(stderr, "Unknown parameter '%c'\n", c);
    return APP_ERR_BAD_PARAM;
  }
  return APP_ERR_NONE;
}

/// ----------------------------------------------------------------------------------------------

