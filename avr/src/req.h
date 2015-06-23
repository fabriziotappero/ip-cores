#ifndef _REQ_H_
#define _REQ_H_
#include <stdint.h>
#include "device.h"

/* Will make callback on this function with idev->priv as arg. */
typedef void req_fn_t(void *);

struct req {
	struct igordev *dev; /* What device we wish to communicate with. */
	uint8_t type;	     /* What operation do we wish to perform. */
/* Request types. */
#define REQ_TYPE_READ	1
#define REQ_TYPE_WRITE	2
#define REQ_TYPE_FUNC	3
#define REQ_TYPE_FLUSH  4
	uint8_t flags;       /* Flags for request. */
/* Request flags. */
#define REQ_CALLBACK	0x01
	uint32_t devnum;     /* What device we are performing the request on. */
	req_fn_t *func;      /* Perform the running of this function. */
};

#define MAXREQ 64

struct rqueue {
	struct req queue[MAXREQ];
	uint8_t off_read;
	uint8_t off_write;
	uint8_t rcount;
	uint8_t wcount;
	int8_t status;
/* Status codes. **/
#define RQUEUE_STATUS_FULL	0x1
#define RQUEUE_STATUS_EMPTY	0x2
};

#define RQUEUE_FULL(rq) ((rq)->status & RQUEUE_STATUS_FULL)
#define RQUEUE_EMPTY(rq) ((rq)->status & RQUEUE_STATUS_EMPTY)
void		 rqueue_init(struct rqueue *);
uint8_t		 rqueue_used(struct rqueue *);
uint8_t		 rqueue_unused(struct rqueue *);
struct req	*req_peak(struct rqueue *);
int8_t		 req_alloc(struct rqueue *, struct igordev *, uint8_t, uint8_t,
		    uint32_t, req_fn_t *);
int8_t		 req_free(struct rqueue *);
#endif /* !_REQ_H_ */
