/*****************************************************************************/
/*   This file is a part of the GRLIB VHDL IP LIBRARY */
/*   Copyright (C) 2004 GAISLER RESEARCH */

/*   This program is free software; you can redistribute it and/or modify */
/*   it under the terms of the GNU General Public License as published by */
/*   the Free Software Foundation; either version 2 of the License, or */
/*   (at your option) any later version. */

/*   See the file COPYING for the full details of the license. */
/*****************************************************************************/

struct dmachanregs 
{
   volatile int ctrl;
   volatile int rxmaxlen;
   volatile int txdesc;
   volatile int rxdesc;
   volatile int addr;
   volatile int unused[3];
};

struct spwregs 
{
   volatile int ctrl;
   volatile int status;
   volatile int nodeaddr;
   volatile int clkdiv;
   volatile int destkey;
   volatile int timereg;
   volatile int timer;
   volatile int unused;
   struct dmachanregs dma[4];
};

struct txdescriptor 
{
   volatile int ctrl;
   volatile int haddr;
   volatile int dlen;
   volatile int daddr;
};

struct rxstatus 
{
   int truncated;
   int dcrcerr;
   int hcrcerr;
   int eep;
};

struct rxdescriptor 
{
   volatile int ctrl;
   volatile int daddr;
};

struct dmachanvar
{
  int    nospill;
  int    rxmaxlen;
  int    rxpnt;
  int    rxchkpnt;
  int    txpnt;
  int    txchkpnt;
  int    addr;
  int    mask;
  struct txdescriptor *txd;
  struct rxdescriptor *rxd;  
};

struct spwvars
{
   struct spwregs *regs;
   int    rmap;
   int    rxunaligned;
   int    rmapcrc;
   int    timetxen;
   int    timerxen;
   int    ver;
   int    khz;
   int    dmachan;
   int    clkdiv;
   int    clkdivs;
   int    timer;
   int    dc;
   int    nodeaddr;
   int    mask;
   int    destkey;
   struct dmachanvar dma[4];
};

int spw_init(struct spwvars *spw);

int wait_running(struct spwvars *spw);

/*sets node specific parameters in the spwvars structure */
int spw_setparam(int nodeaddr, int clkdiv, int destkey,
                 int timetxen, int timerxen, int spwadr, 
                 int khz, struct spwvars *spw);

int spw_setparam_dma(int dmachan, int addr, int mask, int nospill, int rxmaxlen, struct spwvars *spw);

/*set new transmit descriptor pointer*/
int set_txdesc(int dmachan, int pnt, struct spwvars *spw);

/*set new receive descriptor pointer*/
int set_rxdesc(int dmachan, int pnt, struct spwvars *spw);

/*disable spacewire link*/
void spw_disable(struct spwvars *spw);

/*enable spacewire link*/
void spw_enable(struct spwvars *spw);

/*start spacewire link*/
void spw_start(struct spwvars *spw);

/*stop spacewire link*/
void spw_stop(struct spwvars *spw);

/*set clock divisor value. returns 1 if the clockdiv parameter is illegal,
0 when operation completes successfully*/
int spw_setclockdiv(struct spwvars *spw);

/*set node address, returns 1 if the nodeaddr parameter is illegal,
0 when operation completes successfully*/
int spw_set_nodeadr(struct spwvars *spw);

int spw_set_chanadr(int dmachan, struct spwvars *spw);


/*set maximum receive packet length, returns 1 if the nodeaddr parameter is illegal,
0 when operation completes successfully*/
int spw_set_rxmaxlength(int dmachan, struct spwvars *spw);

/*Transmits hsize bytes from hbuf and dsize bytes from dbuf.returns 0 on success. 
/*1 if there are no free buffers. 2 if there was an illegal parameter value.*/
int spw_tx(int dmachan, int hcrc, int dcrc, int skipcrcsize, int hsize, char *hbuf, int dsize, char *dbuf, struct spwvars *spw);

/*Receives one packet to buf. This function only initializes a descriptor, spw_checkrx should
be used to poll when a packet has arrived*/
int spw_rx(int dmachan, char *buf, struct spwvars *spw);

/*Polls receiver descriptor. Returns 0 if no packet has been received,
1 if packet has been received. Then size contains the number of 
bytes received. rxs contains som status bits such as crc errors, 
eep termination etc*/
int spw_checkrx(int dmachan, int *size, struct rxstatus *rxs, struct spwvars *spw);

/*Polls transmitter descriptor, returns 0 if packet has not been transmitted,
  1 if packet was correctly transmitted and 2 if an error occured*/
int spw_checktx(int dmachan, struct spwvars *spw);

/*Send time-codee*/
void send_time(struct spwvars *spw);

/*Check if time-code has been received*/
int check_time(struct spwvars *spw);

/*Get the current time-code value*/
int get_time(struct spwvars *spw);

/*Reset GRSPW*/
void spw_reset(struct spwvars *spw);

/*Enable hardware RMAP*/
void spw_rmapen(struct spwvars *spw);

/*Disable hardware RMAP*/
void spw_rmapdis(struct spwvars *spw);

int spw_setdestkey(struct spwvars *spw);

void spw_setsepaddr(int dmachan, struct spwvars *spw);

void spw_disablesepaddr(int dmachan, struct spwvars *spw);

void spw_enablerx(int dmachan, struct spwvars *spw);

void spw_disablerx(int dmachan, struct spwvars *spw);












        


