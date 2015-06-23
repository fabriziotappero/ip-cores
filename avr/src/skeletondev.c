#include <stdint.h>
#include <stdio.h>
#include <string.h>
#include "device.h"

igordev_read_fn_t skeleton_read;
igordev_write_fn_t skeleton_write;
igordev_init_fn_t skeleton_init;
igordev_status_fn_t skeleton_read_status;
igordev_status_fn_t skeleton_write_status;
igordev_deinit_fn_t skeleton_deinit;

/* Example device for adding device-specific hooks. */

const char *str= "(cons foo bar)";

struct igordev igordev_skeleton = {
	.init = skeleton_init,
	.deinit = skeleton_deinit,
	.read = skeleton_read,
	.write = skeleton_write,
	.read_status = skeleton_read_status,
	.write_status = skeleton_write_status,
	.maxaddr = 14,
	.curaddr = 0,
	.priv = NULL
};

int skeletondev_loaded = 0;
int status;

/* Example initialization routine. */
void
skeleton_init(void)
{
	/* Initialize buffers. Could probably be device-independent */
	status = 0;
	/* Initialize skelton device-specific stuff. */
	skeletondev_loaded = 1;
}

/* Example read routine. */
uint8_t
skeleton_read(uint8_t *data, uint8_t numbytes)
{
	uint64_t curaddr, maxaddr;
	uint8_t i;

	curaddr = igordev_skeleton.curaddr;
	maxaddr = igordev_skeleton.maxaddr;
	printf("Reading in curdev (curaddr, maxaddr) = (%llu, %llu)\n", curaddr,
	    maxaddr);
	if (curaddr < 0 || curaddr >= maxaddr) {
		status = IDEV_STATUS_ERROR;
		return (0);
	}
	printf("numbytes: %d\n", numbytes);
	for (i = 0; i < numbytes && (i + curaddr) < maxaddr; i++) {
		printf("READING %c\n", str[i + curaddr]);
		*(data + i) = str[i + curaddr];
	}
	status = IDEV_STATUS_OK;
	return (i);
}

/* Example write routine. */
uint8_t
skeleton_write(uint8_t *data, uint8_t numbytes)
{
	int i;

	/* Write buffer data to device. We're just testing. */
	for (i = 0; i < numbytes; i++) {
#ifdef WITH_DEBUG
		printf("SKELTON OUT: %c\n", *(data + i));
#endif
	}
	status = IDEV_STATUS_OK;
	return (0);
}

/* Deinit. */
void
skeleton_deinit(void)
{
	skeletondev_loaded = 0;
}

/* 
 * Example on checking read status.
 * XXX: IMPORTANT: Use correct status flags.
 */
int8_t
skeleton_read_status(void)
{
	return (status);
}

/*
 * Example on checking write status.
 * XXX: IMPORTANT: Use correct status flags.
 */
int8_t
skeleton_write_status(void)
{
	/* 
	 * We do not support write, but one would here check write status of the
	 * device.
	 */
	return (status);
}

