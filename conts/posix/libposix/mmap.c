/*
 * Glue logic between posix mmap/munmap functions
 * and their L4 implementation.
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include <errno.h>
#include <stdio.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <l4lib/ipcdefs.h>
#include <libposix.h>

/* FIXME: Implement the same separation that is in read.c write.c etc. such that
 * l4_syscall returns negative value and then the actual posix glue sets the errno
 * rather than the l4_syscall sets it itself
 */

struct mmap_descriptor {
	void *start;
	size_t length;
	int prot;
	int flags;
	int fd;
	off_t offset;
};

static inline void *l4_mmap(void *start, size_t length, int prot, int flags, int fd, off_t pgoffset)
{
	/* Not enough MRs for all arguments, therefore we fill in a structure */
	struct mmap_descriptor desc = {
		.start = start,
		.length = length,
		.prot = prot,
		.flags = flags,
		.fd = fd,
		.offset = pgoffset,
	};
	int ret;

	write_mr(L4SYS_ARG0, (unsigned long)&desc);

	/* Call pager with MMAP request. Check ipc error. */
	if ((ret = l4_sendrecv(pagerid, pagerid, L4_IPC_TAG_MMAP)) < 0) {
		print_err("%s: IPC Error: %d.\n", __FUNCTION__, ret);
		return PTR_ERR(ret);
	}

	if (IS_ERR(ret = l4_get_retval()))
		print_err("%s: MMAP Error: %d.\n", __FUNCTION__, ret);

	return (void *)ret;
}

void *mmap2(void *start, size_t length, int prot, int flags, int fd, off_t pgoffset)
{
	void *ret = l4_mmap(start, length, prot, flags, fd, pgoffset);

	if (IS_ERR(ret)) {
		errno = -(int)ret;
		return MAP_FAILED;
	}
	return ret;
}


void *mmap(void *start, size_t length, int prot, int flags, int fd, off_t offset)
{
	return mmap2(start, length, prot, flags, fd, __pfn(offset));
}

int l4_munmap(void *start, size_t length)
{
	int err;

	write_mr(L4SYS_ARG0, (unsigned long)start);
	write_mr(L4SYS_ARG1, length);

	/* Call pager with MMAP request. */
	if ((err = l4_sendrecv(pagerid, pagerid, L4_IPC_TAG_MUNMAP)) < 0) {
		print_err("%s: IPC Error: %d.\n", __FUNCTION__, err);
		return err;
	}

	/* Check if syscall itself was successful */
	if ((err = l4_get_retval()) < 0) {
		print_err("%s: MUNMAP Error: %d.\n", __FUNCTION__, err);
		return err;
	}
	return 0;
}

int munmap(void *start, size_t length)
{
	int ret = l4_munmap(start, length);

	/* If error, return positive error code */
	if (ret < 0) {
		errno = -ret;
		return -1;
	}
	return 0;
}

int l4_msync(void *start, size_t length, int flags)
{
	write_mr(L4SYS_ARG0, (unsigned long)start);
	write_mr(L4SYS_ARG1, length);
	write_mr(L4SYS_ARG2, flags);

	/* Call pager with MMAP request. */
	if ((errno = l4_sendrecv(pagerid, pagerid, L4_IPC_TAG_MSYNC)) < 0) {
		print_err("%s: IPC Error: %d.\n", __FUNCTION__, errno);
		return -1;
	}
	/* Check if syscall itself was successful */
	if ((errno = l4_get_retval()) < 0) {
		print_err("%s: MSYNC Error: %d.\n", __FUNCTION__, errno);
		return -1;
	}
	return 0;
}

int msync(void *start, size_t length, int flags)
{
	int ret = l4_msync(start, length, flags);

	if (ret < 0) {
		errno = -ret;
		return -1;
	}
	return 0;
}

