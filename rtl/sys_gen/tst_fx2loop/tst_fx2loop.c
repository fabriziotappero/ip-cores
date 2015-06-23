/* $Id: tst_fx2loop.c 530 2013-08-09 21:25:04Z mueller $ */
/*
 * Copyright 2011-2013 by Walter F.J. Mueller <W.F.J.Mueller@gsi.de>
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
 *
 * Revision History: 
 * Date         Rev Version  Comment
 * 2013-08-09   530   2.1.2  -read: write up to 9 nstead of 7 words
 * 2012-04-09   461   2.1.1  fix loop back code: fix run-down, add pipe drain
 * 2012-03-24   460   2.1    add message loop back code (preliminary)
 * 2012-03-10   459   2.0    re-write for asynchronous libusb interface
 * 2012-02-12   457   1.1    redo argument handling; add -stat and -rndm
 * 2012-01-15   453   1.0.1  add -tx2blast; fix bug in loop read loop
 * 2011-12-29   446   1.0    Initial version (only -read/write/loop)
*/

#include <stdlib.h>
#include <stdio.h>
#include <unistd.h>
#include <string.h>
#include <limits.h>
#include <signal.h>
#include <poll.h>
#include <errno.h>
#include <sys/timerfd.h>

#include <libusb-1.0/libusb.h>

static int nsigint = 0;
static int endpoll = 0;
static libusb_context*       pUsbContext = 0;
static libusb_device**       pUsbDevList = 0;
static int                   UsbDevCount = 0;
static libusb_device_handle* pUsbDevHdl  = 0;

static struct pollfd pollfd_fds[16];
static int pollfd_nfds = 0;

struct dsc_queue {
  int par_nfrm;
  int par_nque;
  double stat_nbuf;
  double stat_nbyt;
  double stat_npt;
  uint16_t cval;
};

static struct dsc_queue dsc_rx;
static struct dsc_queue dsc_tx1;
static struct dsc_queue dsc_tx2;

static int par_nwmsg  = 0;
static int par_nwrndm = 0;
static int par_stat   = 0;
static int par_trace  = 0;
static int par_nsec   = 0;

static int cur_nwmsg = 0;
static double stat_nmsg = 0.;

static double t_start;
static int nreq = 0;

static char** argv;
static int argc;
static int argi;


void usage(FILE* of);
int get_pint(char* p);
double get_double(char* p);
int get_arg_pint(int min, int max, const char* text);

void do_write(uint16_t* buf, int nw);
void do_read(int ep);
void do_run();
void do_stat();
void usb_claim();
void usb_release();
char* usb_strerror(int rc);
void prt_time(void);
double get_time(void);
void bad_syscall_exit(const char* text, int rc);
void bad_usbcall_exit(const char* text, int rc);
void bad_transfer_exit(struct libusb_transfer *t, const char* text);

void sigint_handler(int signum)
{
  printf("\n");
  nsigint += 1;
  if (nsigint > 3) {
    fprintf(stderr, "tst_fx2loop-F: 3rd ^C, aborting\n");
    exit(EXIT_FAILURE);
  }
  return;
}

