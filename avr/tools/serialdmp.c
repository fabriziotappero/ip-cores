#include <termios.h>
#include <fcntl.h>
#include <strings.h>
#include <string.h>
#include <stdio.h>
#include <unistd.h>
#include "serialdmp.h"


static int fd;
struct termios settings, oldtio;

#define TYPES 12


static const char* types[TYPES] = {"NONE","INT","CONS","SNOC","PTR","ARRAY","NIL","T","CHAR","SYMBOL","FUNCTION","BUILTIN"};


int main() {
    unsigned char buffer[4];
    int i;

    if (serialinit() == -1 ) {
	printf("serialinit() failed. exiting\n");
	return -1;
    } else {
	printf("serialinit() completed");
    }
    for(i = 0 ; i< 4 ; i++ ) {
	buffer[i] = 0;
    }
    
    while ( 1 ) {
	getdata(buffer,sizeof(char));
	// If buffer = Unit Separator Convert to Object
	if ( buffer[0] == 17 ) {;
	    getdata(buffer,sizeof(buffer));
	    // This printf is somewhat.. ugly
	    printf("TYPE: %s\t DATA: 0x%02X%02X%02X\tRAW: 0x%02X%02X%02X%02X\n",(buffer[0]<TYPES)?types[buffer[0]]:"INVALID",buffer[1],buffer[2],buffer[3],buffer[0],buffer[1],buffer[2],buffer[3]);
	    
	} else {
	    printf("RAW byte read: 0x%02X - %c\n", buffer[0], isalpha(buffer[0])?buffer[0]:'.');
	}
    }

}



int serialinit() {
    
    fd = open(DEVICE, O_RDONLY | O_NOCTTY);
    if ( fd < 0 ) {
	perror(DEVICE);
	return -1;
    }

    tcgetattr(fd, &oldtio);
    bzero(&settings, sizeof(settings));

    settings.c_cflag = BAUDRATE | CRTSCTS | CS8 | CSTOPB | CLOCAL | CREAD;
    settings.c_iflag = IGNPAR;
    settings.c_oflag = 0;
    settings.c_lflag = 0;

    settings.c_cc[VMIN]		= 2;
    settings.c_cc[VTIME]	= 0;

    tcflush(fd, TCIFLUSH);
    tcsetattr(fd, TCSANOW, &settings);

    return 0;
}

void serialuninit() {
    tcsetattr(fd, TCSANOW, &oldtio);
    close(fd);
}

void getdata(char* data ,unsigned char length) {
    char vmin = settings.c_cc[VMIN];
    settings.c_cc[VMIN] = length;
    tcsetattr(fd,TCSANOW,&settings);
    read(fd, data, length);
    settings.c_cc[VMIN] = vmin;
    tcsetattr(fd,TCSANOW,&settings);
}

