#ifndef __TIMER_H__
#define __TIMER_H__

#include "hardware.h"

//-----------------------------------------------------------------
// Defines:
//-----------------------------------------------------------------
typedef unsigned long t_time;

//-----------------------------------------------------------------
// Prototypes:
//-----------------------------------------------------------------
static t_time   timer_now(void) { return TIMER_HW_VAL; }
static long     timer_diff(t_time a, t_time b) { return (long)(a - b); }
static void     timer_sleep(int timeMs)
{
    t_time t = timer_now();

    while (timer_diff(timer_now(), t) < timeMs)
        ;
}

#endif
