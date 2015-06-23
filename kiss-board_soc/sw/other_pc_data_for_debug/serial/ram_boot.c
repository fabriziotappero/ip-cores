
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

	if (2!=argc) {
		fprintf(stderr,"Usage:ram_write address_value\n");
		return -1;
	}

	serial_fd = open("/dev/ttyS0",O_RDWR);

	// serial buffer is cleared
	tcflush(serial_fd,TCIOFLUSH);

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
	while(1) {
		int serial_ioctl;
		serial_ioctl = 0;
		ioctl(serial_fd, TIOCMGET , &serial_ioctl);
		if (serial_ioctl&TIOCM_DSR) {
			fprintf(stderr,"DSR(DTR)\n");
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
	while(1) {
		int serial_ioctl;
		serial_ioctl = 0;
		ioctl(serial_fd, TIOCMGET , &serial_ioctl);
		if (serial_ioctl&TIOCM_DSR) {
			fprintf(stderr,"DSR(DTR)\n");
			break;
		}
		else{
			fprintf(stderr,"NO DSR(DTR)\n");
		}
	}

	// command(4byte)
	{
		tx(0x00); rx(0x00);
		tx(0x00); rx(0x00);
		tx(0x00); rx(0x00);
		tx(0x03); rx(0x03); // 0x00=nop 0x01=write 0x02=read 0x03=boot
	}

	// address(4byte)
	{
		unsigned long int address;
		unsigned char data;
		address = strtoul(argv[1],NULL,16);
		data = (unsigned char)(address>>24); tx(data); rx(data);
		data = (unsigned char)(address>>16); tx(data); rx(data);
		data = (unsigned char)(address>>8 );  tx(data); rx(data);
		data = (unsigned char)(address>>0 );  tx(data); rx(data);
	}

	// size(4byte)
	{
		tx(0x00); rx(0x00);
		tx(0x00); rx(0x00);
		tx(0x00); rx(0x00);
		tx(0x00); rx(0x00);
	}

	close(serial_fd);
	return 0;
}

void tx(unsigned char data){
	write(serial_fd,&data,1);
//fprintf(stderr,"tx:0x%02x ",data);
//fprintf(stderr,"*\r");
//	tcflush(serial_fd,TCOFLUSH); // force send
//	sleep(1);
	return;
}

unsigned char rx(unsigned char data){
	unsigned char ret;
	read(serial_fd,(void *)&ret,1);
//fprintf(stderr,"rx:0x%02x\n",ret);
//fprintf(stderr," \r");
//	if (ret!=data) {
//		fprintf(stderr,"ack data error\n");
//		exit(0);
//	}
	return ret;
}