int main(int main_argc, char *main_argv[])
{
  argc = main_argc;
  argv = main_argv;
  argi = 1;
  
  int i;

  /* setup ^C handler */
  struct sigaction new_action;

  new_action.sa_handler = sigint_handler;
  sigemptyset (&new_action.sa_mask);
  new_action.sa_flags = 0;
  sigaction (SIGINT, &new_action, NULL);

  /* capture -help case here */
  for (i = 1; i < argc; i++) {
    if (strcmp(argv[i], "-help") == 0) {
      usage(stdout);
      return EXIT_SUCCESS;
    }
  }

  /* determine usb device path (first arg or from RETRO_FX2_VID/PID */
  char devbuf[10];
  char* path = 0;

  if (argc > argi && argv[argi][0] != '-') {
    path = argv[argi];
    argi += 1;
  } else {
    char* env_vid = getenv("RETRO_FX2_VID");
    char* env_pid = getenv("RETRO_FX2_PID");
    if (env_vid && strlen(env_vid) == 4 &&
        env_pid && strlen(env_pid) == 4) {
      strncpy(devbuf  , env_vid,4);
      devbuf[4] = ':';
      strncpy(devbuf+5, env_pid,4);
      devbuf[9] = 0;
      path = devbuf;
    } else {
      fprintf(stderr, 
              "tst_fx2loop-F: RETRO_FX2_VID/PID not or ill defined\n");
      return EXIT_FAILURE;
    }
  }

  /* init libusb, connect to device */
  libusb_init(&pUsbContext);
  libusb_set_debug(pUsbContext, 3);
  UsbDevCount = libusb_get_device_list(pUsbContext, &pUsbDevList);

  libusb_device* mydev = 0;

  if (strlen(path)==8 && path[0]=='/' && path[4]=='/') {
    char busnam[4];
    char devnam[4];
    strncpy(busnam, path+1, 3);    
    strncpy(devnam, path+5, 3);
    busnam[3] = 0;
    devnam[3] = 0;

    char* endptr;
    uint8_t busnum = strtol(busnam, &endptr, 10);
    uint8_t devnum = strtol(devnam, &endptr, 10);

    int idev;
    for (idev=0; idev<UsbDevCount; idev++) {
      libusb_device* udev = pUsbDevList[idev];
      if (libusb_get_bus_number(udev) == busnum &&
          libusb_get_device_address(udev) == devnum) {
        mydev = udev;
      }
    }

  } else if (strlen(path)==9 && path[4]==':') {
    char vennam[5];
    char pronam[5];
    memcpy(vennam, path,   4);    
    memcpy(pronam, path+5, 4);
    vennam[4] = 0;
    pronam[4] = 0;

    char* endptr;
    uint16_t vennum = strtol(vennam, &endptr, 16);
    uint16_t pronum = strtol(pronam, &endptr, 16);

    int idev;
    for (idev=0; idev<UsbDevCount; idev++) {
      libusb_device* udev = pUsbDevList[idev];
      struct libusb_device_descriptor devdsc;
      libusb_get_device_descriptor(udev, &devdsc);
      if (devdsc.idVendor==vennum && devdsc.idProduct==pronum) {
        mydev = udev;
      }
    }

  } else {
    fprintf(stderr, "tst_fx2loop-F: dev not in /bus/dev or vend:prod form\n");
    return EXIT_FAILURE;
  }

  if (mydev == 0) {
    fprintf(stderr, "tst_fx2loop-F: no usb device %s found\n", path);
    return EXIT_FAILURE;    
  }

  int rc;
  rc = libusb_open(mydev, &pUsbDevHdl);
  if (rc) {
    fprintf(stderr, "tst_fx2loop-F: failed to open %s rc=%d: %s\n", 
            path, rc, usb_strerror(rc));
    return EXIT_FAILURE;
  }

  /* check for internal timeout handling support */
  if (libusb_pollfds_handle_timeouts(pUsbContext) == 0) {
    fprintf(stderr, "tst_fx2loop-F: libusb_pollfds_handle_timeouts == 0\n"
                    "   this program will not run on this legacy system\n");
    return EXIT_FAILURE;
  }

  for (; argi < argc; ) {

    /* handle setup options ----------------------------------------------- */
    if (strcmp(argv[argi],"-nbrx") == 0) {
      argi += 1;
      dsc_rx.par_nfrm = get_arg_pint(1, 256, "rx buffer size invalid");      
    } else if (strcmp(argv[argi],"-nqrx") == 0) {
      argi += 1;
      dsc_rx.par_nque = get_arg_pint(1, 8, "rx buffer count invalid");

    } else if (strcmp(argv[argi],"-nbtx") == 0) {
      argi += 1;
      dsc_tx1.par_nfrm = get_arg_pint(1, 256, "tx1 buffer size invalid");
    } else if (strcmp(argv[argi],"-nqtx") == 0) {
      argi += 1;
      dsc_tx1.par_nque = get_arg_pint(1, 8, "tx1 buffer count invalid");

    } else if (strcmp(argv[argi],"-nbtx2") == 0) {
      argi += 1;
      dsc_tx2.par_nfrm = get_arg_pint(1, 256, "tx2 buffer size invalid");
    } else if (strcmp(argv[argi],"-nqtx2") == 0) {
      argi += 1;
      dsc_tx2.par_nque = get_arg_pint(1, 8, "tx2 buffer count invalid");

    } else if (strcmp(argv[argi],"-nwmsg") == 0) {
      argi += 1;
      par_nwmsg = get_arg_pint(1, 4096, "loopback message size invalid");

    } else if (strcmp(argv[argi],"-rndm") == 0) {
      argi += 1;
      par_nwrndm = 1;
    } else if (strcmp(argv[argi],"-stat") == 0) {
      argi += 1;
      par_stat = 1;
    } else if (strcmp(argv[argi],"-trace") == 0) {
      argi += 1;
      par_trace = 1;

    /* handle action options ---------------------------------------------- */
    } else if (strcmp(argv[argi],"-write") == 0) {
      uint16_t buf[4096];
      int  nw = 0;
      argi += 1;
      while(argi < argc && nw < 4096) {
        char *argp = argv[argi];
        if (argp[0] == '-') break;
        char* endptr;
        long val = strtol(argp, &endptr, 0);
        if ((endptr && endptr[0]) || val < 0 || val > 0xffff) {
          nw = 0;
          break;
        }
        argi += 1;
        buf[nw++] = (uint16_t)val;
      }
      if (nw == 0) {
        fprintf(stderr, "tst_fx2loop-E: bad word list\n");
        break;
      }
      do_write(buf, nw);

    } else if (strcmp(argv[argi],"-read") == 0) {
      argi += 1;
      int ep = 6;
      if (argi < argc) ep = get_pint(argv[argi++]);
      if (ep != 6 && ep != 8) {
        fprintf(stderr, "tst_fx2loop-F: bad read endpoint (must be 6 or 8)\n");
        return EXIT_FAILURE;
      }
      do_read(ep);
      
    } else if (strcmp(argv[argi],"-run") == 0) {
      argi += 1;
      if (argi < argc) par_nsec = get_pint(argv[argi++]);
      if (par_nsec < 0) {
        fprintf(stderr, "tst_fx2loop-E: bad args for -run\n");
        break;
      }      
      do_run();
      do_stat();

    } else {
      fprintf(stderr, "tst_fx2loop-F: unknown option %s\n", argv[argi]);
      usage(stderr);
      return EXIT_FAILURE;
    }
  }

  return EXIT_SUCCESS;
}

