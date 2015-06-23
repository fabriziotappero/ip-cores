/*
 * This file is subject to the terms and conditions of the BSD License. See
 * the file "LICENSE" in the main directory of this archive for more details.
 *
 * Copyright (C) 2014 Aleksander Osman
 */

#include <cstdio>
#include <cstring>

#include <io.h>
#include <system.h>

int tst_0() {
    volatile unsigned char buf[512];

    int status = IORD(DRIVER_SD_0_BASE, 0);

    printf("SD card status: %d\n", status);

    memset((void *)buf, 0, sizeof(buf));

    IOWR(DRIVER_SD_0_BASE, 0, (int)buf);
    IOWR(DRIVER_SD_0_BASE, 1, 0);
    IOWR(DRIVER_SD_0_BASE, 2, 1);
    IOWR(DRIVER_SD_0_BASE, 3, 2); //read

    while(1) {
        status = IORD(DRIVER_SD_0_BASE, 0);
        printf("SD card status for read: %d\n", status);

        if(status == 2) break;
    }

    int i;
    for(i=0; i<512; i++) {
        if(i > 0 && (i%32) == 0) printf("\n");

        printf("%02x ", buf[i]);
    }
    printf("\n");

    for(i=0; i<512; i++) if(buf[i] != (unsigned char)i) printf("Not Equal: %d\n", i);

    for(i=0; i<512; i++) buf[i] = i;

    IOWR(DRIVER_SD_0_BASE, 0, (int)buf);
    IOWR(DRIVER_SD_0_BASE, 1, 0);
    IOWR(DRIVER_SD_0_BASE, 2, 1);
    IOWR(DRIVER_SD_0_BASE, 3, 3); //write

    while(1) {
        status = IORD(DRIVER_SD_0_BASE, 0);
        printf("SD card status for write: %d\n", status);

        if(status == 2) break;
    }

    return 0;
}

int tst_1() {

	unsigned char buf[1024];

	//IOWR(DRIVER_SD_0_BASE, 3, 1);

	while(IORD(DRIVER_SD_0_BASE, 0) != 2);

	printf("card init\n");

	unsigned char *slow_mem = (unsigned char *)0x08011000;
	for(int i=0; i<1024; i++) slow_mem[i] = i*3;

	/*
	for(int i=0; i<1024; i++) {
		if(i > 0 && (i%16) == 0) printf("\n");
		printf("%02x ", slow_mem[i]);
	}
	printf("\n----------\n");
	*/

	IOWR(DRIVER_SD_0_BASE, 0, (int)slow_mem);
	IOWR(DRIVER_SD_0_BASE, 1, 5859380);
	IOWR(DRIVER_SD_0_BASE, 2, 2);
	IOWR(DRIVER_SD_0_BASE, 3, 3);

	while(IORD(DRIVER_SD_0_BASE, 0) != 2);

	memset((void *)slow_mem, 0, sizeof(buf));
	memset((void *)buf,      0, sizeof(buf));

	for(int i=0; i<2; i++) {
		IOWR(DRIVER_SD_0_BASE, 0, (i==0)? (int)buf : (int)slow_mem);
		IOWR(DRIVER_SD_0_BASE, 1, 5859380);
		IOWR(DRIVER_SD_0_BASE, 2, 2);
		IOWR(DRIVER_SD_0_BASE, 3, 2);

		while(IORD(DRIVER_SD_0_BASE, 0) != 2);
	}

	if(memcmp((const void*)slow_mem, (const void *)buf, sizeof(buf)) != 0) printf("read mismatch !\n");

	int mismatched = 0;
	for(int i=0; i<1024; i++) {
		if(buf[i] != ((i*3) & 0xFF)) mismatched++;
	}
	printf("\nmismatched: %d\n", mismatched);

	if(mismatched > 0) {
		for(int i=0; i<1024; i++) {
			if(i > 0 && (i%16) == 0) printf("\n");
			printf("%02x ", slow_mem[i]);
		}
		printf("\n");
		for(int i=0; i<1024; i++) {
			if(i > 0 && (i%16) == 0) printf("\n");
			printf("%02x ", buf[i]);
		}
	}
	printf("\n");

	return 0;
}

int main() {

	while(IORD(DRIVER_SD_0_BASE, 0) != 2);

	printf("card init\n");

	tst_0();

	printf("filling memory from sd card...\n");

	unsigned char *sdram_ptr = (unsigned char *)0x00000000;

	IOWR(DRIVER_SD_0_BASE, 0, (int)sdram_ptr);
	IOWR(DRIVER_SD_0_BASE, 1, 0);
	IOWR(DRIVER_SD_0_BASE, 2, 262144);
	IOWR(DRIVER_SD_0_BASE, 3, 2); //read

	while(IORD(DRIVER_SD_0_BASE, 0) != 2);
	
	printf("done\n");

	return 0;
}


