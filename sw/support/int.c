/* This file is part of test microkernel for OpenRISC 1000. */
/* (C) 2001 Simon Srot, srot@opencores.org */

#include "support.h"
#include "or1200.h"
#include "int.h"

/* Interrupt handlers table */
struct ihnd int_handlers[MAX_INT_HANDLERS];

/* Initialize routine */
int int_init()
{
	int i;

	for(i = 0; i < MAX_INT_HANDLERS; i++) {
		int_handlers[i].handler = 0;
		int_handlers[i].arg = 0;
	}
	mtspr(SPR_PICMR, 0x00000000);

	//set OR1200 to accept exceptions
	mtspr(SPR_SR, mfspr(SPR_SR) | SPR_SR_IEE);

	return 0;
}

/* Add interrupt handler */ 
int int_add(unsigned long vect, void (* handler)(void *), void *arg)
{
	if(vect >= MAX_INT_HANDLERS)
		return -1;

	int_handlers[vect].handler = handler;
	int_handlers[vect].arg = arg;

	mtspr(SPR_PICMR, mfspr(SPR_PICMR) | (0x00000001L << vect));

	return 0;
}

/* Disable interrupt */ 
int int_disable(unsigned long vect)
{
	if(vect >= MAX_INT_HANDLERS)
		return -1;

	mtspr(SPR_PICMR, mfspr(SPR_PICMR) & ~(0x00000001L << vect));

	return 0;
}

/* Enable interrupt */ 
int int_enable(unsigned long vect)
{
	if(vect >= MAX_INT_HANDLERS)
		return -1;

	mtspr(SPR_PICMR, mfspr(SPR_PICMR) | (0x00000001L << vect));

	return 0;
}

/* Main interrupt handler */
void int_main()
{
	unsigned long picsr = mfspr(SPR_PICSR);   //process only the interrupts asserted at signal catch, ignore all during process
	unsigned long i = 0;

	while(i < 32) {
		if((picsr & (0x01L << i)) && (int_handlers[i].handler != 0)) {
			(*int_handlers[i].handler)(int_handlers[i].arg); 
		}
		i++;
	}

	mtspr(SPR_PICSR, 0);      //clear interrupt status: all modules have level interrupts, which have to be cleared by software,
}                           //thus this is safe, since non processed interrupts will get re-asserted soon enough

