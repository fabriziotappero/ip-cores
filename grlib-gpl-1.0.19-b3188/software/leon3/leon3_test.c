
#include "testmod.h"

void (*mpfunc[16])(int index);

leon3_test(int domp, volatile int *irqmp, int mtest)
{
	int tmp, i;

	if (!get_pid()) report_device(0x01003000);
	if (domp) mptest_start(irqmp);	
	report_subtest(REGFILE+(get_pid()<<4));
	if (regtest()) fail(1);
	multest();
	divtest();
	fputest();
	if (mtest) cramtest();
	if ((*mpfunc[get_pid()])) mpfunc[get_pid()](get_pid());
	if (domp) mptest_end(irqmp);	
	grfpu_test();
	cachetest();
	mmu_test();
}
