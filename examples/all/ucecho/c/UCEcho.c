/*!
   UCEcho -- C host software for ucecho examples
   Copyright (C) 2009-2011 ZTEX GmbH.
   http://www.ztex.de

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License version 3 as
   published by the Free Software Foundation.

   This program is distributed in the hope that it will be useful, but
   WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
   General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program; if not, see http://www.gnu.org/licenses/.
!*/
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <usb.h>

#define BUFSIZE  256

struct usb_device *device;
usb_dev_handle *handle;
char buf[BUFSIZE];

// find the first ucecho device
struct usb_device *find_device ()
{
    struct usb_bus *bus_search;
    struct usb_device *device_search;

    bus_search = usb_busses;
    while (bus_search != NULL)
    {
	device_search = bus_search->devices;
    	while (device_search != NULL)
	{
	    if ( (device_search->descriptor.idVendor == 0x221a) && (device_search->descriptor.idProduct == 0x100) ) 
	    {
		handle = usb_open(device_search);
		usb_get_string_simple(handle, device_search->descriptor.iProduct, buf, BUFSIZE);
		if ( ! strncmp("ucecho", buf , 6 )  )
		    return device_search;
		usb_close(handle);
	    }
	    device_search = device_search->next;
	}
        bus_search = bus_search->next;
    }
    
    return NULL;
}

// main
int main(int argc, char *argv[])
{
    usb_init();						// initializing libusb
    usb_find_busses();					// ... finding busses
    usb_find_devices();					// ... and devices

    device = find_device();				// find the device (hopefully the correct one)

    if ( device == NULL ) {				// nothing found
	fprintf(stderr, "Cannot find ucecho device\n");
	return 1;
    }

    if (usb_claim_interface(handle, 0) < 0) {
	fprintf(stderr, "Error claiming interface 0: %s\n", usb_strerror());
	return 1;
    }
    
    while ( strcmp("QUIT", buf) ) {
	// read string from stdin
	printf("Enter a string or `quit' to exit the program: ");
	scanf("%s", buf);
	
	// write string to ucecho device 
	int i = usb_bulk_write(handle, 0x04, buf, strlen(buf)+1, 1000);
	if ( i < 0 ) {
	    fprintf(stderr, "Error sending data: %s\n", usb_strerror());
	    return 1;
	}
	printf("Send %d bytes: `%s'\n", i , buf);

	// read string back from ucecho device 
	i = usb_bulk_read(handle, 0x82, buf, BUFSIZE, 1000);
	if ( i < 0 ) {
	    fprintf(stderr, "Error readin data: %s\n", usb_strerror());
	    return 1;
	}
	printf("Read %d bytes: `%s'\n", i , buf);

    }

    usb_release_interface(handle, 0);
    usb_close(handle);
    return 0;
}
