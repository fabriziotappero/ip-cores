/*
 * Mock-up l4 library definitions for host testing.
 *
 */
#ifndef __TESTS_LIBL4_H__
#define __TESTS_LIBL4_H__

#include <l4/macros.h>
#include <l4/config.h>
#include <l4/types.h>

u32 l4_map(unsigned long phys, unsigned long virt, u32 size, u32 flags, u32 tid);
u32 l4_unmap(unsigned long a, unsigned long b, u32 npages);
u32 l4_getpid(unsigned int *a, unsigned int *b, unsigned int *c);


#endif
