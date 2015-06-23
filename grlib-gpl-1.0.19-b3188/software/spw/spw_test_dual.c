/*****************************************************************************/
/*   This file is a part of the GRLIB VHDL IP LIBRARY */
/*   Copyright (C) 2004 GAISLER RESEARCH */

/*   This program is free software; you can redistribute it and/or modify */
/*   it under the terms of the GNU General Public License as published by */
/*   the Free Software Foundation; either version 2 of the License, or */
/*   (at your option) any later version. */

/*   See the file COPYING for the full details of the license. */
/******************************************************************************/

#define SPW1_ADDR    0x80000a00
#define SPW2_ADDR    0x80000b00 
#define SPW1_FREQ    50000       /* Frequency of txclk in khz, set to 0 to use reset value  */
#define SPW2_FREQ    50000       /* Frequency of txclk in khz, set to 0 to use reset value  */
#define AHBFREQ      75000        /* Set to zero to leave reset values */

#define SPW_CLKDIV   5

#include <stdlib.h>
#include "spwapi.h"
#include "rmapapi.h"
#include <time.h>
#include <string.h>
#include <limits.h>

#define PKTTESTMAX  128
#define DESCPKT     1024
#define MAXSIZE     16777215     /*must not be set to more than 16777216 (2^24)*/
#define RMAPSIZE    1024
#define RMAPCRCSIZE 1024

#define TEST1       1
#define TEST2       1
#define TEST3       1
#define TEST4       1 
#define TEST5       1 
#define TEST6       1
#define TEST7       1 
#define TEST8       1
#define TEST9       1
#define TEST10      1
#define TEST11      1
#define TEST12      1

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