/*--------------------------------------------------------------------------*/
void usage(FILE* of) 
{
  fprintf(of, "Usage:  tst_fx2loop [dev] [setup-opts...] [action-opts...]\n");
  fprintf(of, "  arguments:\n");
  fprintf(of, "    dev        path usb device, either bus/dev or vend:prod\n");
  fprintf(of, "                 default is $RETRO_FX2_VID:$RETRO_FX2_VID\n");
  fprintf(of, "  setup options:\n");
  fprintf(of, "    -nbrx nb   buffer size (in 512B) for rxblast\n");
  fprintf(of, "    -nqrx nb   number of buffers for rxblast\n");
  fprintf(of, "    -nbtx nb   buffer size (in 512B) for txblast or loop\n");
  fprintf(of, "    -nqtx nb   number of buffers for txblast or loop\n");
  fprintf(of, "    -nbtx2 nb  buffer size (in 512B) for tx2blast\n");
  fprintf(of, "    -nqtx2 nb  number of buffers for tx2blast\n");
  fprintf(of, "    -nwmsg nw  number words for loop test\n");
  fprintf(of, "    -rndm      use random length for loop test\n");
  fprintf(of, "    -stat      print live stats\n");
  fprintf(of, "    -trace     trace usb calls\n");
  fprintf(of, "  action options:\n");
  fprintf(of, "    -write w0 w1 ...  write list of words to endpoint 4\n");
  fprintf(of, "    -read ep   read from endpoint ep\n");
  fprintf(of, "    -run ns    run tests for nw seconds\n");
}

/*--------------------------------------------------------------------------*/

int get_pint(char* p)
{
  char *endptr;
  long num = 0;

  num = strtol(p, &endptr, 0);
  if ((endptr && *endptr) || num < 0 || num > INT_MAX) {
    fprintf(stderr, "tst_fx2loop-E: \"%s\" not a non-negative integer\n", p);
    return -1;
  }
  return num;
}

/*--------------------------------------------------------------------------*/

double get_double(char* p)
{
  char *endptr;
  double num = 0.;

  num = strtod(p, &endptr);
  if ((endptr && *endptr) || num < 0.) {
    fprintf(stderr, "tst_fx2loop-E: \"%s\" not a valid positive float\n", p);
    return -1.;
  }
  return num;
}

/*--------------------------------------------------------------------------*/

int get_arg_pint(int min, int max, const char* text)
{
  int tmp = -1;
  if (argi < argc) tmp = get_pint(argv[argi++]);
  if (tmp < min || tmp > max) {
    fprintf(stderr, "tst_fx2loop-F: %s\n", text);
    exit(EXIT_FAILURE);
  }
  return tmp;
}

/*--------------------------------------------------------------------------*/

void do_write(uint16_t* buf, int nw)
{
  int rc;
  int i;
  int ntrans;
  int tout = 1000;
  int ep = 4;

  usb_claim();
  rc = libusb_bulk_transfer(pUsbDevHdl, ep, 
                            (unsigned char *)buf, nw*2, &ntrans, tout);
  if (rc!=0 || ntrans != nw*2) {
    fprintf(stderr, "tst_fx2loop-E: bulk write failed ntrans=%d rc=%d: %s \n", 
            ntrans, rc, usb_strerror(rc));
  } else {
    prt_time();
    printf("write %4d word:", nw);
    for (i = 0; i < nw; i++) printf(" %4.4x", buf[i]);
    printf("\n");
  }
  usb_release();

  return;
}

