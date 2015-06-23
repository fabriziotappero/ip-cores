#ifndef __LED_H__
#define __LED_H__

#include <stdint.h>

#define LED_ADDRESS	0xC0000000
#define LED_MODE_DATA	0x00000000
#define LED_MODE_INTR	0x00004000
#define LED_CENTER	0x00000100
#define LED_WEST	0x00000200
#define LED_SOUTH	0x00000400
#define LED_EAST	0x00000800
#define LED_NORTH	0x00001000
#define LED_ERROR	0x00002000

uint32_t LED_read(void);
void     LED_write(uint32_t data);
void     LED_setMode(uint32_t mode);

#endif

