/* This file is part of test microkernel for OpenRISC 1000. */
/* (C) 2001 Simon Srot, srot@opencores.org */

#include "support.h"
#include "spr_defs.h"
#include "debug.h"

#include "int.h"

static IHND int_handlers[MAX_INT_HANDLERS] __attribute__ ((section(".bss")));

//void (*vector_0x000)(void) = dummy_main;
//void (*vector_0x100)(void) = dummy_main;
//void (*vector_0x200)(void) = dummy_main;
//void (*vector_0x300)(void) = dummy_main;
//void (*vector_0x400)(void) = dummy_main;
//void (*vector_0x500)(void) = tick_main;		// tick.c
//void (*vector_0x600)(void) = dummy_main;
//void (*vector_0x700)(void) = dummy_main;
//void (*vector_0x800)(void) = int_main;		// int.c
//void (*vector_0x900)(void) = dummy_main;
//void (*vector_0xa00)(void) = dummy_main;
//void (*vector_0xb00)(void) = dummy_main;
//void (*vector_0xc00)(void) = dummy_main;
//void (*vector_0xd00)(void) = dummy_main;
//void (*vector_0xe00)(void) = dummy_main;
//void (*vector_0xf00)(void) = dummy_main;

//
// dummy excption
//
void dummy0x000_main(){
	unsigned long int epcr,eear,esr;
	epcr	= mfspr(SPR_EPCR_BASE);
	eear	= mfspr(SPR_EEAR_BASE);
	esr	= mfspr(SPR_ESR_BASE);
	DEBUG_INTEGER(epcr,8);
	DEBUG_PRINT("\n");
	DEBUG_INTEGER(eear,8);
	DEBUG_PRINT("\n");
	DEBUG_INTEGER(esr,8);
	DEBUG_PRINT("\n");
	return;
}
void dummy0x100_main(){ DEBUG_PRINT("1"); return; }
void dummy0x200_main(){ DEBUG_PRINT("2"); return; }
void dummy0x300_main(){ DEBUG_PRINT("3"); return; }
void dummy0x400_main(){ DEBUG_PRINT("4"); return; }
void dummy0x500_main(){ DEBUG_PRINT("5"); return; }
void dummy0x600_main(){ DEBUG_PRINT("6"); return; }
void dummy0x700_main(){ DEBUG_PRINT("7"); return; }
void dummy0x800_main(){ DEBUG_PRINT("8"); return; }
void dummy0x900_main(){ DEBUG_PRINT("9"); return; }
void dummy0xa00_main(){ DEBUG_PRINT("a"); return; }
void dummy0xb00_main(){ DEBUG_PRINT("b"); return; }
void dummy0xc00_main(){ DEBUG_PRINT("c"); return; }
void dummy0xd00_main(){ DEBUG_PRINT("d"); return; }
void dummy0xe00_main(){ DEBUG_PRINT("e"); return; }
void dummy0xf00_main(){ DEBUG_PRINT("f"); return; }
void dummy_main(){
	unsigned long int epcr,eear,esr;
	epcr	= mfspr(SPR_EPCR_BASE);
	eear	= mfspr(SPR_EEAR_BASE);
	esr	= mfspr(SPR_ESR_BASE);
	DEBUG_INTEGER(epcr,8);
	DEBUG_PRINT("\n");
	DEBUG_INTEGER(eear,8);
	DEBUG_PRINT("\n");
	DEBUG_INTEGER(esr,8);
	DEBUG_PRINT("\n");
	return;
}

int int_init(){
	unsigned long int i;
	// external interrupt
	for(i = 0; i < MAX_INT_HANDLERS; i++) {
		int_handlers[i].handler = 0;
		int_handlers[i].arg = 0;
	}
	return 0;
}

int int_add(unsigned long vect, void (* handler)(void *), void *arg){
	if(vect >= MAX_INT_HANDLERS) return -1;
	int_handlers[vect].handler = handler;
	int_handlers[vect].arg = arg;
	mtspr(SPR_PICMR, mfspr(SPR_PICMR) | (0x00000001L << vect));
	return 0;
}
int int_disable(unsigned long vect){
	if(vect >= MAX_INT_HANDLERS) return -1;
	mtspr(SPR_PICMR, mfspr(SPR_PICMR) & ~(0x00000001L << vect));
	return 0;
}
int int_enable(unsigned long vect){
	if(vect >= MAX_INT_HANDLERS) return -1;
	mtspr(SPR_PICMR, mfspr(SPR_PICMR) | (0x00000001L << vect));
	return 0;
}
void int_main(void){
	{ // external interrupt from exception 0x800
		unsigned long picsr = mfspr(SPR_PICSR);
		unsigned long i = 0;
		mtspr(SPR_PICSR, 0); // need?
		while(i < MAX_INT_HANDLERS) {
			if((picsr & (0x01L << i)) && (int_handlers[i].handler != 0)) {
				(*int_handlers[i].handler)(int_handlers[i].arg); 
				mtspr(SPR_PICSR, mfspr(SPR_PICSR) & ~(0x00000001L << i));
			}
			i++;
  		}
	}
}

