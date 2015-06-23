
#ifndef _CABLE_USBBLASTER_H_
#define _CABLE_USBBLASTER_H_

#include <stdint.h>
#include "cable_common.h"

jtag_cable_t *cable_usbblaster_get_driver(void);
int cable_usbblaster_init();
int cable_usbblaster_out(uint8_t value);
int cable_usbblaster_inout(uint8_t value, uint8_t *in_bit);
int cable_usbblaster_write_stream(uint32_t *stream, int len_bits, int set_last_bit);
int cable_usbblaster_read_stream(uint32_t *outstream, uint32_t *instream, int len_bits, int set_last_bit);
int cable_usbblaster_opt(int c, char *str);
void cable_usbblaster_wait();

#endif
