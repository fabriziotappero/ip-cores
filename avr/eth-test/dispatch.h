#ifndef _DISPATCH_H_
#define _DISPATCH_H_
#include "req.h"
struct req;
/* Should be called by a device when a it has an interrupt. */
int8_t dispatch_request_read(uint8_t, uint32_t *);
int8_t dispatch_request_write(uint8_t, uint32_t);
void dispatch_request_notify(volatile struct req *);
/* Request for buffer loopback from vga to usart. */
req_fn_t dispatch_vga_to_usart;
#endif /* !_DISPATCH_H_ */
