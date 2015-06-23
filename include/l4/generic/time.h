/*
 * System time keeping definitions
 *
 * Copyright (C) 2007 Bahadir Balban
 */

#ifndef __GENERIC_TIME_H__
#define __GENERIC_TIME_H__

/* Used by posix systems */
struct timeval {
	int tv_sec;
	int tv_usec;
};

extern volatile u32 jiffies;

int do_timer_irq(void);
int secondary_timer_irq(void);

#endif /* __GENERIC_TIME_H__ */
