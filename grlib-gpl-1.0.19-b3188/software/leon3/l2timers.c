#include "testmod.h"

struct timerreg {
    volatile unsigned int counter;		/* 0x0 */
    volatile unsigned int reload;		/* 0x4 */
    volatile unsigned int control;		/* 0x8 */
    volatile unsigned int wdog;			/* 0xC */
};

struct l2timers {
    struct timerreg timer[2];
    volatile unsigned int scalercnt;		/* 0x00 */
    volatile unsigned int scalerload;		/* 0x04 */
};

#define IRQPEND 0x10

l2timers_test(int addr)
{
        struct l2timers *lr = (struct l2timers *) addr;
        extern volatile int irqtbl[];
        int i, j, pil, ntimers;

	report_device(0x04006000);
	ntimers = 2;
	lr->scalerload = -1;
	if (lr->scalercnt == lr->scalercnt) fail(1);

/* timer 1 test */

	lr->scalerload = 31;
	lr->scalercnt = 31;
	for (i=0; i<ntimers; i++) lr->timer[i].control = 0; // halt all timers
	
	/* test basic functions */
	for (i=0; i<ntimers; i++) {
	    report_subtest(i);
	    lr->timer[i].counter = 0;
	    lr->timer[i].reload = 15;
	    lr->timer[i].control = 0x6;
	    if (lr->timer[i].counter != 15) fail(3); // check loading
	    lr->timer[i].control = 0xf;
	    for (j=14; j >= 0; j--) { while (lr->timer[i].counter != j) {}}
	    while (lr->timer[i].counter != 15) {}
	    lr->timer[i].control = 0;	
	}

}
