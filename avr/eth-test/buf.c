#include "buf.h"

static uint16_t incptr(uint16_t);
static int8_t	buf_read_byte(struct buf *, uint8_t *);
static int8_t	buf_write_byte(struct buf *, uint8_t);

/* Common routines for buffer handling. */
void
buf_init(struct buf *buf)
{
	uint16_t i;

	for (i = 0; i < MAXBUFLEN; i++)
		buf->data[i] = 0;
	buf->off_read = 0;
	buf->off_write = 0;
	buf->wcount = 0;
	buf->rcount = 0;
	buf->status = BUF_STATUS_EMPTY;
}

static uint16_t
incptr(uint16_t val)
{
	return ((val + 1) % MAXBUFLEN);
}

/* Read from a circular buffer. */
static int8_t
buf_read_byte(struct buf *buf, uint8_t *data)
{
	/* No more data to read. */
	if (buf_readsleft(buf) == 0) {
		buf->status |= BUF_STATUS_EMPTY;
		return (-1);
	}
	buf->status &= ~BUF_STATUS_FULL;
	*data = *(buf->data + buf->off_read);
	buf->off_read = incptr(buf->off_read);
	buf->rcount++;
	return (0);
}

/*
 * Read many bytes from a buffer.
 * Assume data points to a buffer large enough to store num bytes.
 * Returns number of bytes read.
 */
int8_t
buf_read(struct buf *buf, uint8_t *data, uint8_t num)
{
	int8_t i;

	for (i = 0; i < num; i++)
		if (buf_read_byte(buf, (data + i)) != 0)
			break;
	return (i);
}

/* Write to a circular buffer. */
static int8_t
buf_write_byte(struct buf *buf, uint8_t data)
{
	/* See if we have filled the buffer. */
	if (buf_writesleft(buf) == 0) {
		buf->status |= BUF_STATUS_FULL;
		return (-1);
	}
	buf->status &= ~BUF_STATUS_EMPTY;
	*(buf->data + buf->off_write) = data;
	buf->off_write = incptr(buf->off_write);
	buf->wcount++;
	return (0);
}

/*
 * Write many bytes to a buffer.
 * Assume data points to a buffer with num bytes to be sent.
 * Return number of bytes written.
 */
int8_t
buf_write(struct buf *buf, uint8_t *data, uint8_t num)
{
	uint8_t i;

	for (i = 0; i < num; i++)
		if (buf_write_byte(buf, *(data + i)) != 0)
			break;
	return (i);
}

/* Returns number of buffers available for reading. */
uint16_t
buf_readsleft(struct buf *buf)
{
	return (buf->wcount > buf->rcount ?
	    buf->wcount - buf->rcount :
	    buf->rcount - buf->wcount);
}

/* Returns number of buffers available for writing. */
uint16_t
buf_writesleft(struct buf *buf)
{
	return (MAXBUFLEN - buf_readsleft(buf));
}
