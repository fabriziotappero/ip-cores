#ifndef __MONITOR_H__
#define __MONITOR_H__

#include "i2c.h"

#define MONITOR_BUS_ADDR 0x2C

void Monitor_start(void);
uint32_t Monitor_readTemp(int node);


#endif

