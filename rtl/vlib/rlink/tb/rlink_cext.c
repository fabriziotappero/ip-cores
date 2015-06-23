/* $Id: rlink_cext.c 602 2014-11-08 21:42:47Z mueller $
 *
 * Copyright 2007-2014 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
 *
 * This program is free software; you may redistribute and/or modify it under
 * the terms of the GNU General Public License as published by the Free
 * Software Foundation, either version 2, or at your option any later version.
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY, without even the implied warranty of MERCHANTABILITY
 * or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License
 * for complete details.
 *
 *  Revision History: 
 * Date         Rev  Vers    Comment
 * 2014-11-02   602   2.0    sideband handling for rlink v4; count EAGAINs
 * 2014-07-27   575   1.3.2  add ssize_t -> int casts to avoid warnings
 *                           add fflush(stdout) after standart open/close msgs
 * 2011-03-05   366   1.3.1  add RLINK_CEXT_TRACE=2 trace level
 * 2010-12-29   351   1.3    rename cext_rriext -> rlink_cext; rename functions
 *                           cext_* -> rlink_cext_* and fifo file names
 *                           tb_cext_* -> rlink_cext_*
 * 2007-11-18    96   1.2    add 'read before write' logic to avoid deadlocks
 *                           under cygwin broken fifo (size=1 !) implementation
 * 2007-10-19    90   1.1    add trace option, controlled by setting an
 *                           the environment variable CEXT_RRIEXT_TRACE=1
 * 2007-09-23    84   1.0    Initial version 
 */ 

#include <unistd.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <stdio.h>
#include <sched.h>
#include <stdlib.h>
#include <string.h>

/* kSymEsc = 0xCA = 1100 1010 (bin) */
#define CESC  (0xCA)
#define QRBUFSIZE 1024

static int fd_rx = -1;
static int fd_tx = -1;

static int io_trace = 0;

static char qr_buf[QRBUFSIZE];
static int  qr_pr  = 0;
static int  qr_pw  = 0;
static int  qr_nb  = 0;
static int  qr_eof = 0;
static int  qr_err = EAGAIN;

static void rlink_cext_dotrace(const char *text, int dat)
{
  int i;
  int mask = 0x80;
  printf("rlink_cext-I: %s   ", text);
  for (i=0; i<8; i++) {
    printf("%c", (dat&mask)?'1':'0' );
    mask >>= 1;
  }
  printf("\n");
}

static void rlink_cext_doread()
{
  static int  neagain = 0;
  
  char buf[1];
  ssize_t nbyte;
  nbyte = read(fd_rx, buf, 1);
  if (io_trace > 1) {
    if (nbyte < 0 && errno == EAGAIN) {
      neagain += 1;
    } else {
      if (neagain) {
        printf("rlink_cext-I: reads with EAGAIN: %d seen\n", neagain);
        neagain = 0;
      }
      printf("rlink_cext-I: read   rc=%d", (int)nbyte);
      if (nbyte < 0) printf(" errno=%d %s", errno, strerror(errno));
      printf("\n");
    }
  }

  if (nbyte < 0) {
    qr_err = errno;
  } else if (nbyte == 0) {
    qr_err = EAGAIN;
    qr_eof = 1;
  } else {
    qr_err = EAGAIN;
    if (qr_nb < QRBUFSIZE) {
      if (io_trace) rlink_cext_dotrace("rcv8", (unsigned char) buf[0]);
      qr_buf[qr_pw++] = buf[0];
      if (qr_pw >= QRBUFSIZE) qr_pw = 0;
      qr_nb += 1;
    } else {
      printf("Buffer overflow\n"); /* FIXME: better error handling */
    }
  }
}

/* returns:
 *   <0          if error
 *   >=0 <=0xff  normal data
 *   == 0x100    idle
 *   0x01aahhll   if side band message seen
 *
 */

