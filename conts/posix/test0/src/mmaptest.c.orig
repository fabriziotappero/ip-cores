/*
 * Test mmap/munmap posix calls.
 *
 * Copyright (C) 2007 - 2008 Bahadir Balban
 */
#include <sys/ipc.h>
#include <sys/shm.h>
#include <sys/types.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <fcntl.h>
#include <stdio.h>
#include <sys/stat.h>
#include <unistd.h>
#include <tests.h>

#define PAGE_SIZE		0x1000

int mmaptest(void)
{
	int fd;
	void *base;
	int x = 0x1000;

	if ((fd = open("./newfile.txt", O_CREAT | O_TRUNC | O_RDWR, S_IRWXU)) < 0)
		perror("open:");
	else
		printf("open: Success.\n");

	/* Extend the file */
	if ((int)lseek(fd, PAGE_SIZE*16, SEEK_SET) < 0)
		perror("lseek");
	else
		printf("lseek: Success.\n");

	if (write(fd, &x, sizeof(x)) < 0)
		perror("write");
	else
		printf("write: Success.\n");

	if ((int)(base = mmap(0, PAGE_SIZE*16, PROT_READ | PROT_WRITE, MAP_SHARED, fd, 0)) < 0)
		perror("mmap");
	else
		printf("mmap: Success: %p\n", base);

	*(unsigned int *)(base + PAGE_SIZE*2) = 0x1000;
	if (msync(base + PAGE_SIZE*2, PAGE_SIZE, MS_SYNC) < 0)
		perror("msync");
	else
		printf("msync: Success: %p\n", base);

	if (munmap(base + PAGE_SIZE*2, PAGE_SIZE) < 0)
		perror("munmap");
	else
		printf("munmap: Success: %p\n", base);
	*(unsigned int *)(base + PAGE_SIZE*3) = 0x1000;
	*(unsigned int *)(base + PAGE_SIZE*1) = 0x1000;

	return 0;
}
