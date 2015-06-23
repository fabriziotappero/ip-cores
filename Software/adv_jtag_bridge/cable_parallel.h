
#ifndef _CABLE_PARALLEL_H_
#define _CABLE_PARALLEL_H_

#include <stdint.h>
#include "cable_common.h"

int cable_parallel_init();
int cable_parallel_opt(int c, char *str);
void cable_parallel_phys_wait();

jtag_cable_t *cable_xpc3_get_driver(void);
int cable_xpc3_inout(uint8_t value, uint8_t *inval);
int cable_xpc3_out(uint8_t value);

jtag_cable_t *cable_bb2_get_driver(void);
int cable_bb2_inout(uint8_t value, uint8_t *inval);
int cable_bb2_out(uint8_t value);

jtag_cable_t *cable_xess_get_driver(void);
int cable_xess_inout(uint8_t value, uint8_t *inval);
int cable_xess_out(uint8_t value);



#endif
