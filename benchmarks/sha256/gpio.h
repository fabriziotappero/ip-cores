// The Potato Processor Benchmark Applications
// (c) Kristian Klomsten Skordal 2015 <kristian.skordal@wafflemail.net>
// Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

#ifndef GPIO_H
#define GPIO_H

#include <stdint.h>

#define DIRECTION_INPUT		0
#define DIRECTION_OUTPUT	1

void gpio_set_direction(volatile uint32_t * base, uint32_t direction);
void gpio_set_output(volatile uint32_t * base, uint32_t output);
uint32_t gpio_get_value(volatile uint32_t * base);

#endif

