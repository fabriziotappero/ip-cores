/*
 * load.c -- load S-records from serial line
 */


#include "common.h"
#include "stdarg.h"
#include "romlib.h"
#include "load.h"
#include "serial.h"
#include "cpu.h"
#include "mmu.h"


#define NUM_TRIES	10
#define WAIT_DELAY	350000

#define SYN		((unsigned char) 's')
#define ACK		((unsigned char) 'a')

#define LINE_SIZE	520


static Byte line[LINE_SIZE];


static Word getByte(int index) {
  Word hi, lo;

  hi = line[index + 0];
  if (hi >= '0' && hi <= '9') {
    hi -= '0';
  } else
  if (hi >= 'A' && hi <= 'F') {
    hi -= 'A' - 10;
  } else
  if (hi >= 'a' && hi <= 'f') {
    hi -= 'a' - 10;
  } else {
    return (Word) -1;
  }
  lo = line[index + 1];
  if (lo >= '0' && lo <= '9') {
    lo -= '0';
  } else
  if (lo >= 'A' && lo <= 'F') {
    lo -= 'A' - 10;
  } else
  if (lo >= 'a' && lo <= 'f') {
    lo -= 'a' - 10;
  } else {
    return (Word) -1;
  }
  return (hi << 4) | lo;
}


static void serialOut(int serno, Word c) {
  if (serno == 0) {
    ser0out(c);
  } else {
    ser1out(c);
  }
}


static int serialChk(int serno) {
  if (serno == 0) {
    return ser0inchk();
  } else {
    return ser1inchk();
  }
}


static Word serialIn(int serno) {
  if (serno == 0) {
    return ser0in();
  } else {
    return ser1in();
  }
}


void load(int serno, Bool start) {
  int i, j;
  Bool run;
  int type;
  int count;
  Word chksum;
  Word addr;
  Byte b;

  printf("Trying to connect to load server...\n");
  for (i = 0; i < NUM_TRIES; i++) {
    serialOut(serno, SYN);
    for (j = 0; j < WAIT_DELAY; j++) {
      if (serialChk(serno) != 0) {
        break;
      }
    }
    if (j < WAIT_DELAY) {
      break;
    }
    printf("Request timed out...\n");
  }
  if (i == NUM_TRIES ||
      serialIn(serno) != ACK) {
    printf("Unable to establish connection to load server.\n");
    return;
  }
  serialOut(serno, ACK);
  printf("Connected to load server.\n");
  run = true;
  while (run) {
    serialOut(serno, 'r');
    for (i = 0; i < LINE_SIZE; i++) {
      line[i] = serialIn(serno);
      if (line[i] == '\n') {
        break;
      }
    }
    if (i == LINE_SIZE) {
      printf("Error: too many characters in S-record!\n");
      break;
    }
    line[i] = '\0';
    printf("%s\n", line);
    if (line[0] != 'S') {
      printf("Error: malformed S-record!\n");
      break;
    }
    type = line[1];
    count = getByte(2);
    if (i != 2 * count + 4) {
      printf("Error: inconsistent byte count in S-record!\n");
      break;
    }
    chksum = 0;
    for (j = 2; j < i; j += 2) {
      chksum += getByte(j);
    }
    if ((chksum & 0xFF) != 0xFF) {
      printf("Error: wrong checksum in S-record!\n");
      break;
    }
    switch (type) {
      case '0':
        /* S0 record: header (skip) */
        break;
      case '1':
        /* S1 record: 2 byte load address + data (load data) */
        addr = (getByte( 4) <<  8) |
               (getByte( 6) <<  0);
        addr |= 0xC0000000;
        for (j = 0; j < count - 3; j++) {
          b = getByte(2 * j + 8);
          mmuWriteByte(addr + j, b);
        }
        break;
      case '2':
        /* S2 record: 3 byte load address + data (load data) */
        addr = (getByte( 4) << 16) |
               (getByte( 6) <<  8) |
               (getByte( 8) <<  0);
        addr |= 0xC0000000;
        for (j = 0; j < count - 4; j++) {
          b = getByte(2 * j + 10);
          mmuWriteByte(addr + j, b);
        }
        break;
      case '3':
        /* S3 record: 4 byte load address + data (load data) */
        addr = (getByte( 4) << 24) |
               (getByte( 6) << 16) |
               (getByte( 8) <<  8) |
               (getByte(10) <<  0);
        addr |= 0xC0000000;
        for (j = 0; j < count - 5; j++) {
          b = getByte(2 * j + 12);
          mmuWriteByte(addr + j, b);
        }
        break;
      case '5':
        /* S5 record: record count (skip) */
        break;
      case '7':
        /* S7 record: 4 byte start address (set PC, stop loading) */
        addr = (getByte( 4) << 24) |
               (getByte( 6) << 16) |
               (getByte( 8) <<  8) |
               (getByte(10) <<  0);
        addr |= 0xC0000000;
        cpuSetPC(addr);
        run = false;
        break;
      case '8':
        /* S8 record: 3 byte start address (set PC, stop loading) */
        addr = (getByte( 4) << 16) |
               (getByte( 6) <<  8) |
               (getByte( 8) <<  0);
        addr |= 0xC0000000;
        cpuSetPC(addr);
        run = false;
        break;
      case '9':
        /* S9 record: 2 byte start address (set PC, stop loading) */
        addr = (getByte( 4) <<  8) |
               (getByte( 6) <<  0);
        addr |= 0xC0000000;
        cpuSetPC(addr);
        run = false;
        break;
      default:
        /* unknown type of S-record */
        printf("Error: unknown type of S-record!\n");
        run = false;
        break;
    }
  }
  serialOut(serno, 'q');
  printf("Connection to load server closed.\n");
  if (start) {
    cpuRun();
  }
}
