#include "testmod.h"

report(int msg)
{
	*((volatile int *) 0x20000000) = msg;
}

fail(int msg, int cause)
{
	*((volatile int *) 0x20000004) = msg + (cause << 8);
}

main()
{
	int tmp, i;
        ramfill();
        report(START_TEST);
//	report(CMEM_TEST);    if (tmp = cramtest()) fail(CMEM_TEST, tmp);
	report(REGFILE);      if (tmp = regtest()) fail(REGFILE, tmp);
	report(MUL_TEST);     if (tmp = multest()) fail(MUL_TEST, tmp);
	report(DIV_TEST);     if (tmp = divtest()) fail(DIV_TEST, tmp);
	report(CACHE_TEST);   if (tmp = cachetest()) fail(CACHE_TEST, tmp);
	report(IRQ_TEST);     if (tmp = irqtest()) fail(IRQ_TEST, tmp);
	report(APBUART_TEST); if (tmp = apbuart_test()) fail(APBUART_TEST, tmp);
//      report(FTSRCTRL);     if (tmp = ftsrctrl_test()) fail(FTSRCTRL, tmp);
        report(GPIO);         if (tmp = gpio_test()) fail(GPIO, tmp);
	report(STOP_TEST);
}
