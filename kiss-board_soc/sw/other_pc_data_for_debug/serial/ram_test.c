
#include <termios.h>
#include <fcntl.h>
#include <sys/ioctl.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

int main(int argc,char *argv[]);
void tx(unsigned char data);			// tx data
unsigned char rx(unsigned char data);		// ack wait(blocking)

int serial_fd;

int main(int argc,char *argv[]){

	if (4!=argc) {
		fprintf(stderr,"Usage:\n");
		fprintf(stderr," ram_write dev_file address_value size_value\n");
		return -1;
	}

	serial_fd = open(argv[1],O_RDWR);

	// serial buffer is cleared
	tcflush(serial_fd,TCIOFLUSH);

while (1) {
	// DTR=1(active)
	{
		int serial_ioctl;
		serial_ioctl = 0;
		ioctl(serial_fd, TIOCMGET , &serial_ioctl);
		serial_ioctl = serial_ioctl | TIOCM_DTR;
		ioctl(serial_fd, TIOCMSET , &serial_ioctl);
//		serial_ioctl = 0;
//		ioctl(serial_fd, TIOCMGET , &serial_ioctl);
//		if (serial_ioctl&TIOCM_DSR)	fprintf(stderr,"DSR(DTR)\n");
//		else				fprintf(stderr,"NO DSR(DTR)\n");

	}
	// DTR=0(inactive)
	{
		int serial_ioctl;
		serial_ioctl = 0;
		ioctl(serial_fd, TIOCMGET , &serial_ioctl);
		serial_ioctl = serial_ioctl & ~(TIOCM_DTR);
		ioctl(serial_fd, TIOCMSET , &serial_ioctl);
//		serial_ioctl = 0;
//		ioctl(serial_fd, TIOCMGET , &serial_ioctl);
//		if (serial_ioctl&TIOCM_DSR)	fprintf(stderr,"DSR(DTR)\n");
//		else				fprintf(stderr,"NO DSR(DTR)\n");

	}
}
	fprintf(stderr,"WAIT NO DSR(DTR)\n");
	while(1) {
		int serial_ioctl;
		serial_ioctl = 0;
		ioctl(serial_fd, TIOCMGET , &serial_ioctl);
		if (serial_ioctl&TIOCM_DSR) {
			//fprintf(stderr,"DSR(DTR)\n");
		}
		else{
			fprintf(stderr,"NO DSR(DTR)\n");
			break;
		}
	}
	// DTR=1(active)
	{
		int serial_ioctl;
		serial_ioctl = 0;
		ioctl(serial_fd, TIOCMGET , &serial_ioctl);
		serial_ioctl = serial_ioctl | TIOCM_DTR;
		ioctl(serial_fd, TIOCMSET , &serial_ioctl);
//		serial_ioctl = 0;
//		ioctl(serial_fd, TIOCMGET , &serial_ioctl);
//		if (serial_ioctl&TIOCM_DSR)	fprintf(stderr,"DSR(DTR)\n");
//		else				fprintf(stderr,"NO DSR(DTR)\n");

	}
	fprintf(stderr,"WAIT DSR(DTR)\n");
	while(1) {
		int serial_ioctl;
		serial_ioctl = 0;
		ioctl(serial_fd, TIOCMGET , &serial_ioctl);
		if (serial_ioctl&TIOCM_DSR) {
			fprintf(stderr,"DSR(DTR)\n");
			break;
		}
		else{
			//fprintf(stderr,"NO DSR(DTR)\n");
		}
	}

	return 0;
}

