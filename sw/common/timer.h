#ifndef __TIMER_H__
#define __TIMER_H__

#include "mem_map.h"

//-----------------------------------------------------------------
// Defines:
//-----------------------------------------------------------------
typedef unsigned long t_time;

//-----------------------------------------------------------------
// Prototypes:
//-----------------------------------------------------------------

// General timer
void            timer_init(void);
static t_time   timer_now(void) { return TIMER_VAL; }
static long     timer_diff(t_time a, t_time b) { return (long)(a - b); } 
void            timer_sleep(int timeMs);

#endif
