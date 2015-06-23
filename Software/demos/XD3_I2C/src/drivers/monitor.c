#include "monitor.h"

void Monitor_start(void)
{
	I2C_clear();
	I2C_EnQ(MONITOR_BUS_ADDR);
	I2C_EnQ(0x40);	// Configuration Register 1
	I2C_EnQ(0x1);	// Enable monitoring
	I2C_transmit();
}


// Node is 0->Remote 1, 1->Local, 2->Remote 2
uint32_t Monitor_readTemp(int node)
{
	uint8_t reg = 0x25 + node;
	uint32_t data;

	// Set the read register
	I2C_clear();
	I2C_EnQ(MONITOR_BUS_ADDR);
	I2C_EnQ(reg);
	I2C_transmit();
	
	// Receive the register
	I2C_EnQ(MONITOR_BUS_ADDR);
	I2C_setReceive(1);
	I2C_receive();
	data = I2C_DeQ();

	return data;
}

