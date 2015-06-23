/*
 * Generic timer library API
 *
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Author: Bahadir Balban
 */
#ifndef __LIBDEV_TIMER_H__
#define __LIBDEV_TIMER_H__

/*
 * Simple API for the primary timer
 * for userspace
 */
void timer_start(unsigned long timer_base);
void timer_load(u32 val, unsigned long timer_base);
u32 timer_read(unsigned long timer_base);
void timer_stop(unsigned long timer_base);
void timer_init_oneshot(unsigned long timer_base);
void timer_init_periodic(unsigned long timer_base, u32 load_value);
void timer_init(unsigned long timer_base, u32 load_value);

#endif /* __LIBDEV_TIMER_H__ */
