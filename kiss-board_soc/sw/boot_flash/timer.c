
#include "support.h"
#include "spr_defs.h"
#include "timer.h"

int timer_init(TIMER *timer){
	timer->count = 0;
	tick_add(0,timer_main,timer);
	return 0;
}
int timer_main(TIMER *timer){
	timer->count++;
	return 0;
}
unsigned long int timer_get_count(TIMER *timer){
	unsigned long int ret;
tick_disable();
	ret = timer->count;
tick_enable();
	return ret;
}
  
