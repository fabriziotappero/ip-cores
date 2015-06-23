
#ifndef __TIMER_H
#define __TIMER_H

struct timer {
	unsigned long int count;
} typedef TIMER;

int				timer_init(TIMER *timer)						__attribute__ ((section(".text")));
int				timer_main(TIMER *timer)						__attribute__ ((section(".icm")));
unsigned long int		timer_get_count(TIMER *timer)						__attribute__ ((section(".icm")));

#endif