int main(int argc, char *argv[]) 
{
  int  ret;
  clock_t t1, t2;
  double t3, bitrate;
  int  dmachan;
  int  sysfreq;
  int  txfreq1;
  int  txfreq2;
  int  i;
  int  j;
  int  k;
  int  m;
  int  l;
  int  iterations;
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
  struct rxstatus *rxs;
  struct spwvars *spw1;
  struct spwvars *spw2;
  struct rmap_pkt *cmd;
  struct rmap_pkt *reply;
  int *cmdsize;
  int *replysize;
  int startrx[4];
  int rmappkt;
  int rmapincr;
  int destaddr;
  int sepaddr[4];
  int chanen[4];
  int rmaprx;
  int found;
  int rxchan;
  int length;
  int maxlen;
  spw1 = (struct spwvars *) malloc(sizeof(struct spwvars));
  spw2 = (struct spwvars *) malloc(sizeof(struct spwvars));
  rxs = (struct rxstatus *) malloc(sizeof(struct rxstatus));
  size = (int *) malloc(sizeof(int));

  cmd = (struct rmap_pkt *) malloc(sizeof(struct rmap_pkt));
  reply = (struct rmap_pkt *) malloc(sizeof(struct rmap_pkt));
  cmdsize = (int *) malloc(sizeof(int));
  replysize = (int *) malloc(sizeof(int));
  
  if (SPW1_FREQ == 0) {
          spw1->clkdivs = loadmem((int)&(spw1->regs->clkdiv));
  } else {
          spw1->clkdivs = SPW1_FREQ/10000;
          if (spw1->clkdivs)
                  spw1->clkdivs--;
  }
  
  if (SPW2_FREQ == 0) {
          spw2->clkdivs = loadmem((int)&(spw2->regs->clkdiv));
  } else {
          spw2->clkdivs = SPW2_FREQ/10000;
          if (spw2->clkdivs)
                  spw2->clkdivs--;
  }
  
  printf("**** TEST STARTED **** \n\n");
  /************************ TEST INIT ***********************************/
  /*Initalize link*/
  /*initialize parameters*/
  if (spw_setparam(0x1, SPW_CLKDIV, 0xBF, 0, 0, SPW1_ADDR, AHBFREQ, spw1) ) {
    printf("Illegal parameters to spacewire\n");
    exit(1);
  }
  if (spw_setparam(0x2, SPW_CLKDIV, 0xBF, 0, 0, SPW2_ADDR, AHBFREQ ,spw2) ) {
    printf("Illegal parameters to spacewire\n");
    exit(1);
  }

  for(i = 0; i < 4; i++) {
    spw_setparam_dma(i, 0x1, 0x0, 1, 1048576, spw1);
  }
  for(i = 0; i < 4; i++) {
    spw_setparam_dma(i, 0x2, 0x0, 1, 1048576, spw2);
  }
  
  /* reset links */
  spw_reset(spw1);
  spw_reset(spw2);
  /* initialize links */
  if ((ret = spw_init(spw1))) {
    printf("Link initialization failed for link1: %d\n", ret);
  }
  if ((ret = spw_init(spw2))) {
    printf("Link initialization failed for link2: %d\n", ret);
  } 
  
  printf("SPW 1 version: %d \n", spw1->ver);
  printf("SPW 2 version: %d \n", spw2->ver);

  if (wait_running(spw1)) {
          printf("Link 1 did not enter run-state\n");
  }
  if (wait_running(spw2)) {
          printf("Link 2 did not enter run-state\n");
  }

/*   /\************************ TEST 1 **************************************\/  */
/*   /\*Simulatenous time-code and packet transmission/reception*\/ */
#if TEST1 == 1 
  printf("TEST 1: Tx and Rx with simultaneous time-code transmissions \n\n");
  rx0 = malloc(128);
  rx1 = malloc(128);
  rx2 = malloc(128);
  rx3 = malloc(128);
  tx0 = malloc(128);
  tx1 = malloc(128);
  tx2 = malloc(128);
  tx3 = malloc(128);
  /* for(i = 2; i < 128; i++) { */
/*     tx0[i] = (char)i; */
/*     tx1[i] = (char)~i; */
/*     tx2[i] = (char)(i ^ (i + ~i)); */
/*     tx3[i] = (char)(i ^ (i + ~i + 5)); */
/*   } */
  tx0[0] = (char)0x2;
  tx1[0] = (char)0x2;
  tx2[0] = (char)0x1;
  tx3[0] = (char)0x1;
 /*  tx0[1] = (char)0x02; */
/*   tx1[1] = (char)0x02; */
/*   tx2[1] = (char)0x02; */
/*   tx3[1] = (char)0x02; */
  spw_rx(0, rx0, spw1);
  spw_rx(0, rx1, spw1);
  spw_rx(0, rx2, spw2);
  spw_rx(0, rx3, spw2);
  spw_tx(0, 0, 0, 0, 0, tx0, 128, tx0, spw1);
  spw_tx(0, 0, 0, 0, 0, tx1, 128, tx1, spw1);
  spw_tx(0, 0, 0, 0, 0, tx2, 128, tx2, spw2);
  spw_tx(0, 0, 0, 0, 0, tx3, 128, tx3, spw2);

  for (i = 0; i < 2; i++) {
    while(!(tmp = spw_checktx(0, spw1))) {
      for(j = 0; j < 64; j++) {}
    }
    if (tmp != 1) {
      printf("Transmit error link 1\n");
      exit(1);
    }
  }

  for(i = 0; i < 2; i++) {
    while(!(tmp = spw_checktx(0, spw2))) {
      for(j = 0; j < 64; j++) {}
    }
    if (tmp != 1) {
      printf("Transmit error link 2\n");
      exit(1);
    }
  }
  
  for(i = 0; i < 2; i++) {
    while(!(tmp = spw_checkrx(0, size, rxs, spw1))) {
      for(j = 0; j < 64; j++) {}
    }
    if (rxs->truncated) {
      printf("Received packet truncated link 1\n");
      exit(1);
    }
    if(rxs->eep) {
      printf("Received packet terminated with eep link 1\n");
      exit(1);
    }
    if (*size != 128) {
      printf("Received packet has wrong length link 1\n");
      exit(1);
    }
  }

  printf("Link 1 received\n");

  for(i = 0; i < 2; i++) {
    while(!(tmp = spw_checkrx(0, size, rxs, spw2))) {
      for(j = 0; j < 64; j++) {}
    }
    if (rxs->truncated) {
      printf("Received packet truncated link 2\n");
      exit(1);
    }
    if(rxs->eep) {
      printf("Received packet terminated with eep link 2\n");
      exit(1);
    }
    if (*size != 128) {
      printf("Received packet has wrong length link 2\n");
      exit(1);
    }
  }

  printf("Link 2 received\n");
  
  for(j = 0; j < 128; j++) {
    if (loadb((int)&(rx2[j])) != tx0[j]) {
      printf("Compare error buf 0: %u Data: %x Expected: %x \n", j, (unsigned)loadb((int)&(rx2[j])), (unsigned)tx0[j]);
      exit(1);
    }
    if (loadb((int)&(rx3[j])) != tx1[j]) {
      printf("Compare error buf 1: %u Data: %x Expected: %x \n", j, (unsigned)loadb((int)&(rx3[j])), (unsigned)tx1[j]);
      exit(1);
    }
    if (loadb((int)&(rx0[j])) != tx2[j]) {
      printf("Compare error buf 2: %u Data: %x Expected: %x \n", j, (unsigned)loadb((int)&(rx0[j])), (unsigned)tx2[j]);
      exit(1);
    }
    if (loadb((int)&(rx1[j])) != tx3[j]) {
      printf("Compare error buf 3: %u Data: %x Expected: %x \n", j, (unsigned)loadb((int)&(rx1[j])), (unsigned)tx3[j]);
      exit(1);
    }
  }
  free(rx0);
  free(rx1);
  free(rx2);
  free(rx3);
  free(tx0);
  free(tx1);
  free(tx2);
  free(tx3);
  printf("TEST 1: completed successfully\n\n");
#endif
/* /\************************ TEST 2 **************************************\/ */
#if TEST2 == 1
  printf("TEST 2: Tx and Rx of varying sized packets from/to DMA channel \n\n");
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
  txbuf[0] = 0x2;
  txbuf[1] = 0x2;
  for (i = 2; i < PKTTESTMAX; i++) {
    printf(".");      
    for (j = 2; j < i; j++) {
      txbuf[j] = ~txbuf[j];
    }
    while (spw_rx(0, rxbuf, spw2)) {
      for (k = 0; k < 64; k++) {}
    }
    if (spw_tx(0, 0, 0, 0, 0, txbuf, i, txbuf, spw1)) {
      printf("Transmission failed\n");
      exit(1);
    }
    while (!(tmp = spw_checktx(0, spw1))) {
      for (k = 0; k < 64; k++) {}
    }
    if (tmp != 1) {
      printf("Error in transmit \n");
      exit(1);
    }
    while (!(tmp = spw_checkrx(0, size, rxs, spw2))) {
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
    /*printf("Packet %i transferred\n", i);*/
  }
  free(rxbuf);
  free(txbuf);
  printf("\n");
  printf("TEST 2: completed successfully\n\n");
#endif
/*   /\************************ TEST 3 **************************************\/ */
#if TEST3 == 1
  if (spw2->rmap || spw2->rxunaligned) {
    printf("TEST 3: Tx and Rx with varying size and alignment from/to DMA channel\n\n");
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
    txbuf[0] = 0x2;
    txbuf[1] = 0x2;
    for (i = 2; i < PKTTESTMAX; i++) {
      for(m = 1; m < 4; m++) {
        printf(".");
        for (j = 2; j < i; j++) {
          txbuf[j] = ~txbuf[j];
        }
        while (spw_rx(0, (char *)&(rxbuf[m]), spw2)) {
          for (k = 0; k < 64; k++) {}
        }
        if (spw_tx(0, 0, 0, 0, 0, txbuf, i, txbuf, spw1)) {
          printf("Transmission failed\n");
          exit(1);
        }
        while (!(tmp = spw_checktx(0, spw1))) {
          for (k = 0; k < 64; k++) {}
        }
        if (tmp != 1) {
          printf("Error in transmit \n");
          exit(1);
        }
        while (!(tmp = spw_checkrx(0, size, rxs, spw2))) {
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
        /* printf("Packet %i transferred with alignment %i\n", i, m); */
      }
      
    }
    free(rxbuf);
    free(txbuf);
    printf("\n");
    printf("TEST 3: completed successfully\n\n");
  }
#endif
/*   /\************************ TEST 4 **************************************\/ */
#if TEST4 == 1 
  printf("TEST 4: Tx from data pointer with varying alignment\n\n");
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
      printf(".");
      for (j = 2; j < (i+m); j++) {
        txbuf[j] = ~txbuf[j];
      }
      txbuf[m] = 0x2;
      txbuf[m+1] = 0x2;
      while (spw_rx(0, rxbuf, spw2)) {
        for (k = 0; k < 64; k++) {}
      }
      if (spw_tx(0, 0, 0, 0, 0, txbuf, i, (char *)&(txbuf[m]), spw1)) {
        printf("Transmission failed\n");
        exit(1);
      }
      while (!(tmp = spw_checktx(0, spw1))) {
        for (k = 0; k < 64; k++) {}
      }
      if (tmp != 1) {
        printf("Error in transmit \n");
        exit(1);
      }
      while (!(tmp = spw_checkrx(0, size, rxs, spw2))) {
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
      /* printf("Packet %i transferred with alignment %i\n", i, m); */
    }
                                
  }
  free(rxbuf);
  free(txbuf);
  printf("\n");
  printf("TEST 4: completed successfully\n\n");
#endif
  /************************ TEST 5 **************************************/
#if TEST5 == 1
  printf("TEST 5: Tx with header and data pointers with varying aligment on header \n\n");
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
  txbuf[0] = 0x2;
  txbuf[1] = 0x2;
  for(i = 0; i < 256; i++) {
    for(m = 0; m < 4; m++) {
      printf(".");
      for (j = 2; j < PKTTESTMAX; j++) {
        txbuf[j] = ~txbuf[j];
      }
      for (j = 0; j < 260; j++) {
        tx0[j] = ~tx0[j];
      }
      tx0[m] = 0x2;
      tx0[m+1] = 0x2;
      while (spw_rx(0, rxbuf, spw2)) {
        for (k = 0; k < 64; k++) {}
      }
      if (spw_tx(0, 0, 0, 0, i,(char *)&(tx0[m]), PKTTESTMAX, txbuf, spw1)) {
        printf("Transmission failed\n");
        exit(1);
      }
      while (!(tmp = spw_checktx(0, spw1))) {
        for (k = 0; k < 64; k++) {}
      }
      if (tmp != 1) {
        printf("Error in transmit \n");
        exit(1);
      }
      while (!(tmp = spw_checkrx(0, size, rxs, spw2))) {
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
      /* printf("Packet %i transferred with alignment %i\n", i, m); */
    }
                                
  }
  free(rxbuf);
  free(txbuf);
  free(tx0);
  printf("\n");
  printf("TEST 5: completed successfully\n\n");
#endif
/*   /\************************ TEST 6 **************************************\/ */
#if TEST6 == 1
  printf("TEST 6: Tx with data and header both with varying alignment \n\n");
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
    /* printf("Packet with header %i, alignment: %i and data: %i, alignment: %i transferred\n", i, m, j, l); */
    for(j = 0; j < PKTTESTMAX; j++) {
      for(m = 0; m < 4; m++) {
        for(l = 0; l < 4; l++) {
          for (k = 0; k < PKTTESTMAX; k++) {
            txbuf[k] = ~txbuf[k];
          }
          for (k = 0; k < 260; k++) {
            tx0[k] = ~tx0[k];
          }
          tx0[m] = 0x2;
          tx0[m+1] = 0x2;
          txbuf[l] = 0x2;
          txbuf[l+1] = 0x2;
          if (!notrx) {
            while (spw_rx(0, rxbuf, spw2)) {
              for (k = 0; k < 64; k++) {}
            }
          }
          if (spw_tx(0, 0, 0, 0, i,(char *)&(tx0[m]), j, (char *)&(txbuf[l]), spw1)) {
            printf("Transmission failed\n");
            exit(1);
          }
          while (!(tmp = spw_checktx(0, spw1))) {
            for (k = 0; k < 64; k++) {}
          }
          if (tmp != 1) {
            printf("Error in transmit \n");
            exit(1);
          }
          if( (i+j) > 1) {
            while (!(tmp = spw_checkrx(0, size, rxs, spw2))) {
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
            if (spw_checkrx(0, size, rxs, spw2)) {
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
  printf("\n");
  printf("TEST 6: completed successfully\n\n");
#endif
/*   /\************************ TEST 7 **************************************\/ */
#if TEST7 == 1
  printf("TEST 7: Fill descriptor tables completely \n\n");
  for(i = 0; i < 64; i++) {
    tx[i] = malloc(DESCPKT);
  }
  for(i = 0; i < 128; i++) {
    rx[i] = malloc(DESCPKT+256);
  }
  txbuf = malloc(256);
  /*initialize data*/
  for(i = 0; i < 64; i++) {
    tx[i][0] = 0x2;
    tx[i][1] = 0x2;
    for(j = 2; j < DESCPKT; j++) {
      tx[i][j] = j ^ i;
    }
  }
  txbuf[0] = 0x2;
  txbuf[1] = 0x2;
  for(i = 2; i < 256; i++) {
    txbuf[i] = i;
  }
  for(i = 0; i < 128; i++) {
    while (spw_rx(0, rx[i], spw2)) {
      for (k = 0; k < 64; k++) {}
    }
  }
  for(i = 0; i < 64; i++) {
    if (spw_tx(0, 0, 0, 0, 255, txbuf, DESCPKT, tx[i], spw1)) {
      printf("Transmission failed\n");
      exit(1);
    }
  }
  for(i = 0; i < 64; i++) {
    while (!(tmp = spw_checktx(0, spw1))) {
      for (k = 0; k < 64; k++) {}
    }
    if (tmp != 1) {
      printf("Error in transmit \n");
      exit(1);
    }
  }
  for(i = 0; i < 64; i++) {
    while (!(tmp = spw_checkrx(0, size, rxs, spw2))) {
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
    if (spw_tx(0, 0, 0, 0, 255, txbuf, DESCPKT, tx[i], spw1)) {
      printf("Transmission failed\n");
      exit(1);
    }
  }
  for(i = 0; i < 64; i++) {
    while (!(tmp = spw_checktx(0, spw1))) {
      for (k = 0; k < 64; k++) {}
    }
    if (tmp != 1) {
      printf("Error in transmit \n");
      exit(1);
    }
  }
  for(i = 0; i < 64; i++) {
    while (!(tmp = spw_checkrx(0, size, rxs, spw2))) {
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
  printf("TEST 7: completed successfully\n\n");
#endif

/*   /\************************ TEST 8 **************************************\/ */
#if TEST8 == 1
  printf("TEST 8: Transmission and reception of maximum size packets\n");
  txbuf = malloc(MAXSIZE+1);
  rxbuf = malloc(MAXSIZE);
  rx0   = malloc(MAXSIZE);
  tx0   = malloc(64);
      
  if ((rxbuf == NULL) || (txbuf == NULL) || (rx0 == NULL) || (tx0 == NULL)) {
    printf("Memory allocation failed\n");
    exit(1);
  }
  txbuf[0] = 0x2;
  txbuf[1] = 0x2;
  for(i = 2; i < MAXSIZE; i++) {
    txbuf[i] = (i % 256);
  }
  for (i = 0; i < 64; i++) {
          while (spw_rx(0, rxbuf, spw2)) {
                  for (k = 0; k < 64; k++) {}
          }
  }
  spw2->dma[0].rxmaxlen = MAXSIZE+4;
  if (spw_set_rxmaxlength(0, spw2) ) {
    printf("Max length change failed\n");
    exit(1);
  }
  printf("Maximum speed test started (several minutes can pass before the next output on screen)\n");
  t1 = clock();
  for (i = 0; i < 64; i++) {
          if (spw_tx(0, 0, 0, 0, 0, txbuf, MAXSIZE, txbuf, spw1)) {
                  printf("Transmission failed\n");
                  exit(1);
          }
  }
  for (i = 0; i < 64; i++) {
          while (!(tmp = spw_checktx(0, spw1))) {
                  for (k = 0; k < 64; k++) {}
          }
  }
  t2 = clock();
  if (tmp != 1) {
    printf("Error in transmit \n");
    exit(1);
  }
  for (i = 0; i < 64; i++) {
          while (!(tmp = spw_checkrx(0, size, rxs, spw2))) {
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
          
  }
  /* The same buffer is used for all descriptors so check is done only once*/
  for(k = 0; k < MAXSIZE; k++) {
          if (loadb((int)&(rxbuf[k])) != txbuf[k]) {
                  printf("Compare error: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rxbuf[k])), (unsigned)txbuf[k]);
                  exit(1);
          }
  }
  printf("\n");
  t2 = t2 - t1;
  t3 = t2/CLOCKS_PER_SEC;
  bitrate = MAXSIZE/(t3*1000);
  bitrate = bitrate*64*8;
  bitrate /= 1000.0;
  printf("Effective bitrate: %3.1f Mbit/s\n", bitrate);
  printf("Maximum speed test full-duplex started (several minutes can pass before the next output on screen)\n");
  tx0[0] = 0x1;
  tx0[1] = 0x2;
  for(i = 2; i < MAXSIZE; i++) {
    txbuf[i] = ((~txbuf[i]+i) % 256);
  }
  for (i = 0; i < 64; i++) {
          while (spw_rx(0, rxbuf, spw2)) {
                  for (k = 0; k < 64; k++) {}
          }
  }
  for (i = 0; i < 64; i++) {
          while (spw_rx(0, rx0, spw1)) {
                  for (k = 0; k < 64; k++) {}
          }
  }
  spw1->dma[0].rxmaxlen = MAXSIZE+4;
  if (spw_set_rxmaxlength(0, spw1)) {
    printf("Max length change failed\n");
    exit(1);
  }
  t1 = clock();
  for (i = 0; i < 64; i++) {
          if (spw_tx(0, 0, 0, 0, 0, txbuf, MAXSIZE, txbuf, spw1)) {
                  printf("Transmission failed link 1\n");
                  exit(1);
          }
          if (spw_tx(0, 0, 0, 0, 2, tx0, MAXSIZE-2, txbuf, spw2)) {
                  printf("Transmission failed link 2\n");
                  exit(1);
          }
  }
  for (i = 0; i < 64; i++) {
          while (!(tmp = spw_checktx(0, spw1))) {
                  for (k = 0; k < 64; k++) {}
          }
          if (tmp != 1) {
                  printf("Error in transmit \n");
                  exit(1);
          }
          while (!(tmp = spw_checktx(0, spw2))) {
                  for (k = 0; k < 64; k++) {}
          }
          if (tmp != 1) {
                  printf("Error in transmit \n");
                  exit(1);
          }
  }
  t2 = clock();
  for (i = 0; i < 64; i++) {
          while (!(tmp = spw_checkrx(0, size, rxs, spw2))) {
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
          while (!(tmp = spw_checkrx(0, size, rxs, spw1))) {
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
          
  }
  /* The same buffer is used for all descriptors so check is done only once*/
  for(k = 0; k < MAXSIZE; k++) {
          if (loadb((int)&(rxbuf[k])) != txbuf[k]) {
                  printf("Compare error: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rxbuf[k])), (unsigned)txbuf[k]);
                  exit(1);
          }
  }
  for(k = 0; k < 2; k++) {
          if (loadb((int)&(rx0[k])) != tx0[k]) {
                  printf("Compare error: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx0[k])), (unsigned)tx0[k]);
                  exit(1);
          }
  }
  for(k = 2; k < MAXSIZE; k++) {
          if (loadb((int)&(rx0[k])) != txbuf[k-2]) {
                  printf("Compare error: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx0[k])), (unsigned)txbuf[k-2]);
                  exit(1);
          }
  }
  printf("\n");
  t2 = t2 - t1;
  t3 = t2/CLOCKS_PER_SEC;
  bitrate = MAXSIZE/(t3*1000);
  bitrate = bitrate*128*8;
  bitrate /= 1000.0;
  printf("Effective bitrate: %3.1f Mbit/s\n", bitrate);

  for(i = 2; i < MAXSIZE; i++) {
    txbuf[i] = ~txbuf[i];
  }
  spw2->dma[0].rxmaxlen = MAXSIZE;
  if (spw_set_rxmaxlength(0, spw2) ) {
    printf("Max length change failed\n");
    exit(1);
  }
  maxlen = loadmem((int)&(spw2->regs->dma[0].rxmaxlen));
  printf("Maxlen: %d\n", maxlen);
  while (spw_rx(0, rxbuf, spw2)) {
    for (k = 0; k < 64; k++) {}
  }
  if ((ret = spw_tx(0, 0, 0, 0, 2, txbuf, maxlen-1, txbuf, spw1))) {
    printf("Transmission failed: %d\n", ret);
    exit(1);
  }
  while (!(tmp = spw_checktx(0, spw1))) {
    for (k = 0; k < 64; k++) {}
  }
  if (tmp != 1) {
    printf("Error in transmit \n");
    exit(1);
  }
  while (!(tmp = spw_checkrx(0, size, rxs, spw2))) {
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
  if (*size != (maxlen)) {
    printf("Received packet has wrong length\n");
    printf("Expected: %i, Got: %i \n", maxlen, *size);
  }
  for(k = 0; k < 2; k++) {
    if (loadb((int)&(rxbuf[k])) != txbuf[k]) {
      printf("Compare error: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rxbuf[k])), (unsigned)txbuf[k]);
      exit(1);
    }
  }
  for(k = 0; k < maxlen-2; k++) {
    if (loadb((int)&(rxbuf[k+2])) != txbuf[k]) {
      printf("Compare error: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rxbuf[k+2])), (unsigned)txbuf[k]);
      exit(1);
    }
  }
  for(i = 2; i < MAXSIZE; i++) {
    txbuf[i] = ~txbuf[i];
  }
  printf("\n");
  spw2->dma[0].rxmaxlen = maxlen+4;
  if (spw_set_rxmaxlength(0, spw2) ) {
    printf("Max length change failed\n");
    exit(1);
  }
  while (spw_rx(0, rxbuf, spw2)) {
    for (k = 0; k < 64; k++) {}
  }
  if (spw_tx(0, 0, 0, 0, 2, txbuf, maxlen-1, txbuf, spw1)) {
    printf("Transmission failed\n");
    exit(1);
  }
  while (!(tmp = spw_checktx(0, spw1))) {
    for (k = 0; k < 64; k++) {}
  }
  if (tmp != 1) {
    printf("Error in transmit \n");
    exit(1);
  }
  while (!(tmp = spw_checkrx(0, size, rxs, spw2))) {
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
  if (*size != (maxlen+1)) {
    printf("Received packet has wrong length\n");
    printf("Expected: %i, Got: %i \n", maxlen+1, *size);
  }
  for(k = 0; k < 2; k++) {
    if (loadb((int)&(rxbuf[k])) != txbuf[k]) {
      printf("Compare error: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rxbuf[k])), (unsigned)txbuf[k]);
      exit(1);
    }
  }
  for(k = 0; k < maxlen-2; k++) {
    if (loadb((int)&(rxbuf[k+2])) != txbuf[k]) {
      printf("Compare error: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rxbuf[k+2])), (unsigned)txbuf[k]);
      exit(1);
    }
  }
  free(rxbuf);
  free(txbuf);
  free(tx0);
  free(rx0);
  printf("TEST 8: completed successfully\n");
#endif
/*   /\************************ TEST 9 **************************************\/ */
#if TEST9 == 1
  printf("TEST 9: RMAP CRC for DMA channel(random data) \n\n");
  if (spw2->rmap || spw2->rmapcrc) {
    if ((txbuf = calloc(PKTTESTMAX+4, 1)) == NULL) {
      printf("Transmit buffer initialization failed\n");
      exit(1);
    }
    if ((rxbuf = calloc(PKTTESTMAX+256+2, 1)) == NULL) {
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
    notrx = 0; data = 0; hdr = 0;
    for(i = 0; i < 256; i++) {
      printf(".");
      for(j = 0; j < PKTTESTMAX; j++) {
        for(m = 0; m < 4; m++) {
          for(l = 0; l < 4; l++) {
            /* printf("h %i, a: %i d: %i, a: %i\n", i, m, j, l);  */
            for (k = 0; k < PKTTESTMAX; k++) {
              txbuf[k] = ~txbuf[k];
            }
            for (k = 0; k < 260; k++) {
              tx0[k] = ~tx0[k];
            }
            if (i != 0) {
              hdr = 1;
            } else {
              hdr = 0;
            }
            if ((i != 0) || (j != 0)) {
                    data = 1;
            } else {
                    data = 0;
            }
            tx0[m] = 0x2;
            tx0[m+1] = 0x2;
            txbuf[l] = 0x2;
            txbuf[l+1] = 0x2;
            if (!notrx) {
              while (spw_rx(0, rxbuf, spw2)) {
                for (k = 0; k < 64; k++) {}
              }
            }
            if (spw_tx(0, hdr, 1, 0, i,(char *)&(tx0[m]), j, (char *)&(txbuf[l]), spw1)) {
              printf("Transmission failed\n");
              exit(1);
            }
            while (!(tmp = spw_checktx(0, spw1))) {
              for (k = 0; k < 64; k++) {}
            }
            if (tmp != 1) {
              printf("Error in transmit \n");
              exit(1);
            }
            if( (i+j+hdr+data) > 1) {
              while (!(tmp = spw_checkrx(0, size, rxs, spw2))) {
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
              if (*size != (j+i+hdr+data)) {
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
                if (loadb((int)&(rxbuf[k+i+hdr])) != txbuf[k+l]) {
                  printf("Compare error: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rxbuf[k+i+hdr])), (unsigned)txbuf[k+l]);
                  exit(1);
                }
              }
              notrx = 0;
            } else {
              for(k = 0; k < 1048576; k++) {}
              if (spw_checkrx(0, size, rxs, spw2)) {
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
    printf("\n");
    printf("TEST: 9 completed successfully\n\n");
  }
#endif 
/*   /\************************ TEST 10 **************************************\/ */
#if TEST10==1
  if (spw2->rmap == 1) {
    printf("TEST 10: RMAP and transmit spa test\n");
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

    printf("\nNon verified writes\n");
    /* enable rmap*/
    spw_rmapen(spw2);
    for(i = 0; i < RMAPSIZE; i++) {
      printf(".");
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
        cmd->destaddr = 0x2;
        cmd->destkey  = 0xBF;
        cmd->srcaddr  = 0x1;
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
        reply->destaddr = 0x2;
        reply->destkey  = 0XBF;
        reply->srcaddr  = 0x1;
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
        while (spw_rx(0, rx1, spw1)) {
          for (k = 0; k < 64; k++) {}
        }
        if (spw_tx(0, 1, 1, 0, *cmdsize, tx0, j, tx1, spw1)) {
          printf("Transmission failed\n");
          exit(1);
        }
        while (!(tmp = spw_checktx(0, spw1))) {
          for (k = 0; k < 64; k++) {}
        }
        if (tmp != 1) {
          printf("Error in transmit \n");
          exit(1);
        }
        iterations = 0;
        while (!(tmp = spw_checkrx(0, size, rxs, spw1))) {
          if (iterations > 1000) {
            printf("ERROR: Time limit exceeded while waiting for RMAP reply\n");
            exit(0);
          }
          for (k = 0; k < 64; k++) {}
          /* printf("0x%x\n", spw2->regs->status);*/
          iterations++;
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
        /* if ((i % 512) == 0) { */
/*           printf("Packet  %i, alignment %i\n", i, m); */
/*         } */
      }
    }
    printf("\n");
    printf("Non-verified write test passed\n");
    printf("\nVerified writes\n");
    for(i = 0; i < 64; i++) {
      printf(".");
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
        cmd->destaddr = 0x2;
        cmd->destkey  = 0xBF;
        cmd->srcaddr  = 0x1;
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
        reply->destaddr = 0x2;
        reply->destkey  = 0XBF;
        reply->srcaddr  = 0x1;
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
        while (spw_rx(0, rx1, spw1)) {
          for (k = 0; k < 64; k++) {}
        }
        if (spw_tx(0, 1, 1, 0, *cmdsize, tx0, j, tx1, spw1)) {
          printf("Transmission failed\n");
          exit(1);
        }
        while (!(tmp = spw_checktx(0, spw1))) {
          for (k = 0; k < 64; k++) {}
        }
        if (tmp != 1) {
          printf("Error in transmit \n");
          exit(1);
        }
        iterations = 0;
        while (!(tmp = spw_checkrx(0, size, rxs, spw1))) {
          if (iterations > 1000) {
            printf("ERROR: Time limit exceeded while waiting for RMAP reply\n");
            exit(0);
          }
          for (k = 0; k < 64; k++) {}
          /* printf("0x%x\n", spw2->regs->status);*/
          iterations++;
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
        /* if (((i % 4) == 0) && ((m % 8) == 0)) { */
/*           printf("Packet  %i, alignment %i\n", i, m); */
/*         } */
      }
    }
    printf("\n");
    printf("Verified write test passed\n");
    printf("\nRMW\n");
    for(i = 0; i < 64; i++) {
      printf(".");      
      for(m = 0; m < 8; m++) {
        for(j = 0; j < i; j++) {
          tx1[j]  = ~tx1[j];
        }
        if (m >= 4) {
          cmd->incr     = no;
        } else {
          cmd->incr     = yes;
        }
        cmd->type     = rmwcmd;
        cmd->verify   = yes;
        cmd->ack      = yes;
        cmd->destaddr = 0x2;
        cmd->destkey  = 0xBF;
        cmd->srcaddr  = 0x1;
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
        reply->type     = rmwrep;
        reply->verify   = yes;
        reply->ack      = yes;
        if (m >= 4) {
          reply->incr     = no;
                                        
        } else {
          reply->incr     = yes;
        }
        if ( (((((int)&(rx0[(m%4)])) % 2) != 0) && ((cmd->len/2) == 2)) ||
             (((((int)&(rx0[(m%4)])) % 4) != 0) && ((cmd->len/2) == 4)) ||
             ((cmd->len/2) == 3) ) {
          reply->status   = 10;
        } else {
          reply->status   = 0;
        }
        if ( (cmd->len != 0) && (cmd->len != 2) && (cmd->len != 4) &&
             (cmd->len != 6) && (cmd->len != 8)) {
          reply->status = 11;
        }
        if (m >= 4) {
          reply->status = 2;
        }
        if (reply->status == 0) {
          for(k = 0; k < (i/2); k++) {
            rx2[*replysize+1+k] = loadb((int)&(rx0[k+m]));
          }
        }
        reply->destaddr = 0x2;
        reply->destkey  = 0xBF;
        reply->srcaddr  = 0x1;
        reply->tid      = i;
        reply->addr     = (int)&(rx0[(m%4)]);
        if (reply->status == 0) {
          reply->len      = (i/2);
        } else {
          reply->len      = 0;
        }
        reply->dstspalen = 0;
        reply->dstspa  = (char *)NULL;
        reply->srcspalen = 0;
        reply->srcspa = (char *)NULL;
        if (build_rmap_hdr(reply, rx2, replysize)) {
          printf("RMAP reply build failed\n");
          exit(1);
        }
        while (spw_rx(0, rx1, spw1)) {
          for (k = 0; k < 64; k++) {}
        }
        if (spw_tx(0, 1, 1, 0, *cmdsize, tx0, j, tx1, spw1)) {
          printf("Transmission failed\n");
          exit(1);
        }
        while (!(tmp = spw_checktx(0, spw1))) {
          for (k = 0; k < 64; k++) {}
        }
        if (tmp != 1) {
          printf("Error in transmit \n");
          exit(1);
        }
        iterations = 0;
        while (!(tmp = spw_checkrx(0, size, rxs, spw1))) {      
          if (iterations > 1000) {
            printf("ERROR: Time limit exceeded while waiting for RMAP reply\n");
            exit(0);
          }
          for (k = 0; k < 64; k++) {}
          /* printf("0x%x\n", spw2->regs->status);*/
          iterations++;
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
        if ((reply->status == 0) && (i != 0)) {
          if (*size != (*replysize+1+(i/2)+1)) {
            printf("Received packet has wrong length\n");
            printf("Expected: %i, Got: %i \n", *replysize+2+(i/2), *size);
            exit(1);
          }
        } else {
          if (*size != (*replysize+2)) {
            printf("Received packet has wrong length\n");
            printf("Expected: %i, Got: %i \n", *replysize+1, *size);
            exit(1);
          }
        }
        for(k = 0; k < *replysize; k++) {
          if (loadb((int)&(rx1[k])) != rx2[k]) {
            printf("Compare error 0: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx1[k])), (unsigned)rx2[k]);
            exit(1);
          }
        }
        if (reply->status == 0) {
          for(k = *replysize+1; k < *replysize+1+(i/2); k++) {
            if (loadb((int)&(rx1[k])) != rx2[k]) {
              printf("Compare error 1: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx1[k])), (unsigned)rx2[k]);
              exit(1);
            }
          }
          for(k = 0; k < (i/2); k++) {
            if (loadb((int)&(rx0[k+(m%4)])) != ((tx1[k] & tx1[k+(i/2)]) | (rx2[*replysize+1+k] & ~tx1[k+(i/2)]) )) {
              printf("Compare error 2: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx0[k+(m%4)])), (unsigned)tx1[k]);
              exit(1);
            }
          }
                                        
        }
        /* if (((i % 4) == 0) && ((m % 8) == 0)) { */
/*           printf("Packet  %i, alignment %i\n", i, m); */
/*         } */
      }
    }
    printf("\n");
    printf("RMW test passed\n");
    printf("\nReads\n");
    for(i = 0; i < RMAPSIZE; i++) {
      printf(".");      
      for(m = 0; m < 8; m++) {
        for(j = 0; j < i+4; j++) {
          rx0[j]  = ~rx0[j];
        }
        if (m >= 4) {
          cmd->incr     = no;
        } else {
          cmd->incr     = yes;
        }
        cmd->type     = readcmd;
        cmd->verify   = no;
        cmd->ack      = yes;
        cmd->destaddr = 0x2;
        cmd->destkey  = 0xBF;
        cmd->srcaddr  = 0x1;
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
        reply->type     = readrep;
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
        if (reply->status == 0) {
          reply->len      = i;
        } else {
          reply->len      = 0;
        }
        reply->destaddr = 0x2;
        reply->destkey  = 0xBF;
        reply->srcaddr  = 0x1;
        reply->tid      = i;
        reply->addr     = (int)&(rx0[(m%4)]);
        reply->dstspalen = 0;
        reply->dstspa  = (char *)NULL;
        reply->srcspalen = 0;
        reply->srcspa = (char *)NULL;
        if (build_rmap_hdr(reply, rx2, replysize)) {
          printf("RMAP reply build failed\n");
          exit(1);
        }
        while (spw_rx(0, rx1, spw1)) {
          for (k = 0; k < 64; k++) {}
        }
        if (spw_tx(0, 1, 0, 0, *cmdsize, tx0, 0, tx1, spw1)) {
          printf("Transmission failed\n");
          exit(1);
        }
        while (!(tmp = spw_checktx(0, spw1))) {
          for (k = 0; k < 64; k++) {}
        }
        if (tmp != 1) {
          printf("Error in transmit \n");
          exit(1);
        }
        iterations = 0;
        while (!(tmp = spw_checkrx(0, size, rxs, spw1))) {
          if (iterations > 1000) {
            printf("ERROR: Time limit exceeded while waiting for RMAP reply\n");
            exit(0);
          }
          for (k = 0; k < 64; k++) {}
          /* printf("0x%x\n", spw2->regs->status);*/
          iterations++;      
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
        for (k = 0; k < *replysize; k++) {
          if (loadb((int)&(rx1[k])) != rx2[k]) {
            printf("Compare error 0: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx1[k])), (unsigned)rx2[k]);
            exit(1);
          }
        }
        if ((reply->status) == 0 && (i != 0)) {
          if (*size != (*replysize+2+i)) {
            printf("Received packet has wrong length\n");
            printf("Expected: %i, Got: %i \n", *replysize+2+i, *size);
          }
          if (cmd->incr == yes) {
            for(k = 0; k < i; k++) {
              if (loadb((int)&(rx1[*replysize+1+k])) != rx0[k+(m%4)]) {
                printf("Compare error 1: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx1[*replysize+1+k])), (unsigned)rx0[k+(m%4)]);
                exit(1);
              }
            }
          } else {
            for(k = 0; k < i; k++) {
              if (loadb((int)&(rx1[*replysize+1+k])) != rx0[(k%4)+(m%4)]) {
                printf("Compare error 2: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx1[*replysize+1+k])), (unsigned)rx0[(k%4)+(m%4)]);
                printf("Rx1: %x, Rx0: %x\n", (int)rx1, (int)rx0);
                //exit(1);
              }
            }
          }
        } else {
          if (*size != (*replysize+2)) {
            printf("Received packet has wrong length\n");
            printf("Expected: %i, Got: %i \n", *replysize+2, *size);
          }
        }
        /* if ((i % 512) == 0) { */
/*           printf("Packet  %i, alignment %i\n", i, m); */
/*         } */
      }
    }
    printf("\n");
    printf("Read test passed\n");
    /*late and early eop tests*/
    printf("\nLate and early eop\n");
    for(i = 0; i < RMAPSIZE; i++) {
      printf(".");      
      if (i < 16) {
        tmp = -i;
      } else {
        tmp = -16;
      }
      for (j = tmp; j < i; j++) {
        for (m = 0; m < 3; m++) {
/*           printf("Packet  %i, type %i, offset: %i\n", i, m, j); */
          for(k = 0; k < i; k++) {
            tx1[k]  = ~tx1[k];
          }
          if (m == 0) {
            cmd->type     = writecmd;
            cmd->verify   = no;
            reply->type   = writerep;
            reply->verify = no;
          } else if (m == 2) {
            cmd->type     = rmwcmd;
            cmd->verify   = yes;
            reply->type    = rmwrep;
            reply->verify = yes;
          } else {
            cmd->type     = writecmd;
            cmd->verify   = yes;
            reply->type    = writerep;
            reply->verify = yes;
          }
          cmd->incr     = yes;
          cmd->ack      = yes;
          cmd->destaddr = 0x2;
          cmd->destkey  = 0xBF;
          cmd->srcaddr  = 0x1;
          cmd->tid      = i;
          cmd->addr     = (int)rx0;
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
          reply->len       = 0;
          if (j < 0 ) {
            reply->status = 5;
          } else if (j == 0) {
            reply->status = 0;
                                                
          } else {
            reply->status = 6;
            for(l = 0; l < i; l++) {
              if ((int)tx1[l] != 0) {
                reply->status = 4;
              }
            }
          }
          if(m == 2 ) {
            if((cmd->len != 0) && (cmd->len != 2) && (cmd->len != 4) &&
               (cmd->len != 6) && (cmd->len != 8)) {
              reply->status = 11;
            } else if( (((cmd->len/2) == 2) && (cmd->addr % 2 != 0)) ||
                       (((cmd->len/2) == 4) && (cmd->addr % 4 != 0)) ||
                       ((cmd->len/2) == 3) ) {
              reply->status = 10;
            } else {
              if (reply->status != 0) {
                reply->len = 0;
              } else {
                reply->len = cmd->len/2;
              }
            }
          } else if (m != 0) {
            if(cmd->len > 4) {
              reply->status = 9;
            } else if( (((cmd->len) == 2) && (cmd->addr % 2 != 0)) ||
                       (((cmd->len) == 4) && (cmd->addr % 4 != 0)) ||
                       ((cmd->len) == 3) ) {
              reply->status = 10;
            }
          }
          reply->incr      = yes;
          reply->ack       = yes;
          reply->destaddr  = 0x2;
          reply->destkey   = 0xBF;
          reply->srcaddr   = 0x1;
          reply->tid       = i;
          reply->addr      = (int)rx0;
          reply->dstspalen = 0;
          reply->dstspa    = (char *) NULL;
          reply->srcspalen = 0;
          reply->srcspa    = (char *) NULL;
          if (build_rmap_hdr(reply, rx2, replysize)) {
            printf("RMAP reply build failed\n");
            exit(1);
          }
          if ((reply->status == 0) || (reply->status == 6)) {
            for(k = 0; k < reply->len; k++) {
              rx2[*replysize+1+k] = loadb((int)&(rx0[k]));
            }
          }
          while (spw_rx(0, rx1, spw1)) {
            for (k = 0; k < 64; k++) {}
          }
          if (spw_tx(0, 1, 1, 0, *cmdsize, tx0, i+j, tx1, spw1)) {
            printf("Transmission failed\n");
            exit(1);
          }
          while (!(tmp = spw_checktx(0, spw1))) {
            for (k = 0; k < 64; k++) {}
          }
          if (tmp != 1) {
            printf("Error in transmit \n");
            exit(1);
          }
          iterations = 0;
          while (!(tmp = spw_checkrx(0, size, rxs, spw1))) {
            if (iterations > 1000) {
              printf("ERROR: Time limit exceeded while waiting for RMAP reply\n");
              exit(0);
            }
            for (k = 0; k < 64; k++) {}
            /* printf("0x%x\n", spw2->regs->status);*/
            iterations++;            
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
          if (m == 2) {
            if ((i != 0) && ((reply->status == 0) || (reply->status == 6))) {
              tmp = reply->len+1;
            } else {
              tmp = 1;
            }
          } else {
            tmp = 0;
          }
          if (*size != (*replysize+1+tmp)) {
            printf("Received packet has wrong length\n");
            printf("Expected: %i, Got: %i \n", *replysize+1+tmp, *size);
            exit(1);
          }
          if (tmp == 0) {
            tmp++;
          }
          for(k = 0; k < *replysize; k++) {
            if (loadb((int)&(rx1[k])) != rx2[k]) {
              if (k != 3) {
                printf("Compare error 0: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx1[k])), (unsigned)rx2[k]);
                printf("Packet  %i, type %i, offset: %i\n", i, m, j);
                exit(1);
              }
            }
          }
          if ((reply->status == 0) || (reply->status == 6)) {
            if (m == 2) {
              for(k = 0; k < reply->len; k++) {
                if (loadb((int)&(rx1[k+*replysize+1])) != rx2[k+*replysize+1]) {
                  printf("Compare error 2: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx1[k+*replysize+1])), (unsigned)rx2[k+*replysize+1]);
                  printf("Rx0: %x, Rx1: %x, Rx2: %x\n", (int)rx0, (int)rx1, (int)rx2);
                  exit(1);
                }
              }
              for(k = 0; k < (reply->len/2); k++) {
                if (loadb((int)&(rx0[k])) != ((tx1[k] & tx1[k+(i/2)]) | (rx2[*replysize+1+k] & ~tx1[k+(i/2)]) )) {
                  printf("Compare error 3: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx0[k])), (unsigned)tx1[k]);
                  exit(1);
                }
              }
            } else {
              for (k = 0; k < i; k++) {
                if (loadb((int)&(rx0[k])) != tx1[k]) {
                  printf("Compare error 1: %u Data: %x Expected: %x \n", k, (unsigned)loadb((int)&(rx0[k])), (unsigned)tx1[k]);
                  exit(1);
                }
              }
            }
          }
        }
      }
                        
    }
    printf("\n");
    printf("TEST 10: completed successfully\n\n");
  }
#endif
/*   /\************************ TEST 11 **************************************\/ */
#if TEST11 == 1
  printf("TEST 11: DMA channel RMAP CRC test\n\n");
  if ((spw2->rmapcrc == 1) && (spw2->rmap == 0)) {
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
            l = 1;
            break;
          case 1:
            cmd->type     = readcmd;
            cmd->verify   = no;
            j = 0;
            l = 0;
            break;
          case 2:
            cmd->type     = rmwcmd;
            j           = (i % 8);
            cmd->verify   = yes;
            l = 1;
            break;
          case 3:
            cmd->type     = writerep;
            j           = 0;
            cmd->verify   = no;
            l = 0;
            break;
          case 4:
            cmd->type     = readrep;
            cmd->verify   = no;
            j           = i;
            l = 1;
            break;
          case 5:
            cmd->type     = rmwrep;
            j           = (i/2);
            cmd->verify   = yes;
            l = 1; 
            break;
          default:
            break;
        }
        
        if (m < 3) {
            cmd->destaddr = 0x2;
            cmd->srcaddr  = 0x1;
        }
        else {  
            cmd->destaddr = 0x1;
            cmd->srcaddr  = 0x2;
        }

        cmd->incr     = no;
        cmd->ack      = yes;
        cmd->destkey  = 0xBF;
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

        while (spw_rx(0, rx1, spw2)) {
          for (k = 0; k < 64; k++) {}
        }
        if (spw_tx(0, 1, l, 0, *cmdsize, tx0, j, tx1, spw1)) {
          printf("Transmission failed\n");
          exit(1);
        }
        while (!(tmp = spw_checktx(0, spw1))) {
          for (k = 0; k < 64; k++) {}
        }

        if (tmp != 1) {
          printf("Error in transmit \n");
          exit(1);
        }

        while (!(tmp = spw_checkrx(0, size, rxs, spw2))) {
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
  printf("TEST 11: completed successfully\n\n");
#endif
/*   /\************************ TEST 12 **************************************\/ */
#if TEST12 == 1
  printf("TEST 12 Multiple DMA channel test\n\n");
  if ((spw1->ver == 1) && (spw2->ver == 1)) {
          printf("Check address mask with one channel enabled using default addressing\n");
          rx0 = malloc(256);
          rx1 = malloc(256);
          rx2 = malloc(256);
          for(l = 0; l < spw2->dmachan; l++) {
                  rx[l] = malloc(256);
          }
          tx0 = malloc(128);
          tx1 = malloc(128);
          if (spw2->rmap) {
                  spw_rmapen(spw2);
          }
          for(i = 1; i < 128; i++) {
                  tx0[i] = (i % 256);
          }
          printf("Dmachan: %d\n", spw2->dmachan);
          for(i = 0; i < 1048576; i++) {
                  if ((i % 1000) == 0) {
                          printf(".");
                  }
                  for(l = 0; l < spw2->dmachan; l++) {
                          chanen[l] = (rand() % 2);
                          if (chanen[l]) {
                                  spw_enablerx(l, spw2);
                                  spw_rx(l, rx[l], spw2);
                          } else {
                                  spw_disablerx(l, spw2);
                          }
                          sepaddr[l] = (rand() % 2);
                          if (sepaddr[l]) {
                                  spw_setsepaddr(l, spw2);
                          } else {
                                  spw_disablesepaddr(l, spw2);
                          }
                          spw2->dma[l].addr = (rand() % 256);
                          spw2->dma[l].mask = (rand() % 256);
                          spw_set_chanadr(l, spw2);
                  }
                  spw2->nodeaddr = (rand() % 256);
                  spw2->mask = (rand() % 256);
                  spw_set_nodeadr(spw2);
                  if (spw2->rmap) {
                  /*         printf("Rmap\n"); */
                          rmappkt = (rand() % 2);
                  } else {
                          rmappkt = 0;
                  }
                  rmapincr = (rand() % 2);
                  destaddr = (rand() % 256);
                  tx0[0] = (char)destaddr;
                  tx0[1] = (char)0x5;
                  for(l = 2; l < 128; l++) {
                          tx0[l] = ~((tx0[l] + i) % 256);
                  }
             /*      printf("Destaddr: %x\n", destaddr); */
/*                   printf("DefAddr: %x, DefMask: %x, EffAddr: %x, EffDestAddr: %x\n", spw2->nodeaddr, spw2->mask, spw2->nodeaddr & ~spw2->mask, destaddr & ~spw2->mask); */
/*                   for(l = 0; l < spw2->dmachan; l++) { */
/*                           printf("Addr: %x, Mask: %x, EffAddr: %x, EffDestAddr: %x\n", spw2->dma[l].addr, spw2->dma[l].mask, spw2->dma[l].addr & ~spw2->dma[l].mask, destaddr & ~spw2->dma[l].mask); */
/*                   } */
                  rmaprx = 0;
                  if (rmappkt) {
                          if (rmapincr) {
                                  cmd->incr     = no;
                          } else {
                                  cmd->incr     = yes;
                          }
                          cmd->type     = writecmd;
                          cmd->verify   = no;
                          cmd->ack      = yes;
                          cmd->destaddr = destaddr;
                          cmd->destkey  = 0xBF;
                          cmd->srcaddr  = 0x1;
                          cmd->tid      = (i % 65536);
                          cmd->addr     = (int)&(rx1[0]);
                          cmd->len      = 128;
                          cmd->status   = 0;
                          cmd->dstspalen = 0;
                          cmd->dstspa  = (char *)NULL;
                          cmd->srcspalen = 0;
                          cmd->srcspa = (char *)NULL;
                          if ((ret = build_rmap_hdr(cmd, tx1, cmdsize))) {
                                  printf("RMAP cmd build failed: %d\n", ret);
                                  exit(1);
                          }
                          reply->type     = writerep;
                          reply->verify   = no;
                          reply->ack      = yes;
                          if (rmapincr) {
                                  reply->incr     = no;
                          } else {
                                  reply->incr     = yes;
                          }
                          reply->destaddr = destaddr;
                          reply->destkey  = 0xBF;
                          reply->srcaddr  = 0x1;
                          reply->tid      = (i % 65536);
                          reply->addr     = (int)&(rx1[0]);
                          reply->len      = 0;
                          reply->dstspalen = 0;
                          reply->dstspa  = (char *)NULL;
                          reply->srcspalen = 0;
                          reply->srcspa = (char *)NULL;
                          if ((destaddr & ~spw2->mask) == (spw2->nodeaddr & ~spw2->mask)) {
                                  reply->status = 0; rmaprx = 1;
                          } else {
                                  reply->status = 12;
                                  reply->destaddr = spw2->nodeaddr;
                          }
                          if ((ret = build_rmap_hdr(reply, rx2, replysize))) {
                                  printf("RMAP reply build failed: %d\n", ret);
                                  exit(1);
                          }
                          
                  }
                  found = 0;
                  for (l = 0; l < spw2->dmachan; l++) {
                          /* printf("Chan: %d En: %d Sep: %d\n", l, chanen[l], sepaddr[l]); */
                          if (chanen[l]) {
                                  if (((spw2->dma[l].addr & ~spw2->dma[l].mask) == (destaddr & ~spw2->dma[l].mask)) && sepaddr[l]) {
                                          if (!(rmaprx) && !(found)) {
                                                  startrx[l] = 0; rxchan = l;
                                                  found = 1;
                                          }
                                  } else if (((spw2->nodeaddr & ~spw2->mask) == (destaddr & ~spw2->mask)) && !(sepaddr[l]) && !(rmappkt)) {
                                          if (!(found)) {
                                                  startrx[l] = 0; rxchan = l;
                                                  found = 1;
                                          }
                                  }
                          }
                  }
                  length = (rand() % 128);
                  if (length < 3) {
                          length = 3;
                  }
                  if (!(found) && rmappkt) {
                          rmaprx = 1;
                  } else if (!found) {
                          rxchan = -1;
                  }
                  if (rmappkt && rmaprx) {
                          spw_rx(0, rx1, spw1);
                  }
                  if (rmappkt) {
                          /* printf("Rmap\n"); */
                          spw_tx(0, 1, 1, 0, *cmdsize, tx1, 128, tx0, spw1);
                  } else {
                          /* printf("Len: %d\n", length); */
                          spw_tx(0, 0, 0, 0, 0, tx0, length, tx0, spw1);
                  }
                  /* printf("Addr: %x, Rxchan: %d, sepaddr: %d, DefAddr: %x, DefMask: %x, RxAddr: %x, RxMask: %x, Rmap: %d\n", tx0[0], rxchan, sepaddr[rxchan], spw2->nodeaddr, spw2->mask, spw2->dma[rxchan].addr, spw2->dma[rxchan].mask, rmappkt); */
/*                   printf("Here\n"); */
                  
                  while(!(tmp = spw_checktx(0, spw1))) {
                          for(l = 0; l < 64; l++) {}
                  }
                  if (tmp != 1) {
                          printf("Transmit error link 1\n");
                          exit(1);
                  }
                  /* if (i == 78) { */
/*                           printf("Here2\n"); */
/*                   } */
                  if (!(rmaprx) && found) {
                          if (rmappkt) {
                                  length = 128+*cmdsize+2;
                          }
                          /* printf("Here3\n"); */
                          while(!(tmp = spw_checkrx(rxchan, size, rxs, spw2))) {
                                  for(l = 0; l < 64; l++) {}
                          }
                          /* printf("Received link %d\n", rxchan); */
/*                           printf("Here4\n");  */
                          if (rxs->truncated) {
                                  printf("Received packet truncated link 2\n");
                                  exit(1);
                          }
                          if(rxs->eep) {
                                  printf("Received packet terminated with eep link 2\n");
                                  exit(1);
                          }
                          if (*size != length) {
                                  printf("Received packet has wrong length link 2. Expected: %d, Got: %d\n", length, *size);
                                  exit(1);
                          }
                          /* if (i == 1) { */
/*                                   for(l = 0; l < length; l++) { */
/*                                           printf("Tx0: %x, Rx0: %x\n", tx0[l], loadb((int)&(rx[rxchan][l]))); */
/*                                   } */
/*                           } */
                          if (rmappkt) {
                                  for(l = 0; l < *cmdsize; l++) {
                                          if (loadb((int)&(rx[rxchan][l])) != tx1[l]) {
                                                  printf("Compare error buf 0: %u Data: %x Expected: %x \n", l, (unsigned)loadb((int)&(rx[rxchan][l])), (unsigned)tx1[l]);
                                                  exit(1);
                                          }
                                  }
                                  for(l = 0; l < 128; l++) {
                                          if (loadb((int)&(rx[rxchan][l+*cmdsize+1])) != tx0[l]) {
                                                  printf("Compare error buf 0: %u Data: %x Expected: %x \n", l, (unsigned)loadb((int)&(rx[rxchan][l+*cmdsize+1])), (unsigned)tx0[l]);
                                                  exit(1);
                                          }
                                  }
                          } else {
                                  for(l = 0; l < length; l++) {
                                          if (loadb((int)&(rx[rxchan][l])) != tx0[l]) {
                                                  printf("Compare error buf 0: %u Data: %x Expected: %x \n", l, (unsigned)loadb((int)&(rx[rxchan][l])), (unsigned)tx0[l]);
                                                  exit(1);
                                          }
                                  }
                          }
                  } else if (rmaprx) {
                          /* printf("Here5\n"); */
                          while(!(tmp = spw_checkrx(0, size, rxs, spw1))) {
                                  for(l = 0; l < 64; l++) {}
                          }
                          /* printf("Here6\n"); */
                          if (rxs->truncated) {
                                  printf("Received packet truncated link 2\n");
                                  exit(1);
                          }
                          if(rxs->eep) {
                                  printf("Received packet terminated with eep link 2\n");
                                  exit(1);
                          }
                          if (*size != (*replysize+1)) {
                                  printf("Received packet has wrong length link 2\n");
                                  exit(1);
                          }
                          for(l = 0; l < *replysize; l++) {
                                  if (loadb((int)&(rx1[l])) != rx2[l]) {
                                          printf("Compare error buf 0: %u Data: %x Expected: %x \n", l, (unsigned)loadb((int)&(rx1[l])), (unsigned)rx2[l]);
                                          exit(1);
                                  }
                          }
                  }
                  /* send dummy packets to disable all channels*/
                  for (l = 0; l < spw2->dmachan; l++) {
                          if (chanen[l] && (l != rxchan)) {
                                  if (sepaddr[l]) {
                                          tx0[0] = spw2->dma[l].addr;
/*                                           printf("Addr: %x\n", tx0[0]); */
                                  } else {
                                          tx0[0] = spw2->nodeaddr;
/*                                           printf("Addr: %x\n", tx0[0]); */
                                  }
                                  spw_tx(0, 0, 0, 0, 0, tx0, 128, tx0, spw1);
                                  while(!(tmp = spw_checkrx(l, size, rxs, spw2))) {
                                          for(k = 0; k < 64; k++) {}
                                  }
                          }
                          spw_disablerx(l, spw2);
                  }
                  
          }
          free(rx0);
          free(rx1);
          free(rx2);
          free(tx0);
          for(l = 0; l < spw2->dmachan; l++) {
                  free(rx[l]);
          }
          
  }
  printf("\nTEST 12: completed successfully\n\n");
#endif
  printf("*********** Test suite completed successfully ************\n");
  exit(0);
        
}
