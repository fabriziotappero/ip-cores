#include <stdlib.h>
#include "device.h"
#include "global.h"
#include "req.h"
#include "dev/7seg.h"


volatile struct req reqpool[MAXREQ];

static uint8_t req_exists(struct igordev *, uint8_t, uint8_t, uint32_t,
    req_fn_t *);


void req_init() {
    int8_t i;
    volatile struct req* nreq;
    for ( i = 0 ; i < MAXREQ ; i++ ) {
	nreq = &reqpool[i];
	nreq->dev = NULL;
	nreq->type = 0;
	nreq->flags = 0;
	nreq->taken = 0;
	nreq->devnum = 0xFF;
	nreq->func = NULL;
    }
}

volatile struct req *
req_alloc(void)
{
	int8_t i;

	for (i = 0; i < MAXREQ; i++) {
		if (!reqpool[i].taken) {
			reqpool[i].taken = 1;
			return (&reqpool[i]);
		}

	}
	return (NULL);
}

void
req_free(volatile struct req *req)
{
	req->dev = NULL;
	req->type = 0;
	req->flags = 0;
	req->taken = 0;
	req->devnum = 0xFF;
	req->func = NULL;
}

/*
 * Check if a request of the same type have already been allocated.
 */
static uint8_t
req_exists(struct igordev *dev, uint8_t type, uint8_t flags, uint32_t devnum,
    req_fn_t *func)
{
	volatile struct req *nreq;
	int8_t i;

	/* 
	 * XXX: This should perhaps check the queue, but since the taken field
	 * in principle marks the request to be executed, we use that as a
	 * requirement for an active request
	 */
	for (i = 0; i < MAXREQ; i++) {
		if (reqpool[i].taken) {
			nreq = &reqpool[i];
			/* It is the same. */
			if (nreq->dev == dev && nreq->type == type &&
			    nreq->flags == flags && nreq->func == func &&
			    nreq->devnum == devnum) {
				return (1);
				
			}
		}
		display_char(i);
		_delay_ms(50);

	}
	return (0);
}

volatile struct req *
req_make(struct igordev *dev, uint8_t type, uint8_t flags, uint32_t devnum,
    req_fn_t *func)
{
	volatile struct req *nreq;

	/* Do not make a request if it already exists in the pool. */
	if (req_exists(dev, type, flags, devnum, func)) {
		display_char(8);
		_delay_ms(1000);
		return (NULL);
	}
	nreq = req_alloc();
	if ( nreq == NULL) {
		display_char(3);
		_delay_ms(1000);
		return (NULL);
	}
	nreq->dev = dev;
	nreq->type = type;
	nreq->flags = flags;
	nreq->func = func;
	nreq->devnum = devnum;
	return (nreq);
}
