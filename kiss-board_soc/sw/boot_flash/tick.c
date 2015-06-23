
#include "support.h"
#include "spr_defs.h"
#include "tick.h"

static TICK tick[TICK_MAX_HANDLERS] __attribute__ ((section(".bss")));

int tick_init(){
	unsigned long int i;
	for (i=0;i<TICK_MAX_HANDLERS;i++) {
		tick[i].handler = 0;
		tick[i].arg     = 0;
	}
	mtspr(SPR_TTMR,(SPR_TTMR_RT|SPR_TTMR_IE)|TICK_EXPIRE_COUNT);

	return 0;
}
int tick_add(unsigned long vect,void (* handler)(void *),void *arg){
	if (vect>=TICK_MAX_HANDLERS) return -1;
tick_disable();
	tick[vect].handler = handler;
	tick[vect].arg     = arg;
tick_enable();
	return 0;
}
int tick_disable(){
	mtspr(SPR_TTMR, mfspr(SPR_TTMR) & ~(SPR_TTMR_IE) );
	return 0;
}
int tick_enable(){
	mtspr(SPR_TTMR, mfspr(SPR_TTMR) | SPR_TTMR_IE );
	return 0;
}
void tick_main(void){
	unsigned long int i;
	unsigned long int ttmr;
	ttmr = mfspr(SPR_TTMR);
	if (ttmr & SPR_TTMR_IP) {
		// call tick handler
		for (i=0;i<TICK_MAX_HANDLERS;i++)
			if (tick[i].handler!=0) (*tick[i].handler)(tick[i].arg); 
		// timer flag clear
	 	mtspr(SPR_TTMR, mfspr(SPR_TTMR) & ~(SPR_TTMR_IP) );
	}
}

