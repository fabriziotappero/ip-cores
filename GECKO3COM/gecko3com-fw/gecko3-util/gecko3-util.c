/* GECKO3COM
 *
 * Copyright (C) 2008 by
 *   ___    ____  _   _
 *  (  _`\ (  __)( ) ( )   
 *  | (_) )| (_  | |_| |   Berne University of Applied Sciences
 *  |  _ <'|  _) |  _  |   School of Engineering and
 *  | (_) )| |   | | | |   Information Technology
 *  (____/'(_)   (_) (_)
 *
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details. 
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*********************************************************************/
/** \file     gecko3-util.c
 *********************************************************************
 * \brief     simple small helper tool for GECKO3COM
 *
 *            with this tool you can set the serial number, hw revision
 *            and FPGA type of a GECKO3COM driven device. 
 *            mainly this is the GECKO3main but the firmware could be
 *            used on other boards. \n
 *            Based on existing code of dfu-util and testlibusb
 *
 * \warning   does only work on little endian machines! 
 *
 * \author    Christoph Zimmermann bfh.ch
 * \date      2009-1-23 first version
 * \date      2009-8-25 fixed some little bugs. option --device works now, 
 *                      counts connected GECKO3 boards now correct.
 *
*/

#include <stdio.h>
#include <string.h>
#include <getopt.h>
#include <usb.h>
#include <errno.h>

#include "gecko3-util.h"

#define VERSION               "1.1"


/* global variables */
int debug;
static int verbose = 0;

/* type definitions */
struct usb_vendprod {
	u_int16_t vendor;
	u_int16_t product;
};

struct gecko3_if {
	u_int16_t vendor;
	u_int16_t product;
	u_int8_t configuration;
	u_int8_t interface;
	u_int8_t altsetting;
	unsigned int flags;
	struct usb_device *dev;

	struct usb_dev_handle *dev_handle;
};

static struct option opts[] = {
	{ "help", 0, 0, 'h' },
	{ "version", 0, 0, 'V' },
	{ "verbose", 0, 0, 'v' },
	{ "device", 1, 0, 'd' },
	{ "transfer-size", 1, 0, 't' },
	{ "set-serial", 1, 0, 's' },
	{ "set-hw-rev", 1, 0, 'r' },
	{ "set-fpga-type", 1, 0, 'f' },
	{ "set-fpga-idcode", 1, 0, 'i' },
};

/*----------------------------------------------------------------------------*/
/* start of functions block */

/* define a portable function for reading a 16bit little-endian word */
unsigned short get_int16_le(const void *p)
{
    const unsigned char *cp = p;

    return ( cp[0] ) | ( ((unsigned short)cp[1]) << 8 );
}

static int _get_first_cb(struct gecko3_if *dif, void *v)
{
	struct gecko3_if *v_dif = v;

	memcpy(v_dif, dif, sizeof(*v_dif)-sizeof(struct usb_dev_handle *));

	/* return a value that makes find_gecko3_if return immediately */
	return 1;
}


/* Iterate over all matching devices within system */
static int iterate_gecko3_devices(struct gecko3_if *dif,
    int (*action)(struct usb_device *dev, void *user), void *user)
{
	struct usb_bus *usb_bus;
	struct usb_device *dev;

	/* Walk the tree and find our device. */
	for (usb_bus = usb_get_busses(); NULL != usb_bus;
	     usb_bus = usb_bus->next) {
		for (dev = usb_bus->devices; NULL != dev; dev = dev->next) {
			int retval;

			if (dif && \
		    	    (dev->descriptor.idVendor == dif->vendor && \
			     dev->descriptor.idProduct == dif->product)) {
			  retval = action(dev, user);
			  if (retval)
			    return retval;
			}
		}
	}
	return 0;
}


static int found_gecko3_device(struct usb_device *dev, void *user)
{
	struct gecko3_if *dif = user;

	dif->dev = dev;
	return 1;
}


/* Find the first device, save it in gecko3_if->dev */
static int get_first_gecko3_device(struct gecko3_if *dif)
{
	return iterate_gecko3_devices(dif, found_gecko3_device, dif);
}


static int count_one_gecko3_device(struct usb_device *dev, void *user)
{
	int *num = user;

	(*num)++;
	return 0;
}


