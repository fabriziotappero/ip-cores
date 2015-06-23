extern rsysreg(int addr);
extern wsysreg(int *addr, int data);

cache_disable() 
{
  asm(" sta %g0, [%g0] 2 ");
}

cache_enable()
{
  asm(" set 0x81000f, %o0; sta %o0, [%g0] 2 ");
}

ramfill()
{
	int dbytes, ibytes, isets, dsets; 
	int icconf, dcconf;
	int cachectrl; 

        icconf = rsysreg(8);
        dcconf = rsysreg(12);

	isets = ((icconf >> 24) & 3) + 1;
	dsets = ((dcconf >> 24) & 3) + 1;
	ibytes = (1 << (((icconf >> 20) & 0xF) + 10)) * isets;
	dbytes = (1 << (((dcconf >> 20) & 0xF) + 10)) * dsets;
        cache_disable();
        ifill(ibytes);
	dfill(dbytes);
        flush();
        cache_enable();
        
}
