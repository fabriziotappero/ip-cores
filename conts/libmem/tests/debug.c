#include "debug.h"
#include <stdio.h>

void print_page_area_list(struct page_allocator *p)
{
	struct page_area *area;

	list_foreach_struct (area, &p->page_area_list, list) {
		printf("%-20s\n%-20s\n", "Page area:","-------------------------");
		printf("%-20s %u\n", "Pfn:", area->pfn);
		printf("%-20s %d\n", "Used:", area->used);
		printf("%-20s %d\n\n", "Number of pages:", area->numpages);
	}
}

void print_km_area(struct km_area *s)
{
	printf("%-20s\n%-20s\n", "Subpage area:","-------------------------");
	printf("%-20s 0x%lu\n", "Addr:", s->vaddr);
	printf("%-20s 0x%lu\n", "Size:", s->size);
	printf("%-20s %d\n", "Used:", s->used);
	printf("%-20s %d\n\n", "Head_of_pages:", s->pg_alloc_pages);

}

void print_km_area_list(struct link *km_areas)
{
	struct km_area *area;

	list_foreach_struct (area, km_areas, list)
		print_km_area(area);
}

