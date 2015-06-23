/*****************************************************************************/
/*   This file is a part of the GRLIB VHDL IP LIBRARY */
/*   Copyright (C) 2004 GAISLER RESEARCH */

/*   This program is free software; you can redistribute it and/or modify */
/*   it under the terms of the GNU General Public License as published by */
/*   the Free Software Foundation; either version 2 of the License, or */
/*   (at your option) any later version. */

/*   See the file COPYING for the full details of the license. */
/*****************************************************************************/


/*****************************************************************************/
/*Testroutine for GRSPW. Must be used with one device in loopback mode       */
/*****************************************************************************/
#include <stdlib.h>
#include "spwapi.h"
#include "rmapapi.h"

#define SPW_ADDR    0x80000c00
#define AHBFREQ     40000

#define PKTTESTMAX  128
#define DESCPKT     1024
#define MAXSIZE     4194304
#define RMAPSIZE    1024
#define RMAPCRCSIZE 1024

static inline char loadb(int addr)
{
  char tmp;        
  asm(" lduba [%1]1, %0 "
      : "=r"(tmp)
      : "r"(addr)
    );
  return tmp;
}

static inline int loadmem(int addr)
{
  int tmp;        
  asm(" lda [%1]1, %0 "
      : "=r"(tmp)
      : "r"(addr)
    );
  return tmp;
}

