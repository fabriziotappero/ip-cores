#include "or1200.h"
#include "support.h"
#include "tick.h"

int tick_int;

void tick_ack(void)
{
	tick_int--;
}

void tick_init(void)
{
	mtspr(SPR_TTMR, 25000000 & SPR_TTMR_PERIOD);    //1s
	//mtspr(SPR_TTMR, 125000 & SPR_TTMR_PERIOD);    //5ms

	mtspr(SPR_TTMR, mfspr(SPR_TTMR) | SPR_TTMR_RT | SPR_TTMR_IE);	//restart after match, enable interrupt
	mtspr(SPR_TTMR, mfspr(SPR_TTMR) & ~(SPR_TTMR_IP));    //clears interrupt

	//set OR1200 to accept exceptions
	mtspr(SPR_SR, mfspr(SPR_SR) | SPR_SR_TEE);

	tick_int = 0;
}

void tick_except(void)
{
	tick_int++;
	mtspr(SPR_TTMR, mfspr(SPR_TTMR) & ~(SPR_TTMR_IP));    //clears interrupt
}
