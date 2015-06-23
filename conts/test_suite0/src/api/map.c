/*
 * Test l4_map/unmap system call.
 *
 * Copyright (C) 2010 B Labs Ltd.
 *
 * Author: Bahadir Balban
 */
#include <l4lib/macros.h>
#include L4LIB_INC_ARCH(syscalls.h)
#include L4LIB_INC_ARCH(syslib.h)
#include INC_GLUE(memory.h)
#include <l4/api/errno.h>
#include <tests.h>

#define KERNEL_PAGE		0xF0000000UL
#define KIP_PAGE		0xFF000000UL
#define SYSCALL_PAGE		0xFFFFF000UL
#define VECTOR_PAGE		0xFFFF0000UL

int test_api_map(void)
{
	int err;
	unsigned int flags;
	l4id_t self = self_tid();

	/*
	 * Make a valid mapping, a few pages below
	 * the end of physical and virtual marks
	 */
	if ((err = l4_map((void *)CONFIG_CONT0_PHYS0_END - PAGE_SIZE * 5,
			  (void *)CONFIG_CONT0_VIRT0_END - PAGE_SIZE * 5,
			  1,
			  MAP_USR_RW,
			  self)) < 0) {
		dbg_printf("sys_map failed on valid request. err=%d\n",
			   err);
		return err;
	}

	/*
	 * Redo the same mapping. This should be valid.
	 */
	if ((err = l4_map((void *)CONFIG_CONT0_PHYS0_END - PAGE_SIZE * 5,
			  (void *)CONFIG_CONT0_VIRT0_END - PAGE_SIZE * 5,
			  1,
			  MAP_USR_RW,
			  self)) < 0) {
		dbg_printf("sys_map failed on re-doing "
			   "valid request. err=%d\n", err);
		return err;
	}

	/*
	 * Try mapping outside the virtual range
	 */
	if ((err = l4_map((void *)CONFIG_CONT0_PHYS0_END - PAGE_SIZE * 5,
			  (void *)CONFIG_CONT0_VIRT0_END,
			  1,
			  MAP_USR_RW,
			  self)) == 0) {
		dbg_printf("sys_map succeeded on invalid "
			   "virtual range ret=%d\n", err);
		return -1;
	}

	/*
	 * Try mapping outside the physical range
	 */
	if ((err = l4_map((void *)CONFIG_CONT0_PHYS0_END,
			  (void *)CONFIG_CONT0_VIRT0_END - PAGE_SIZE * 5,
			  1,
			  MAP_USR_RW,
			  self)) == 0) {
		dbg_printf("sys_map succeeded on invalid "
			   "physical range ret=%d\n", err);
		return -1;
	}

	/*
	 * Try having them both out of range
	 */
	if ((err = l4_map((void *)CONFIG_CONT0_PHYS0_END,
			  (void *)CONFIG_CONT0_VIRT0_END,
			  1,
			  MAP_USR_RW,
			  self)) == 0) {
		dbg_printf("sys_map succeeded when invalid "
			   "physical and virtual ranges "
			   "supplied ret=%d\n", err);
		return -1;
	}

	/*
	 * Try out of range by off-by-one page size excess
	 */
	if ((err = l4_map((void *)CONFIG_CONT0_PHYS0_END - PAGE_SIZE * 5,
			  (void *)CONFIG_CONT0_VIRT0_END - PAGE_SIZE * 5,
			  6,
			  MAP_USR_RW,
			  self)) == 0) {
		dbg_printf("sys_map succeeded when invalid "
			   "physical and virtual ranges using "
			   "off-by-one page size."
			   "ret=%d\n", err);
		return -1;
	}

	/*
	 * Try invalid page size
	 */
	if ((err = l4_map((void *)CONFIG_CONT0_PHYS0_END - PAGE_SIZE * 5,
			  (void *)CONFIG_CONT0_VIRT0_END - PAGE_SIZE * 5,
			  0xFFFFFFFF,
			  MAP_USR_RW,
			  self)) == 0) {
		dbg_printf("sys_map succeeded when invalid "
			   "page size supplied ret=%d\n", err);
		return -1;
	}

	/*
	 * Try invalid flags
	 */
	flags = 0;
	if ((err = l4_map((void *)CONFIG_CONT0_PHYS0_END - PAGE_SIZE * 5,
			  (void *)CONFIG_CONT0_VIRT0_END - PAGE_SIZE * 5,
			  1,
			  flags,
			  self)) == 0) {
		dbg_printf("sys_map succeeded when invalid "
			   "flags supplied flags=%u, ret=%d\n", flags, err);
		return -1;
	}
	flags = MAP_KERN_RWX;
	if ((err = l4_map((void *)CONFIG_CONT0_PHYS0_END - PAGE_SIZE * 5,
			  (void *)CONFIG_CONT0_VIRT0_END - PAGE_SIZE * 5,
			  1,
			  0,
			  self)) == 0) {
		dbg_printf("sys_map succeeded when invalid "
			   "flags supplied flags=%u, ret=%d\n", flags, err);
		return -1;
	}
	flags = MAP_KERN_IO;
	if ((err = l4_map((void *)CONFIG_CONT0_PHYS0_END - PAGE_SIZE * 5,
			  (void *)CONFIG_CONT0_VIRT0_END - PAGE_SIZE * 5,
			  1,
			  0,
			  self)) == 0) {
		dbg_printf("sys_map succeeded when invalid "
			   "flags supplied flags=%u, ret=%d\n", flags, err);
		return -1;
	}

	flags = MAP_KERN_RX;
	if ((err = l4_map((void *)CONFIG_CONT0_PHYS0_END - PAGE_SIZE * 5,
			  (void *)CONFIG_CONT0_VIRT0_END - PAGE_SIZE * 5,
			  1,
			  0,
			  self)) == 0) {
		dbg_printf("sys_map succeeded when invalid "
			   "flags supplied flags=%u, ret=%d\n", flags, err);
		return -1;
	}

	flags = 0xF0F0F01;
	if ((err = l4_map((void *)CONFIG_CONT0_PHYS0_END - PAGE_SIZE * 5,
			  (void *)CONFIG_CONT0_VIRT0_END - PAGE_SIZE * 5,
			  1,
			  0,
			  self)) == 0) {
		dbg_printf("sys_map succeeded when invalid "
			   "flags supplied flags=%u, ret=%d\n", flags, err);
		return -1;
	}

	/*
	 * Try passing wraparound values
	 */
	if ((err = l4_map((void *)0xFFFFFFFF,
			  (void *)CONFIG_CONT0_VIRT0_END - PAGE_SIZE * 5,
			  1,
			  MAP_USR_RW,
			  self)) == 0) {
		dbg_printf("sys_map succeeded when invalid "
			   "wraparound ranges supplied ret=%d\n", err);
		return -1;
	}

	/*
	 * Try passing wraparound values
	 */
	if ((err = l4_map((void *)CONFIG_CONT0_PHYS0_END - PAGE_SIZE * 5,
			  (void *)0xFFFFF000,
			  2,
			  MAP_USR_RW,
			  self)) == 0) {
		dbg_printf("sys_map succeeded when invalid "
			   "wraparound ranges supplied ret=%d\n", err);
		return -1;
	}

	/*
	 * Try mapping onto kernel
	 */
	if ((err = l4_map((void *)CONFIG_CONT0_PHYS0_END - PAGE_SIZE * 5,
			  (void *)0xF0000000,
			  1,
			  MAP_USR_RW,
			  self)) == 0) {
		dbg_printf("sys_map succeeded when trying to "
			   "map onto the kernel ret=%d\n", err);
		return -1;
	}

	/*
	 * Try mapping to vector page
	 */
	if ((err = l4_map((void *)CONFIG_CONT0_PHYS0_END - PAGE_SIZE * 5,
			  (void *)0xFFFF0000,
			  1,
			  MAP_USR_RW,
			  self)) == 0) {
		dbg_printf("sys_map succeeded when trying to "
			   "map to the vectors page ret=%d\n", err);
		return -1;
	}

	/*
	 * Try mapping to kip
	 */
	if ((err = l4_map((void *)CONFIG_CONT0_PHYS0_END - PAGE_SIZE * 5,
			  (void *)0xFF000000,
			  1,
			  MAP_USR_RW,
			  self)) == 0) {
		dbg_printf("sys_map succeeded when trying to "
			   "map to the kip page ret=%d\n", err);
		return -1;
	}

	/*
	 * Try mapping to syscall page
	 */
	if ((err = l4_map((void *)CONFIG_CONT0_PHYS0_END - PAGE_SIZE * 5,
			  (void *)0xFFFFF000,
			  1,
			  MAP_USR_RW,
			  self)) == 0) {
		dbg_printf("sys_map succeeded when trying to "
			   "map to the kip page ret=%d\n", err);
		return -1;
	}

	return 0;
}


