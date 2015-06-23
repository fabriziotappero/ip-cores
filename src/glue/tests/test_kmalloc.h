#ifndef __TEST_KMALLOC_H__
#define __TEST_KMALLOC_H__

#include <generic/kmalloc.h>

void test_kmalloc(int num_allocs, int allocs_max, FILE *initstate, FILE *exitstate);

#endif
