#include <linux/ioctl.h>

#define SPARTAN_IOC_NUM 'S'
#define SPARTAN_IOC_MAX_NUM 11

#define SPARTAN_IOC_CURRESGET    _IO(SPARTAN_IOC_NUM, 1)            // read current resource - (0 = none)
#define SPARTAN_IOC_CURRESSET    _IO(SPARTAN_IOC_NUM, 2)            // set current resource
#define SPARTAN_IOC_CURBASE      _IOR(SPARTAN_IOC_NUM, 3, base)     // read current resource base address
#define SPARTAN_IOC_CURBASEMAP   _IOR(SPARTAN_IOC_NUM, 4, base)     // read current resource remaped base address ( 0 - not remaped)
#define SPARTAN_IOC_CURBASESIZE  _IOR(SPARTAN_IOC_NUM, 5, base_size)// read current resource size
#define SPARTAN_IOC_NUMOFRES     _IO(SPARTAN_IOC_NUM, 6)            // read number of found resources
#define SPARTAN_IOC_VIDEO_BASE     _IOR(SPARTAN_IOC_NUM, 7, base)            // read video buffer phyisical base address
#define SPARTAN_IOC_VIDEO_VBASE     _IOR(SPARTAN_IOC_NUM, 8, base)            // read video buffer virtual base address
#define SPARTAN_IOC_VIDEO_SIZE     _IOR(SPARTAN_IOC_NUM, 9, base_size)            // read video buffer size	
#define SPARTAN_IOC_SET_VIDEO_BUFF _IO(SPARTAN_IOC_NUM, 10)                // fill video buffer
#define SPARTAN_IOC_GET_VIDEO_BUFF _IO(SPARTAN_IOC_NUM, 11)                // copy video buffer to user space


#define SPARTAN_P_IMG_CTRL1_ADDR	0x110
#define SPARTAN_P_BA1_ADDR		0x114
#define SPARTAN_P_AM1_ADDR		0x118
#define SPARTAN_P_TA1_ADDR		0x11c


#define SPARTAN_W_IMG_CTRL1_ADDR        0x184
#define SPARTAN_W_BA1_ADDR              0x188
#define SPARTAN_W_AM1_ADDR              0x18C
#define SPARTAN_W_TA1_ADDR              0x190

#define SPARTAN_CRT_CTRL	        0x000
#define SPARTAN_CRT_ADD                 0x004
#define SPARTAN_CRT_PALETTE_BASE	0x400
