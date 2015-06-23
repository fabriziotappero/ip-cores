#ifndef __TEST_ALLOCPAGE_H__
#define __TEST_ALLOCPAGE_H__

#include <generic/alloc_page.h>
#include "tests.h"

void test_allocpage(int num_allocs, int alloc_max, FILE *init, FILE *exit);
void print_page_area(struct page_area *a, int no);
void print_caches(struct mem_cache *c);
void print_cache(struct mem_cache *c, int cacheno);
void print_areas(struct page_area *ar);
void print_page_area(struct page_area *ar, int areano);
#endif
