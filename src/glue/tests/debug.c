#include <generic/physmem.h>
#include "debug.h"
#include <stdio.h>

void print_page_area_list(struct page_area *p)
{
	struct page_area *current_item = p;
	struct link *begin = &p->list;
	if (!current_item) {
		printf("%-20s\n", "Null list.");
		return;
	}

	printf("%-20s", "Page area:");
	printf("%s", (list_empty(&current_item->list) ? "(Single Item.)\n" : "\n"));
	printf("%-20s\n","-------------------------");
	printf("%-20s %d\n", "Index:", current_item->index);
	printf("%-20s %d\n", "Used:", current_item->used);
	printf("%-20s %d\n\n", "Number of pages:", current_item->numpages);

	list_foreach_struct (current_item, begin, list) {
		printf("%-20s\n%-20s\n", "Page area:","-------------------------");
		printf("%-20s %d\n", "Index:", current_item->index);
		printf("%-20s %d\n", "Used:", current_item->used);
		printf("%-20s %d\n\n", "Number of pages:", current_item->numpages);
	}
}
void print_subpage_area(struct subpage_area *s)
{
	printf("%-20s\n%-20s\n", "Subpage area:","-------------------------");
	printf("%-20s 0x%x\n", "Addr:", s->vaddr);
	printf("%-20s 0x%x\n", "Size:", s->size);
	printf("%-20s %d\n", "Used:", s->used);
	printf("%-20s %d\n\n", "Head_of_pages:", s->head_of_pages);

}

void print_subpage_area_list(struct subpage_area *s)
{
	struct subpage_area *current_item = s;
	struct link *begin = &s->list;
	if (!current_item) {
		printf("Null list.\n");
		return;
	}

	printf("%-20s", "Subpage area:");
	printf("%s", (list_empty(&current_item->list) ? "(Single Item.)\n" : "\n"));
	printf("%-20s\n","-------------------------");
	printf("%-20s 0x%x\n", "Addr:", current_item->vaddr);
	printf("%-20s 0x%x\n", "Size:", current_item->size);
	printf("%-20s %d\n", "Used:", current_item->used);
	printf("%-20s %d\n\n", "Head_of_pages:", current_item->head_of_pages);

	list_foreach_struct (current_item, begin, list) {
		print_subpage_area(current_item);
	}
}

