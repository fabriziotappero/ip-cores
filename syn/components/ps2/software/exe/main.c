#include <stdio.h>
#include <unistd.h>

#include <system.h>
#include <io.h>

int main() {

	IOWR_8DIRECT(PS2_0_BASE, 4, 0x60);
	IOWR_8DIRECT(PS2_0_BASE, 0, 0x03);

	usleep(100000);

	IOWR_8DIRECT(PS2_0_BASE, 4, 0xD4);
	IOWR_8DIRECT(PS2_0_BASE, 0, 0xF4);

	while(1) {

		int impl   = IORD(PIO_0_BASE, 0);
		int status = IORD_8DIRECT(PS2_0_BASE, 4);

		if(impl & 0x02) { //mouse
			int scancode = IORD_8DIRECT(PS2_0_BASE, 0);
			printf("mouse: %02x, status: %02x\n", scancode, status);
		}
		if(impl & 0x01) { //keyboard
			int scancode = IORD_8DIRECT(PS2_0_BASE, 0);
			printf("keyboard: %02x, status: %02x\n", scancode, status);
		}
	}

	return 0;
}
