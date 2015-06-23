
#include "libl4.h"

unsigned long virt_to_phys(unsigned long addr)
{
	return addr;
}

unsigned long phys_to_virt(unsigned long addr)
{
	return addr;
}

u32 l4_getpid(unsigned int *a, unsigned int *b, unsigned int *c)
{
	return 0;
}

u32 l4_unmap(unsigned long a, unsigned long b, u32 npages)
{
	return 0;
}

u32 l4_map(unsigned long a, unsigned long b, u32 size, u32 flags, unsigned int tid)
{
	return 0;
}

