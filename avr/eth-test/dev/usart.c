#include <avr/io.h>
#include <avr/interrupt.h>
#include <global.h>
#include <stdint.h>
#include <device.h>
#include <dispatch.h>
#include <req.h>
#include <stdlib.h>
#include <string.h>

#define BAUD 9600
#define MUBRR ((FOSC/16/BAUD)-1)

static struct {
	struct buf readbuf;
	struct buf writebuf;
} usart_data;

#define XON	0x11
#define XOFF	0x13
/* Internal flow control. */
uint8_t xflow_local;
/* Internal flow control for transmit. */
uint8_t xflow_state_transmit;
/* External flow control. */
uint8_t xflow_remote;

static int8_t usart_send_data(void);
static igordev_read_fn_t usart_recv;
static igordev_write_fn_t usart_send;
static igordev_init_fn_t init;
static igordev_flush_fn_t usart_flush;

/* XXX: Not completed. */
struct igordev igordev_usart = {
	.init = init,
	.read = usart_recv,
	.write = usart_send,
	.flush = usart_flush,
	.read_status = 0,
	.write_status = 0,
	.priv = &usart_data
};


void init() {
	/* Set internal stuff first. */
	const char *uhello = "Hello, world from USART!\r\n";
	volatile struct req *req;
	buf_init(&usart_data.readbuf);
	buf_init(&usart_data.writebuf);
	igordev_usart.read_status = igordev_usart.write_status = IDEV_STATUS_OK;
	xflow_local = xflow_remote = xflow_state_transmit = XON;
	igordev_usart.id = (CAN_READ | CAN_WRITE |
	    (DEVTYPE_SERIAL << DEVTYPE_OFFSET));

	// Disable powersaving
	PRR0 &= ~(1<<PRUSART0);

	// Set tranfser speed
	UBRR0L = (uint8_t)MUBRR;
	UBRR0H = (uint8_t)(MUBRR>>8);

	// Enable reciever, transmitter and interrupts ( Not active until global interrupts are enabled)
	UCSR0B = (1<<RXEN0)|(1<<TXEN0)|(1<<RXCIE0);
	
	// Set format, stopbits, mode: 8n1
	UCSR0C = (0<<USBS0)|(0<<UPM01)|(0<<UPM00)|(0<<UMSEL01)|(0<<UMSEL00)|(3<<UCSZ00);
	buf_write(&usart_data.writebuf, (uint8_t *)uhello, strlen(uhello));
	req = req_make(&igordev_usart, REQ_TYPE_FLUSH, 0, 0, NULL);
	if (req != NULL)
		dispatch_request_notify(req);
}

// Received a word
ISR(SIG_USART0_RECV) {
        // Read UDR to reset interrupt flag
	struct buf *buf;
	uint8_t data;

	igordev_usart.read_status = IDEV_STATUS_INTR;
	/* Store in the buffers. */
	data = UDR0;
	/* If we received external flow control signal. */
	if (data == XOFF || data == XON) {
		xflow_remote = data;
		igordev_usart.read_status = IDEV_STATUS_OK;
		return;
	}

	buf = &usart_data.readbuf;
#define ONESQUARE (MAXBUFLEN / 4)
	if (buf_writesleft(buf) < (ONESQUARE - 1))
		xflow_local = XOFF;

	buf_write(buf, &data, 1);
	igordev_usart.read_status = IDEV_STATUS_OK;
}

/*
 * Read num bytes from addr and place it into data.
 * Data assumed to be a buffer large enough for num bytes.
 * Addr here is ignored, since serial is a streaming device.
 */
uint8_t
usart_recv(uint64_t addr, uint8_t *data, uint8_t num)
{
	struct buf *buf;
	uint8_t byte;
	uint8_t i;

	buf = &usart_data.readbuf;
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
 * Example of transmit. Currently initiates the write and let the TX interrupt
 * handle the rest.
 */
uint8_t 
usart_send(uint64_t addr, uint8_t *data, uint8_t num)
{
	struct buf *buf;
	uint8_t i = 0;
	/* Transmit only once, and the buffer will be flushed anyway. */
	/* Only output data if we're provided with data. */
	if (num > 0 && data != NULL) {
		/* Copy data into write buffer. */
		buf = &usart_data.writebuf;
		i = buf_write(buf, data, num);
	}
	return (i);
}

/* Send whatever we have in the output buffer. */
static void
usart_flush(void)
{
	struct buf *buf;
	buf = &usart_data.writebuf;

	igordev_usart.write_status = IDEV_STATUS_BUSY;
	/* Flush as long as it is ok. */
	while (!BUF_EMPTY(buf) && usart_send_data() == 0);
	igordev_usart.write_status = IDEV_STATUS_OK;
}

/* Sends the next byte in the buffer. */
static int8_t
usart_send_data(void)
{
	struct buf *buf;
	uint8_t data;

	/* Cannot send data yet. */
	if (xflow_remote == XOFF)
		return (-1);

	buf = &usart_data.writebuf;
	switch (xflow_local) {
	case XON:
		/* If we have few reads left, make sure we can get more. */
		buf_read(buf, &data, 1);
		if (BUF_EMPTY(buf))
			return (-1);
		break;
	case XOFF:
		/* If we have not signalled OK again, do it. */
		if (buf_readsleft(buf) >= (MAXBUFLEN - ONESQUARE) &&
		    xflow_state_transmit == XOFF) {
			data = XON;
			xflow_state_transmit = XON;
			xflow_local = XON;
			break;
		}
		/* If we have not sent the xflow_state signal, do it. */
		if (xflow_state_transmit == XON) {
			data = XOFF;
			xflow_state_transmit = XOFF;
			break;
		}
		return (-1);
	default:
		return (-1);
	}
	while (!(UCSR0A & (1<<UDRE0)));
	UDR0 = data; /* Initiate transfer. */
	return (0);
}

#if 0
void
usart_loopback(void *arg)
{
	struct buf *in;
	uint8_t data[MAXBUFLEN];
	uint8_t i, num;

	cli();
	in = &usart_data.readbuf;
	/* Fill output buffer from input buffer. */
	i = 0;
	num = buf_read(in, data, MAXBUFLEN);
	usart_send(data, num);
	sei();
}
#endif
