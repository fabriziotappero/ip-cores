/*
 * fpga_l3_fade - header for L3 communication protocol with FPGA based system
 * Copyright (C) 2012 by Wojciech M. Zabolotny
 * Institute of Electronic Systems, Warsaw University of Technology
 *
 *  This program is free software; you can redistribute it and/or modify
 *  it under the terms of the GNU General Public License as published by
 *  the Free Software Foundation; either version 2 of the License, or
 *  (at your option) any later version.
 *
 *  This program is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the GNU General Public License
 *  along with this program; if not, write to the Free Software
 *  Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 * 
 * Additionally I (Wojciech Zabolotny) allow you to include this header file
 * to compile your closed source applications (however yo should check, that 
 * license terms of other include files used by this one allow you to do it...). 
 */

#ifndef _FPGA_L3_FADE_H_


#include <linux/socket.h>
#include <linux/if_ether.h>
#include <linux/if.h>

struct l3_v1_buf_pointers {
  int head;
  int tail;
  char eof;
} __attribute__ ((__packed__));

struct l3_v1_slave  {
    unsigned char  mac[ETH_ALEN];
    char           devname[IFNAMSIZ];
}  __attribute__ ((__packed__));

struct l3_v1_usercmd {
  uint16_t cmd;
  uint16_t nr_of_retries;
  uint32_t arg;
  uint32_t timeout;
  uint8_t resp[12];
}  __attribute__ ((__packed__));

#define L3_V1_IOC_MAGIC 0xa5

#define L3_V1_IOC_SETWAKEUP	_IO(L3_V1_IOC_MAGIC,0x30)
#define L3_V1_IOC_GETBUFLEN 	_IO(L3_V1_IOC_MAGIC,0x31)
#define L3_V1_IOC_READPTRS 	_IOR(L3_V1_IOC_MAGIC,0x32,struct l3_v1_buf_pointers)
#define L3_V1_IOC_WRITEPTRS  	_IO(L3_V1_IOC_MAGIC,0x33)
#define L3_V1_IOC_GETMAC        _IOW(L3_V1_IOC_MAGIC,0x34,struct l3_v1_slave)
#define L3_V1_IOC_STARTMAC     	_IO(L3_V1_IOC_MAGIC,0x35)
#define L3_V1_IOC_STOPMAC     	_IO(L3_V1_IOC_MAGIC,0x36)
#define L3_V1_IOC_FREEMAC     	_IO(L3_V1_IOC_MAGIC,0x37)
#define L3_V1_IOC_USERCMD     	_IOWR(L3_V1_IOC_MAGIC,0x38,struct l3_v1_usercmd)
#define L3_V1_IOC_RESETMAC     	_IO(L3_V1_IOC_MAGIC,0x39)

/* Error flags */
#define FADE_ERR_INCORRECT_PACKET_TYPE (1<<0)
#define FADE_ERR_INCORRECT_SET (1<<1)
#define FADE_ERR_INCORRECT_LENGTH (1<<2)

/* Commands understood by the FPGA */
#define FCMD_START 1
#define FCMD_STOP 2
#define FCMD_ACK 3
#define FCMD_NACK 4
#define FCMD_RESET 5

#define _FPGA_L3_FADE_H_
#endif
