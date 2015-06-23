
#include "dsu3.h"

dsu3_tb_check(int dsuaddr)
{
    int i, tmp, atmp, k, j, histlen;
    unsigned int ahblen;
    int pat5 = 0x55555555;
    int patA = 0xAAAAAAAA;
    int err = 0;
    volatile int xtmp = 2;
    volatile int vtmp = 0;

    report_device(0x01004000);

    // check that AHB breakpoints work 
    /*
    *((volatile int *) (dsuaddr + DSU3_AHBCTRL)) = 0;
    *((volatile int *) (dsuaddr + DSU3_TIMETAG)) = 0;
    *((volatile int *) (dsuaddr + DSU3_AHBINDEX)) = 0;
    *((volatile int *) (dsuaddr + DSU3_AHBBPT1)) = (int) &xtmp;
    *((volatile int *) (dsuaddr + DSU3_AHBMSK1)) = -1;
    *((volatile int *) (dsuaddr + DSU3_AHBCTRL)) = 1;
    xtmp += 1;;
    if (*((volatile int *) (dsuaddr + DSU3_AHBCTRL))) fail (1);
    if ((*((volatile int *) (dsuaddr + DSU3_AHBBUF))) /= (int) &xtmp) 
    	fail (2);
    */

    *((volatile int *) (dsuaddr + DSU3_AHBCTRL)) = 0xffff0000;
    ahblen = *((volatile int *) (dsuaddr + DSU3_AHBCTRL));
    ahblen = (ahblen >> 14);
    if (ahblen) {
        check_tbuf(dsuaddr + DSU3_AHBBUF, ahblen+1);
    }

    *((volatile int *) (dsuaddr + DSU3_TBCTRL)) = 0x0000ffff;
    ahblen = *((volatile int *) (dsuaddr + DSU3_TBCTRL));
    if (ahblen) {
        check_tbuf(dsuaddr + DSU3_TBUF, ahblen+1);
    }
}

check_tbuf(int addr, int ahblen)
{
    long long patchk = 0x5555555555555555LL;
    long long patichk = 0xaaaaaaaaaaaaaaaaLL;
    int j, tmp, atmp;
    
        report_subtest(1);	// checker board test
	atmp = addr;
	j = 0;
	while (j < ahblen) {
	    *((volatile long long *)(atmp)) = patchk;
	    *((volatile long long *)(atmp+8)) = patchk;
	    *((volatile long long *)(atmp+16)) = patichk;
	    *((volatile long long *)(atmp+24)) = patichk;
	    j += 32;
	}
	atmp = addr;
	j = 0;
	while (j < ahblen) {
	    if (*((volatile long long *)(atmp)) != patchk) fail(j);
	    if (*((volatile long long *)(atmp+8)) != patchk) fail(j);
	    if (*((volatile long long *)(atmp+16)) != patichk) fail(j);
	    if (*((volatile long long *)(atmp+24)) != patichk) fail(j);
	    j += 32;
	}
        report_subtest(2);	// inverted checker board test
	atmp = addr;
	j = 0;
	while (j < ahblen) {
	    *((volatile long long *)(atmp)) = patichk;
	    *((volatile long long *)(atmp+8)) = patichk;
	    *((volatile long long *)(atmp+16)) = patchk;
	    *((volatile long long *)(atmp+24)) = patchk;
	    j += 32;
	}
	atmp = addr;
	j = 0;
	while (j < ahblen) {
	    if (*((volatile long long *)(atmp)) != patichk) fail(j);
	    if (*((volatile long long *)(atmp+8)) != patichk) fail(j);
	    if (*((volatile long long *)(atmp+16)) != patchk) fail(j);
	    if (*((volatile long long *)(atmp+24)) != patchk) fail(j);
	    j += 32;
	}
        report_subtest(3);	// check address decoder
        for (j=0; j<ahblen; j++) {
	    atmp = addr + j*4;
	    *((volatile int *)(atmp)) = atmp;
        }
        for (j=0; j<ahblen; j++) {
	    atmp = addr + j*4;
	    tmp = *((volatile int *) (atmp));
	    if (tmp != atmp) fail(j);
        }
}


