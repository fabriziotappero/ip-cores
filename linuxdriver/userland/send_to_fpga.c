/*
    Interface Program for the Linux Driver for Enterpoint's Raggedstone1 FPGA PCI Board
    This demo driver allows access to the Board's 7segment displays.
    
    License: GPL
    See file "GPL" for details

*/

#include <stdio.h>
#include <fcntl.h>      /* open */ 
#include <stdlib.h>     /* exit */
#include <sys/ioctl.h>  /* ioctl */
#include <netinet/in.h>

#define MAJOR_NUM 100
#define IOCTL_SETDPY _IOR(MAJOR_NUM, 0, short int)
#define DEVICE_NAME "/dev/fpga"


int ioctl_setdpy(int file_desc, short int data)
{
	int ret_val;

	ret_val = ioctl(file_desc, IOCTL_SETDPY, data);

	if (ret_val < 0) 
	{
		printf ("ioctl_set_msg failed:%d\n", ret_val);
		exit(-1);
	}
	return(0);
}

int main(int argc, char ** argv)
{
	int file_desc, ret_val;
	char *msg = "Message passed by ioctl\n";
	short int val = 0x7733;

	file_desc = open(DEVICE_NAME, 0);
	if (file_desc < 0) 
	{
		printf ("Can't open device file: %s\n", DEVICE_NAME);
		exit(-1);
	}

	if(argc >= 2 )
	{
//		sscanf(argv[1], "0x%x", &val);
		val = atoi(argv[1]);
//		val = htons(val);
	}
	else
		val = htons(val);
	ioctl_setdpy(file_desc, val);
	close(file_desc); 
	exit(0);
}
