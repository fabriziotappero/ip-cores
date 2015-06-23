#ifndef _IO_H_
#define _IO_H_

#include <inttypes.h>
#include "regs.h"

#define IO_AREA_MASK  0x3FFFF00

#define IO_DEVICES    0x00
#define IO_CURDEV     0x01
#define IO_CLI        0x02
#define IO_SAI        0x03
#define IO_INTRDEV    0x04
#define IO_OBJECT     0x10
#define IO_ADDR_L     0x11
#define IO_ADDR_H     0x12
#define IO_SIZE_L     0x13
#define IO_SIZE_H     0x14
#define IO_STATUS     0x15
#define IO_IDENT      0x16
#define IO_IRQENABLE  0x17

#define MAX_DEVICES   0x05

#define DEV_BOOT      0x03
#define DEV_TERMINAL  0x02
#define DEV_SERIAL    0x00
#define DEV_STORAGE   0x01
#define DEV_NETWORK   0x04

// identification register:
#define CAN_READ      0x01
#define CAN_WRITE     0x02
#define ADDR_READ     0x04
#define ADDR_WRITE    0x08
#define DEVTYPE_MASK  0xFF
#define DEVTYPE_SHIFT 0x04

// status register:
#define READY_READ    0x01
#define READY_WRITE   0x02
#define ERRCODE_MASK  0xFF
#define ERRCODE_SHIFT 0x02

typedef struct {
	uint64_t addr;
	uint64_t size;
	uint32_t status;
	uint32_t ident;
	int irqenable;
	int make_object;
	FILE *fr, *fw;
} device_t;

void io_init(void);
void io_set_file(uint32_t devnr, char *filename);
void io_set_files(uint32_t devnr, char *readfile, char *writefile);
void io_memory_set(unsigned int pos, reg_t value);
reg_t io_memory_get(unsigned int pos);

#endif
