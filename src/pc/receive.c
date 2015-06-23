/*
 * receive.c -- LogicProbe serial line receiver
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>


static int debug = 0;

static FILE *diskFile = NULL;
static int sfd = 0;
static struct termios origOptions;
static struct termios currOptions;


void serialClose(void);


void error(char *fmt, ...) {
  va_list ap;

  va_start(ap, fmt);
  printf("Error: ");
  vprintf(fmt, ap);
  printf("\n");
  va_end(ap);
  if (diskFile != NULL) {
    fclose(diskFile);
    diskFile = NULL;
  }
  if (sfd != 0) {
    serialClose();
    sfd = 0;
  }
  exit(1);
}


void serialOpen(char *serialPort) {
  sfd = open(serialPort, O_RDWR | O_NOCTTY | O_NDELAY);
  if (sfd == -1) {
    error("cannot open serial port '%s'", serialPort);
  }
  tcgetattr(sfd, &origOptions);
  currOptions = origOptions;
  cfsetispeed(&currOptions, B38400);
  cfsetospeed(&currOptions, B38400);
  currOptions.c_cflag |= (CLOCAL | CREAD);
  currOptions.c_cflag &= ~PARENB;
  currOptions.c_cflag &= ~CSTOPB;
  currOptions.c_cflag &= ~CSIZE;
  currOptions.c_cflag |= CS8;
  currOptions.c_cflag &= ~CRTSCTS;
  currOptions.c_lflag &= ~(ICANON | ECHO | ECHONL | ISIG | IEXTEN);
  currOptions.c_iflag &= ~(IGNBRK | BRKINT | IGNPAR | PARMRK);
  currOptions.c_iflag &= ~(INPCK | ISTRIP | INLCR | IGNCR | ICRNL);
  currOptions.c_iflag &= ~(IXON | IXOFF | IXANY);
  currOptions.c_oflag &= ~(OPOST | ONLCR | OCRNL | ONOCR | ONLRET);
  tcsetattr(sfd, TCSANOW, &currOptions);
}


void serialClose(void) {
  tcsetattr(sfd, TCSANOW, &origOptions);
  close(sfd);
}


int serialSnd(unsigned char b) {
  int n;

  n = write(sfd, &b, 1);
  return n == 1;
}


int serialRcv(unsigned char *bp) {
  int n;

  n = read(sfd, bp, 1);
  return n == 1;
}


int main(int argc, char *argv[]) {
  unsigned char b;
  int i, j;

  if (argc != 3) {
    printf("Usage: %s <serial_port> <data_file>\n", argv[0]);
    exit(1);
  }
  serialOpen(argv[1]);
  serialRcv(&b);
  diskFile = fopen(argv[2], "wb");
  if (diskFile == NULL) {
    error("cannot open data file %s for write", argv[2]);
  }
  for (i = 0; i < 512; i++) {
    if (debug) {
      printf("%03d:  ", i);
    }
    for (j = 0; j < 16; j++) {
      while (!serialRcv(&b)) ;
      if (fwrite(&b, 1, 1, diskFile) != 1) {
        error("cannot write to data file %s", argv[2]);
      }
      if (debug) {
        printf("%02X  ", b);
      }
    }
    if (debug) {
      printf("\n");
    }
  }
  if (diskFile != NULL) {
    fclose(diskFile);
    diskFile = NULL;
  }
  if (sfd != 0) {
    serialClose();
    sfd = 0;
  }
  return 0;
}