/*--------------------------------------------------------------------------*/

void do_read(int ep)
{
  int rc;
  int i;
  int ntrans;
  uint16_t buf[4096];
  int tout = 1000;
  int nloop;

  usb_claim();
  for (nloop=0;;nloop++) {
    rc = libusb_bulk_transfer(pUsbDevHdl, ep|0x80, 
                              (unsigned char *)buf, 2*4096, &ntrans, tout);
    
    if (ntrans==0 && rc) {
      if (rc==LIBUSB_ERROR_TIMEOUT && ntrans==0 && nloop>0) break;
      fprintf(stderr, "tst_fx2loop-E: bulk read failed ntrans=%d rc=%d: %s \n", 
              ntrans, rc, usb_strerror(rc));
      break;
    }
    prt_time();
    printf("read  %4d word:", ntrans/2);
    int nprt = ntrans/2;
    if (nprt > 9) nprt = 9;
    for (i = 0; i < nprt; i++)  printf(" %4.4x", (uint16_t)buf[i]);
    printf("\n");
    if (nsigint>0) break;
  }
  usb_release();
  return;
}

/*----------------------------------------------------------*/
void pollfd_add(int fd, short events, void *user_data)
{
  if (pollfd_nfds >= 16) {
    fprintf(stderr, "tst_fx2loop-F: pollfd list overflow\n");
    exit(EXIT_FAILURE);
  }
  if (par_trace) {
    prt_time();
    printf("pollfd_add: fd=%3d evt=%4.4x\n", fd, events);
  }
  pollfd_fds[pollfd_nfds].fd      = fd;
  pollfd_fds[pollfd_nfds].events  = events;
  pollfd_fds[pollfd_nfds].revents = 0;
  pollfd_nfds += 1;
  return;
}

/*----------------------------------------------------------*/
void pollfd_remove(int fd, void *user_data)
{
  int iw = 0;
  int ir = 0;
  if (par_trace) {
    prt_time();
    printf("pollfd_remove: fd=%3d\n", fd);
  }
  for (ir = 0; ir < pollfd_nfds; ir++) {
    if (pollfd_fds[ir].fd     != fd) {
      pollfd_fds[iw].fd      = pollfd_fds[ir].fd;
      pollfd_fds[iw].events  = pollfd_fds[ir].events;
      pollfd_fds[iw].revents = pollfd_fds[ir].revents;
      iw += 1;
    }
  }
  pollfd_nfds = iw;
  return;
}

/*----------------------------------------------------------*/
void pollfd_init() 
{
  const struct libusb_pollfd** plist = libusb_get_pollfds(pUsbContext);
  const struct libusb_pollfd** p;
  
  for (p = plist; *p !=0; p++) {
    pollfd_add((*p)->fd, (*p)->events, NULL);
  }

  free(plist);

  libusb_set_pollfd_notifiers(pUsbContext, pollfd_add, pollfd_remove,NULL);

  return;
}

/*----------------------------------------------------------*/
int keep_running() 
{
  if (nsigint > 0) return 0;
  if (par_nsec > 0 && (get_time()-t_start) > par_nsec) return 0;
  return 1;
  
}

/* forward declaration needed... */
void cb_rxblast(struct libusb_transfer *t);

/*----------------------------------------------------------*/
void que_write()
{
  int rc;
  int i;
  int nw = 512*dsc_rx.par_nfrm/2;
  int length = 2*nw;
  uint16_t* pdat;

  struct libusb_transfer* t = libusb_alloc_transfer(0);

  t->dev_handle = pUsbDevHdl;
  t->flags      = LIBUSB_TRANSFER_FREE_TRANSFER | LIBUSB_TRANSFER_FREE_BUFFER;
  t->endpoint   = 4;
  t->type       = LIBUSB_TRANSFER_TYPE_BULK;
  t->timeout    = 1000;
  t->status     = 0;
  t->buffer     = malloc(length);
  t->length     = length;
  t->actual_length = 0;
  t->callback   = cb_rxblast;
  t->user_data  = 0;

  pdat = (uint16_t*)(t->buffer);
  for (i = 0; i < nw; i++) *pdat++ = dsc_rx.cval++;
  
  rc = libusb_submit_transfer(t);
  if (rc) bad_usbcall_exit("libusb_submit_transfer()", rc);

  nreq += 1;

  if (par_trace) {
    prt_time();
    printf("que_write: ep=%1d l=%5d\n", t->endpoint&(~0x80), t->length);
  }

  return;
}