int test_api_unmap(void)
{
	int err;
	l4id_t self = self_tid();

	/*
	 * Try a valid unmap
	 */
	if ((err = l4_unmap((void *)CONFIG_CONT0_VIRT0_END - PAGE_SIZE * 5,
			    1,
			    self)) < 0) {
		dbg_printf("sys_unmap failed on valid request. err=%d\n",
			   err);
		return err;
	}

	/*
	 * Try the same unmap, should return ENOMAP
	 */
	if ((err = l4_unmap((void *)CONFIG_CONT0_VIRT0_END - PAGE_SIZE * 5,
			    1,
			    self)) != -ENOMAP) {
		dbg_printf("sys_unmap did not return ENOMAP "
			   "on second unmap of same region. err=%d\n",
			   err);
		return -1;
	}


	/*
	 * Try unmapping privileged areas
	 */
	if ((err = l4_unmap((void *)KERNEL_PAGE, 1, self)) == 0) {
		dbg_printf("sys_unmap succeeded on invalid "
			   "unmap region. err=%d\n", err);
		return -1;
	}

	if ((err = l4_unmap((void *)VECTOR_PAGE, 1, self)) == 0) {
		dbg_printf("sys_unmap succeeded on invalid "
			   "unmap region. err=%d\n", err);
		return -1;
	}

	if ((err = l4_unmap((void *)SYSCALL_PAGE, 1, self)) == 0) {
		dbg_printf("sys_unmap succeeded on invalid "
			   "unmap region. err=%d\n", err);
		return -1;
	}

	/*
	 * Try unmapping with range rollover
	 */
	if ((err = l4_unmap((void *)KERNEL_PAGE, 0xFFFFFFFF, self)) == 0) {
		dbg_printf("sys_unmap succeeded on invalid "
			   "unmap region. err=%d\n", err);
		return -1;
	}
	if ((err = l4_unmap((void *)CONFIG_CONT0_VIRT0_END - PAGE_SIZE * 5,
			    0xFFFFFFFF, self)) == 0) {
		dbg_printf("sys_unmap succeeded on invalid "
			   "unmap region. err=%d\n", err);
		return -1;
	}

	/*
	 * Try unmapping zero pages
	 */
	if ((err = l4_unmap((void *)CONFIG_CONT0_VIRT0_END - PAGE_SIZE * 5,
			    0, self)) == 0) {
		dbg_printf("sys_unmap succeeded on invalid "
			   "unmap region. err=%d\n", err);
		return -1;
	}

	/*
	 * Try unmapping with invalid id
	 */
	if ((err = l4_unmap((void *)CONFIG_CONT0_VIRT0_END - PAGE_SIZE * 5,
			    1, 0xFFFFFFFF)) == 0) {
		dbg_printf("sys_unmap succeeded on invalid "
			   "unmap region. err=%d\n", err);
		return -1;
	}

	return 0;
}

int test_api_map_unmap(void)
{
	int err;

	if ((err = test_api_map()) < 0)
		goto out_err;

	if ((err = test_api_unmap()) < 0)
		goto out_err;


	printf("MAP/UNMAP:                     -- PASSED --\n");
	return 0;

out_err:
	printf("MAP/UNMAP:                     -- FAILED --\n");
	return err;

}

