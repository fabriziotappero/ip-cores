#include "i2c.h"

void I2C_clear(void)
{
	volatile uint32_t *i2c = (volatile uint32_t *)I2C_ADDRESS;
	uint32_t cmd = (1 << 8);

	*i2c = cmd;
}

void I2C_EnQ(uint8_t byte)
{
	volatile uint32_t *i2c = (volatile uint32_t *)I2C_ADDRESS;
	
	uint32_t cmd = (1 << 9) | (uint32_t)byte;
	*i2c = cmd;
}

void I2C_transmit(void)
{
	volatile uint32_t *i2c = (volatile uint32_t *)I2C_ADDRESS;

	uint32_t cmd = (1 << 10);
	*i2c = cmd;
}

void I2C_setReceive(uint8_t bytes)
{
	volatile uint32_t *i2c = (volatile uint32_t *)I2C_ADDRESS;

	uint32_t cmd = (1 << 12) | (uint32_t)bytes;
	*i2c = cmd;
}

void I2C_receive(void)
{
	volatile uint32_t *i2c = (volatile uint32_t *)I2C_ADDRESS;

	uint32_t cmd = (1 << 11);
	*i2c = cmd;
}

uint32_t I2C_DeQ(void)
{
	volatile uint32_t *i2c = (volatile uint32_t *)I2C_ADDRESS;

	uint32_t data = *i2c;
	return data;
}

