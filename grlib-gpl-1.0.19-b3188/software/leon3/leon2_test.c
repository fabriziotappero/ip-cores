
#include "testmod.h"

leon2_test(volatile int *irqmp, int mtest)
{
	int tmp, i;

	report_device(0x04002000);
	report_subtest(REGFILE);
	if (regtest()) fail(1);
	multest();
	divtest();
	fputest();
	/*
	if (mtest) cramtest();
	if (domp) mptest_end(irqmp);	
	cachetest();
	*/
}
