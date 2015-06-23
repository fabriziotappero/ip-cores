/*
 * This file is subject to the terms and conditions of the GNU General Public
 * License.  See the file "COPYING" in the main directory of this archive
 * for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

#include <linux/interrupt.h>
#include <linux/irq.h>
#include <linux/time.h>
#include <linux/init.h>
#include <linux/clockchips.h>

#include <asm/time.h>

#define SIMPLE_TIMER_IRQ_NUMBER     2
#define SIMPLE_TIMER_ACK_ADDRESS    0xBFFFFFF8

static void simple_timer_set_mode(enum clock_event_mode mode,
              struct clock_event_device *evt)
{
    switch (mode) {
    case CLOCK_EVT_MODE_PERIODIC:
        break;
    case CLOCK_EVT_MODE_ONESHOT:
    case CLOCK_EVT_MODE_UNUSED:
    case CLOCK_EVT_MODE_SHUTDOWN:
        break;
    case CLOCK_EVT_MODE_RESUME:
        break;
    }
}

static struct clock_event_device simple_clockevent_device = {
    .name       = "simple-timer",
    .features   = CLOCK_EVT_FEAT_PERIODIC,
    
    /* .set_mode, .mult, .shift, .max_delta_ns and .min_delta_ns left uninitialized */
    
    .rating     = 300,
    .irq        = SIMPLE_TIMER_IRQ_NUMBER,
    .cpumask    = cpu_all_mask,
    .set_mode   = simple_timer_set_mode,
};

static irqreturn_t simple_timer_interrupt(int irq, void *dev_id)
{
    struct clock_event_device *cd = dev_id;

    *(volatile u8 *)SIMPLE_TIMER_ACK_ADDRESS = 0;

    cd->event_handler(cd);

    return IRQ_HANDLED;
}

static struct irqaction simple_timer_irqaction = {
    .handler    = simple_timer_interrupt,
    .flags      = IRQF_PERCPU | IRQF_TIMER,
    .name       = "simple-timer",
};

void __init plat_time_init(void)
{
    struct clock_event_device *cd = &simple_clockevent_device;
    struct irqaction *action = &simple_timer_irqaction;

    clockevent_set_clock(cd, 100);
    
    clockevents_register_device(cd);
    action->dev_id = cd;
    setup_irq(SIMPLE_TIMER_IRQ_NUMBER, &simple_timer_irqaction);
}
