/*
 * loadserv.c -- serial line load server
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>


#define SYN		((unsigned char) 's')
#define ACK		((unsigned char) 'a')

#define LINE_SIZE	520


static int debugCmds = 1;
static int debugData = 0;

static FILE *loadFile = NULL;
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
  if (loadFile != NULL) {
    fclose(loadFile);
    loadFile = NULL;
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


void connect(void) {
  unsigned char b;

  printf("SYN... ");
  fflush(stdout);
  while (!serialSnd(ACK)) ;
  tcdrain(sfd);
  printf("ACK... ");
  fflush(stdout);
  while (!serialRcv(&b)) ;
  if (b != ACK) {
    error("cannot synchronize with client");
  }
  printf("connected\n");
}


int main(int argc, char *argv[]) {
  char *serialPort;
  char *loadName;
  unsigned char b;
  unsigned char cmd;
  char line[LINE_SIZE];
  int n, i;

  if (argc != 3) {
    printf("Usage: %s <serial port> <file to be loaded>\n", argv[0]);
    exit(1);
  }
  serialPort = argv[1];
  loadName = argv[2];
  loadFile = fopen(loadName, "rt");
  if (loadFile == NULL) {
    error("cannot open file to be loaded '%s'", loadName);
  }
  /* open serial interface */
  serialOpen(serialPort);
  /* wait for client to connect */
  printf("Waiting for client...\n");
  while (1) {
    if (serialRcv(&b) && b == SYN) {
      break;
    }
  }
  connect();
  fseek(loadFile, 0, SEEK_SET);
  /* connected, now handle requests */
  while (1) {
    while (!serialRcv(&cmd)) ;
    if (cmd == 'q') {
      /* quit */
      if (debugCmds) {
        printf("quit\n");
      }
      break;
    }
    if (cmd == SYN) {
      /* this happens if the client has been reset */
      connect();
      fseek(loadFile, 0, SEEK_SET);
      continue;
    }
    if (cmd != 'r') {
      /* unknown command */
      if (debugCmds) {
        printf("unknown... UNCMD\n");
      }
      continue;
    }
    /* only read requests get here */
    if (debugCmds) {
      printf("reading record... ");
      fflush(stdout);
    }
    if (fgets(line, LINE_SIZE, loadFile) == NULL) {
      if (debugCmds) {
        printf("RDERR\n");
      }
    } else {
      n = strlen(line);
      for (i = 0; i < n; i++) {
        while (!serialSnd(line[i])) ;
      }
      tcdrain(sfd);
      if (debugCmds) {
        printf("OK\n");
      }
      if (debugData) {
        printf("%s", line);
      }
    }
  }
  if (loadFile != NULL) {
    fclose(loadFile);
    loadFile = NULL;
  }
  if (sfd != 0) {
    serialClose();
    sfd = 0;
  }
  return 0;
}
