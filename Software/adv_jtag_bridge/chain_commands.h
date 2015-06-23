#ifndef _CHAIN_COMMANDS_H_
#define _CHAIN_COMMANDS_H_

#include <stdint.h>

// These two are used by both debug modules
extern int current_chain;
extern int desired_chain;

// These are needed by the advanced debug module
extern int global_DR_prefix_bits;
extern int global_DR_postfix_bits;
extern unsigned char global_xilinx_bscan;

// Discover devices on JTAG chain
int jtag_enumerate_chain(uint32_t **id_array, int *num_devices);
int jtag_get_idcode(uint32_t cmd, uint32_t *idcode);

// Functions to set configuration for the JTAG chain
void config_set_IR_size(int size);
void config_set_IR_prefix_bits(int bits);
void config_set_IR_postfix_bits(int bits);
void config_set_DR_prefix_bits(int bits);
void config_set_DR_postfix_bits(int bits);
void config_set_debug_cmd(unsigned int cmd);
void config_set_alt_vjtag(unsigned char enable);
void config_set_vjtag_cmd_vir(unsigned int cmd);
void config_set_vjtag_cmd_vdr(unsigned int cmd);
void config_set_xilinx_bscan(unsigned char enable);

// Operations on the JTAG TAP
int tap_reset(void);
int tap_enable_debug_module(void);
int tap_set_ir(int ir);
int tap_set_shift_dr(void);
int tap_exit_to_idle(void);

// Functions to Send/receive bitstreams via JTAG
// These functions are aware of other devices in the chain, and may adjust for them.
int jtag_write_bit(uint8_t packet);
int jtag_read_write_bit(uint8_t packet, uint8_t *in_bit);
int jtag_write_stream(uint32_t *out_data, int length_bits, unsigned char set_TMS);
int jtag_read_write_stream(uint32_t *out_data, uint32_t *in_data, int length_bits, 
			   unsigned char adjust, unsigned char set_TMS);

int retry_do(void);
void retry_ok(void);

#endif
