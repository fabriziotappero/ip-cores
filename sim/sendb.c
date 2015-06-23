#include <stdio.h>   /* Standard input/output definitions */
#include <string.h>  /* String function definitions */
#include <unistd.h>  /* UNIX standard function definitions */
#include <fcntl.h>   /* File control definitions */
#include <errno.h>   /* Error number definitions */
#include <termios.h> /* POSIX terminal control definitions */

#include <curses.h>

int getbaud(int fd) {
	struct termios termAttr;
	int inputSpeed = -1;
	speed_t baudRate;
	tcgetattr(fd, &termAttr);
	/* Get the input speed.                              */
	baudRate = cfgetispeed(&termAttr);
	switch (baudRate) {
		case B0:      inputSpeed = 0; break;
		case B50:     inputSpeed = 50; break;
		case B110:    inputSpeed = 110; break;
		case B134:    inputSpeed = 134; break;
		case B150:    inputSpeed = 150; break;
		case B200:    inputSpeed = 200; break;
		case B300:    inputSpeed = 300; break;
		case B600:    inputSpeed = 600; break;
		case B1200:   inputSpeed = 1200; break;
		case B1800:   inputSpeed = 1800; break;
		case B2400:   inputSpeed = 2400; break;
		case B4800:   inputSpeed = 4800; break;
		case B9600:   inputSpeed = 9600; break;
		case B19200:  inputSpeed = 19200; break;
		case B38400:  inputSpeed = 38400; break;
		case B115200:  inputSpeed = 115200; break;
	}
	return inputSpeed;
}


int fd;

int initport(int fd) {
	struct termios options;
	// Get the current options for the port...
	tcgetattr(fd, &options);
	// Set the baud rates to 19200...
	cfsetispeed(&options, B115200);
	cfsetospeed(&options, B115200);
	// Enable the receiver and set local mode...
	options.c_cflag |= (CLOCAL | CREAD);

	options.c_cflag &= ~PARENB;
	options.c_cflag &= ~CSTOPB;
	options.c_cflag &= ~CSIZE;
	options.c_cflag |= CS8;

	// Set the new options for the port...
	tcsetattr(fd, TCSANOW, &options);
	return 1;
}

int main(int argc, char **argv) 
{
	int ch, count=0;

	fd = open("/dev/ttyUSB0", O_RDWR | O_NOCTTY | O_NDELAY);
	if (fd == -1) {
		perror("open_port: Unable to open /dev/ttyUSB0 - ");
		return 1;
	} else {
		fcntl(fd, F_SETFL, 0);
	}
	
	printf("baud=%d\n", getbaud(fd));
	initport(fd);
	printf("baud=%d\n", getbaud(fd));

	
	while(((ch=getchar())!=-1) /*|| count<256*/) {
//	  if(ch==-1) ch=0x00;   
//	  usleep(100);
	  write(fd, &ch, 1);
//          printf("%02x ", ch);	  
	  //fflush(stdout);
	  count++;
	}

	puts("\n\n=>\n\n");
	usleep(50000);
	
//	while((read(fd, &ch, 1)>0) && (getch()==ERR)) {
//	  printf("%02x ", (unsigned char) ch);
//	  fflush(stdout);
//	}

	close(fd);
	return 0;
}

