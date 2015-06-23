#include <avr/io.h>
#include <avr/interrupt.h>
#include "global.h"

#include <stdint.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include "encdec.h"
#include "req.h"
#include "device.h"
#include "dispatch.h"
#include "dev/7seg.h"
#include "dev/spi.h"

#include "req.h"
#include "bus.h"

#include "uip/telnetd.h"
#include "uip/uip.h"
#include "uip/uip-conf.h"
#include "uip/uip_arp.h"
#include "uip/timer.h"
#include "uip/clock.h"
#include "dev/nic.h"
#include "dev/enc28j60-uip.c"

#define swap32(x)			\
	((((x) & 0xff000000) >> 24) |	\
	(((x) & 0x00ff0000) >>  8) |	\
	(((x) & 0x0000ff00) <<  8) |	\
	(((x) & 0x000000ff) << 24))

/* Peripherals we know of. */
//extern struct igordev igordev_boot;
extern struct igordev igordev_usart;
//extern struct igordev igordev_mmc;
//extern struct igordev igordev_kvga;
#define NUMDEV 1
struct igordev *idevs[NUMDEV];

// Currently seleted device
volatile uint32_t curdev;
// Last device performing interrupt.
volatile uint32_t intrdev;

volatile struct req *rqueue[MAXREQ];

static void	dispatch_request_perform(volatile struct req *);

void init_network_stuff(void);
void do_network_stuff(void);

#ifdef WITH_DEBUG
#define DEBUG(...) fprintf(stderr, __VA_ARGS__)
#else
#define DEBUG(...)
#endif
/* Contains the dispatcher and its routines. */
int
main(void)
{
	struct idev_mgmt *imgmt;
	volatile struct req *req;
	uint32_t i, data;

	cli();
	curdev = DEVTYPE_BOOT;

	/* Initialize device structure with the different device types. */
//	idevs[DEVTYPE_BOOT] = &igordev_boot;
	idevs[DEVTYPE_SERIAL] = &igordev_usart;
//	idevs[DEVTYPE_STORAGE] = &igordev_mmc;
//	idevs[DEVTYPE_TERM] = &igordev_kvga;

	for (i = 0; i < MAXREQ; i++)
		rqueue[i] = NULL;
	
	init_fpgabus();
	req_init();
	_delay_ms(1);
//	display_init(); // 7Seg init
	DEBUG("Initializing devices\n");
	configure_spi(); //Must run before Ethernet/MMC init
	for (i = 0; i < NUMDEV; i++) {
		idevs[i]->init();
		imgmt = &idevs[i]->imgmt;
		imgmt->irqenable = 0;
		imgmt->baseaddr = 0;
		imgmt->curaddr = 0;
		imgmt->size = 0;
	}
	init_network_stuff();
	DEBUG("Done initializing devices\n");

	/* Boot load test. */
//	for (i = 0; i < 10; i++) {
//		display_char(i);
//		_delay_ms(50.0);
//	}
//	display_char(curdev);
/*
   BOOT BLOCK LAYOUT

   +---------------------------+----------+
   | Boot program size         | 4 bytes  |
   +---------------------------+----------+
   | Data area size            | 4 bytes  |
   +---------------------------+----------+
   |                           |          |
   |  Boot program             | Variable |
   |                           |          |
   +---------------------------+----------+
   |                           |          |
   |  Data area                | Variable |
   |                           |          |
   +---------------------------+----------+
 
 */
	/* Initialize the device boot block layout. */
	/* Read boot program size */
//	igordev_mmc.read(0, (uint8_t *)&data, 4);
//	igordev_boot.imgmt.size = swap32(data);
//	igordev_mmc.read(0, (uint8_t *)&data, 4);
//	igordev_mmc.imgmt.size = swap32(data);
	/* Set up segments. */
//	igordev_boot.imgmt.baseaddr = 8;
//	igordev_mmc.imgmt.baseaddr = 8 + igordev_boot.imgmt.size;
	_delay_ms(10);
	sei();
//	avr_online();

	while (1) {
		
		/* Look through all active requests. */
		for (i = 0; i < MAXREQ; i++) {
			if (rqueue[i] == NULL)
				continue;
			req = rqueue[i];
			dispatch_request_perform(req);
			rqueue[i] = NULL;
			req_free(req);
		}
		do_network_stuff();
	}
	return (0);
}

