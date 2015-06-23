
#ifndef _CABLE_XPC_DLC9_H_
#define _CABLE_XPC_DLC9_H_

#include <stdint.h>
#include "cable_common.h"

int cable_xpcusb_out(uint8_t value);
int cable_xpcusb_inout(uint8_t value, uint8_t *inval);

int cable_xpcusb_write_bit(uint8_t packet_out);
int cable_xpcusb_read_write_bit(uint8_t packet_out, uint8_t *bit_in);

int cable_xpcusb_cpld_write_bit(uint8_t value);
int cable_xpcusb_cpld_readwrite_bit(uint8_t value, uint8_t *inval);

int cable_xpcusb_write_stream(uint32_t *outstream, int len_bits, int set_last_bit);
int cable_xpcusb_readwrite_stream(uint32_t *outstream, uint32_t *instream, int len_bits, int set_last_bit);

int cable_xpcusb_opt(int c, char *str);
jtag_cable_t *cable_xpcusb_get_driver(void);

int cable_xpcusb_init();

#endif
