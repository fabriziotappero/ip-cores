#ifndef _UART_H_
  #define _UART_H_

// Prototypes
const char *uart0_printf(const char *string);

void uart0_scanf(unsigned char *buffer, int length, unsigned char en_echo);

void uart0_print_buffer(unsigned char *buffer, int size);

#endif // _UART_H_