/* Count matching devices within system */
static int count_gecko3_devices(struct gecko3_if *dif)
{
	int num_found = 0;

	iterate_gecko3_devices(dif, count_one_gecko3_device, &num_found);
	return num_found;
}

static int parse_vendprod(struct usb_vendprod *vp, const char *str)
{
	unsigned long vend, prod;
	const char *colon;

	colon = strchr(str, ':');
	if (!colon || strlen(colon) < 2)
		return -EINVAL;

	vend = strtoul(str, NULL, 16);
	prod = strtoul(colon+1, NULL, 16);

	if (vend > 0xffff || prod > 0xffff)
		return -EINVAL;

	vp->vendor = vend;
	vp->product = prod;

	return 0;
}

static void help(void)
{
	printf("Usage: gecko3-util [options] ...\n"
		"  -h --help\t\t\tPrint this help message\n"
		"  -V --version\t\t\tPrint the version number\n"
		"  -v --verbose\n"
		"  -d --device vendor:product\tSpecify Vendor/Product ID of GECKO3COM device\n"
		"  -t --transfer-size\t\tSpecify the number of bytes per USB Transfer\n"
		"  -s --set-serial\t\tWrite the Serial Number. Expects a String as argument\n"
		"  -r --set-hw-rev\t\tWrite the Hardware Revision. Only one digit\n"
		"  -f --set-fpga-type\t\tWrite the FPGA type. Formated as ASCII String\n"
		"  -i --set-fpga-idcode\t\tWrite the FPGA JTAG IDCODE. This is a 32bit Integer value\n"
		);
}

static void print_version(void)
{
	printf("gecko3-util version %s\n", VERSION);
}

/*----------------------------------------------------------------------------*/