/*----------------------------------------------------------*/
void que_read(int ep, int nb, libusb_transfer_cb_fn cb)
{
  int rc;
  int length = 512*nb;

  struct libusb_transfer* t = libusb_alloc_transfer(0);

  t->dev_handle = pUsbDevHdl;
  t->flags      = LIBUSB_TRANSFER_FREE_TRANSFER | LIBUSB_TRANSFER_FREE_BUFFER;
  t->endpoint   = (unsigned char) (ep|0x80);
  t->type       = LIBUSB_TRANSFER_TYPE_BULK;
  t->timeout    = 1000;
  t->status     = 0;
  t->buffer     = malloc(length);
  t->length     = length;
  t->actual_length = 0;
  t->callback   = cb;
  t->user_data  = 0;

  rc = libusb_submit_transfer(t);
  if (rc) bad_usbcall_exit("libusb_submit_transfer()", rc);

  nreq += 1;

  if (par_trace) {
    prt_time();
    printf("que_read: ep=%1d l=%5d\n", t->endpoint&(~0x80), t->length);
  }

  return;
}

/*----------------------------------------------------------*/
void send_msg()
{
  int rc;
  int i;
  int nw = par_nwmsg;
  int length;
  uint16_t* pdat;

  if (par_nwrndm) nw = 1 + (random() % par_nwmsg);
  length = 2 * nw;
  cur_nwmsg = nw;

  struct libusb_transfer* t = libusb_alloc_transfer(0);

  t->dev_handle = pUsbDevHdl;
  t->flags      = LIBUSB_TRANSFER_FREE_TRANSFER | LIBUSB_TRANSFER_FREE_BUFFER;
  t->endpoint   = 4;
  t->type       = LIBUSB_TRANSFER_TYPE_BULK;
  t->timeout    = 1000;
  t->status     = 0;
  t->buffer     = malloc(length);
  t->length     = length;
  t->actual_length = 0;
  t->callback   = cb_rxblast;
  t->user_data  = 0;

  pdat = (uint16_t*)(t->buffer);
  for (i = 0; i < nw-1; i++) *pdat++ = dsc_rx.cval++;
  *pdat++ = 0xdead;
  
  rc = libusb_submit_transfer(t);
  if (rc) bad_usbcall_exit("libusb_submit_transfer()", rc);

  nreq += 1;

  if (par_trace) {
    prt_time();
    printf("send_msg: ep=%1d l=%5d", t->endpoint&(~0x80), t->length);
    printf(" buf=%4.4x,..", ((uint16_t*)(t->buffer))[0]);
    for (i = nw-2; i < nw; i++) {
      printf(",%4.4x", ((uint16_t*)(t->buffer))[i]);
    }
    printf("\n");
  }
  
  return;
}

/*----------------------------------------------------------*/
void cb_rxblast(struct libusb_transfer *t)
{
  nreq -= 1;

  if (par_trace) {
    prt_time();
    printf("cb_rx : ep=%d l=%5d al=%5d\n", 
           t->endpoint&(~0x80), t->length, t->actual_length);
  }

  bad_transfer_exit(t, "cb_rxblast");
  dsc_rx.stat_nbuf += 1;
  dsc_rx.stat_nbyt += t->actual_length;

  if (par_nwmsg==0 && keep_running()) que_write();

  return;
}

/*----------------------------------------------------------*/
void cb_txblast(struct libusb_transfer *t, int ep, libusb_transfer_cb_fn cb,
                struct dsc_queue* pdsc)
{
  nreq -= 1;

  if (par_trace) {
    prt_time();
    printf("cb_txx: ep=%d l=%5d al=%5d\n", 
           t->endpoint&(~0x80), t->length, t->actual_length);
  }

  bad_transfer_exit(t, "cb_txblast");
  if (t->actual_length > 0) {
    uint16_t* pdat = (uint16_t*)(t->buffer);
    int nw = t->actual_length/2;
    int i;
    if (pdsc->stat_nbuf == 0) pdsc->cval = pdat[0];
    for (i = 0; i < nw; i++) {
      uint16_t dat = *pdat++;
      if (pdsc->cval != dat) {
        prt_time();
        printf("FAIL: on ep=%d seen %4.4x expect %4.4x after %10.0f char\n", 
               ep&(~0x80), dat, pdsc->cval, pdsc->stat_nbyt+2*i);
        pdsc->cval = dat;
      }
      pdsc->cval += 1;
    }
  }

  pdsc->stat_nbuf += 1;
  pdsc->stat_nbyt += t->actual_length;
  if (t->actual_length < t->length) pdsc->stat_npt += 1;

