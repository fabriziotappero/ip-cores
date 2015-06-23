
#include "testmod.h"
#define CCTRL_IFP (1<<15)
#define CCTRL_DFP (1<<14)

extern rsysreg(int addr);
extern wsysreg(int *addr, int data);
extern cache_disable();
extern cache_enable();

cramtest()
{
	volatile double mrl[8*1024 + 8];
	int i; 
	int ilinesz, dlinesz, dbytes, ibytes, itmask, dtmask, isets, dsets; 
	int icconf, dcconf, cachectrl;

	flush();
	cache_enable();
	icconf = rsysreg(8);
	dcconf = rsysreg(12);

	report_subtest(DDAT_TEST);

	isets = ((icconf >> 24) & 3) + 1;
	ilinesz = 1 << (((icconf >> 16) & 7) + 2);
	ibytes = (1 << (((icconf >> 20) & 15) + 10)) * isets;
	itmask = (ilinesz - 1) | (0x80000000 - ibytes);
	dsets = ((dcconf >> 24) & 3) + 1;
	dlinesz = 1 << (((dcconf >> 16) & 7) + 2);
	dbytes = (1 << (((dcconf >> 20) & 15) + 10)) * dsets;
	dtmask = (dlinesz - 1) | (0x80000000 - dbytes);

	do cachectrl = rsysreg(0); while(cachectrl & (CCTRL_IFP | CCTRL_DFP));


	/* dcache data ram */

	if (ddramtest1(dbytes, mrl,0x55555555)) fail(1);
	if (ddramtest2(dbytes, mrl,0xaaaaaaaa)) fail(2);

	report_subtest(DTAG_TEST);
	cache_disable();

	/* dcache tag ram */

	if (dtramtest(dbytes, (0xaaaaaa00 & dtmask), dtmask, dlinesz,
	    0xaaaaaaaa)) fail(3);
	if (dtramtest(dbytes, (0x55555500 & dtmask), dtmask, dlinesz,
	    0x55555555)) fail(4);

	/* icache data ram */

	report_subtest(IDAT_TEST);
	if (idramtest(ibytes, 0x55555555)) fail(5);
	if (idramtest(ibytes, 0xaaaaaaaa)) fail(6);

	/* icache tag ram */

	report_subtest(ITAG_TEST);
	if (itramtest(ibytes, itmask, ilinesz, 0xaaaaaaaa)) fail(7);
	if (itramtest(ibytes, itmask, ilinesz, 0x55555555)) fail(8);
	flush();
	cache_enable();
	return(0);

}

