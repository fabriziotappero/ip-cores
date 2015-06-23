
#include "amba.h"

struct ahbpp_type *ahbpp = (struct ahbpp_type *) 0xFFFFF000;
struct apbpp_type *apbpp = (struct apbpp_type *) 0x800FF000;

find_ahb_slv(int id, struct ambadev *dev)
{
struct ambadev *ahbdevpp;
int i, j;
    for (i=0; i<NAHBSLV; i++) {
	if ((ahbpp[i].cfg[0] >> 12) == id) {
	    ahbdevpp->id = id;
	    ahbdevpp->irq = ahbpp[i].cfg[0] & PPIRQMASK;
	    ahbdevpp->ppstart = (int) &ahbpp[i];
	    for (j = 0; j < 4; j++) {
		switch (ahbpp[i].mem[0] & 0x0F) {
		case 2:
	    	    ahbdevpp->start[j] = ahbpp[i].mem[j] & PPAHBMASK;
	    	    ahbdevpp->end[j] = ahbdevpp->start[j] + 
			((~(ahbpp[i].mem[j] << 16)) + 0x100000) & PPAHBMASK;
		case 3:
	    	    ahbdevpp->start[j] = ((int) ahbpp) + 
		    	(ahbpp[i].mem[j] & PPAHBMASK) >> 12;
	    	    ahbdevpp->end[j] = ahbdevpp->start[j] + 
			(((~(ahbpp[i].mem[j] << 16)) + 0x100000) & PPAHBMASK) >> 12;
		}
	    }
	    break;
	}
    }
    return(i/NAHBSLV);
}
	
