// The Potato Processor Benchmark Applications
// (c) Kristian Klomsten Skordal 2015 <kristian.skordal@wafflemail.net>
// Report bugs and issues on <http://opencores.org/project,potato,bugtracker>

#ifndef TIMER_H
#define TIMER_H

#include <stdint.h>

void timer_set(volatile uint32_t * base, uint32_t compare);
void timer_reset(volatile uint32_t * base);

#endif

