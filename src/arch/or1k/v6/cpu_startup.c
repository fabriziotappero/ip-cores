/*
 * Copyright (C) 2010 B Labs Ltd.
 * Author: Prem Mallappa <prem.mallappa@b-labs.co.uk>
 */

#include INC_CPU(cpu.h)
//#include INC_SUBARCH(cpu.h)
//#include INC_ARCH(cpu.h)


/* This code is guaranteed to be executed before MMU is enabled */

void cpu_startup(void)
{
	/* For now this should have
	 * cache disabling
	 * branch prediction disabling
	 */

	/* Here enable the common bits
	 * cache
	 * branch prediction
	 * write buffers
	 */

	/* Enable V6 page tables */
	//unsigned int val = arm_get_cp15_cr() | 1<<23;
        //arm_set_cp15_cr(val);


#if defined (CONFIG_SMP)
	/* Enable SCU*/
	/* Enable SMP bit in CP15 */
#endif

}
