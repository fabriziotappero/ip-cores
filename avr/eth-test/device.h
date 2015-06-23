#ifndef _DEVICE_H_
#define _DEVICE_H_

#include "buf.h"

/* Different function types to be implemented by a device. */
typedef uint8_t	igordev_read_fn_t(uint64_t, uint8_t *, uint8_t);
typedef uint8_t	igordev_write_fn_t(uint64_t, uint8_t *, uint8_t);
typedef void	igordev_init_fn_t(void);
typedef void	igordev_deinit_fn_t(void);
typedef void	igordev_flush_fn_t(void);
typedef int8_t status_t;

/* An error occured during read/write */
#define IDEV_STATUS_ERROR	1
/* The last read/write was ok */
#define IDEV_STATUS_OK		2
/* The last interrupt was not handled due to overflow. */
#define IDEV_STATUS_OVERFLOW	3
/* The device will be handling an interrupt. */
#define IDEV_STATUS_INTR	4
/* The device is busy in main. */
#define IDEV_STATUS_BUSY	5

struct idev_mgmt {
	uint8_t irqenable;	/* Marks if device have irq enabled. */
	uint64_t baseaddr;	/* Base address of device. */
	uint64_t curaddr;	/* Marks current address to read/write from. */
	uint64_t size;		/* Marks max address to read/write from. */
};

/* 
 * This is just a suggestion to what we may need. It will probably be extended
 * quite soon...
 */
struct igordev {
	/* Hardware initialization. */
	igordev_init_fn_t *init;
	/* Hardware deinit... */
	igordev_deinit_fn_t *deinit;
	/* Perform a read from the device. */
	igordev_read_fn_t *read;
	/* Perform a write to the device. */
	igordev_write_fn_t *write;
	/* Perform a flush of the devices output buffers. */
	igordev_flush_fn_t *flush;

	/* Status pointers to device status. */
	status_t write_status;
	status_t read_status;

	struct idev_mgmt imgmt;

	/* Identification register describing the device capabilities. */
	uint32_t id;
#define CAN_READ	0x01
#define CAN_WRITE	0x02
#define ADDR_READ	0x04
#define ADDR_WRITE	0x08
#define DEVTYPE_MASK	0xFF
#define DEVTYPE_OFFSET	0x04

/* Device types */
#define DEVTYPE_SERIAL	0
#define DEVTYPE_STORAGE	1
#define DEVTYPE_TERM	2
#define DEVTYPE_BOOT	3

	/* Private for device handler. */
	void *priv;
};

/* Device memory areas. */
#define DEVICES		0x00
#define CURDEV		0x01
#define CLI		0x02
#define SAI		0x03
#define INTRDEV		0x04

/* Device-specific. */
#define OBJECT		0x10
#define ADDR_L		0x11
#define ADDR_H		0x12
#define SIZE_L		0x13
#define SIZE_H		0x14
#define STATUS		0x15
#define IDENTIFICATION	0x16
#define IRQENABLE	0x17

/* Functions for initializing and selecting devices. */
void		 device_init(void);
struct igordev	*device_select(uint8_t);
#endif /* !_DEVICE_H_ */
