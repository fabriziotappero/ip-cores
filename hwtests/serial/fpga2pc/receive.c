/*
 * receive.c -- serial line test program
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>


#define NUM_TRIES	10

#define SYN		0x16
#define ACK		0x06


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
  char *serialPort;
  unsigned char prev, curr;
  int count, errors;

  if (argc != 2) {
    printf("Usage: %s <serial port>\n", argv[0]);
    exit(1);
  }
  serialPort = argv[1];
  serialOpen(serialPort);
  count = 0;
  errors = 0;
  while (!serialRcv(&prev)) ;
  count++;
  while (count < 100000) {
    while (!serialRcv(&curr)) ;
    count++;
    if (((prev + 1) & 0xFF) != curr) {
      errors++;
    }
    prev = curr;
  }
  if (sfd != 0) {
    serialClose();
    sfd = 0;
  }
  printf("count = %d (ok = %d, errors = %d)\n",
         count, count - errors, errors);
  return 0;
}
