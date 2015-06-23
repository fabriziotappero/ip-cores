/*
 * l4/posix glue for open()
 *
 * Copyright (C) 2007 Bahadir Balban
 */
#include <errno.h>
#include <stdio.h>
#include <stdarg.h>
#include <string.h>
#include <sys/shm.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <l4lib/os/posix/kstat.h>
#include <l4lib/ipcdefs.h>
#include <l4lib/utcb.h>
#include <fcntl.h>
#include <l4/macros.h>
#include INC_GLUE(memory.h)
#include <shpage.h>
#include <libposix.h>

static inline int l4_fstat(int fd, void *buffer)
{
	int err;

	/* Pathname address on utcb page */
	write_mr(L4SYS_ARG0, fd);
	write_mr(L4SYS_ARG1, (unsigned long)buffer);

	/* Call pager with open() request. Check ipc error. */
	if ((err = l4_sendrecv_full(pagerid, pagerid, L4_IPC_TAG_FSTAT)) < 0) {
		print_err("%s: L4 IPC Error: %d.\n", __FUNCTION__, err);
		return err;
	}
	/* Check if syscall itself was successful */
	if ((err = l4_get_retval()) < 0) {
		print_err("%s: FSTAT Error: %d.\n", __FUNCTION__, err);
		return err;
	}
	return err;
}

int kstat_to_stat(struct kstat *ks, struct stat *s)
{
	s->st_dev = 0;
	s->st_ino = ks->vnum;
	s->st_mode = ks->mode;
	s->st_nlink = ks->links;
	s->st_uid = ks->uid;
	s->st_gid = ks->gid;
	s->st_rdev = 0;
	s->st_size = ks->size;
	s->st_blksize = ks->blksize;
	s->st_blocks = ks->size / ks->blksize;
	s->st_atime = ks->atime;
	s->st_mtime = ks->mtime;
	s->st_ctime = ks->ctime;

	return 0;
}

static inline int l4_stat(const char *pathname, void *buffer)
{
	int err;
	struct kstat ks;

	utcb_full_strcpy_from(pathname);

	/* Pathname address on utcb page */
	write_mr(L4SYS_ARG0, (unsigned long)utcb_full_buffer());

	/* Pass on buffer that should receive stat */
	write_mr(L4SYS_ARG1, (unsigned long)&ks);

	/* Call vfs with stat() request. Check ipc error. */
	if ((err = l4_sendrecv_full(pagerid, pagerid, L4_IPC_TAG_STAT)) < 0) {
		print_err("%s: L4 IPC Error: %d.\n", __FUNCTION__, err);
		return err;
	}

	/* Check if syscall itself was successful */
	if ((err = l4_get_retval()) < 0) {
		print_err("%s: STAT Error: %d.\n", __FUNCTION__, err);
		return err;
	}

	/* Convert c0-style stat structure to posix stat */
	kstat_to_stat(&ks, buffer);

	return err;
}

int fstat(int fd, struct stat *buffer)
{
	int ret;

	ret = l4_fstat(fd, buffer);

	/* If error, return positive error code */
	if (ret < 0) {
		errno = -ret;
		return -1;
	}
	/* else return value */
	return ret;

}

int stat(const char *pathname, struct stat *buffer)
{
	int ret;

	ret = l4_stat(pathname, buffer);

	/* If error, return positive error code */
	if (ret < 0) {
		errno = -ret;
		return -1;
	}
	/* else return value */
	return ret;

}

