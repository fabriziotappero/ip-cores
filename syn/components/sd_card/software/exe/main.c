
#include <stdio.h>
#include <system.h>
#include <io.h>

int main() {

	volatile unsigned char buf[512];

	int status = IORD(SD_CARD_0_BASE, 0);

	printf("SD card status: %d\n", status);

	memset(buf, 0, sizeof(buf));

	IOWR(SD_CARD_0_BASE, 0, buf);
	IOWR(SD_CARD_0_BASE, 1, 0);
	IOWR(SD_CARD_0_BASE, 2, 1);
	IOWR(SD_CARD_0_BASE, 3, 2); //read

	while(1) {
		status = IORD(SD_CARD_0_BASE, 0);
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

	IOWR(SD_CARD_0_BASE, 0, buf);
	IOWR(SD_CARD_0_BASE, 1, 0);
	IOWR(SD_CARD_0_BASE, 2, 1);
	IOWR(SD_CARD_0_BASE, 3, 3); //write

	while(1) {
		status = IORD(SD_CARD_0_BASE, 0);
		printf("SD card status for write: %d\n", status);

		if(status == 2) break;
	}


	return 0;
}
