
#ifndef _CABLE_FT245_H_
#define _CABLE_FT245_H_

#include <stdint.h>
#include "cable_common.h"


jtag_cable_t *cable_ft245_get_driver(void);
int cable_ft245_init();
int cable_ft245_out(uint8_t value);
int cable_ft245_inout(uint8_t value, uint8_t *in_bit);
int cable_ft245_write_stream(uint32_t *stream, int len_bits, int set_last_bit);
int cable_ft245_read_stream(uint32_t *outstream, uint32_t *instream, int len_bits, int set_last_bit);
int cable_ft245_opt(int c, char *str);
void cable_ft245_wait();

#endif