  if (keep_running()) que_read(ep, pdsc->par_nfrm, cb);
}

/*----------------------------------------------------------*/
void cb_tx1blast(struct libusb_transfer *t)
{
  cb_txblast(t, 6, cb_tx1blast, &dsc_tx1);
  return;
}

/*----------------------------------------------------------*/
void cb_tx2blast(struct libusb_transfer *t)
{
  cb_txblast(t, 8, cb_tx2blast, &dsc_tx2);
  return;
}

/*----------------------------------------------------------*/
void cb_txloop(struct libusb_transfer *t)
{
  nreq -= 1;

  if (par_trace) {
    prt_time();
    printf("cb_txl: ep=%d l=%5d al=%5d\n", 
           t->endpoint&(~0x80), t->length, t->actual_length);
  }

  bad_transfer_exit(t, "cb_txloop");
  if (t->actual_length > 0) {
    uint16_t* pdat = (uint16_t*)(t->buffer);
    int nw = t->actual_length/2;
    int i;

    for (i = 0; i < nw; i++) {
      uint16_t dat = *pdat++;

      if (cur_nwmsg > 0) {
        uint16_t dat_exp = (cur_nwmsg>1) ? dsc_tx1.cval++ : 0xdead;
        if (dat_exp != dat) {
          prt_time();
          printf("FAIL: on ep=6 seen %4.4x expect %4.4x after %10.0f char\n", 
                 dat, dat_exp, dsc_tx1.stat_nbyt+2*i);
          if (cur_nwmsg>1) dsc_tx1.cval = dat + 1;
        }
        cur_nwmsg -= 1;
        if (cur_nwmsg==0 && dat==0xdead) stat_nmsg += 1;
      } else {
        prt_time();
        printf("FAIL: on ep=6 seen %4.4x unexpected after %10.0f char\n", 
               dat, dsc_tx1.stat_nbyt+2*i);
      }
    }
  }

  dsc_tx1.stat_nbuf += 1;
  dsc_tx1.stat_nbyt += t->actual_length;
  if (t->actual_length < t->length) dsc_tx1.stat_npt += 1;

  if (cur_nwmsg==0) {                       /* end of message seen */
    if (keep_running()) {
      send_msg();
    } else {
      if (par_trace) { prt_time(); printf("set endpoll = 1\n"); }
      endpoll = 1;
    }
  }
  
  que_read(6, dsc_tx1.par_nfrm, cb_txloop);

  return;
}

/*----------------------------------------------------------*/
void tx_pipe_drain(int ep)
{
  unsigned char buf[16384];
  int ntrans;
  int rc = libusb_bulk_transfer(pUsbDevHdl, ep|0x80,
                                buf, sizeof(buf), &ntrans, 10);
  if (rc == LIBUSB_ERROR_TIMEOUT) return;
  if (rc) bad_usbcall_exit("pipe drain: libusb_bulk_transfer()", rc);

  fprintf(stderr, "tst_fx2loop-I: pipe drain for ep=%d: ntrans=%d\n",
          ep&(~0x80), ntrans);

  return;
}

