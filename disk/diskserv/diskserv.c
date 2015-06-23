/*
 * diskserv.c -- serial line disk server
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <stdarg.h>
#include <fcntl.h>
#include <unistd.h>
#include <termios.h>


#define SYN		0x16
#define ACK		0x06

#define RESULT_OK	0x00
#define RESULT_UNCMD	0x01
#define RESULT_TOOBIG	0x02
#define RESULT_POSERR	0x03
#define RESULT_RDERR	0x04
#define RESULT_WRERR	0x05


static int debugCmds = 1;
static int debugData = 0;

static FILE *diskFile = NULL;
static unsigned int numSectors;
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


void sendResult(unsigned char result) {
  while (!serialSnd(result)) ;
  tcdrain(sfd);
}


void showData(unsigned char buffer[512]) {
  int i, j;
  unsigned char c;

  for (i = 0; i < 32; i++) {
    printf("%03X   ", i * 16);
    for (j = 0; j < 16; j++) {
      c = buffer[i * 16 + j];
      printf("%02X ", c);
    }
    printf("  ");
    for (j = 0; j < 16; j++) {
      c = buffer[i * 16 + j];
      if (c >= 0x20 && c < 0x7F) {
        printf("%c", c);
      } else {
        printf(".");
      }
    }
    printf("\n");
  }
}


int main(int argc, char *argv[]) {
  char *serialPort;
  char *diskName;
  int i;
  unsigned char b;
  unsigned char cmd;
  unsigned int sector;
  unsigned char buffer[512];

  if (argc != 3) {
    printf("Usage: %s <serial port> <disk image file>\n", argv[0]);
    exit(1);
  }
  serialPort = argv[1];
  diskName = argv[2];
  diskFile = fopen(diskName, "r+b");
  if (diskFile == NULL) {
    error("cannot open disk image file '%s'", diskName);
  }
  fseek(diskFile, 0, SEEK_END);
  numSectors = ftell(diskFile) / 512;
  fseek(diskFile, 0, SEEK_SET);
  printf("Disk '%s' has 0x%08X sectors.\n", diskName, numSectors);
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
  /* connected, now handle requests */
  while (1) {
    while (!serialRcv(&cmd)) ;
    if (cmd == 'q') {
      /* for tests only, a real client would never quit */
      if (debugCmds) {
        printf("quit\n");
      }
      break;
    }
    if (cmd == SYN) {
      /* this happens if the client has been reset */
      connect();
      continue;
    }
    if (cmd == 'c') {
      /* client asks for disk capacity */
      sendResult(RESULT_OK);
      for (i = 0; i < 4; i++) {
        b = (numSectors >> (8 * (3 - i))) & 0xFF;
        while (!serialSnd(b)) ;
      }
      tcdrain(sfd);
      if (debugCmds) {
        printf("capacity... OK\n");
      }
      continue;
    }
    if (cmd != 'r' && cmd != 'w') {
      /* unknown command */
      sendResult(RESULT_UNCMD);
      if (debugCmds) {
        printf("unknown... UNCMD\n");
      }
      continue;
    }
    /* only read and write requests get here */
    sector = 0;
    for (i = 0; i < 4; i++) {
      while (!serialRcv(&b)) ;
      sector = (sector << 8) | b;
    }
    if (cmd == 'r') {
      if (debugCmds) {
        printf("reading sector 0x%08X... ", sector);
        fflush(stdout);
      }
      if (sector >= numSectors) {
        sendResult(RESULT_TOOBIG);
        if (debugCmds) {
          printf("TOOBIG\n");
        }
      } else
      if (fseek(diskFile, sector * 512, SEEK_SET) != 0) {
        sendResult(RESULT_POSERR);
        if (debugCmds) {
          printf("POSERR\n");
        }
      } else
      if (fread(buffer, 1, 512, diskFile) != 512) {
        sendResult(RESULT_RDERR);
        if (debugCmds) {
          printf("RDERR\n");
        }
      } else {
        sendResult(RESULT_OK);
        for (i = 0; i < 512; i++) {
          while (!serialSnd(buffer[i])) ;
        }
        tcdrain(sfd);
        if (debugCmds) {
          printf("OK\n");
        }
        if (debugData) {
          showData(buffer);
        }
      }
      continue;
    }
    if (cmd == 'w') {
      if (debugCmds) {
        printf("writing sector 0x%08X... ", sector);
        fflush(stdout);
      }
      for (i = 0; i < 512; i++) {
        while (!serialRcv(buffer + i)) ;
      }
      if (sector >= numSectors) {
        sendResult(RESULT_TOOBIG);
        if (debugCmds) {
          printf("TOOBIG\n");
        }
      } else
      if (fseek(diskFile, sector * 512, SEEK_SET) != 0) {
        sendResult(RESULT_POSERR);
        if (debugCmds) {
          printf("POSERR\n");
        }
      } else
      if (fwrite(buffer, 1, 512, diskFile) != 512) {
        sendResult(RESULT_WRERR);
        if (debugCmds) {
          printf("WRERR\n");
        }
      } else {
        sendResult(RESULT_OK);
        if (debugCmds) {
          printf("OK\n");
        }
        if (debugData) {
          showData(buffer);
        }
      }
      continue;
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
