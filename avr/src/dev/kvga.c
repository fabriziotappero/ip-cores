#include <avr/io.h>
#include <avr/interrupt.h>
#include <stdint.h>
#include <global.h>
#include <device.h>
#include <dispatch.h>
#include <stdlib.h>
#include <string.h>

#define BAUD 9600
#define MUBRR ((FOSC/16/BAUD)-1)


static struct {
	struct buf readbuf;
	struct buf writebuf;
} kvga_data;

/* Commands to KVGA. */
#define ECHO_ON "\033[12h"
#define ECHO_OFF "\033[12l"

/* Newline, linefeed, carriage return commands. */
#define SET_NEWLINE_MODE "\033[20h"
#define SET_LINEFEED_MODE "\033[20l"
#define ENABLE_AUTO_LF "\033[>8h"
#define DISABLE_AUTO_LF "\033[>8l"
#define ENABLE_AUTO_CR "\033[>9h"
#define DISABLE_AUTO_CR "\033[>9l"

/* Status line commands. */
#define ENABLE_STATUSLINE "\033[?15l"
#define DISABLE_STATUSLINE "\033[?15h"


static igordev_read_fn_t kvga_recv;
static igordev_write_fn_t kvga_send;
static igordev_init_fn_t kvga_init;
static igordev_flush_fn_t kvga_flush;

struct igordev igordev_kvga = {
	.init = kvga_init,
	.read = kvga_recv,
	.write = kvga_send,
	.flush = kvga_flush,
	.read_status = 0,
	.write_status = 0,
	.priv = &kvga_data
};


void
kvga_init(void)
{
	const char *hello = "Hello, world from TVT-KVGA!\r\n";
//	const char *dummyprompt = "igor> ";

	/* Set internal stuff first. */
	buf_init(&kvga_data.readbuf);
	buf_init(&kvga_data.writebuf);
	igordev_kvga.read_status = igordev_kvga.write_status = IDEV_STATUS_OK;

	// Set identification register.
	igordev_kvga.id = (CAN_READ | CAN_WRITE |
	    (DEVTYPE_TERM << DEVTYPE_OFFSET));

	// Disable powersaving
	PRR1 &= ~(1<<PRUSART1);

	// Set tranfser speed
	UBRR1L = (uint8_t)MUBRR;
	UBRR1H = (uint8_t)(MUBRR>>8);

	// Enable reciever, transmitter and interrupts ( Not active until global interrupts are enabled)
	UCSR1B = (1<<RXEN1)|(1<<TXEN1)|(1<<RXCIE1);

	// Set format, stopbits, mode: 8n1
	UCSR1C = (0<<USBS1)|(0<<UPM11)|(0<<UPM10)|(0<<UMSEL11)|(0<<UMSEL10)|(3<<UCSZ10);

	/* Shut down echo by default. */
	buf_write(&kvga_data.writebuf, (uint8_t *)ECHO_OFF, strlen(ECHO_OFF));
	buf_write(&kvga_data.writebuf, (uint8_t *)SET_LINEFEED_MODE,
	    strlen(SET_LINEFEED_MODE));
	buf_write(&kvga_data.writebuf, (uint8_t *)DISABLE_AUTO_CR,
	    strlen(DISABLE_AUTO_CR));
	buf_write(&kvga_data.writebuf, (uint8_t *)ENABLE_STATUSLINE,
	    strlen(ENABLE_STATUSLINE));
	buf_write(&kvga_data.writebuf, (uint8_t *)hello, strlen(hello));
	/* XXX: Just a dummy-prompt until we have the FPGA doing stuff. */
//	buf_write(&kvga_data.writebuf, (uint8_t *)dummyprompt,
//	    strlen(dummyprompt));
	// XXX: Return value not checked.
	dispatch_request_make(&igordev_kvga, REQ_TYPE_FLUSH, 0, 0, NULL);
	/* Auto linefeed */
//	kvga_send((uint8_t *)AUTO_LINEFEED, strlen(AUTO_LINEFEED));
}

// Received a word
ISR(SIG_USART1_RECV)
{
        // Read UDR to reset interrupt flag
	struct buf *rbuf, *wbuf;
	uint8_t data;

	igordev_kvga.read_status = IDEV_STATUS_INTR;
	/* Store in the buffers. */
	data = UDR1;

	/* Swallow newlines. */
	rbuf = &kvga_data.readbuf;
	wbuf = &kvga_data.writebuf;
#define ONESQUARE (MAXBUFLEN / 4)
	/*
	 * If buffer is getting full, don't echo the input to signal that the
	 * user have to wait
	 */
	if (buf_writesleft(rbuf) < (ONESQUARE - 1))
		return;

	buf_write(rbuf, &data, 1);
	/* Echo to output buffer. */
//	buf_write(wbuf, &data, 1);
	// XXX: Return value not checked
//	dispatch_request_make(&igordev_kvga, REQ_TYPE_FLUSH, 0, 0, NULL);
	/* As a way to allow us to test it. */
	// XXX: Return value not checked
//	dispatch_request_make(&igordev_kvga, REQ_TYPE_FUNC, 0, 0,
//	    dispatch_vga_to_usart);

	igordev_kvga.read_status = IDEV_STATUS_OK;
}

/*
 * Read num bytes from addr and place it into data.
 * Data assumed to be a buffer large enough for num bytes.
 * Addr here is ignored, since serial is a streaming device.
 */
uint8_t
kvga_recv(uint64_t addr, uint8_t *data, uint8_t num)
{
	struct buf *buf;
	uint8_t byte;
	uint8_t i;

	buf = &kvga_data.readbuf;
	/* Avoid making larger buffers for now. */
	for (i = 0; i < num; i++) {
		buf_read(buf, &byte, 1);
		if (BUF_EMPTY(buf))
			break;
		*(data + i) = byte;
	}
	return (i);
}

/* 
 k* KVGA transmit, initiates a data transfer by writing to the outputbuffer and
 * starting the transfer of the first character.
 */
uint8_t 
kvga_send(uint64_t addr, uint8_t *data, uint8_t num)
{
	struct buf *buf;
	uint8_t i;
	/* Transmit only once, and the buffer will be flushed anyway. */
	i = 0;
	/* If we're not provided with data, just flush it. */
	if (num > 0 && data != NULL) {
		/* Copy data into write buffer. */
		buf = &kvga_data.writebuf;
		i = buf_write(buf, data, num);
	}
	return (i);
}

/* Send whatever we have in the output buffers. */
void
kvga_flush(void)
{
	struct buf *buf;
	uint8_t data;

	igordev_kvga.write_status = IDEV_STATUS_BUSY;
	buf = &kvga_data.writebuf;
	buf_read(buf, &data, 1);
	while (!BUF_EMPTY(buf)) {
		/* Wait until output buffer is ready. */
		while (!( UCSR1A & (1<<UDRE1)));

		UDR1 = data; /* Initiate transfer. */
		buf_read(buf, &data, 1);
	}
	igordev_kvga.write_status = IDEV_STATUS_OK;
}
