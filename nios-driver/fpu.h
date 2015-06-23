#ifndef FPU_H_
#define FPU_H_

#include <stdio.h>
#include "system.h"
#include <unistd.h>
#include "alt_types.h"
#include <stdlib.h>
#include <stdio.h>
#include "system.h"
#include <unistd.h>
#include "alt_types.h"
#include "io.h"
#include "fpu.h"
#include "sys/alt_timestamp.h"
#include "altera_avalon_performance_counter.h"
#include <time.h>
#include <sys/alt_irq.h>

double __wrap___adddf3(double a, double b);
double __wrap___subdf3(double a, double b);
double __wrap___muldf3(double a, double b);
//double __wrap___adddf3(double a, double b);

#endif /* FPU_H_ */
