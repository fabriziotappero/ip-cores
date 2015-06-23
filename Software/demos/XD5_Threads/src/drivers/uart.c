#include "uart.h"

void UART_disableBoot(void)
{
	volatile uint32_t *uart = (volatile uint32_t *)UART_ADDRESS;
	uint32_t data;

	data = 0x00000100;

	*uart = data;
}

uint8_t UART_readByte(void)
{
	volatile uint32_t *uart = (volatile uint32_t *)UART_ADDRESS;
	uint32_t data;

	data = *uart;

	return (uint8_t)data;
}

uint32_t UART_readMessage(void)
{
	volatile uint32_t *uart = (volatile uint32_t *)UART_ADDRESS;
	
	return *uart;
}

void UART_writeByte(uint8_t byte)
{
	volatile uint32_t *uart = (volatile uint32_t *)UART_ADDRESS;
	uint32_t data;

	data = (uint32_t)byte;
	*uart = data;
}

