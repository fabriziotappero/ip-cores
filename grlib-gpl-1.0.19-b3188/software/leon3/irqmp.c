#include "testmod.h"
#include "irqmp.h"

struct irqmp *irqmp_base;
static volatile int irqtbl[18];

irqhandler(int irq)
{
	irqtbl[irqtbl[0]] = irq + 0x10;
	irqtbl[0]++;
}

init_irqmp(struct irqmp *lr)
{
	lr->irqlevel = 0;	/* clear level reg */
	lr->irqmask = 0x0;	/* mask all interrupts */
	lr->irqclear = -1;	/* clear all pending interrupts */
	irqtbl[0] = 1;		/* init irqtable */
}
	
irqtest(int addr)
{
	int i, a, psr;
	volatile int marr[4];
	volatile int larr[4];
	struct irqmp *lr = (struct irqmp *) addr;
	irqmp_base = lr;

	report_device(0x0100d000);
	init_irqmp(lr);

	for (i=1; i<16; i++) catch_interrupt(irqhandler, i);

/* test that interrupts are properly prioritised */
	
	lr->irqforce = 0x0fffe;	/* force all interrupts */
	if (lr->irqforce != 0x0fffe) fail(1); /* check force reg */

	lr->irqmask = 0x0fffe;	  /* unmask all interrupts */
	if (lr->irqmask != 0x0fffe) fail(2); /* check mask reg */
	while (lr->irqforce) {};  /* wait until all iterrupts are taken */

	/* check that all interrupts were take in right order */
	if (irqtbl[0] != 16) fail(3);
	for (i=1;i<16;i++) { if (irqtbl[i] != (0x20 - i))  fail(4);}

/* test priority of the two interrupt levels */

	irqtbl[0] = 1;			/* init irqtable */
	lr->irqlevel = 0xaaaa;	/* set level reg to  odd irq -> level 1 */
	lr->irqmask = 0xfffe;	        
	if (lr->irqlevel != 0xaaaa) fail(5); /* check level reg */
	if (lr->irqmask != 0xfffe) fail(5); /* check mask reg */
	lr->irqforce = 0x0fffe;	/* force all interrupts */
	while (lr->irqforce) {};  /* wait until all iterrupts are taken */

	/* check that all interrupts were take in right order */
	if (irqtbl[0] != 16) fail(6);
	for (i=1;i<8;i++) { if (irqtbl[i] != (0x20 - (i*2-1)))
		fail(7);}
	for (i=2;i<8;i++) { if (irqtbl[i+8] != (0x20 - (i*2)))
		fail(8);}

/* check interrupts of multi-cycle instructions */

	marr[0] = 1; marr[1] = marr[0]+1; marr[2] = marr[1]+1; 
	a = marr[2]+1; marr[3] = a; larr[0] = 6;

	lr->irqlevel = 0;	/* clear level reg */
	lr->irqmask = 0x0;	/* mask all interrupts */
	irqtbl[0] = 1;		/* init irqtable */
	lr->irqmask = 0x00002;	  /* unmask interrupt */
	lr->irqforce = 0x00002;	/* force interrupt */

	asm(
	"	mov  %asr17, %g1\n\t"
	"	andcc %g1, 0x100, %g0\n\t"
	"	be 1f\n\t"
	"	nop \n\t"
	"	umul %g0, %g1, %g0\n\t"
	"	umul %g0, %g1, %g0\n\t"
	"	umul %g0, %g1, %g0\n\t"
	" 	1:\n\t"
	"	");

	lr->irqforce = 0x00002;	/* force interrupt */
	asm("nop;");
	larr[1] = larr[0];
	if (larr[0] != 6) fail(10);
	lr->irqforce = 0x00002;	/* force interrupt */
	asm("nop;");
	larr[1] = 0;
	if (larr[1] != 0) fail(11);

	while (lr->irqforce) {};  /* wait until all iterrupts are taken */

	/* check number of interrupts */
	if (irqtbl[0] != 4) fail(13);

	lr->irqmask = 0x0;	/* mask all interrupts */

/* check that PSR.PIL work properly */

	lr->irqforce = 0x0fffe;	/* force all interrupts */
	irqtbl[0] = 1;		/* init irqtable */
	psr = xgetpsr() | (15 << 8);
	setpsr(psr); /* PIL = 15 */
	lr->irqmask = -1;	/* enable all interrupts */
	while (!lr->irqmask);   /* avoid compiler optimisation */
	if (irqtbl[0] != 2) fail(14);
	if (irqtbl[1] != 0x1f) fail(15);
	setpsr(xgetpsr() - (1 << 8));
	for (i=2;i<16;i++) { 
		setpsr(xgetpsr() - (1 << 8));
		if (irqtbl[0] != i+1) fail(16);
		if (irqtbl[i] != (0x20 - i))  fail(17);
	}

/* test optional secondary interrupt controller */
/*
	lr->irqmask = 0x0;
	lr->imask2 = 0x0;
	lr->ipend2 = 0x0;	
	lr->ipend2 = 0x1;
	if (!lr->ipend2) return(0);
	lr->ipend2 = -1;
	lr->imask2 = -1;
	for (i=lr->istat2 & 0x1f; i >=0; i--) {
		if ((lr->istat2 & 0x1f) != i) fail (17+i);
		lr->istat2 = (1 << i);
	        lr->irqclear = -1;
	}
	if (lr->istat2 & 0x20) fail (33);
	if (lr->irqpend) fail (34);
*/
	lr->irqmask = 0x0;	/* mask all interrupts */
	lr->irqclear = -1;	/* clear all pending interrupts */
	return(0);

}
	
