/*
 * Copyright (C) 2009 Bahadir Balban
 */

#ifndef __BOOTMEM_H__
#define __BOOTMEM_H__

unsigned long bootmem_free_pages(void);
void *alloc_bootmem(int size, int alignment);
pmd_table_t *alloc_boot_pmd(void);

#endif /* __BOOTMEM_H__ */
