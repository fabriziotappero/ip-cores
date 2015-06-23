// The Potato Processor Benchmark Applications
// (c) Kristian Klomsten Skordal 2015 <kristian.skordal@wafflemail.net>
// Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

#include "gpio.h"
#include "platform.h"

void gpio_set_direction(volatile uint32_t * base, uint32_t direction)
{
	base[GPIO_DIR >> 2] = direction;
}

void gpio_set_output(volatile uint32_t * base, uint32_t output)
{
	base[GPIO_OUTPUT >> 2] = output;
}

uint32_t gpio_get_value(volatile uint32_t * base)
{
	return base[GPIO_INPUT >> 2];
}


