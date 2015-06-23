#ifndef __CLOCK_ARCH_H__
#define __CLOCK_ARCH_H__

#include <stdint.h>

typedef uint16_t clock_time_t;

//Freqency divided prescaler and counter register size
#define CLOCK_CONF_SECOND	(clock_time_t)(F_CPU / (1024*255))
	//May fail and give overflow

#include "clock.h"

#endif /* __CLOCK_ARCH_H__ */
