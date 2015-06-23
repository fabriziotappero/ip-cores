// The Potato Processor Benchmark Applications
// (c) Kristian Klomsten Skordal 2015 <kristian.skordal@wafflemail.net>
// Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

#include <stdint.h>
#include "../platform.h"

void exception_handler(uint32_t cause, void * epc, void * regbase)
{
	// Not used in this application
}

int main(void)
{
	const char * hello_string = "Hello world\n\r";
	volatile uint32_t * uart = IO_ADDRESS(UART_BASE);

	for(int i = 0; hello_string[i] != 0; ++i)
	{
		while(uart[UART_STATUS >> 2] & (1 << 3));
		uart[UART_TX >> 2] = hello_string[i] & 0x000000ff;
	}

	return 0;
}

