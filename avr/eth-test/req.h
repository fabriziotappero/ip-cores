#ifndef _REQ_H_
#define _REQ_H_
#include <stdint.h>
#include "device.h"
/* Type which will be called with the devices idata->priv as argument. */

/* XXX: We can allow an extra arg parameter to struct and req_make if needed. */
typedef void req_fn_t(void *);
struct req {
	struct igordev *dev; /* What device we wish to communicate with. */
	uint8_t type;	     /* What operation do we wish to perform. */
	uint8_t flags;       /* Flags for request. */
	uint8_t taken;	     /* Internal allocation flags. */
	uint32_t devnum;     /* What device we are performing the request on. */
	req_fn_t *func;      /* Perform the running of this function. */
};
/* Request types. */
#define REQ_TYPE_READ	1
#define REQ_TYPE_WRITE	2
#define REQ_TYPE_FUNC	3
#define REQ_TYPE_FLUSH  4
/* Request flags. */
#define REQ_CALLBACK	0x01

/* Max number of requests. Regulates queue length and request pool size. */
#define MAXREQ 64

volatile struct req *req_alloc(void);
void	    req_free(volatile struct req *);
void	    req_init(void);
volatile struct req *req_make(struct igordev *, uint8_t, uint8_t, uint32_t, req_fn_t *);

#endif /* !_REQ_H_ */
