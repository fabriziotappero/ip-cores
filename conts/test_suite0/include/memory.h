#ifndef __TESTSUITE_MEMORY_H__
#define __TESTSUITE_MEMORY_H__



void *virtual_page_new(int npages);
void *physical_page_new(int npages);
void virtual_page_free(void *address, int npages);
void physical_page_free(void *address, int npages);

void page_pool_init(void);
#endif /* __TESTSUITE_MEMORY_H__ */
