#ifndef __PAGER_BOOTM_H__
#define __PAGER_BOOTM_H__

#define __initdata	SECTION(".init.data")

void *alloc_bootmem(int size, int alignment);


#endif /* __PAGER_BOOTM_H__ */
