#ifndef _BUF_H_
#define _BUF_H_
#include <stdint.h>

/* Maximum length of buffer. */
#define MAXBUFLEN 200

/* Per device data buffer. */
struct buf {
	uint8_t data[MAXBUFLEN]; /* The data buffer to be used. */
	uint16_t off_read;	 /* The current read pointer in the buffer. */
	uint16_t off_write;	 /* The current write pointer in the buffer. */
	/* These shall be able to store numbers > MAXBUFLEN. */
	uint16_t wcount;
	uint16_t rcount;
#define BUF_STATUS_FULL 	0x1
#define BUF_STATUS_EMPTY	0x2
/* 
 * For users of buf, note that the status flags will be set when the condition
 * is discovered, which means it will signal an empty buffer after the last call
 * filling it up.
 */
	int8_t status;		 /* The status of the buffer. */
};

#define BUF_FULL(b) ((b)->status & BUF_STATUS_FULL)
#define BUF_EMPTY(b) ((b)->status & BUF_STATUS_EMPTY)

void	 buf_init(struct buf *);
uint16_t buf_readsleft(struct buf *);
uint16_t buf_writesleft(struct buf *);
int8_t   buf_write(struct buf *, uint8_t *, uint8_t);
int8_t   buf_read(struct buf *, uint8_t *, uint8_t);

#endif /* !_BUF_H_ */
