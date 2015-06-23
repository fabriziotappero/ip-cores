/*
 * WISHBONE SD Card Controller IP Core
 *
 * sd_example.c
 *
 * This file is part of the WISHBONE SD Card
 * Controller IP Core project
 * http://opencores.org/project,sd_card_controller
 *
 * Description
 * Example application using WISHBONE SD Card Controller
 * IP Core. The app perform core initialisation,
 * mmc/sd card initialisation and then reads one block
 * of data from the card.
 * This app is using some of code from u-boot project
 * (mmc.c and mmc.h)
 *
 * Author(s):
 *     - Marek Czerski, ma.czerski@gmail.com
 */
/*
 *
 * Copyright (C) 2013 Authors
 *
 * This source file may be used and distributed without
 * restriction provided that this copyright statement is not
 * removed from the file and that any derivative work contains
 * the original copyright notice and the associated disclaimer.
 *
 * This source file is free software; you can redistribute it
 * and/or modify it under the terms of the GNU Lesser General
 * Public License as published by the Free Software Foundation;
 * either version 2.1 of the License, or (at your option) any
 * later version.
 *
 * This source is distributed in the hope that it will be
 * useful, but WITHOUT ANY WARRANTY; without even the implied
 * warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
 * PURPOSE. See the GNU Lesser General Public License for more
 * details.
 *
 * You should have received a copy of the GNU Lesser General
 * Public License along with this source; if not, download it
 * from http://www.opencores.org/lgpl.shtml
 */

#include "mmc.h"
#include <stdio.h>
#include <stdlib.h>

struct mmc * ocsdc_mmc_init(int base_addr, int clk_freq);

#define BLKSIZE 512
#define BLKCNT 10

char buff[BLKSIZE*BLKCNT] = {'\0'};

void printHex(const void *lpvbits, const unsigned int n) {
    char* data = (char*) lpvbits;
    unsigned int i = 0;
    char line[17] = {};
    printf("%.8X | ", (unsigned int)data);
    while ( i < n ) {
        line[i%16] = *(data+i);
        if ((line[i%16] < 32) || (line[i%16] > 126)) {
            line[i%16] = '.';
        }
        printf("%.2X", (unsigned char)*(data+i));
        i++;
        if (i%4 == 0) {
            if (i%16 == 0) {
                if (i < n-1)
                    printf(" | %s\n\r%.8X | ", line, (unsigned int)data+i);
            } else {
                printf(" ");
            }
        }
    }
    while (i%16 > 0) {
        (i%4 == 0)?printf("   "):printf("  ");
        line[i%16] = ' ';
        i++;
    }
    printf(" | %s\n\r", line);
}

int main(void) {
	printf("Hello World !!!\n\r");

	//init ocsdc driver
	struct mmc * drv = ocsdc_mmc_init(0x9e000000, 50000000);
	if (!drv) {
		printf("ocsdc_mmc_init failed\n\r");
		return -1;
	}
	printf("ocsdc_mmc_init success\n\r");

	drv->has_init = 0;
	int err = mmc_init(drv);
	if (err != 0 || drv->has_init == 0) {
		printf("mmc_init failed\n\r");
		return -1;
	}
	printf("mmc_init success\n\r");

	print_mmcinfo(drv);

	//read 1 block
	printf("attempting to read 1 block\n\r");
	if (mmc_bread(drv, 0, 1, buff) == 0) {
		printf("mmc_bread failed\n\r");
		return -1;
	}
	printf("mmc_bread success\n\r");

	printHex(buff, BLKSIZE);

	return EXIT_SUCCESS;
}
