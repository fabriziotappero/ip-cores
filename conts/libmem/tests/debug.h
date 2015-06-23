#ifndef __DEBUG_H__
#define __DEBUG_H__

//#include <kmalloc/kmalloc.h>
#include <mm/alloc_page.h>
#include <l4/lib/list.h>

#if defined(DEBUG)
#define dprintf	printf
#else
#define dprintf(...)
#endif

void print_page_area_list(struct page_allocator *p);
void print_km_area_list(struct link *s);
void print_km_area(struct km_area *s);
#endif /* DEBUG_H */
