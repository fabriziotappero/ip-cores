#ifndef __UART_H__
#define __UART_H__

#include <stdint.h>

#define	UART_ADDRESS 0xB0000000

void UART_disableBoot(void);
uint8_t UART_readByte(void);
uint32_t UART_readMessage(void);
void UART_writeByte(uint8_t byte);

#endif