/*--------------------------------------------------------------------------*/
void do_run()
{
  int rc;
  int fd_timer = -1;
  int i;
  
  struct itimerspec tspec;
  struct dsc_queue dsc_rx_last  = dsc_rx;
  struct dsc_queue dsc_tx1_last = dsc_tx1;
  struct dsc_queue dsc_tx2_last = dsc_tx2;

  if (par_trace) {
    prt_time();
    printf("rx:nf=%d,nq=%d; tx1:nf=%d,nq=%d; tx2:nf=%d,nq=%d\n",
           dsc_rx.par_nfrm, dsc_rx.par_nque,
           dsc_tx1.par_nfrm, dsc_tx2.par_nque,
           dsc_tx2.par_nfrm, dsc_tx2.par_nque);
  }

  /* setup pollfd list */
  fd_timer = timerfd_create(CLOCK_MONOTONIC, TFD_NONBLOCK);
  if (fd_timer < 0) bad_syscall_exit("timerfd_create() failed", fd_timer);
  tspec.it_interval.tv_sec  = 1;
  tspec.it_interval.tv_nsec = 0;
  tspec.it_value.tv_sec  = 1;
  tspec.it_value.tv_nsec = 0;
  rc = timerfd_settime(fd_timer, 0, &tspec, NULL);
  if (rc<0) bad_syscall_exit("timerfd_settime() failed", rc);
  pollfd_fds[0].fd      = fd_timer;
  pollfd_fds[0].events  = POLLIN;
  pollfd_fds[0].revents = 0;
  pollfd_nfds = 1;

  pollfd_init();

  /* setup loop */
  if (par_nwmsg > 0) {
    dsc_rx.par_nfrm = 0;
    dsc_rx.par_nque = 0;
    if (dsc_tx1.par_nfrm == 0) dsc_tx1.par_nfrm = 1;
    if (dsc_tx1.par_nque == 0) dsc_tx1.par_nque = 1;

    tx_pipe_drain(6);                       /* drain tx1 */
    for (i = 0; i < dsc_tx1.par_nque; i++)  /* prime tx1 */
      que_read(6, dsc_tx1.par_nfrm, cb_txloop);
    send_msg();
  }

  /* setup rxblast */
  if (dsc_rx.par_nfrm > 0) {
    int i;
    if (dsc_rx.par_nque == 0) dsc_rx.par_nque = 1;
    for (i = 0; i < dsc_rx.par_nque; i++) que_write();
  }

  /* setup txblast */
  if (par_nwmsg==0 && dsc_tx1.par_nfrm>0) {
    int i;
    if (dsc_tx1.par_nque == 0) dsc_tx1.par_nque = 1;
    for (i = 0; i < dsc_tx1.par_nque; i++) 
      que_read(6, dsc_tx1.par_nfrm, cb_tx1blast);
  }

  /* setup tx2blast */
  if (dsc_tx2.par_nfrm > 0) {
    int i;
    if (dsc_tx2.par_nque == 0) dsc_tx2.par_nque = 1;
    for (i = 0; i < dsc_tx2.par_nque; i++) 
      que_read(8, dsc_tx2.par_nfrm, cb_tx2blast);
  }

  t_start = get_time();

  while(nreq>0 && endpoll==0) {
    uint64_t tbuf;
    rc = poll(pollfd_fds, pollfd_nfds, 2000);
    if (rc==-1 && errno==EINTR) continue;
    if (rc < 0) bad_syscall_exit("poll() failed", rc);
    if (rc == 0) fprintf(stderr, "tst_fx2loop-I: poll() timeout\n");

    if (par_trace) {
      int i;
      prt_time();
      printf("poll: rc=%d:", rc);
      for (i = 0; i < pollfd_nfds; i++) {
        printf(" %d,%2.2x", pollfd_fds[i].fd, pollfd_fds[i].revents);
      }
      printf("\n");
    }    

    if (pollfd_fds[0].revents == POLLIN) {
      errno = EBADMSG;                      /* to be reported on short read */
      rc = read(fd_timer, &tbuf, sizeof(tbuf));
      if (rc != sizeof(tbuf)) bad_syscall_exit("read(fd_timer,...) failed", rc);
      if (par_stat) {
        prt_time();
        if (par_nwmsg>0 || dsc_rx.par_nque>0) {
          double nbuf = dsc_rx.stat_nbuf - dsc_rx_last.stat_nbuf;
          double nbyt = dsc_rx.stat_nbyt - dsc_rx_last.stat_nbyt;
          printf("rx: %5.0f,%7.1f  ", nbuf, nbyt/1000.);
        }
        if (dsc_tx1.par_nque > 0 ) {
          double nbuf = dsc_tx1.stat_nbuf - dsc_tx1_last.stat_nbuf;
          double nbyt = dsc_tx1.stat_nbyt - dsc_tx1_last.stat_nbyt;
          printf("tx1: %5.0f,%7.1f  ", nbuf, nbyt/1000.);
        }
        if (dsc_tx2.par_nque > 0 ) {
          double nbuf = dsc_tx2.stat_nbuf - dsc_tx2_last.stat_nbuf;
          double nbyt = dsc_tx2.stat_nbyt - dsc_tx2_last.stat_nbyt;
          printf("tx2: %5.0f,%7.1f  ", nbuf, nbyt/1000.);
        }
        printf("\n");
        dsc_rx_last  = dsc_rx;
        dsc_tx1_last = dsc_tx1;
        dsc_tx2_last = dsc_tx2;
      }
    } else {
      struct timeval tv;
      tv.tv_sec  = 0;
      tv.tv_usec = 0;
      rc = libusb_handle_events_timeout(pUsbContext, &tv);
      //setting the timeval pointer to NULL should work, but doesn't (in 1.0.6)
      //rc = libusb_handle_events_timeout(pUsbContext, 0);
      if (rc) bad_usbcall_exit("libusb_handle_events_timeout()", rc);
    }
  }

  return;
}

/*--------------------------------------------------------------------------*/

