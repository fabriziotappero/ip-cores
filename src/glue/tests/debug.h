#ifndef __DEBUG_H__
#define __DEBUG_H__

#include <generic/physmem.h>
#include <generic/kmalloc.h>
#include <generic/alloc_page.h>
#include <lib/list.h>

void print_physmem(struct memdesc *m);
void print_page_area_list(struct page_area *p);
void print_subpage_area_list(struct subpage_area *s);
void print_subpage_area(struct subpage_area *s);
#endif /* DEBUG_H */
