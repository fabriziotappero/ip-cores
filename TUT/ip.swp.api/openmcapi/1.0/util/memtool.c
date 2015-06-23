/*
 * Copyright (c) 2011, Mentor Graphics Corporation
 * All rights reserved.
 *
 * Redistribution and use in source and binary forms, with or without
 * modification, are permitted provided that the following conditions are met:
 *
 * 1. Redistributions of source code must retain the above copyright notice,
 *    this list of conditions and the following disclaimer.
 * 2. Redistributions in binary form must reproduce the above copyright notice,
 *    this list of conditions and the following disclaimer in the documentation
 *    and/or other materials provided with the distribution.
 * 3. Neither the name of the <ORGANIZATION> nor the names of its contributors
 *    may be used to endorse or promote products derived from this software
 *    without specific prior written permission.
 *
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
 * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
 * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
 * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
 * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
 * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
 * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
 * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
 * POSSIBILITY OF SUCH DAMAGE.
 */

/* XXX would be better to stay closer to dd(1) parameters and functionality */

#include <stdio.h>
#include <sys/mman.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <stdlib.h>
#include <string.h>
#include <assert.h>
#include <sys/ioctl.h>
#include <getopt.h>
#include <limits.h>

#define DEVMCOMM "/dev/mcomm"

typedef int (*command_t)(void *mem, size_t bytes, unsigned long base);

static ssize_t read_mcomm_size(void)
{
	ssize_t size;
	unsigned long val;
	FILE *f;
	int rc;

	f = fopen("/sys/devices/mcomm.0/size", "r");
	if (!f)
		return -ENOENT;

	rc = fscanf(f, "%lx", &val);
	size = val;
	if (rc < 0) {
		perror("fscanf");
		size = -EINVAL;
	}

	fclose(f);

	return size;
}

static void *map(int fd, ssize_t bytes, unsigned long off)
{
	void *mem = NULL;

	mem = mmap(NULL, bytes, PROT_READ|PROT_WRITE, MAP_SHARED, fd, off);
	if (mem == MAP_FAILED) {
		perror("mmap");
		return NULL;
	}

	return mem;
}

static void unmap(int fd, void *mem, int bytes)
{
	close(fd);
	munmap(mem, bytes);
}

void usage(char *name)
{
	printf("Usage: %s [options] <command>\n"
	       "Options:\n"
		   "  -d, --device=<path>\n"
		   "          Device to open.\n"
		   "\n"
		   "  -o, --offset=<offset>\n"
		   "          Offset (in bytes) at which to start. Must be page-aligned.\n"
		   "\n"
		   "  -l, --length=<length>\n"
		   "          Number of bytes on which to operate.\n"
		   "          Defaults to the entire mcomm region, or 4K for other devices.\n"
		   "\n"
	       "Commands:\n"
		   "  clear: zeroes memory\n"
		   "  dump:  dump memory contents as hex\n",
		   name);
	exit(1);
}

static int clear(void *mem, size_t bytes, unsigned long base)
{
	memset(mem, 0, bytes);
	return 0;
}

static int dump(void *addr, size_t bytes, unsigned long base)
{
	const int COLS = 4;
	unsigned int *data = addr;
	int pos, i;

    for (pos = 0; sizeof(int) * pos < bytes; pos += COLS) {
        printf("%08lx:", base + pos * sizeof(int));
        for (i = 0; i < COLS; i++)
            printf(" %08x", data[pos + i]);
        printf("\n");
    }

	return 0;
}

int main(int argc, char *argv[])
{
	unsigned long offset = 0;
	unsigned long length = ULONG_MAX;
	char *dev = "/dev/mem";
	unsigned int *mem;
	command_t command = NULL;
	ssize_t bytes;
	int dev_fd;
	int c;
	int rc = 0;
	unsigned int pagesize;

	while (1) {
		static struct option long_options[] = {
			{"device", 1, 0, 'd'},
			{"offset", 1, 0, 'o'},
			{"length", 1, 0, 'l'},
			{NULL, 0, 0, 0},
		};
		int option_index = 0;

		c = getopt_long(argc, argv, "d:o:l:", long_options, &option_index);
		if (c == -1)
			break;

		switch (c) {
		case 'd':
			dev = optarg;
			break;

		case 'o':
			offset = strtoul(optarg, NULL, 0);
			if (offset == ULONG_MAX) {
				printf("couldn't use offset\n");
				usage(argv[0]);
			}
			pagesize = getpagesize();
			if (offset & (pagesize-1)) {
				printf("offset must be a multiple of 0x%x\n", pagesize);
				usage(argv[0]);
			}
			break;

		case 'l':
			length = strtoul(optarg, NULL, 0);
			if (length == ULONG_MAX) {
				printf("couldn't use length\n");
				usage(argv[0]);
			}
			break;

		default:
			printf("%d\n", c);
			usage(argv[0]);
		}
	}

	if (optind < argc) {
		char *cmdstr = argv[optind];

		if (strcmp(cmdstr, "dump") == 0)
			command = dump;
		else if (strcmp(cmdstr, "clear") == 0)
			command = clear;

		optind++;
	}

	if ((optind < argc) || (command == NULL)) {
		usage(argv[0]);
	}

	dev_fd = open(dev, O_RDWR);
	if (dev_fd < 0) {
		rc = errno;
		perror("open");
		return rc;
	}

	if (strncmp(dev, DEVMCOMM, strlen(DEVMCOMM)) == 0) {
		bytes = read_mcomm_size();
		if (bytes <= 0) {
			perror("read mcomm size");
			goto out;
		}
	} else {
		bytes = 1<<12;
	}

	if (length < bytes)
		bytes = length;

	mem = map(dev_fd, bytes, offset);
	if (mem == NULL) {
		rc = -1;
		goto out;
	}

	rc = command(mem, bytes, offset);

	unmap(dev_fd, mem, bytes);

out:
	return rc;
}
