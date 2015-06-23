/*****************************************************************************/
/*   This file is a part of the GRLIB VHDL IP LIBRARY                        */
/*   Copyright (C) 2007 GAISLER RESEARCH                                     */
/*                                                                           */
/*   This program is free software; you can redistribute it and/or modify    */
/*   it under the terms of the GNU General Public License as published by    */
/*   the Free Software Foundation; either version 2 of the License, or       */
/*   (at your option) any later version.                                     */
/*                                                                           */
/*   See the file COPYING for the full details of the license.               */
/*****************************************************************************/

/* Changelog */
/* 2007-11-13: Simple Ethernet speed test added - Kristoffer Glembo */
/* 2007-11-13: GRETH BareC API added            - Kristoffer Glembo */

#include <stdlib.h>
#include <time.h>
#include "greth_api.h"

/* Set to 1 if using GRETH_GBIT, otherwise 0 */
#define GRETH_GBIT 1

/* Set to 10,100, or 1000 */
#define GRETH_SPEED 100

/* Set to 1 to run full duplex, 0 to run half duplex */
#define GRETH_FULLDUPLEX 1

#define GRETH_ADDR 0x80000b00

/* Destination MAC address */
#define DEST_MAC0  0x00
#define DEST_MAC1  0x13
#define DEST_MAC2  0x72
#define DEST_MAC3  0xAE
#define DEST_MAC4  0x72
#define DEST_MAC5  0x21

/* Source MAC address */
#define SRC_MAC0  0xDE
#define SRC_MAC1  0xAD
#define SRC_MAC2  0xBE
#define SRC_MAC3  0xEF
#define SRC_MAC4  0x00
#define SRC_MAC5  0x20 

struct greth_info greth;

int main(void) {

    unsigned long long i;
    unsigned char buf[1514];
    clock_t t1, t2;
    unsigned long long datasize;
    double time, bitrate;

    greth.regs = (greth_regs *) GRETH_ADDR;

    /* Dest. addr */
    buf[0] = DEST_MAC0;
    buf[1] = DEST_MAC1;
    buf[2] = DEST_MAC2;
    buf[3] = DEST_MAC3;
    buf[4] = DEST_MAC4;
    buf[5] = DEST_MAC5;

    /* Source addr */
    buf[6]  = SRC_MAC0;
    buf[7]  = SRC_MAC1;
    buf[8]  = SRC_MAC2;
    buf[9]  = SRC_MAC3;
    buf[10] = SRC_MAC4;
    buf[11] = SRC_MAC5;

    /* Length 1500 */
    buf[12] = 0x05;
    buf[13] = 0xDC;

    memcpy(greth.esa, &buf[6], 6);

    for (i = 14; i < 1514; i++) {
        buf[i] = i;
    }

    greth_init(&greth);

    printf("\nSending 1500 Mbyte of data to %.02x:%.02x:%.02x:%.02x:%.02x:%.02x\n", buf[0], buf[1], \
                                                                                    buf[2], buf[3], \
                                                                                    buf[4], buf[5]);
    t1 = clock();
    i = 0;
    while(i < (unsigned long long) 1024*1024) {

        /* greth_tx() returns 1 if a free descriptor is found, otherwise 0 */
        i += greth_tx(1514, buf, &greth);

    }
    t2 = clock();

    time = (double)(t2 - t1)/CLOCKS_PER_SEC;
    printf("\nTime: %f\n", time);

    datasize = (unsigned long long)1024*1024*1500*8; /* In bits */
    bitrate = (double) datasize/time;
    printf("Bitrate: %f Mbps\n", bitrate/(1024*1024));

    return 0;
}