void do_stat()
{
  printf("run statistics:\n");
  printf("runtime  : %13.3f\n", get_time()-t_start);
  printf("nbuf_rx  : %13.0f\n", dsc_rx.stat_nbuf);
  printf("nbyt_rx  : %13.0f\n", dsc_rx.stat_nbyt);
  printf("nbuf_tx1 : %13.0f\n", dsc_tx1.stat_nbuf);
  printf("nbyt_tx1 : %13.0f\n", dsc_tx1.stat_nbyt);
  printf("npt_tx1  : %13.0f\n", dsc_tx1.stat_npt);
  printf("nbuf_tx2 : %13.0f\n", dsc_tx2.stat_nbuf);
  printf("nbyt_tx2 : %13.0f\n", dsc_tx2.stat_nbyt);
  printf("npt_tx2  : %13.0f\n", dsc_tx2.stat_npt);
  printf("nmsg     : %13.0f\n", stat_nmsg);
  return;
}

/*--------------------------------------------------------------------------*/

void usb_claim()
{
  int rc = libusb_claim_interface(pUsbDevHdl, 0);
  if (rc) bad_usbcall_exit("libusb_claim_interface()", rc);
  return;
}

/*--------------------------------------------------------------------------*/

void usb_release()
{
  int rc = libusb_release_interface(pUsbDevHdl, 0);
  if (rc) bad_usbcall_exit("libusb_release_interface()", rc);
  return;
}

/*--------------------------------------------------------------------------*/

char* usb_strerror(int rc)
{
  switch(rc) {
    case LIBUSB_SUCCESS:
      return "";
    case LIBUSB_ERROR_IO: 
      return "Input/output error";
    case LIBUSB_ERROR_INVALID_PARAM: 
      return "Invalid parameter";
    case LIBUSB_ERROR_ACCESS: 
      return "Access denied";
    case LIBUSB_ERROR_NO_DEVICE: 
      return "No such device";
    case LIBUSB_ERROR_NOT_FOUND: 
      return "Entity not found";
    case LIBUSB_ERROR_BUSY: 
      return "Resource busy";
    case LIBUSB_ERROR_TIMEOUT: 
      return "Operation timed out";
    case LIBUSB_ERROR_OVERFLOW: 
      return "Overflow";
    case LIBUSB_ERROR_PIPE: 
      return "Pipe error";
    case LIBUSB_ERROR_INTERRUPTED: 
      return "System call interrupted";
    case LIBUSB_ERROR_NO_MEM: 
      return "Insufficient memory";
    case LIBUSB_ERROR_NOT_SUPPORTED: 
      return "Operation not supported";
    case LIBUSB_ERROR_OTHER: 
      return "Other error";
    default:
      return "Unknown libusb error code";
  }
}

/*--------------------------------------------------------------------------*/

void prt_time(void)
{
  struct timeval tv;
  struct timezone tz;
  struct tm tmval;

  gettimeofday(&tv, &tz);
  localtime_r(&tv.tv_sec, &tmval);
  printf("%02d:%02d:%02d.%06d: ", tmval.tm_hour, tmval.tm_min, tmval.tm_sec, 
	 (int) tv.tv_usec);
}

/*--------------------------------------------------------------------------*/

double get_time(void)
{
  struct timeval tv;
  struct timezone tz;
  gettimeofday(&tv, &tz);
  return (double)tv.tv_sec + 1.e-6 * (double)tv.tv_usec;
}

/*--------------------------------------------------------------------------*/

void bad_syscall_exit(const char* text, int rc) 
{
  fprintf(stderr, "tst_fx2loop-F: %s failed with rc=%d errno=%d : %s\n",
          text, rc, errno, strerror(errno));
  exit(EXIT_FAILURE);
}

/*--------------------------------------------------------------------------*/

void bad_usbcall_exit(const char* text, int rc) 
{
  fprintf(stderr, "tst_fx2loop-F: %s failed with rc=%d: %s\n",
          text, rc, usb_strerror(rc));
  exit(EXIT_FAILURE);
}

/*--------------------------------------------------------------------------*/

void bad_transfer_exit(struct libusb_transfer *t, const char* text) 
{
  const char* etext = 0;

  if (t->status == LIBUSB_TRANSFER_ERROR)     etext = "ERROR";
  if (t->status == LIBUSB_TRANSFER_STALL)     etext = "STALL";
  if (t->status == LIBUSB_TRANSFER_NO_DEVICE) etext = "NO_DEVICE";
  if (t->status == LIBUSB_TRANSFER_OVERFLOW)  etext = "OVERFLOW";

  if (etext == 0) return;
  
  fprintf(stderr, "tst_fx2loop-F: transfer failure in %s on ep=%d: %s\n",
          text, (int)(t->endpoint&(~0x80)), etext);
  exit(EXIT_FAILURE);
}