static void
dispatch_request_perform(volatile struct req *req)
{
	struct igordev *idev;
	struct idev_mgmt *imgmt;
	volatile struct req *nreq;
	uint32_t data, d;
	uint8_t num, osize, total, *ptr;

	idev = req->dev;
	imgmt = &idev->imgmt;
	switch (req->type) {
	case REQ_TYPE_READ:
		/* Wait until device is ready. */
		while (idev->read_status != IDEV_STATUS_OK);
		total = DATA_SIZE_TYPE(DATA_TYPE_DEV(req->devnum));
		ptr = (uint8_t *)&data;
		while (idev->read_status != IDEV_STATUS_ERROR) {
			num = idev->read(imgmt->curaddr + imgmt->baseaddr, ptr,
			    total);
			total -= num;
			imgmt->curaddr += num;
			if (total <= 0)
				break;
			ptr += num;
		}
		if (idev->read_status == IDEV_STATUS_ERROR)
			return;
		if (req->flags & REQ_CALLBACK) {
			d = encode_object(data, req->devnum);

			DEBUG("Perform buffer read from main: '%c'\n", d);
			fpga_finish_read(d);
		}
		break;
	case REQ_TYPE_WRITE:
		/* Wait until device is ready. */
		while (idev->write_status != IDEV_STATUS_OK);

		data = decode_object(fpga_delayed_write(), req->devnum, &osize);
		total = osize;
//		if (imgmt->curaddr + total >= imgmt->size)
//			imgmt->curaddr = 0;
		/* Write until we have been able to write the data. */
		ptr = (uint8_t *)&data;
		while (idev->write_status != IDEV_STATUS_ERROR) {
			num = idev->write(imgmt->curaddr + imgmt->baseaddr, ptr,
			    osize);
			// Try and flush if we can't write
			// XXX: Should count and report error if it doesn't
			// help.
			if (num == 0)
				idev->flush();
			total -= num;
			imgmt->curaddr += num;
			if (total <= 0)
				break;
			ptr += num;
		}
		if (idev->write_status == IDEV_STATUS_ERROR)
			return;
		// Request a flush now that we finished the write.
		nreq = req_make(idev, REQ_TYPE_FLUSH, 0, req->devnum, NULL);
		if (nreq != NULL)
			dispatch_request_notify(nreq);
		break;
	case REQ_TYPE_FLUSH:
		idev->flush();
		break;
	case REQ_TYPE_FUNC:
		req->func(idev->priv);
		break;
	}
}

/* 
 * Notify the dispatcher of an I/O request. Note that the request is dropped if
 * there is no space for it in the queue!
 */
void
dispatch_request_notify(volatile struct req *req)
{
	uint8_t i;

	for (i = 0; i < MAXREQ; i++) {
		if (rqueue[i] == NULL) {
			rqueue[i] = req;
			return;
		}
	}
}