int rlink_cext_getbyte(int clk)
{
  char buf[1];
  ssize_t nbyte;
  int irc;
  int tdat;
  char* env_val;

  static int odat;
  static int nidle = 0;
  static int ncesc = 0;
  static int nside = -1;

  if (fd_rx < 0) {		/* fifo's not yet opened */
    fd_rx = open("rlink_cext_fifo_rx", O_RDONLY|O_NONBLOCK);
    if (fd_rx <= 0) {
      perror("rlink_cext-E: failed to open rlink_cext_fifo_rx");
      return -2;
    }
    printf("rlink_cext-I: connected to rlink_cext_fifo_rx\n");
    fflush(stdout);
    
    fd_tx = open("rlink_cext_fifo_tx", O_WRONLY);
    if (fd_tx <= 0) {
      perror("rlink_cext-E: failed to open rlink_cext_fifo_tx");
      return -2;
    }
    printf("rlink_cext-I: connected to rlink_cext_fifo_tx\n");
    fflush(stdout);

    nidle = 0;
    ncesc = 0;
    nside = -1;

    /* determine trace level from RLINK_CEXT_TRACE: */
    /*  "1"  trace bytes read and written */
    /*  "2"  trace also read() and write() calls */
    io_trace = 0;
    env_val = getenv("RLINK_CEXT_TRACE");
    if (env_val) {
      printf("rlink_cext-I: seen RLINK_CEXT_TRACE=%s\n", env_val);
      if (strcmp(env_val, "0") == 0) {
        printf("rlink_cext-I: set trace level to 0 (off)\n");
      } else if (strcmp(env_val, "1") == 0) {
        printf("rlink_cext-I: set trace level to 1 (bytes)\n");
        io_trace = 1;
      } else if (strcmp(env_val, "2") == 0) {
        printf("rlink_cext-I: set trace level to 2 (bytes + calls)\n");
        io_trace = 2;
      } else {
        printf("rlink_cext-E: invalid RLINK_CEXT_TRACE value; ignored\n");
      }
    }
    
  }

  rlink_cext_doread();

  if (qr_nb == 0) {		            /* no character to be processed */
    if (qr_eof != 0) {		            /* EOF seen */
      if (ncesc >= 2) {			    /*  two+ CESC seen  ? */
	printf("rlink_cext-I: seen EOF, wait for reconnect\n");
        fflush(stdout);
	close(fd_rx);
	close(fd_tx);
	fd_rx = -1;
	fd_tx = -1;
	usleep(500000);			    /* wait 0.5 sec */
	return 0x100;			    /* return idle, will reconnect */
      }
    
      printf("rlink_cext-I: seen EOF, schedule clock stop and exit\n");
      fflush(stdout);
      return -1;			    /* signal EOF seen */

    } else if (qr_err == EAGAIN) {          /* nothing read, return idle */
      if (nidle < 8 || (nidle%1024)==0) {
	irc = sched_yield();
	if (irc < 0) perror("rlink_cext-W: sched_yield failed");
      }
      nidle += 1;
      return 0x100;
    } else {			            /* must be a read error */
      errno = qr_err;
      perror("rlink_cext-E: read error on rlink_cext_fifo_rx");
      return -3;
    }
  }

  nidle = 0;
  tdat = (unsigned char) qr_buf[qr_pr++];
  if (qr_pr >= QRBUFSIZE) qr_pr = 0;
  qr_nb -= 1;
  
  if (tdat == CESC) {
    ncesc += 1;
    if (ncesc == 2) nside = 0;
  } else {
    ncesc = 0;
  }

  switch (nside) {
  case -1:				    /* normal data */
    return tdat;
  case 0:				    /* 2nd CESC, return it */
    nside += 1;
    odat = 0x01000000;                      /* init odat */
    return tdat;

  /* decode oob data as formated by RlinkPacketBufSnd::SndOob() */
  /* odat format:  0x01aadddd */
  case 1:				    /* get ADDR(3:0) */
    nside += 1;
    odat  |= (tdat&0x0f)<<16;
    return 0x100;
  case 2:				    /* get ADDR(7:4) */
    nside += 1;
    odat  |= (tdat&0x0f)<<20;
    return 0x100;
  case 3:				    /* get data( 3: 0) */
    nside += 1;
    odat  |= (tdat&0x0f);
    return 0x100;
  case 4:				    /* get data( 7: 4) */
    nside += 1;
    odat  |= (tdat&0x0f)<<4;
    return 0x100;
  case 5:				    /* get data(11: 8) */
    nside += 1;
    odat  |= (tdat&0x0f)<<8;
    return 0x100;
  case 6:				    /* get data(15:12) */
    nside  = -1;
    odat  |= (tdat&0x0f)<<12;
    return odat;
  }  
}

int rlink_cext_putbyte(int dat) 
{
  char buf[1];
  ssize_t nbyte;

  rlink_cext_doread();

  if (io_trace) rlink_cext_dotrace("snd8", dat);

  buf[0] = (unsigned char) dat;
  nbyte = write(fd_tx, buf, 1);
  if (io_trace > 1) {
    printf("rlink_cext-I: write  rc=%d", (int)nbyte);
    if (nbyte < 0) printf(" errno=%d %s", errno, strerror(errno));
    printf("\n");
  }

  if (nbyte < 0) {
    perror("rlink_cext-E: write error on rlink_cext_fifo_tx");
    return -3;
  }

  return 0;
}
