#ifndef _DBG_API_H_
#define _DBG_API_H_

#include <sys/types.h>
#include <stdint.h>



// API for GDB
int dbg_wb_read32(uint32_t adr, uint32_t *data);
int dbg_wb_write32(uint32_t adr, uint32_t data);
int dbg_wb_write16(uint32_t adr, uint16_t data);
int dbg_wb_write8(uint32_t adr, uint8_t data);
int dbg_wb_read_block32(uint32_t adr, uint32_t *data, int len);
int dbg_wb_read_block16(uint32_t adr, uint16_t *data, int len);
int dbg_wb_read_block8(uint32_t adr, uint8_t *data, int len);
int dbg_wb_write_block32(uint32_t adr, uint32_t *data, int len);
int dbg_wb_write_block16(uint32_t adr, uint16_t *data, int len);
int dbg_wb_write_block8(uint32_t adr, uint8_t *data, int len);
int dbg_cpu0_read(uint32_t adr, uint32_t *data);
int dbg_cpu0_read_block(uint32_t adr, uint32_t *data, int count);
int dbg_cpu0_write(uint32_t adr, uint32_t data);
int dbg_cpu0_write_block(uint32_t adr, uint32_t *data, int count);
int dbg_cpu0_write_ctrl(uint32_t adr, uint8_t data);
int dbg_cpu0_read_ctrl(uint32_t adr, uint8_t *data);
//int dbg_cpu1_read(uint32_t adr, uint32_t *data);
//int dbg_cpu1_write(uint32_t adr, uint32_t data);
//int dbg_cpu1_write_reg(uint32_t adr, uint8_t data);
//int dbg_cpu1_read_ctrl(uint32_t adr, uint8_t *data);
int dbg_serial_sndrcv(unsigned int *bytes_to_send, const uint8_t *data_to_send, unsigned int *bytes_received, uint8_t *data_received);

#endif