int main(void) 
{
  int  i;
  int  j;
  int  k;
  int  m;
  int  l;
  int  data;
  int  hdr;
  int  notrx;
  int  tmp;
  int  eoplen;        
  int  *size;
  char *txbuf;
  char *rxbuf;
  char *rx0;
  char *rx1;
  char *rx2;
  char *rx3;
  char *tx0;
  char *tx1;
  char *tx2;
  char *tx3;
  char *tx[64];
  char *rx[128];
  struct rmap_pkt *cmd;
  int *cmdsize;
  struct rmap_pkt *reply;
  int *replysize;
  struct rxstatus *rxs;
  struct spwvars *spw;
  spw = (struct spwvars *) malloc(sizeof(struct spwvars));
  rxs = (struct rxstatus *) malloc(sizeof(struct rxstatus));
  size = (int *) malloc(sizeof(int));
  
  printf("Test started\n");
  /************************ TEST INIT ***********************************/
  /*Initalize link*/
  /*initialize parameters*/
  if (spw_setparam(0x14, 0, 0xBF, 1, 1, 1, 1048576, SPW_ADDR, AHBFREQ, spw) ) {
    printf("Illegal parameters to spacewire\n");
    exit(1);
  }
  /*reset link*/
  spw_reset(spw);
  /*initialize link*/
  if (spw_init(spw)) {
    printf("Link initialization failed\n");
  }
  /************************ TEST 1 **************************************/ 
  /*Simulatenous time-code and packet transmission/reception*/
  printf("Test transmission and reception with simultaneous time-code transmissions\n");
  rx0 = malloc(128);
  rx1 = malloc(128);
  rx2 = malloc(128);
  rx3 = malloc(128);
  tx0 = malloc(128);
  tx1 = malloc(128);
  tx2 = malloc(128);
  tx3 = malloc(128);
  for(i = 0; i < 128; i++) {
    tx0[i] = (char)i;
    tx1[i] = (char)~i;
    tx2[i] = (char)(i ^ (i + ~i));
    tx3[i] = (char)(i ^ (i + ~i + 5));
  }
  tx0[0] = 0x14;
  tx1[0] = 0x14;
  tx2[0] = 0x14;
  tx3[0] = 0x14;
  tx0[1] = 0x02;
  tx1[1] = 0x02;
  tx2[1] = 0x02;
  tx3[1] = 0x02;
  spw_rx(rx0, spw);
  spw_rx(rx1, spw);
  spw_rx(rx2, spw);
  spw_rx(rx3, spw);
  spw_tx(0, 0, 0, 0, tx0, 128, tx0, spw);
  spw_tx(0, 0, 0, 0, tx1, 128, tx1, spw);
  spw_tx(0, 0, 0, 0, tx2, 128, tx2, spw);
  spw_tx(0, 0, 0, 0, tx3, 128, tx3, spw);
  if (check_time(spw)) {
    printf("Tick out set before any time-codes were sent\n");
    exit(1);
  }
  if (get_time(spw)) {
    printf("Time-code nonzero before any time-code were sent/received\n");
    exit(1);
  }
  for(i = 0; i < 20; i++) {
    send_time(spw);
  }
  for(i = 0; i < 4; i++) {
    while(!(tmp = spw_checktx(spw))) {
      for(j = 0; j < 64; j++) {}
    }
    if (tmp != 1) {
      printf("Transmit error\n");
      exit(1);
    }
  }
  for(i = 0; i < 4; i++) {
    while(!(tmp = spw_checkrx(size, rxs, spw))) {
      for(j = 0; j < 64; j++) {}
    }
    if (rxs->truncated) {
      printf("Received packet truncated\n");
      exit(1);
    }
    if(rxs->eep) {
      printf("Received packet terminated with eep\n");
      exit(1);
    }
    if (*size != 128) {
      printf("Received packet has wrong length\n");
      exit(1);
    }
  }
  for(j = 0; j < 128; j++) {
    if (loadb((int)&(rx0[j])) != tx0[j]) {
      printf("Compare error buf 0: %u Data: %x Expected: %x \n", j, (unsigned)loadb((int)&(rx0[j])), (unsigned)tx0[j]);
      exit(1);
    }
    if (loadb((int)&(rx1[j])) != tx1[j]) {
      printf("Compare error buf 1: %u Data: %x Expected: %x \n", j, (unsigned)loadb((int)&(rx1[j])), (unsigned)tx1[j]);
      exit(1);
    }
    if (loadb((int)&(rx2[j])) != tx2[j]) {
      printf("Compare error buf 2: %u Data: %x Expected: %x \n", j, (unsigned)loadb((int)&(rx2[j])), (unsigned)tx2[j]);
      exit(1);
    }
    if (loadb((int)&(rx3[j])) != tx3[j]) {
      printf("Compare error buf 3: %u Data: %x Expected: %x \n", j, (unsigned)loadb((int)&(rx3[j])), (unsigned)tx3[j]);
      exit(1);
    }
  }
  if(get_time(spw) != 20) {
    printf("Time-counter has wrong value\n");
    exit(1);
  }
  free(rx0);
  free(rx1);
  free(rx2);
  free(rx3);
  free(tx0);
  free(tx1);
  free(tx2);
  free(tx3);
  printf("Test 1 completed successfully\n");
  /************************ TEST 2 **************************************/
  printf("Test transmission and reception of different sized packets from DMA channel\n");
  if ((txbuf = calloc(PKTTESTMAX, 1)) == NULL) {
    printf("Transmit buffer initialization failed\n");
    exit(1);
  }
  if ((rxbuf = calloc(PKTTESTMAX, 1)) == NULL) {
    printf("Receive buffer initialization failed\n");
    exit(1);
  }
  /*initialize data*/
  for (j = 0; j < PKTTESTMAX; j++) {
    txbuf[j] = (char)j;
  }
  txbuf[0] = 0x14;
  txbuf[1] = 0x2;
  for (i = 2; i < PKTTESTMAX; i++) {
    for (j = 2; j < i; j++) {
      txbuf[j] = ~txbuf[j];
    }
    while (spw_rx(rxbuf, spw)) {
      for (k = 0; k < 64; k++) {}
    }
    if (spw_tx(0, 0, 0, 0, txbuf, i, txbuf, spw)) {
      printf("Transmission failed\n");
                        exit(1);
    }
    while (!(tmp = spw_checktx(spw))) {
      for (k = 0; k < 64; k++) {}
    }
    if (tmp != 1) {
      printf("Error in transmit \n");
      exit(1);
    }
    while (!(tmp = spw_checkrx(size, rxs, spw))) {
      for (k = 0; k < 64; k++) {}
    }
    if (rxs->truncated) {
      printf("Received packet truncated\n");
      exit(1);
    }
    if(rxs->eep) {
      printf("Received packet terminated with eep\n");
      exit(1);
    }
    if (*size != i) {
      printf("Received packet has wrong length\n");
      printf("Expected: %i, Got: %i \n", i, *size);
    }
    for(j = 0; j < i; j++) {
      if (loadb((int)&(rxbuf[j])) != txbuf[j]) {
        printf("Compare error: %u Data: %x Expected: %x \n", j, (unsigned)loadb((int)&(rxbuf[j])), (unsigned)txbuf[j]);
        //exit(1);
      }
    }
//    printf("Packet %i transferred\n", i);
  }
  free(rxbuf);
  free(txbuf);
  printf("Test 2 completed successfully\n");
  /************************ TEST 3 **************************************/
  if (spw->rmap || spw->rxunaligned) {
    printf("Test transmission and reception of different sized packets from DMA channel,\n");
    printf("with different alignment,\n");
    if ((txbuf = calloc(PKTTESTMAX, 1)) == NULL) {
      printf("Transmit buffer initialization failed\n");
      exit(1);
    }
    if ((rxbuf = calloc(PKTTESTMAX+4, 1)) == NULL) {
      printf("Receive buffer initialization failed\n");
      exit(1);
    }
    /*initialize data*/
    for (j = 0; j < PKTTESTMAX; j++) {
      txbuf[j] = (char)j;
    }
    txbuf[0] = 0x14;
    txbuf[1] = 0x2;
    for (i = 2; i < PKTTESTMAX; i++) {
      for(m = 1; m < 4; m++) {
        for (j = 2; j < i; j++) {
          txbuf[j] = ~txbuf[j];
        }
        while (spw_rx((char *)&(rxbuf[m]), spw)) {
          for (k = 0; k < 64; k++) {}
        }
        if (spw_tx(0, 0, 0, 0, txbuf, i, txbuf, spw)) {
          printf("Transmission failed\n");
          exit(1);
        }
        while (!(tmp = spw_checktx(spw))) {
          for (k = 0; k < 64; k++) {}
        }
        if (tmp != 1) {
          printf("Error in transmit \n");
          exit(1);
        }
        while (!(tmp = spw_checkrx(size, rxs, spw))) {
          for (k = 0; k < 64; k++) {}
        }
        if (rxs->truncated) {
          printf("Received packet truncated\n");
          exit(1);
        }
        if(rxs->eep) {
          printf("Received packet terminated with eep\n");
          exit(1);
        }
        if (*size != i) {
          printf("Received packet has wrong length\n");
          printf("Expected: %i, Got: %i \n", i, *size);
        }
        for(j = 0; j < i; j++) {
          if (loadb((int)&(rxbuf[j+m])) != txbuf[j]) {
            printf("Compare error: %u Data: %x Expected: %x \n", j, (unsigned)loadb((int)&(rxbuf[j+m])), (unsigned)txbuf[j]);
            exit(1);
          }
        }
//        printf("Packet %i transferred of aligment %i\n", i, m);
      }
      
    }
    free(rxbuf);
    free(txbuf);
    printf("Test 3 completed successfully\n");
  }
  /************************ TEST 4 **************************************/
  printf("Test transmission of packets with different alignment,\n");
  if ((txbuf = calloc(PKTTESTMAX+4, 1)) == NULL) {
    printf("Transmit buffer initialization failed\n");
    exit(1);
  }
  if ((rxbuf = calloc(PKTTESTMAX+256, 1)) == NULL) {
    printf("Receive buffer initialization failed\n");
    exit(1);
  }
  /*initialize data*/
  for (j = 0; j < PKTTESTMAX+4; j++) {
    txbuf[j] = (char)j;
  }
  for(i = 2; i < PKTTESTMAX; i++) {
    for(m = 0; m < 4; m++) {
      for (j = 2; j < (i+m); j++) {
        txbuf[j] = ~txbuf[j];
      }
      txbuf[m] = 0x14;
      txbuf[m+1] = 0x2;
      while (spw_rx(rxbuf, spw)) {
        for (k = 0; k < 64; k++) {}
      }
      if (spw_tx(0, 0, 0, 0, txbuf, i, (char *)&(txbuf[m]), spw)) {
        printf("Transmission failed\n");
        exit(1);
      }
      while (!(tmp = spw_checktx(spw))) {
        for (k = 0; k < 64; k++) {}
      }
      if (tmp != 1) {
        printf("Error in transmit \n");
        exit(1);
      }
      while (!(tmp = spw_checkrx(size, rxs, spw))) {
        for (k = 0; k < 64; k++) {}
      }
      if (rxs->truncated) {
        printf("Received packet truncated\n");
        exit(1);
      }
      if(rxs->eep) {
        printf("Received packet terminated with eep\n");
        exit(1);
      }
      if (*size != i) {
        printf("Received packet has wrong length\n");
        printf("Expected: %i, Got: %i \n", i, *size);
      }
      for(j = 0; j < i; j++) {
        if (loadb((int)&(rxbuf[j])) != txbuf[j+m]) {
          printf("Compare error: %u Data: %x Expected: %x \n", j, (unsigned)loadb((int)&(rxbuf[j])), (unsigned)txbuf[j+m]);
          exit(1);
        }
      }
//      printf("Packet %i transferred of aligment %i\n", i, m);
    }
                                
  }
  free(rxbuf);
  free(txbuf);
  printf("Test 4 completed successfully\n");
  /************************ TEST 5 **************************************/
  printf("Test transmission of packets with different alignment, and header\n");
  if ((txbuf = calloc(PKTTESTMAX+4, 1)) == NULL) {
    printf("Transmit buffer initialization failed\n");
    exit(1);
  }
  if ((rxbuf = calloc(PKTTESTMAX+256, 1)) == NULL) {
    printf("Receive buffer initialization failed\n");
    exit(1);
  }
  if ((tx0 = calloc(260, 1)) == NULL) {
    printf("Receive buffer initialization failed\n");
    exit(1);
  }
  /*initialize data*/
  for (j = 0; j < PKTTESTMAX; j++) {
    txbuf[j] = (char)j;
  }
  for (j = 0; j < 260; j++) {
    tx0[j] = (char)~j;
  }
  txbuf[0] = 0x14;
  txbuf[1] = 0x2;
  for(i = 0; i < 256; i++) {
    for(m = 0; m < 4; m++) {
      for (j = 2; j < PKTTESTMAX; j++) {
        txbuf[j] = ~txbuf[j];
      }
      for (j = 0; j < 260; j++) {
        tx0[j] = ~tx0[j];
      }
      tx0[m] = 0x14;
      tx0[m+1] = 0x2;
      while (spw_rx(rxbuf, spw)) {
        for (k = 0; k < 64; k++) {}
      }
      if (spw_tx(0, 0, 0, i,(char *)&(tx0[m]), PKTTESTMAX, txbuf, spw)) {
        printf("Transmission failed\n");
        exit(1);
      }
      while (!(tmp = spw_checktx(spw))) {
        for (k = 0; k < 64; k++) {}
      }
      if (tmp != 1) {
        printf("Error in transmit \n");
        exit(1);
      }
      while (!(tmp = spw_checkrx(size, rxs, spw))) {
        for (k = 0; k < 64; k++) {}
      }
      if (rxs->truncated) {
        printf("Received packet truncated\n");
        exit(1);
      }
      if(rxs->eep) {
        printf("Received packet terminated with eep\n");
        exit(1);
      }
      if (*size != (PKTTESTMAX+i)) {
        printf("Received packet has wrong length\n");
        printf("Expected: %i, Got: %i \n", i+PKTTESTMAX, *size);
      }
      for(j = 0; j < i; j++) {
        if (loadb((int)&(rxbuf[j])) != tx0[j+m]) {
          printf("Compare error: %u Data: %x Expected: %x \n", j, (unsigned)loadb((int)&(rxbuf[j])), (unsigned)tx0[j+m]);
        }
      }
      for(j = 0; j < PKTTESTMAX; j++) {
        if (loadb((int)&(rxbuf[j+i])) != txbuf[j]) {
          printf("Compare error: %u Data: %x Expected: %x \n", j, (unsigned)loadb((int)&(rxbuf[j+i])), (unsigned)txbuf[j]);
        }
      }
      if (i % 32 == 0 && m == 0)
          printf("Packet %i transferred of aligment %i\n", i, m);
    }
                                
  }
  free(rxbuf);
  free(txbuf);
  free(tx0);
  printf("Test 5 completed successfully\n");
  /************************ TEST 6 **************************************/
  printf("Test transmission of packets with different alignment, and header\n");
  if ((txbuf = calloc(PKTTESTMAX+4, 1)) == NULL) {
    printf("Transmit buffer initialization failed\n");
    exit(1);
  }
  if ((rxbuf = calloc(PKTTESTMAX+256, 1)) == NULL) {
    printf("Receive buffer initialization failed\n");
    exit(1);
  }
  if ((tx0 = calloc(260, 1)) == NULL) {
    printf("Receive buffer initialization failed\n");
    exit(1);
  }
  /*initialize data*/
  for (j = 0; j < PKTTESTMAX; j++) {
    txbuf[j] = (char)j;
  }
  for (j = 0; j < 260; j++) {
    tx0[j] = (char)~j;
  }
  notrx = 0;
  for(i = 0; i < 256; i++) {
      printf(".");
//    printf("Packet with header %i, alignment: %i and data: %i, alignment: %i transferred\n", i, m, j, l);
    for(j = 0; j < PKTTESTMAX; j++) {
      for(m = 0; m < 4; m++) {
        for(l = 0; l < 4; l++) {
          for (k = 0; k < PKTTESTMAX; k++) {
            txbuf[k] = ~txbuf[k];
          }
          for (k = 0; k < 260; k++) {
            tx0[k] = ~tx0[k];
          }
          tx0[m] = 0x14;
          tx0[m+1] = 0x2;
          txbuf[l] = 0x14;
          txbuf[l+1] = 0x2;
          if (!notrx) {
            while (spw_rx(rxbuf, spw)) {
              for (k = 0; k < 64; k++) {}
            }
          }
          if (spw_tx(0, 0, 0, i,(char *)&(tx0[m]), j, (char *)&(txbuf[l]), spw)) {
            printf("Transmission failed\n");
            exit(1);
          }
          while (!(tmp = spw_checktx(spw))) {
            for (k = 0; k < 64; k++) {}
          }
          if (tmp != 1) {
            printf("Error in transmit \n");
            exit(1);
          }
          if( (i+j) > 1) {
            while (!(tmp = spw_checkrx(size, rxs, spw))) {
              for (k = 0; k < 64; k++) {}
            }
            if (rxs->truncated) {
              printf("Received packet truncated\n");
              exit(1);
            }
            if(rxs->eep) {
              printf("Received packet terminated with eep\n");
              exit(1);
            }
            if (*size != (j+i)) {
              printf("Received packet has wrong length\n");
              printf("Expected: %i, Got: %i \n", i+j, *size);
            }
            for(k = 0; k < i; k++) {
              if (loadb((int)&(rxbuf[k])) != tx0[k+m]) {
                printf("Compare error: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rxbuf[k])), (unsigned)tx0[k+m]);
                exit(1);
              }
            }
            for(k = 0; k < j; k++) {
              if (loadb((int)&(rxbuf[k+i])) != txbuf[k+l]) {
                printf("Compare error: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rxbuf[k+i])), (unsigned)txbuf[k+l]);
                exit(1);
              }
            }
            notrx = 0;
          } else {
            for(k = 0; k < 1048576; k++) {}
            if (spw_checkrx(size, rxs, spw)) {
              printf("Packet recevied/sent although length was too small\n");
              exit(1);
            }
            notrx = 1;
          }
        }
                                
      }
    }
                
                
                                
  }
  free(rxbuf);
  free(txbuf);
  free(tx0);
  printf("\nTest 6 completed successfully\n");
  /************************ TEST 7 **************************************/
  printf("Test to fill descriptor tables completely\n");
  for(i = 0; i < 64; i++) {
    tx[i] = malloc(DESCPKT);
  }
  for(i = 0; i < 128; i++) {
    rx[i] = malloc(DESCPKT+256);
  }
  txbuf = malloc(256);
  /*initialize data*/
  for(i = 0; i < 64; i++) {
    tx[i][0] = 0x14;
    tx[i][1] = 0x2;
    for(j = 2; j < DESCPKT; j++) {
      tx[i][j] = j ^ i;
    }
  }
  txbuf[0] = 0x14;
  txbuf[1] = 0x2;
  for(i = 2; i < 256; i++) {
    txbuf[i] = i;
  }
  for(i = 0; i < 128; i++) {
    while (spw_rx(rx[i], spw)) {
      for (k = 0; k < 64; k++) {}
    }
  }
  for(i = 0; i < 64; i++) {
    if (spw_tx(0, 0, 0, 255, txbuf, DESCPKT, tx[i], spw)) {
      printf("Transmission failed\n");
      exit(1);
    }
  }
  for(i = 0; i < 64; i++) {
    while (!(tmp = spw_checktx(spw))) {
      for (k = 0; k < 64; k++) {}
    }
    if (tmp != 1) {
      printf("Error in transmit \n");
      exit(1);
    }
  }
  for(i = 0; i < 64; i++) {
    while (!(tmp = spw_checkrx(size, rxs, spw))) {
      for (k = 0; k < 64; k++) {}
    }
    if (rxs->truncated) {
      printf("Received packet truncated\n");
      exit(1);
    }
    if(rxs->eep) {
      printf("Received packet terminated with eep\n");
      exit(1);
    }
    if (*size != (255+DESCPKT)) {
      printf("Received packet has wrong length\n");
      printf("Expected: %i, Got: %i \n", 255+DESCPKT, *size);
    }
    for(k = 0; k < 255; k++) {
      if (loadb((int)&(rx[i][k])) != txbuf[k]) {
        printf("Txbuf: %x Rxbuf: %x\n", (int)txbuf, (int)rx[i]);
        printf("Compare error: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx[i][k])), (unsigned)txbuf[k]);
        exit(1);
      }
    }
    for(k = 0; k < DESCPKT; k++) {
      if (loadb((int)&(rx[i][k+255])) != tx[i][k]) {
        printf("Compare error: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx[i][k+255])), (unsigned)tx[i][k]);
        exit(1);
      }
    }
  }
  /*second transmit loop*/
  for(i = 0; i < 64; i++) {
    if (spw_tx(0, 0, 0, 255, txbuf, DESCPKT, tx[i], spw)) {
      printf("Transmission failed\n");
      exit(1);
    }
  }
  for(i = 0; i < 64; i++) {
    while (!(tmp = spw_checktx(spw))) {
      for (k = 0; k < 64; k++) {}
    }
    if (tmp != 1) {
      printf("Error in transmit \n");
      exit(1);
    }
  }
  for(i = 0; i < 64; i++) {
    while (!(tmp = spw_checkrx(size, rxs, spw))) {
      for (k = 0; k < 64; k++) {}
    }
    if (rxs->truncated) {
      printf("Received packet truncated\n");
      exit(1);
    }
    if(rxs->eep) {
      printf("Received packet terminated with eep\n");
      exit(1);
    }
    if (*size != (255+DESCPKT)) {
      printf("Received packet has wrong length\n");
      printf("Expected: %i, Got: %i \n", 255+DESCPKT, *size);
    }
    for(k = 0; k < 255; k++) {
      if (loadb((int)&(rx[i+64][k])) != txbuf[k]) {
        printf("Compare error: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx[i][k])), (unsigned)txbuf[k]);
        exit(1);
      }
    }
    for(k = 0; k < DESCPKT; k++) {
      if (loadb((int)&(rx[i+64][k+255])) != tx[i][k]) {
        printf("Compare error: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rxbuf[k+255])), (unsigned)tx[i][k]);
        exit(1);
      }
    }
  }
  for(i = 0; i < 64; i++) {
    free(tx[i]);
  }
  for(i = 0; i < 128; i++) {
    free(rx[i]);
  }
  free(txbuf);
  printf("Test 7 completed successfully\n");
  /************************ TEST 8 **************************************/
  printf("Test transmission and reception of maximum size packets\n");
  txbuf = malloc(MAXSIZE+1);
  rxbuf = malloc(MAXSIZE);
  if ((rxbuf == NULL) || (txbuf == NULL)) {
    printf("Memory allocation failed\n");
    exit(1);
  }
  txbuf[0] = 0x14;
  txbuf[1] = 0x2;
  for(i = 2; i < MAXSIZE; i++) {
    txbuf[i] = i;
  }
  while (spw_rx(rxbuf, spw)) {
    for (k = 0; k < 64; k++) {}
  }
  spw->rxmaxlen = MAXSIZE;
  if (spw_set_rxmaxlength(spw) ) {
    printf("Max length change failed\n");
    exit(1);
  }
  if (spw_tx(0, 0, 0, 0, txbuf, MAXSIZE, txbuf, spw)) {
    printf("Transmission failed\n");
    exit(1);
  }
  while (!(tmp = spw_checktx(spw))) {
    for (k = 0; k < 64; k++) {}
  }
  if (tmp != 1) {
    printf("Error in transmit \n");
    exit(1);
  }
  while (!(tmp = spw_checkrx(size, rxs, spw))) {
    for (k = 0; k < 64; k++) {}
  }
  if (rxs->truncated) {
    printf("Received packet truncated\n");
    exit(1);
  }
  if(rxs->eep) {
    printf("Received packet terminated with eep\n");
    exit(1);
  }
  if (*size != (MAXSIZE)) {
    printf("Received packet has wrong length\n");
    printf("Expected: %i, Got: %i \n", MAXSIZE, *size);
  }
  for(k = 0; k < MAXSIZE; k++) {
    if (loadb((int)&(rxbuf[k])) != txbuf[k]) {
      printf("Compare error: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rxbuf[k])), (unsigned)txbuf[k]);
      exit(1);
    }
  }
  for(i = 2; i < MAXSIZE; i++) {
    txbuf[i] = ~txbuf[i];
  }
  while (spw_rx(rxbuf, spw)) {
    for (k = 0; k < 64; k++) {}
  }
  if (spw_tx(0, 0, 0, 0, txbuf, MAXSIZE+1, txbuf, spw)) {
    printf("Transmission failed\n");
    exit(1);
  }
  while (!(tmp = spw_checktx(spw))) {
    for (k = 0; k < 64; k++) {}
  }
  if (tmp != 1) {
    printf("Error in transmit \n");
    exit(1);
  }
  while (!(tmp = spw_checkrx(size, rxs, spw))) {
    for (k = 0; k < 64; k++) {}
  }
  if (!rxs->truncated) {
    printf("Received packet not truncated\n");
    exit(1);
  }
  if(rxs->eep) {
    printf("Received packet terminated with eep\n");
    exit(1);
  }
  if (*size != (MAXSIZE)) {
    printf("Received packet has wrong length\n");
    printf("Expected: %i, Got: %i \n", MAXSIZE, *size);
  }
  for(k = 0; k < MAXSIZE; k++) {
    if (loadb((int)&(rxbuf[k])) != txbuf[k]) {
      printf("Compare error: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rxbuf[k])), (unsigned)txbuf[k]);
      exit(1);
    }
  }
  for(i = 2; i < MAXSIZE; i++) {
    txbuf[i] = ~txbuf[i];
  }
  while (spw_rx(rxbuf, spw)) {
    for (k = 0; k < 64; k++) {}
  }
  if (spw_tx(0, 0, 0, 0, txbuf, MAXSIZE, txbuf, spw)) {
    printf("Transmission failed\n");
    exit(1);
  }
  while (!(tmp = spw_checktx(spw))) {
    for (k = 0; k < 64; k++) {}
  }
  if (tmp != 1) {
    printf("Error in transmit \n");
    exit(1);
  }
  while (!(tmp = spw_checkrx(size, rxs, spw))) {
    for (k = 0; k < 64; k++) {}
  }
  if (rxs->truncated) {
    printf("Received packet truncated\n");
    exit(1);
  }
  if(rxs->eep) {
    printf("Received packet terminated with eep\n");
    exit(1);
  }
  if (*size != (MAXSIZE)) {
    printf("Received packet has wrong length\n");
    printf("Expected: %i, Got: %i \n", MAXSIZE, *size);
  }
  for(k = 0; k < MAXSIZE; k++) {
    if (loadb((int)&(rxbuf[k])) != txbuf[k]) {
      printf("Compare error: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rxbuf[k])), (unsigned)txbuf[k]);
      exit(1);
    }
  }
  free(rxbuf);
  free(txbuf);
  printf("Test 8 completed successfully\n");
  /************************ TEST 9 **************************************/
/*   printf("Test crc\n"); */
/*   if (spw->rmap || spw->rmapcrc) { */
/*     printf("Test transmission of packets with different alignment, and header\n"); */
/*     if ((txbuf = calloc(PKTTESTMAX+4, 1)) == NULL) { */
/*       printf("Transmit buffer initialization failed\n"); */
/*       exit(1); */
/*     } */
/*     if ((rxbuf = calloc(PKTTESTMAX+256+2, 1)) == NULL) { */
/*       printf("Receive buffer initialization failed\n"); */
/*       exit(1); */
/*     } */
/*     if ((tx0 = calloc(260, 1)) == NULL) { */
/*       printf("Receive buffer initialization failed\n"); */
/*       exit(1); */
/*     } */
/*     /\*initialize data*\/ */
/*     for (j = 0; j < PKTTESTMAX; j++) { */
/*       txbuf[j] = (char)j; */
/*     } */
/*     for (j = 0; j < 260; j++) { */
/*       tx0[j] = (char)~j; */
/*     } */
/*     notrx = 0; data = 0; hdr = 0; */
/*     for(i = 0; i < 256; i++) { */
/* //      printf("Packet with header %i, alignment: %i and data: %i, alignment: %i transferred\n", i, m, j, l); */
/*       for(j = 0; j < PKTTESTMAX; j++) { */
/*         for(m = 0; m < 4; m++) { */
/*           for(l = 0; l < 4; l++) { */
/*             for (k = 0; k < PKTTESTMAX; k++) { */
/*               txbuf[k] = ~txbuf[k]; */
/*             } */
/*             for (k = 0; k < 260; k++) { */
/*               tx0[k] = ~tx0[k]; */
/*             } */
/*             if (i != 0) { */
/*               hdr = 1; */
/*             } else { */
/*               hdr = 0; */
/*             } */
/*             if (j != 0) { */
/*               data = 1; */
                                                
/*             } else { */
/*               data = 0; */
/*             } */
/*             tx0[m] = 0x14; */
/*             tx0[m+1] = 0x2; */
/*             txbuf[l] = 0x14; */
/*             txbuf[l+1] = 0x2; */
/*             if (!notrx) { */
/*               while (spw_rx(rxbuf, spw)) { */
/*                 for (k = 0; k < 64; k++) {} */
/*               } */
/*             } */
/*             if (spw_tx(1, 1, 0, i,(char *)&(tx0[m]), j, (char *)&(txbuf[l]), spw)) { */
/*               printf("Transmission failed\n"); */
/*               exit(1); */
/*             } */
/*             while (!(tmp = spw_checktx(spw))) { */
/*               for (k = 0; k < 64; k++) {} */
/*             } */
/*             if (tmp != 1) { */
/*               printf("Error in transmit \n"); */
/*               exit(1); */
/*             } */
/*             if( (i+j+hdr+data) > 1) { */
/*               while (!(tmp = spw_checkrx(size, rxs, spw))) { */
/*                 for (k = 0; k < 64; k++) {} */
/*               } */
/*               if (rxs->truncated) { */
/*                 printf("Received packet truncated\n"); */
/*                 exit(1); */
/*               } */
/*               if(rxs->eep) { */
/*                 printf("Received packet terminated with eep\n"); */
/*                 exit(1); */
/*               } */
/*               if (*size != (j+i+hdr+data)) { */
/*                 printf("Received packet has wrong length\n"); */
/*                 printf("Expected: %i, Got: %i \n", i+j, *size); */
/*               } */
/*               for(k = 0; k < i; k++) { */
/*                 if (loadb((int)&(rxbuf[k])) != tx0[k+m]) { */
/*                   printf("Compare error: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rxbuf[k])), (unsigned)tx0[k+m]); */
/*                   exit(1); */
/*                 } */
/*               } */
/*               for(k = 0; k < j; k++) { */
/*                 if (loadb((int)&(rxbuf[k+i+hdr])) != txbuf[k+l]) { */
/*                   printf("Compare error: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rxbuf[k+i+hdr])), (unsigned)txbuf[k+l]); */
/*                   exit(1); */
/*                 } */
/*               } */
/*               notrx = 0; */
/*             } else { */
/*               for(k = 0; k < 1048576; k++) {} */
/*               if (spw_checkrx(size, rxs, spw)) { */
/*                 printf("Packet recevied/sent although length was too small\n"); */
/*                 exit(1); */
/*               } */
/*               notrx = 1; */
/*             } */
/*           } */
                                
/*         } */
/*       } */
                
                
                                
/*     } */
/*     free(rxbuf); */
/*     free(txbuf); */
/*     free(tx0); */
/*     printf("Test 9 completed successfully\n"); */
/*   } */
  /************************ TEST 10 **************************************/
  if (spw->rmap == 1) {
    printf("Test RMAP, including transmit spa test\n");
    tx0 = (char *)malloc(64);
    tx1 = (char *)calloc(RMAPSIZE, 1);
    rx0 = (char *)malloc(RMAPSIZE+4);
    rx1 = (char *)malloc(32+RMAPSIZE);
    rx2 = (char *)malloc(32+RMAPSIZE);
    if( (tx0 == NULL) || (tx1 == NULL) || (rx0 == NULL) ||
        (rx1 == NULL) || (rx2 == NULL) ) {
      printf("Memory initialization error\n");
      exit(1);
    }
    cmd = (struct rmap_pkt *) malloc(sizeof(struct rmap_pkt));
    reply = (struct rmap_pkt *) malloc(sizeof(struct rmap_pkt));
    cmdsize = (int *) malloc(sizeof(int));
    replysize = (int *) malloc(sizeof(int));
    /* enable rmap*/
    spw_rmapen(spw);
    for(i = 0; i < RMAPSIZE; i++) {
      for(m = 0; m < 8; m++) {
        for(j = 0; j < i; j++) {
          tx1[j]  = ~tx1[j];
        }
        if (m >= 4) {
          cmd->incr     = no;
        } else {
          cmd->incr     = yes;
        }
        cmd->type     = writecmd;
        cmd->verify   = no;
        cmd->ack      = yes;
        cmd->destaddr = 0x14;
        cmd->destkey  = 0xBF;
        cmd->srcaddr  = 0x14;
        cmd->tid      = i;
        cmd->addr     = (int)&(rx0[(m%4)]);
        cmd->len      = i;
        cmd->status   = 0;
        cmd->dstspalen = 0;
        cmd->dstspa  = (char *)NULL;
        cmd->srcspalen = 0;
        cmd->srcspa = (char *)NULL;
        if (build_rmap_hdr(cmd, tx0, cmdsize)) {
          printf("RMAP cmd build failed\n");
          exit(1);
        }
        reply->type     = writerep;
        reply->verify   = no;
        reply->ack      = yes;
        if (m >= 4) {
          reply->incr     = no;
          if ( ((((int)&(rx0[(m%4)])) % 4) != 0) || ((cmd->len % 4) != 0) )  {
            reply->status   = 10;
          } else {
            reply->status   = 0;
          }
        } else {
          reply->incr     = yes;
          reply->status   = 0;
        }
        reply->destaddr = 0x14;
        reply->destkey  = 0XBF;
        reply->srcaddr  = 0x14;
        reply->tid      = i;
        reply->addr     = (int)&(rx0[(m%4)]);
        reply->len      = i;
        reply->dstspalen = 0;
        reply->dstspa  = (char *)NULL;
        reply->srcspalen = 0;
        reply->srcspa = (char *)NULL;
        if (build_rmap_hdr(reply, rx2, replysize)) {
          printf("RMAP reply build failed\n");
          exit(1);
        }
        while (spw_rx(rx1, spw)) {
          for (k = 0; k < 64; k++) {}
        }
        if (spw_tx(1, 1, 0, *cmdsize, tx0, j, tx1, spw)) {
          printf("Transmission failed\n");
          exit(1);
        }
        while (!(tmp = spw_checktx(spw))) {
          for (k = 0; k < 64; k++) {}
        }
        if (tmp != 1) {
          printf("Error in transmit \n");
          exit(1);
        }
        while (!(tmp = spw_checkrx(size, rxs, spw))) {
          for (k = 0; k < 64; k++) {}
        }
        if (rxs->truncated) {
          printf("Received packet truncated\n");
          exit(1);
        }
        if(rxs->eep) {
          printf("Received packet terminated with eep\n");
          exit(1);
        }
        if(rxs->hcrcerr) {
          printf("Received packet header crc error detected\n");
          exit(1);
        }
        if(rxs->dcrcerr) {
          printf("Received packet data crc error detected\n");
          exit(1);
        }
        if (*size != (*replysize+1)) {
          printf("Received packet has wrong length\n");
          printf("Expected: %i, Got: %i \n", *replysize+1, *size);
        }
        for(k = 0; k < *replysize; k++) {
          if (loadb((int)&(rx1[k])) != rx2[k]) {
            printf("Compare error 0: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx1[k])), (unsigned)rx2[k]);
            exit(1);
          }
        }
        if (reply->status == 0) {
          if (m < 4) {
            for(k = 0; k < i; k++) {
              if (loadb((int)&(rx0[k+(m%4)])) != tx1[k]) {
                printf("Compare error 1: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx0[k+(m%4)])), (unsigned)tx1[k]);
                exit(1);
              }
            }
          } else {
            if (i != 0) {
              for(k = 0; k < 4; k++) {
                if (loadb((int)&(rx0[k+(m%4)])) != tx1[k + (i - 4)]) {
                  printf("Compare error 1: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx0[k+(m%4)])), (unsigned)tx1[k+(i-4)]);
                  exit(1);
                }
              }
            }
          }
        }
        if ((i % 512) == 0) {
          printf("Packet  %i, alignment %i\n", i, m);
        }
      }
    }
    printf("Non-verified write test passed\n");
    for(i = 0; i < 64; i++) {
      for(m = 0; m < 8; m++) {
        for(j = 0; j < i; j++) {
          tx1[j]  = ~tx1[j];
        }
        if (m >= 4) {
          cmd->incr     = no;
        } else {
          cmd->incr     = yes;
        }
        cmd->type     = writecmd;
        cmd->verify   = yes;
        cmd->ack      = yes;
        cmd->destaddr = 0x14;
        cmd->destkey  = 0xBF;
        cmd->srcaddr  = 0x14;
        cmd->tid      = i;
        cmd->addr     = (int)&(rx0[(m%4)]);
        cmd->len      = i;
        cmd->status   = 0;
        cmd->dstspalen = 0;
        cmd->dstspa  = (char *)NULL;
        cmd->srcspalen = 0;
        cmd->srcspa = (char *)NULL;
        if (build_rmap_hdr(cmd, tx0, cmdsize)) {
          printf("RMAP cmd build failed\n");
          exit(1);
        }
        reply->type     = writerep;
        reply->verify   = yes;
        reply->ack      = yes;
        if (m >= 4) {
          reply->incr     = no;
                                        
        } else {
          reply->incr     = yes;
        }
        if ( (((((int)&(rx0[(m%4)])) % 2) != 0) && (cmd->len == 2)) ||
             (((((int)&(rx0[(m%4)])) % 4) != 0) && (cmd->len == 4)) ||
             (cmd->len == 3) ) {
          reply->status   = 10;
        } else {
          reply->status   = 0;
        }
        if (cmd->len > 4) {
          reply->status = 9;
                                        
        }
        reply->destaddr = 0x14;
        reply->destkey  = 0XBF;
        reply->srcaddr  = 0x14;
        reply->tid      = i;
        reply->addr     = (int)&(rx0[(m%4)]);
        reply->len      = i;
        reply->dstspalen = 0;
        reply->dstspa  = (char *)NULL;
        reply->srcspalen = 0;
        reply->srcspa = (char *)NULL;
        if (build_rmap_hdr(reply, rx2, replysize)) {
          printf("RMAP reply build failed\n");
          exit(1);
        }
        while (spw_rx(rx1, spw)) {
          for (k = 0; k < 64; k++) {}
        }
        if (spw_tx(1, 1, 0, *cmdsize, tx0, j, tx1, spw)) {
          printf("Transmission failed\n");
          exit(1);
        }
        while (!(tmp = spw_checktx(spw))) {
          for (k = 0; k < 64; k++) {}
        }
        if (tmp != 1) {
          printf("Error in transmit \n");
          exit(1);
        }
        while (!(tmp = spw_checkrx(size, rxs, spw))) {
          for (k = 0; k < 64; k++) {}
        }
        if (rxs->truncated) {
          printf("Received packet truncated\n");
          exit(1);
        }
        if(rxs->eep) {
          printf("Received packet terminated with eep\n");
          exit(1);
        }
        if(rxs->hcrcerr) {
          printf("Received packet header crc error detected\n");
          exit(1);
        }
        if(rxs->dcrcerr) {
          printf("Received packet data crc error detected\n");
          exit(1);
        }
        if (*size != (*replysize+1)) {
          printf("Received packet has wrong length\n");
          printf("Expected: %i, Got: %i \n", *replysize+1, *size);
          exit(1);
        }
        for(k = 0; k < *replysize; k++) {
          if (loadb((int)&(rx1[k])) != rx2[k]) {
            printf("Compare error 0: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx1[k])), (unsigned)rx2[k]);
            exit(1);
          }
        }
        if (reply->status == 0) {
          for(k = 0; k < i; k++) {
            if (loadb((int)&(rx0[k+(m%4)])) != tx1[k]) {
              printf("Compare error 1: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx0[k+(m%4)])), (unsigned)tx1[k]);
              exit(1);
            }
          }
                                        
        }
        if (((i % 4) == 0) && ((m % 8) == 0)) {
          printf("Packet  %i, alignment %i\n", i, m);
        }
      }
    }
    printf("Verified write test passed\n");

/*     for(i = 0; i < 64; i++) { */
/*       for(m = 0; m < 8; m++) { */
/*         for(j = 0; j < i; j++) { */
/*           tx1[j]  = ~tx1[j]; */
/*         } */
/*         if (m >= 4) { */
/*           cmd->incr     = no; */
/*         } else { */
/*           cmd->incr     = yes; */
/*         } */
/*         cmd->type     = rmwcmd; */
/*         cmd->verify   = yes; */
/*         cmd->ack      = yes; */
/*         cmd->destaddr = 0x14; */
/*         cmd->destkey  = 0xBF; */
/*         cmd->srcaddr  = 0x14; */
/*         cmd->tid      = i; */
/*         cmd->addr     = (int)&(rx0[(m%4)]); */
/*         cmd->len      = i; */
/*         cmd->status   = 0; */
/*         cmd->dstspalen = 0; */
/*         cmd->dstspa  = (char *)NULL; */
/*         cmd->srcspalen = 0; */
/*         cmd->srcspa = (char *)NULL; */
/*         if (build_rmap_hdr(cmd, tx0, cmdsize)) { */
/*           printf("RMAP cmd build failed\n"); */
/*           exit(1); */
/*         } */
/*         reply->type     = rmwrep; */
/*         reply->verify   = yes; */
/*         reply->ack      = yes; */
/*         if (m >= 4) { */
/*           reply->incr     = no; */
                                        
/*         } else { */
/*           reply->incr     = yes; */
/*         } */
/*         if ( (((((int)&(rx0[(m%4)])) % 2) != 0) && ((cmd->len/2) == 2)) || */
/*              (((((int)&(rx0[(m%4)])) % 4) != 0) && ((cmd->len/2) == 4)) || */
/*              ((cmd->len/2) == 3) ) { */
/*           reply->status   = 10; */
/*         } else { */
/*           reply->status   = 0; */
/*         } */
/*         if ( (cmd->len != 0) && (cmd->len != 2) && (cmd->len != 4) && */
/*              (cmd->len != 6) && (cmd->len != 8)) { */
/*           reply->status = 11; */
/*         } */
/*         if (m >= 4) { */
/*           reply->status = 2; */
/*         } */
/*         if (reply->status == 0) { */
/*           for(k = 0; k < (i/2); k++) { */
/*             rx2[*replysize+1+k] = rx0[k+m]; */
/*           } */
/*         } */
/*         reply->destaddr = 0x14; */
/*         reply->destkey  = 0XBF; */
/*         reply->srcaddr  = 0x14; */
/*         reply->tid      = i; */
/*         reply->addr     = (int)&(rx0[(m%4)]); */
/*         if (reply->status == 0) { */
/*           reply->len      = (i/2); */
/*         } else { */
/*           reply->len      = 0; */
/*         } */
/*         reply->dstspalen = 0; */
/*         reply->dstspa  = (char *)NULL; */
/*         reply->srcspalen = 0; */
/*         reply->srcspa = (char *)NULL; */
/*         if (build_rmap_hdr(reply, rx2, replysize)) { */
/*           printf("RMAP reply build failed\n"); */
/*           exit(1); */
/*         } */
/*         while (spw_rx(rx1, spw)) { */
/*           for (k = 0; k < 64; k++) {} */
/*         } */
/*         if (spw_tx(1, 1, 0, *cmdsize, tx0, j, tx1, spw)) { */
/*           printf("Transmission failed\n"); */
/*           exit(1); */
/*         } */
/*         while (!(tmp = spw_checktx(spw))) { */
/*           for (k = 0; k < 64; k++) {} */
/*         } */
/*         if (tmp != 1) { */
/*           printf("Error in transmit \n"); */
/*           exit(1); */
/*         } */
/*         while (!(tmp = spw_checkrx(size, rxs, spw))) { */
/*           for (k = 0; k < 64; k++) {} */
/*         } */
/*         if (rxs->truncated) { */
/*           printf("Received packet truncated\n"); */
/*           exit(1); */
/*         } */
/*         if(rxs->eep) { */
/*           printf("Received packet terminated with eep\n"); */
/*           exit(1); */
/*         } */
/*         if(rxs->hcrcerr) { */
/*           printf("Received packet header crc error detected\n"); */
/*           exit(1); */
/*         } */
/*         if(rxs->dcrcerr) { */
/*           printf("Received packet data crc error detected\n"); */
/*           exit(1); */
/*         } */
/*         if ((reply->status == 0) && (i != 0)) { */
/*           if (*size != (*replysize+1+(i/2)+1)) { */
/*             printf("Received packet has wrong length\n"); */
/*             printf("Expected: %i, Got: %i \n", *replysize+2+(i/2), *size); */
/*             exit(1); */
/*           } */
/*         } else { */
/*           if (*size != (*replysize+1)) { */
/*             printf("Received packet has wrong length\n"); */
/*             printf("Expected: %i, Got: %i \n", *replysize+1, *size); */
/*             exit(1); */
/*           } */
/*         } */
/*         for(k = 0; k < *replysize; k++) { */
/*           if (loadb((int)&(rx1[k])) != rx2[k]) { */
/*             printf("Compare error 0: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx1[k])), (unsigned)rx2[k]); */
/*             exit(1); */
/*           } */
/*         } */
/*         if (reply->status == 0) { */
/*           for(k = *replysize+1; k < *replysize+1+(i/2); k++) { */
/*             if (loadb((int)&(rx1[k])) != rx2[k]) { */
/*               printf("Compare error 1: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx1[k])), (unsigned)rx2[k]); */
/*               exit(1); */
/*             } */
/*           } */
/*           for(k = 0; k < (i/2); k++) { */
/*             if (loadb((int)&(rx0[k+(m%4)])) != ((tx1[k] & tx1[k+(i/2)]) | (rx2[*replysize+1+k] & ~tx1[k+(i/2)]) )) { */
/*               printf("Compare error 2: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx0[k+(m%4)])), (unsigned)tx1[k]); */
/*               exit(1); */
/*             } */
/*           } */
                                        
/*         } */
/*         if (((i % 4) == 0) && ((m % 8) == 0)) { */
/*           printf("Packet  %i, alignment %i\n", i, m); */
/*         } */
/*       } */
/*     } */
/*     printf("RMW test passed\n"); */

/*     for(i = 0; i < RMAPSIZE; i++) { */
/*       for(m = 0; m < 8; m++) { */
/*         for(j = 0; j < i+4; j++) { */
/*           rx0[j]  = ~rx0[j]; */
/*         } */
/*         if (m >= 4) { */
/*           cmd->incr     = no; */
/*         } else { */
/*           cmd->incr     = yes; */
/*         } */
/*         cmd->type     = readcmd; */
/*         cmd->verify   = no; */
/*         cmd->ack      = yes; */
/*         cmd->destaddr = 0x14; */
/*         cmd->destkey  = 0xBF; */
/*         cmd->srcaddr  = 0x14; */
/*         cmd->tid      = i; */
/*         cmd->addr     = (int)&(rx0[(m%4)]); */
/*         cmd->len      = i; */
/*         cmd->status   = 0; */
/*         cmd->dstspalen = 0; */
/*         cmd->dstspa  = (char *)NULL; */
/*         cmd->srcspalen = 0; */
/*         cmd->srcspa = (char *)NULL; */
/*         if (build_rmap_hdr(cmd, tx0, cmdsize)) { */
/*           printf("RMAP cmd build failed\n"); */
/*           exit(1); */
/*         } */
/*         reply->type     = readrep; */
/*         reply->verify   = no; */
/*         reply->ack      = yes; */
/*         if (m >= 4) { */
/*           reply->incr     = no; */
/*           if ( ((((int)&(rx0[(m%4)])) % 4) != 0) || ((cmd->len % 4) != 0) )  { */
/*             reply->status   = 10; */
/*           } else { */
/*             reply->status   = 0; */
/*           } */
/*         } else { */
/*           reply->incr     = yes; */
/*           reply->status   = 0; */
/*         } */
/*         if (reply->status == 0) { */
/*           reply->len      = i; */
/*         } else { */
/*           reply->len      = 0; */
/*         } */
/*         reply->destaddr = 0x14; */
/*         reply->destkey  = 0XBF; */
/*         reply->srcaddr  = 0x14; */
/*         reply->tid      = i; */
/*         reply->addr     = (int)&(rx0[(m%4)]); */
/*         reply->dstspalen = 0; */
/*         reply->dstspa  = (char *)NULL; */
/*         reply->srcspalen = 0; */
/*         reply->srcspa = (char *)NULL; */
/*         if (build_rmap_hdr(reply, rx2, replysize)) { */
/*           printf("RMAP reply build failed\n"); */
/*           exit(1); */
/*         } */
/*         while (spw_rx(rx1, spw)) { */
/*           for (k = 0; k < 64; k++) {} */
/*         } */
/*         if (spw_tx(1, 0, 0, *cmdsize, tx0, 0, tx1, spw)) { */
/*           printf("Transmission failed\n"); */
/*           exit(1); */
/*         } */
/*         while (!(tmp = spw_checktx(spw))) { */
/*           for (k = 0; k < 64; k++) {} */
/*         } */
/*         if (tmp != 1) { */
/*           printf("Error in transmit \n"); */
/*           exit(1); */
/*         } */
/*         while (!(tmp = spw_checkrx(size, rxs, spw))) { */
/*           for (k = 0; k < 64; k++) {} */
/*         } */
/*         if (rxs->truncated) { */
/*           printf("Received packet truncated\n"); */
/*           exit(1); */
/*         } */
/*         if(rxs->eep) { */
/*           printf("Received packet terminated with eep\n"); */
/*           exit(1); */
/*         } */
/*         if(rxs->hcrcerr) { */
/*           printf("Received packet header crc error detected\n"); */
/*           exit(1); */
/*         } */
/*         if(rxs->dcrcerr) { */
/*           printf("Received packet data crc error detected\n"); */
/*           exit(1); */
/*         } */
/*         for (k = 0; k < *replysize; k++) { */
/*           if (loadb((int)&(rx1[k])) != rx2[k]) { */
/*             printf("Compare error 0: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx1[k])), (unsigned)rx2[k]); */
/*             exit(1); */
/*           } */
/*         } */
/*         if ((reply->status) == 0 && (i != 0)) { */
/*           if (*size != (*replysize+2+i)) { */
/*             printf("Received packet has wrong length\n"); */
/*             printf("Expected: %i, Got: %i \n", *replysize+2+i, *size); */
/*           } */
/*           if (cmd->incr == yes) { */
/*             for(k = 0; k < i; k++) { */
/*               if (loadb((int)&(rx1[*replysize+1+k])) != rx0[k+(m%4)]) { */
/*                 printf("Compare error 1: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx1[*replysize+1+k])), (unsigned)rx0[k+(m%4)]); */
/*                 exit(1); */
/*               } */
/*             } */
/*           } else { */
/*             for(k = 0; k < i; k++) { */
/*               if (loadb((int)&(rx1[*replysize+1+k])) != rx0[(k%4)+(m%4)]) { */
/*                 printf("Compare error 2: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx1[*replysize+1+k])), (unsigned)rx0[(k%4)+(m%4)]); */
/*                 printf("Rx1: %x, Rx0: %x\n", (int)rx1, (int)rx0); */
/*                 //exit(1); */
/*               } */
/*             } */
/*           } */
/*         } else { */
/*           if (*size != (*replysize+1)) { */
/*             printf("Received packet has wrong length\n"); */
/*             printf("Expected: %i, Got: %i \n", *replysize+1, *size); */
/*           } */
/*         } */
/*         if ((i % 512) == 0) { */
/*           printf("Packet  %i, alignment %i\n", i, m); */
/*         } */
/*       } */
/*     } */
/*     printf("Read test passed\n"); */

/*     /\*late and early eop tests*\/ */
/*     for(i = 0; i < RMAPSIZE; i++) { */
/*       if (i < 16) { */
/*         tmp = -i; */
/*       } else { */
/*         tmp = -16; */
/*       } */
/*       for (j = tmp; j < i; j++) { */
/*         for (m = 0; m < 3; m++) { */
/*           for(k = 0; k < i; k++) { */
/*             tx1[k]  = ~tx1[k]; */
/*           } */
/*           if (m == 0) { */
/*             cmd->type     = writecmd; */
/*             cmd->verify   = no; */
/*             reply->type   = writerep; */
/*             reply->verify = no; */
/*           } else if (m == 2) { */
/*             cmd->type     = rmwcmd; */
/*             cmd->verify   = yes; */
/*             reply->type    = rmwrep; */
/*             reply->verify = yes; */
/*           } else { */
/*             cmd->type     = writecmd; */
/*             cmd->verify   = yes; */
/*             reply->type    = writerep; */
/*             reply->verify = yes; */
/*           } */
/*           cmd->incr     = yes; */
/*           cmd->ack      = yes; */
/*           cmd->destaddr = 0x14; */
/*           cmd->destkey  = 0xBF; */
/*           cmd->srcaddr  = 0x14; */
/*           cmd->tid      = i; */
/*           cmd->addr     = (int)rx0; */
/*           cmd->len      = i; */
/*           cmd->status   = 0; */
/*           cmd->dstspalen = 0; */
/*           cmd->dstspa  = (char *)NULL; */
/*           cmd->srcspalen = 0; */
/*           cmd->srcspa = (char *)NULL; */
/*           if (build_rmap_hdr(cmd, tx0, cmdsize)) { */
/*             printf("RMAP cmd build failed\n"); */
/*             exit(1); */
/*           } */
/*           reply->len       = 0; */
/*           if (j < 0 ) { */
/*             reply->status = 5; */
/*           } else if (j == 0) { */
/*             reply->status = 0; */
                                                
/*           } else { */
/*             reply->status = 6; */
/*             for(l = 0; l < i; l++) { */
/*               if ((int)tx1[l] != 0) { */
/*                 reply->status = 4; */
/*               } */
/*             } */
/*           } */
/*           if(m == 2 ) { */
/*             if((cmd->len != 0) && (cmd->len != 2) && (cmd->len != 4) && */
/*                (cmd->len != 6) && (cmd->len != 8)) { */
/*               reply->status = 11; */
/*             } else if( (((cmd->len/2) == 2) && (cmd->addr % 2 != 0)) || */
/*                        (((cmd->len/2) == 4) && (cmd->addr % 4 != 0)) || */
/*                        ((cmd->len/2) == 3) ) { */
/*               reply->status = 10; */
/*             } else { */
/*               if ((reply->status != 0) && (reply->status != 6)) { */
/*                 reply->len = 0; */
/*               } else { */
/*                 reply->len = cmd->len/2; */
/*               } */
/*             } */
/*           } else if (m != 0) { */
/*             if(cmd->len > 4) { */
/*               reply->status = 9; */
/*             } else if( (((cmd->len) == 2) && (cmd->addr % 2 != 0)) || */
/*                        (((cmd->len) == 4) && (cmd->addr % 4 != 0)) || */
/*                        ((cmd->len) == 3) ) { */
/*               reply->status = 10; */
/*             } */
/*           } */
/*           reply->incr      = yes; */
/*           reply->ack       = yes; */
/*           reply->destaddr  = 0x14; */
/*           reply->destkey   = 0xBF; */
/*           reply->srcaddr   = 0x14; */
/*           reply->tid       = i; */
/*           reply->addr      = (int)rx0; */
/*           reply->dstspalen = 0; */
/*           reply->dstspa    = (char *) NULL; */
/*           reply->srcspalen = 0; */
/*           reply->srcspa    = (char *) NULL; */
/*           if (build_rmap_hdr(reply, rx2, replysize)) { */
/*             printf("RMAP reply build failed\n"); */
/*             exit(1); */
/*           } */
/*           if ((reply->status == 0) || (reply->status == 6)) { */
/*             for(k = 0; k < reply->len; k++) { */
/*               rx2[*replysize+1+k] = loadb((int)&(rx0[k])); */
/*             } */
/*           } */
/*           while (spw_rx(rx1, spw)) { */
/*             for (k = 0; k < 64; k++) {} */
/*           } */
/*           if (spw_tx(1, 1, 0, *cmdsize, tx0, i+j, tx1, spw)) { */
/*             printf("Transmission failed\n"); */
/*             exit(1); */
/*           } */
/*           while (!(tmp = spw_checktx(spw))) { */
/*             for (k = 0; k < 64; k++) {} */
/*           } */
/*           if (tmp != 1) { */
/*             printf("Error in transmit \n"); */
/*             exit(1); */
/*           } */
/*           while (!(tmp = spw_checkrx(size, rxs, spw))) { */
/*             for (k = 0; k < 64; k++) {} */
/*           } */
/*           if (rxs->truncated) { */
/*             printf("Received packet truncated\n"); */
/*             exit(1); */
/*           } */
/*           if(rxs->eep) { */
/*             printf("Received packet terminated with eep\n"); */
/*             exit(1); */
/*           } */
/*           if(rxs->hcrcerr) { */
/*             printf("Received packet header crc error detected\n"); */
/*             exit(1); */
/*           } */
/*           if(rxs->dcrcerr) { */
/*             printf("Received packet data crc error detected\n"); */
/*             exit(1); */
/*           } */
/*           if (m == 2) { */
/*             if ((i != 0) && ((reply->status == 0) || (reply->status == 6))) { */
/*               tmp = reply->len+1; */
/*             } else { */
/*               tmp = 0; */
/*             } */
/*           } else { */
/*             tmp = 0; */
/*           } */
/*           if (*size != (*replysize+1+tmp)) { */
/*             printf("Received packet has wrong length\n"); */
/*             printf("Expected: %i, Got: %i \n", *replysize+1+tmp, *size); */
/*             exit(1); */
/*           } */
/*           if (tmp == 0) { */
/*             tmp++; */
/*           } */
/*           for(k = 0; k < *replysize; k++) { */
/*             if (loadb((int)&(rx1[k])) != rx2[k]) { */
/*               if (k != 3) { */
/*                 printf("Compare error 0: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx1[k])), (unsigned)rx2[k]); */
/*                 printf("Packet  %i, type %i, offset: %i\n", i, m, j); */
/*                 exit(1); */
/*               } */
/*             } */
/*           } */
/*           if ((reply->status == 0) || (reply->status == 6)) { */
/*             if (m == 2) { */
/*               for(k = 0; k < reply->len; k++) { */
/*                 if (loadb((int)&(rx1[k+*replysize+1])) != rx2[k+*replysize+1]) { */
/*                   printf("Compare error 2: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx1[k+*replysize+1])), (unsigned)rx2[k+*replysize+1]); */
/*                   printf("Rx0: %x, Rx1: %x, Rx2: %x\n", (int)rx0, (int)rx1, (int)rx2); */
/*                   exit(1); */
/*                 } */
/*               } */
/*               for(k = 0; k < (reply->len/2); k++) { */
/*                 if (loadb((int)&(rx0[k])) != ((tx1[k] & tx1[k+(i/2)]) | (rx2[*replysize+1+k] & ~tx1[k+(i/2)]) )) { */
/*                   printf("Compare error 3: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx0[k])), (unsigned)tx1[k]); */
/*                   exit(1); */
/*                 } */
/*               } */
/*             } else { */
/*               for (k = 0; k < i; k++) { */
/*                 if (loadb((int)&(rx0[k])) != tx1[k]) { */
/*                   printf("Compare error 1: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx0[k])), (unsigned)tx1[k]); */
/*                   exit(1); */
/*                 } */
/*               } */
/*             } */
/*           } */
/*           if (((i % 8) == 0) && (m == 0) && (j == 0)) { */
/*             printf("Packet  %i, type %i, offset: %i\n", i, m, j); */
/*           } */
/*         } */
/*       } */
                        
/*     } */
/*     printf("Test 10 completed successfully\n"); */
   } 

  /************************ TEST 11 **************************************/
  printf("Dma channel RMAP CRC test\n");
  if ((spw->rmapcrc == 1) && (spw->rmap == 0)) {
    tx0 = (char *)malloc(64); 
    tx1 = (char *)calloc(RMAPCRCSIZE, 1);
    rx1 = (char *)malloc(32+RMAPCRCSIZE);
    for(i = 0; i < RMAPCRCSIZE; i++) {
      for(m = 0; m < 6; m++) {
        for(k = 0; k < i; k++) {
          tx1[k]  = ~tx1[k];
        }
        switch (m) {
          case 0:
            cmd->type     = writecmd;
            cmd->verify   = no;
            j = i;
            break;
          case 1:
            cmd->type     = readcmd;
            cmd->verify   = no;
            j = 0;
            break;
          case 2:
            cmd->type     = rmwcmd;
            j           = (i % 8);
            cmd->verify   = yes;
            break;
          case 3:
            cmd->type     = writerep;
            j           = 0;
            cmd->verify   = no;
            break;
          case 4:
            cmd->type     = readrep;
            cmd->verify   = no;
            j           = i;
            break;
          case 5:
            cmd->type     = rmwrep;
            j           = (i/2);
            cmd->verify   = yes;
            break;
          default:
            break;
        }
        cmd->incr     = no;
        cmd->ack      = yes;
        cmd->destaddr = 0x14;
        cmd->destkey  = 0xBF;
        cmd->srcaddr  = 0x14;
        cmd->tid      = i;
        cmd->addr     = (int)(rx0);
        cmd->len      = i;
        cmd->status   = 0;
        cmd->dstspalen = 0;
        cmd->dstspa  = (char *)NULL;
        cmd->srcspalen = 0;
        cmd->srcspa = (char *)NULL;
        if (build_rmap_hdr(cmd, tx0, cmdsize)) {
          printf("RMAP cmd build failed\n");
          exit(1);
        }
        while (spw_rx(rx1, spw)) {
          for (k = 0; k < 64; k++) {}
        }
        if (spw_tx(1, 1, 0, *cmdsize, tx0, j, tx1, spw)) {
          printf("Transmission failed\n");
          exit(1);
        }
        while (!(tmp = spw_checktx(spw))) {
          for (k = 0; k < 64; k++) {}
        }
        if (tmp != 1) {
          printf("Error in transmit \n");
          exit(1);
        }
        while (!(tmp = spw_checkrx(size, rxs, spw))) {
          for (k = 0; k < 64; k++) {}
        }
        if (rxs->truncated) {
          printf("Received packet truncated\n");
          exit(1);
        }
        if(rxs->eep) {
          printf("Received packet terminated with eep\n");
          exit(1);
        }
        if(rxs->hcrcerr) {
          printf("Received packet header crc error detected\n");
          exit(1);
        }
        if(rxs->dcrcerr) {
          printf("Received packet data crc error detected\n");
          exit(1);
        }
        if (j != 0) {
          l = 1;
        } else {
          l = 0;
        }
        if (*size != (*cmdsize+1+j+l)) {
          printf("Received packet has wrong length\n");
          printf("Expected: %i, Got: %i \n", *cmdsize+1+j+l, *size);
          exit(1);
        }
        for(k = 0; k < *cmdsize; k++) {
          if (loadb((int)&(rx1[k])) != tx0[k]) {
            printf("Compare error 0: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx1[k])), (unsigned)tx0[k]);
            printf("Packet  %i, type %i\n", i, m);
            exit(1);
          }
        }
        for(k = 0; k < j; k++) {
          if (loadb((int)&(rx1[k+*cmdsize+1])) != tx1[k]) {
            printf("Compare error 1: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx1[k+*cmdsize+1])), (unsigned)tx1[k]);
            exit(1);
          }
        }
        if (((i % 4) == 0) && ((m % 3) == 0)) {
          printf("Packet  %i, type %i\n", i, m);
        }
      }
    }
  }
  printf("Test 11 completed successfully\n");
  printf("*********** Test suite completed successfully ************\n");
  exit(0);
        
}
