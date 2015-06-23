#include <pthread.h>
#include <unistd.h>

#include <stdlib.h>
#include <stdio.h>

#include "testbus.h"
#include "dispatch.h"
#include "encdec.h"
#include "device.h"

void * fpga_intr(void *);

#define MAXSLEEP 4

/* Our "interrupt" thread requireing reads and writes. */
pthread_t intrthr;

void init_fpgabus(void)
{
	srandom(time(0));
	printf("Init fpga\n");
	pthread_create(&intrthr, NULL, fpga_intr, NULL);
}

uint32_t writedata;
int wait_read = 0;
int wait_write = 0;

void *
fpga_intr(void *arg)
{
	uint32_t lval, data;
	uint32_t dataaddr;
	long rval;
	uint8_t addr;
	int error;

	/* XXX: for now. */
	addr = 0;
	dataaddr = 0;

	printf("Starting thread\n");

	while (1) {
		rval = (random() % MAXSLEEP) + 1;
		printf("Sleeping for %ld micro-seconds\n", rval);
		sleep(rval);
		rval = (random() % 9);

		// Silly way of doing it, but i'm lazy
		switch (rval) {
		case 0:
			// Do a object read
			/* Set address. */
			addr = ADDR_L;
			wait_write = 1;
			error = dispatch_request_write(addr, dataaddr);
			if (error) {
				printf("Have to wait for request\n");
				while (wait_write);
			} else
				printf("Successful setting address\n");

			/* Doing a read from curdev. */
			addr = OBJECT;
			printf("Requesting a read from a device.\n");
			wait_read = 1;
			error = dispatch_request_read(addr, &data);
			if (error) {
				printf("Have to wait for request\n");
				while (wait_read);
			} else
				printf("Got value 0x%x from dispatch\n", data);
			dataaddr++;
			break;
		case 1:
			// Do a object write
			addr = ADDR_L;
			wait_write = 1;
			error = dispatch_request_write(addr, dataaddr);
			if (error) {
				printf("Have to wait for request\n");
				while (wait_write);
			} else
				printf("Successful setting address\n");

			lval = (random() % 26) + 'a';
			printf("Requesting a write to a device.\n");
			wait_write = 1;
			writedata = lval;
			error = dispatch_request_write(addr, lval);
			if (error) {
				printf("Unable to perform the write at this "
				    "time, waiting\n");
				while (wait_write);
			}
			else
				printf("Wrote value 0x%x\n", lval);
			break;
		case 2:
			// Request to read number of devices.
			addr = DEVICES;
			printf("Requesting number of devices\n");
			error = dispatch_request_read(addr, &data);
			if (error)
				printf("Got error response\n");
			else
				printf("Number of devices: 0x%x\n", data);
			break;
		case 3:
			// Request to read current device
			addr = CURDEV;
			printf("Requesting curdev\n");
			error = dispatch_request_read(addr, &data);
			if (error)
				printf("Got error response on curdev\n");
			else
				printf("Curdev: 0x%x\n", data);
			break;
		case 4:
			// Request to know what device performed last interrupt
			addr = INTRDEV;
			printf("Requesting interrupt device\n");
			error = dispatch_request_read(addr, &data);
			if (error)
				printf("Got error response on INTRDEV\n");
			else
				printf("INTRDEV: 0x%x\n", data);
			break;
		case 5:
			// Per device stuff reading
			addr = SIZE_L;
			printf("Requesting device size\n");
			error = dispatch_request_read(addr, &data);
			if (error)
				printf("Got error response on SIZE_L\n");
			else
				printf("SIZE_L: 0x%x\n", data);
			break;
		case 6:
			addr = STATUS;
			printf("Requesting STATUS\n");
			error = dispatch_request_read(addr, &data);
			if (error)
				printf("Got error response on STATUS\n");
			else
				printf("STATUS: 0x%x\n", data);
			break;
		case 7:
			addr = IRQENABLE;
			printf("Requesting IRQENABLE\n");
			error = dispatch_request_read(addr, &data);
			if (error)
				printf("Got error response on IRQENABLE\n");
			else
				printf("IRQENABLE: 0x%x\n", data);
			break;
		// Write stuff
		case 8:
			addr = IRQENABLE;
			data = 0x10000001;
			printf("Requesting IRQENABLE write\n");
			error = dispatch_request_write(addr, data);
			if (error)
				printf("Got error response on IRQENABLE\n");
			else
				printf("IRQENABLE set!");
			break;
		}
	}
}

void fpga_finish_read(uint32_t data)
{
	printf("Finished a read, value: 0x%x\n", data);
	wait_read = 0;
}

uint32_t fpga_delayed_write(void)
{
	wait_write = 0;
	printf("Finished a write, value 0x%x returned\n", writedata);
	return (writedata);
}
