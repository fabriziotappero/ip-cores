
#ifndef _CABLE_COMMON_H_
#define _CABLE_COMMON_H_

#include <stdint.h>


typedef struct {
  const char *name;
  int (*inout_func)(uint8_t, uint8_t *);
  int (*out_func)(uint8_t);
  int (*init_func)();
  int (*opt_func)(int, char *);
  int (*bit_out_func)(uint8_t);
  int (*bit_inout_func)(uint8_t, uint8_t *);
  int (*stream_out_func)(uint32_t *, int, int);
  int (*stream_inout_func)(uint32_t *, uint32_t *, int, int);
  int (*flush_func)();
  const char *opts;
  const char *help;
} jtag_cable_t;

// Defines to use in the 'packet' args of cable_write_bit()
// and cable_read_write_bit().  Note that while TRST is 
// active low for JTAG hardware, here the TRST bit
// should be set when you want the TRST wire active
// (JTAG TAP to be reset).
#define TRST     (0x04)
#define TMS      (0x02)
#define TDO      (0x01)

// These should only be used in the cable_* files.
#define TCLK_BIT (0x01)
#define TRST_BIT (0x02)
#define TDI_BIT  (0x04)
#define TMS_BIT  (0x08)
#define TDO_BIT  (0x20)

// Cable subsystem / init routines
void cable_setup(void);
int cable_select(const char *cable);
int cable_init();
int cable_parse_opt(int c, char *str);
const char *cable_get_args();
void cable_print_help();


// Cable API routines
int cable_write_bit(uint8_t packet);
int cable_read_write_bit(uint8_t packet_out, uint8_t *bit_in);
int cable_write_stream(uint32_t *stream, int len_bits, int set_last_bit);
int cable_read_write_stream(uint32_t *outstream, uint32_t *instream, int len_bits, int set_last_bit);
int cable_flush(void);

// Common functions for lower-level drivers to use as desired
int cable_common_write_bit(uint8_t packet);
int cable_common_read_write_bit(uint8_t packet_out, uint8_t *bit_in);
int cable_common_write_stream(uint32_t *stream, int len_bits, int set_last_bit);
int cable_common_read_stream(uint32_t *outstream, uint32_t *instream, int len_bits, int set_last_bit);

#endif