int8_t
dispatch_request_read(uint8_t addr, uint32_t *data)
{
	struct igordev *idev;
	struct idev_mgmt *imgmt;
	volatile struct req *req;
	uint32_t status;

	/* See what address we want to read from. */
	switch (addr) {
	case DEVICES:
		*data = OBJECT_NEW(TYPE_INT, NUMDEV);
		return (0);
	case CURDEV:
		*data = OBJECT_NEW(TYPE_INT, curdev);
		return (0);
	case CLI:
	case SAI:
		*data = 0;
		return (0);
	case INTRDEV:
		*data = OBJECT_NEW(TYPE_INT, intrdev);
		return (0);
	};

	/* Device-specific operation, so fetch currently enabled device. */
	idev = idevs[curdev];
	imgmt = &idev->imgmt;
	
	switch (addr) {
	/* Read an object from current device. */
	case OBJECT:
		break;
	/* Read lower 26 bits of current address from device. */
	case ADDR_L:
		*data = OBJECT_NEW(TYPE_INT, (uint32_t)(imgmt->curaddr >> 2));
		return (0);
	/* Read upper 26 bits of current address from device. */
	case ADDR_H:
		*data = OBJECT_NEW(TYPE_INT, (uint32_t)((imgmt->curaddr >> 2) >>
		    SIZE_INT));
		return (0);
	/* Read lower 26 bits of device size. */
	case SIZE_L:
		*data = OBJECT_NEW(TYPE_INT, (uint32_t)(imgmt->size >> 2));
		return (0);
	/* Read upper 26 bits of device size. */
	case SIZE_H:
		*data = OBJECT_NEW(TYPE_INT, (uint32_t)((imgmt->size >> 2) >>
		    SIZE_INT));
		return (0);
	/* Read status register of device. */
	case STATUS:
		status = (idev->read_status == IDEV_STATUS_OK);
		status |= ((idev->write_status == IDEV_STATUS_OK) <<
		    1);
		/* XXX: Error codes. */
		*data = OBJECT_NEW(TYPE_INT, status);
		return (0);
	/* Device identification. */
	case IDENTIFICATION:
		*data = OBJECT_NEW(TYPE_INT, idev->id);
		return (0);
	/* Read irq enable for device. */
	case IRQENABLE:
		*data = OBJECT_NEW(TYPE_INT, (uint32_t)imgmt->irqenable);
		return (0);
	default: /* XXX: Invalid address. */
		return (0);
	}

	DEBUG("Reading object of size %d\n", osize);
	/* Request for a read. */
	req = req_make(idev, REQ_TYPE_READ, REQ_CALLBACK, curdev, NULL);
	if (req == NULL)
		return (-1); /* XXX: Set error. */
	dispatch_request_notify(req);
	return (-1);
}

int8_t
dispatch_request_write(uint8_t addr, uint32_t data)
{
	struct igordev *idev;
	struct idev_mgmt *imgmt;
	volatile struct req *req;
	uint32_t status;
	uint64_t newaddr;
	uint8_t i; //num, osize;

	/* See what address we want to read from. */
	switch (addr) {
	/* Read-only */
	case DEVICES:
	case INTRDEV:
		return (0);
	case CURDEV:
		DEBUG("Setting current device\n");
		/* Should perhaps have some error signalling. */
		if (OBJECT_DATUM(data) >= NUMDEV)
			return (0); /* Invalid device. */
		curdev = OBJECT_DATUM(data);
		display_char(curdev);
		return (0);
	case CLI:
		for (i = 0; i < NUMDEV; i++)
			idevs[i]->imgmt.irqenable = 0;
		return (0);
	case SAI:
		for (i = 0; i < NUMDEV; i++)
			idevs[i]->imgmt.irqenable = 1;
		return (0);
	};
	idev = idevs[curdev];
	imgmt = &idev->imgmt;
	switch (addr) {
	/* Read-only. */
	case SIZE_L:
	case SIZE_H:
	case IDENTIFICATION:
		return (0);
	/* Write an object from current device. */
	case OBJECT:
		break;
	/* Write lower 26 bits of current address from device. */
	case ADDR_L:
		newaddr = (OBJECT_DATUM(data) << 2) |
		    ((uint64_t)((uint32_t)(imgmt->curaddr >> BSIZE_INT)) <<
		    BSIZE_INT);
		// Only set it if it does not exceed the device space.
		if (newaddr + imgmt->baseaddr < imgmt->size)
			imgmt->curaddr = newaddr;
		return (0);
	/* Read upper 26 bits of current address from device. */
	case ADDR_H:
		newaddr = ((OBJECT_DATUM(data) << 2) << BSIZE_INT) |
		    ((uint32_t)imgmt->curaddr);
		// Only set it if it does not exceed the device space.
		if (newaddr + imgmt->baseaddr < imgmt->size)
			imgmt->curaddr = newaddr;
		return (0);
	/* Read status register of device. */
	case STATUS:
		/* Writing 0 resets the error codes. */
		status = OBJECT_DATUM(data);
		if (status != 0)
			return (0); /* Not allowed. */
		/* XXX: reset error codes. */
		return (0);
	/* Set irq enable for device. */
	case IRQENABLE:
		imgmt->irqenable = OBJECT_DATUM(data);
		return (0);
	default: /* XXX: Invalid address. */
		return (0);
	}
	display_char(11);
	if ( idev == NULL ) 
	    display_char(13);
	req = req_make(idev, REQ_TYPE_WRITE, REQ_CALLBACK, curdev, NULL);
	display_char(4);
	if (req == NULL) {
		display_char(5);
		return (-2); /* XXX: panic */
	}
	display_char(6);
	dispatch_request_notify(req);
	display_char(7);
	return (-1);
}

