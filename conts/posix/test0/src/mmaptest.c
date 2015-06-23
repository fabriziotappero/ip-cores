/*
 * Test mmap/munmap posix calls.
 *
 * Copyright (C) 2007, 2008 Bahadir Balban
 */
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <unistd.h>
#include <tests.h>
#include <errno.h>

int mmaptest(void)
{
	int fd;
	void *base;
	int x = 0x1000;

	if ((fd = open("./mmapfile.txt", O_CREAT | O_TRUNC | O_RDWR, S_IRWXU)) < 0)
		goto out_err;

	/* Extend the file */
	if ((int)lseek(fd, PAGE_SIZE*16, SEEK_SET) < 0)
		goto out_err;

	if (write(fd, &x, sizeof(x)) < 0)
		goto out_err;

	if (IS_ERR(base = mmap(0, PAGE_SIZE*16, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0)))
		goto out_err;

	*(unsigned int *)(base + PAGE_SIZE*2) = 0x1000;
	if (msync(base + PAGE_SIZE*2, PAGE_SIZE, MS_SYNC) < 0)
		goto out_err;

	if (munmap(base + PAGE_SIZE*2, PAGE_SIZE) < 0)
		goto out_err;

	*(unsigned int *)(base + PAGE_SIZE*3) = 0x1000;
	*(unsigned int *)(base + PAGE_SIZE*1) = 0x1000;

	printf("MMAP TEST           -- PASSED --\n");
	return 0;

out_err:
	printf("MMAP TEST           -- FAILED --\n");
	return 0;
}

