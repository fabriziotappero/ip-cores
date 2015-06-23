#include "testmod.h"
#ifdef LEON2
#include "leon2.h"
#endif

struct mulcase {
	int	fac1;
	int	fac2;
	int	res;
};

volatile struct mulcase mula[] = { { 2, 3, 6}, { 2, -3, -6}, { 0,  1, 0},
	{ 0, -1, 0}, {  1, -1, -1}, { -1,  1, -1}, { -2,  3, -6},
	{ -2, -3, 6}, {  0,  0, 9}};

int mulscctmp = 0xfffff000;

multest()
{
#ifdef LEON2
	struct l2regs *lr = (struct l2regs *) 0x80000000;
#endif
	int i = 0;

	report_subtest(MUL_TEST+(get_pid()<<4));
	if (mulscc_test() != 0x123) fail(1);

	/* skip test if multiplier disabled */
#ifdef LEON2
	if (!((lr->leonconf >> MUL_CONF_BIT) & 1)) return(0);
#else
	if (!((get_asr17() >> 8) & 1)) return(0);	
#endif
	
	while (mula[i].res != 9) {
	    if ((mula[i].fac1 * mula[i].fac2) - mula[i].res) fail(2);
	    i++;
	}
	if (!mulpipe()) fail(3);
#ifdef LEON2
	if (!((lr->leonconf >> MAC_CONF_BIT) & 1)) return(0);	
#else
	if (!((get_asr17() >> 9) & 1)) return(0);	
#endif
	if (!macpipe()) fail(4);
	return(0);
}

int ddd[8] = {0,0,0,0,0,0,0,0};