int main(int argc, char **argv)
{
	struct usb_vendprod vendprod;
	struct gecko3_if _rt_dif, _dif, *dif = &_dif;
	char serial_num[20] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
	unsigned int hw_rev;
	char fpga_type[20] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
	char fpga_idcode[20] = {0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0};
	int num_devs;
	unsigned int transfer_size = 0;
	const char *little_endian_data;
	int ret;
	
	printf("gecko3-util - (C) 2009 by Berne University of Applied Science\n"
	       "This program is Free Software and has ABSOLUTELY NO WARRANTY\n\n");

	memset(dif, 0, sizeof(*dif));
	dif->vendor = GECKO3COM_VID;
	dif->product = GECKO3COM_PID;
	dif->flags = 0;

	usb_init();
	//usb_set_debug(255);
	usb_find_busses();
	usb_find_devices();

	while (1) {
		int c, option_index = 0;
		c = getopt_long(argc, argv, "hVvd:t:s:r:i:f:", opts,
				&option_index);
		if (c == -1)
			break;

		switch (c) {
		case 'h':
			help();
			exit(0);
			break;
		case 'V':
			print_version();
			exit(0);
			break;
		case 'v':
			verbose = 1;
			break;
		case 'd':
			/* Parse device */
			if (parse_vendprod(&vendprod, optarg) < 0) {
				fprintf(stderr, "unable to parse `%s'\n", optarg);
				exit(2);
			}
			dif->vendor = vendprod.vendor;
			dif->product = vendprod.product;
			break;
		case 't':
			transfer_size = atoi(optarg);
			break;
		case 's':
		        dif->flags |= FL_SET_SERIAL;
			strcpy(serial_num, optarg);
			break;
		case 'i':
		        dif->flags |= FL_SET_FPGA_IDCODE;
			strcpy(fpga_idcode, optarg);
			break;
		case 'r':
		        dif->flags |= FL_SET_HW_REV;
			hw_rev = atoi(optarg);
			break;
		case 'f':
		        dif->flags |= FL_SET_FPGA_TYPE;
			strcpy(fpga_type, optarg);
			break;
		default:
		        help();
		        exit(2);
		}
	}


	if (dif->flags == 0) {
		fprintf(stderr, "You need to specify one of -s, -r, -f or -i\n\n");
		help();
		exit(2);
	}

	num_devs = count_gecko3_devices(dif);
	if (num_devs == 0) {
		fprintf(stderr, "No GECKO3COM USB device found\n");
		exit(1);
	} else if (num_devs > 1) {
		/* We do not support more than one GECKO3COM device */
		fprintf(stderr, "More than one GECKO3COM USB device found. "
		       "We can handle only one device at the same time. "
		       "Please disconnect all but one device\n");
		exit(3);
	}
	if (!get_first_gecko3_device(dif))
		exit(3);

	/* We have exactly one device. It's usb_device is now in dif->dev */

	printf("Opening USB Device 0x%04x:0x%04x...\n", dif->vendor, dif->product);
	dif->dev_handle = usb_open(dif->dev);
	if (!dif->dev_handle) {
		fprintf(stderr, "Cannot open device: %s\n", usb_strerror());
		exit(1);
	}

	printf("Claiming USB Interface...\n");
	if (usb_claim_interface(dif->dev_handle,GECKO3COM_IF) < 0) {
	        fprintf(stderr, "Cannot claim interface: %s\n",
			usb_strerror());
		exit(1);
	}

	/* write Serial Number to the device */
	if (dif->flags & FL_SET_SERIAL) {
	       printf("Write Serial Number...\n");
	       ret = usb_control_msg(dif->dev_handle, 
				     bmRT_TYPE_VENDOR | bmRT_DIR_OUT,  /* bmRequestType */
				     VRQ_SET_SERIAL,                   /* bRequest      */
				     0,                                /* wValue        */
				     0,                                /* wIndex        */
				     serial_num,                       /* Data          */
				     SERIAL_NO_LEN,                    /* wLength       */
				     TIMEOUT);
	       if (ret < 0) {
		       fprintf(stderr, "Cannot write Serial Number: %s\n",
			       usb_strerror());
		       exit(1);
	       }
	}

	/* write Hardware Revision to the device */
	if (dif->flags & FL_SET_HW_REV) {
	       printf("Write Hardware Revision...\n");
	       ret = usb_control_msg(dif->dev_handle, 
				     bmRT_TYPE_VENDOR | bmRT_DIR_OUT,  /* bmRequestType */
				     VRQ_SET_HW_REV,                   /* bRequest      */
				     0,                                /* wValue        */
				     0,                                /* wIndex        */
				     (char*)(&hw_rev),                 /* Data          */
				     1,                                /* wLength       */
				     TIMEOUT);
	       if (ret < 0) {
		       fprintf(stderr, "Cannot write Hardware Revision: %s\n",
			       usb_strerror());
		       exit(1);
	       }
	}

	/* write FPGA Type to the device */
	if (dif->flags & FL_SET_FPGA_TYPE) {
	       printf("Write FPGA Type...\n");
	       ret = usb_control_msg(dif->dev_handle, 
				     bmRT_TYPE_VENDOR | bmRT_DIR_OUT,  /* bmRequestType */
				     VRQ_SET_FPGA_TYPE,                /* bRequest      */
				     0,                                /* wValue        */
				     0,                                /* wIndex        */
				     fpga_type,                        /* Data          */
				     FPGA_TYPE_LEN,                    /* wLength       */
				     TIMEOUT);
	       if (ret < 0) {
		       fprintf(stderr, "Cannot write FPGA Type: %s\n",
			       usb_strerror());
		       exit(1);
	       }
	}

	/* write FPGA IDCODE to the device */
	if (dif->flags & FL_SET_FPGA_IDCODE) {
	       printf("Write FPGA IDCODE...\n");
	       ret = usb_control_msg(dif->dev_handle, 
				     bmRT_TYPE_VENDOR | bmRT_DIR_OUT,  /* bmRequestType */
				     VRQ_SET_FPGA_IDCODE,              /* bRequest      */
				     0,                                /* wValue        */
				     0,                                /* wIndex        */
				     fpga_idcode,                      /* Data          */
				     FPGA_IDCODE_LEN,                  /* wLength       */
				     TIMEOUT);
	       if (ret < 0) {
		       fprintf(stderr, "Cannot write FPGA IDCODE: %s\n",
			       usb_strerror());
		       exit(1);
	       }
	}

	printf("We're done. Cleaning up...\n");
	if (usb_release_interface(dif->dev_handle, GECKO3COM_IF) < 0) {
	        fprintf(stderr, "Cannot release interface: %s\n",
			usb_strerror());
		exit(1);
	}
	if (usb_close(dif->dev_handle) < 0) {
	        fprintf(stderr, "Cannot close USB device: %s\n",
			usb_strerror());
		exit(1);
	}
	printf("Finished\n");
	exit(0);
}
