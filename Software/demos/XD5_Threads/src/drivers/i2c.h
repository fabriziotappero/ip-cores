#ifndef __I2C_H__
#define __I2C_H__

#include <stdint.h>

#define I2C_ADDRESS 0x90000000

void I2C_clear(void);
void I2C_EnQ(uint8_t byte);
void I2C_transmit(void);
void I2C_setReceive(uint8_t bytes);
void I2C_receive(void);
uint32_t I2C_DeQ(void);

#endif

