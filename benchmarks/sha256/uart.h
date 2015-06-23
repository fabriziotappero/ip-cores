// The Potato Processor Benchmark Applications
// (c) Kristian Klomsten Skordal 2015 <kristian.skordal@wafflemail.net>
// Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

#ifndef UART_H
#define UART_H

#include <stdint.h>

// TODO: Implement the M extension and then write a printf function.

void uart_puts(volatile uint32_t * base, const char * s);
void uart_putc(volatile uint32_t * base, char c);
void uart_puth(volatile uint32_t * base, uint32_t n);

#endif

