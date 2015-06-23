#include <stdlib.h>
#include "device.h"
//#include "global.h"
#include "req.h"
//#include "dev/7seg.h"


#if 0
static uint8_t req_exists(struct igordev *, uint8_t, uint8_t, uint32_t,
    req_fn_t *);
#endif

static uint8_t	increqptr(uint8_t);

/*
 * Initialize an rqueue.
 */
void
rqueue_init(struct rqueue *rq)
{
	struct req *req;
	uint8_t i;

	for (i = 0 ; i < MAXREQ; i++) {
		req = &rq->queue[i];
		req->dev = NULL;
		req->type = 0;
		req->flags = 0;
		req->devnum = 0xFF;
		req->func = NULL;
	}
	rq->off_read = 0;
	rq->off_write = 0;
	rq->wcount = 0;
	rq->rcount = 0;
	rq->status = RQUEUE_STATUS_EMPTY;
}


/* Allocate space for new request, if possible. */
int8_t
req_alloc(struct rqueue *rq, struct igordev *dev, uint8_t type, uint8_t flags,
    uint32_t devnum, req_fn_t *func)
{
	struct req *req;

	if (rqueue_unused(rq) == 0) {
		rq->status |= RQUEUE_STATUS_FULL;
		return (-1);
	}
	req = &rq->queue[rq->off_write];
	req->dev = dev;
	req->type = type;
	req->flags = flags;
	req->devnum = devnum;
	req->func = func;
	rq->off_write = increqptr(rq->off_write);
	rq->wcount++;
	rq->status &= ~RQUEUE_STATUS_EMPTY;
	return (0);
}

/* Just peak at the next element. */
struct req *
req_peak(struct rqueue *rq)
{
	struct req *req;

	if (rqueue_used(rq) == 0) {
		rq->status |= RQUEUE_STATUS_EMPTY;
		return (NULL);
	}
	req = &rq->queue[rq->off_read];
	return (req);
}

/* Free the next element. */
int8_t
req_free(struct rqueue *rq)
{
	struct req *req;
	if (rqueue_used(rq) == 0) {
		rq->status |= RQUEUE_STATUS_EMPTY;
		return (-1);
	}
	/* Initialize struct again. */
	req = &rq->queue[rq->off_read];
	req->dev = NULL;
	req->type = 0;
	req->flags = 0;
	req->devnum = 0xFF;
	req->func = NULL;
	rq->off_read = increqptr(rq->off_read);
	rq->rcount++;
	rq->status &= ~RQUEUE_STATUS_FULL;
	return (0);
}

/* Calculate number of allocations done. */
uint8_t
rqueue_used(struct rqueue *rq)
{
	return (rq->wcount > rq->rcount ?
	    rq->wcount - rq->rcount :
	    rq->rcount - rq->wcount);
}

/* Calculate the number of allocations left */
uint8_t
rqueue_unused(struct rqueue *rq)
{
	return (MAXREQ - rqueue_used(rq));
}

static uint8_t
increqptr(uint8_t val)
{
	return ((val + 1) % MAXREQ);
}

#if 0
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
#endif