/* Read data from kvga and put it in usart output buffer. */
/*void
dispatch_vga_to_usart(void *args)
{
	uint8_t data[MAXBUFLEN];
	uint8_t num;

	num = igordev_kvga.read(1, data, MAXBUFLEN);
	igordev_usart.write(1, data, num);
	while (igordev_usart.write_status != IDEV_STATUS_OK);
}
*/
//Network stuff - cleanup and integrate into driver framework later

#define BUF ((struct uip_eth_hdr *)&uip_buf[0])
struct timer periodic_timer, arp_timer;

void init_network_stuff(void)
{
	uip_ipaddr_t ipaddr;
	
	clock_init(); //This also activates interrupts
  
	timer_set(&periodic_timer, (clock_time_t)(F_CPU / 2));
	timer_set(&arp_timer, (clock_time_t)(F_CPU * 10));

	network_init();

	uip_init();

	uip_ipaddr(ipaddr, 192,168,0,25);
	uip_sethostaddr(ipaddr);

	uip_ipaddr(ipaddr, 255,255,255,0);
	uip_setnetmask(ipaddr);

	//Init applications
	telnetd_init();
}

void do_network_stuff(void)
{
	int i;
	uip_len = network_read();
	if(uip_len > 0) {
		if(BUF->type == htons(UIP_ETHTYPE_IP)) {
			uip_arp_ipin();
			uip_input();
	/* If the above function invocation resulted in data that
	   should be sent out on the network, the global variable
	   uip_len is set to a value > 0. */
			if(uip_len > 0) {
				uip_arp_out();
				network_send();
			}
		} else if(BUF->type == htons(UIP_ETHTYPE_ARP)) {
			uip_arp_arpin();
	/* If the above function invocation resulted in data that
	   should be sent out on the network, the global variable
	   uip_len is set to a value > 0. */
			if(uip_len > 0) {
				network_send();
			}
		}

	} else if(timer_expired(&periodic_timer)) {
		timer_reset(&periodic_timer);
		for(i = 0; i < UIP_CONNS; i++) {
			uip_periodic(i);
	/* If the above function invocation resulted in data that
	   should be sent out on the network, the global variable
	   uip_len is set to a value > 0. */
			if(uip_len > 0) {
				uip_arp_out();
				network_send();
			}
		}

#if UIP_UDP
		for(i = 0; i < UIP_UDP_CONNS; i++) {
			uip_udp_periodic(i);
	/* If the above function invocation resulted in data that
	   should be sent out on the network, the global variable
	   uip_len is set to a value > 0. */
			if(uip_len > 0) {
				uip_arp_out();
				network_send();
			}
		}
#endif /* UIP_UDP */
      
	/* Call the ARP timer function every 10 seconds. */
		if(timer_expired(&arp_timer)) {
			timer_reset(&arp_timer);
			uip_arp_timer();
		}
	}
}
