/*
 * serial.c -- serial line simulation
 */


#ifdef __linux__
#define _XOPEN_SOURCE
#endif

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <setjmp.h>
#include <signal.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>
#include <fcntl.h>
#include <termios.h>

#include "common.h"
#include "console.h"
#include "error.h"
#include "except.h"
#include "cpu.h"
#include "timer.h"
#include "serial.h"


/**************************************************************/


static Bool debug = false;


typedef struct {
  pid_t pid;
  FILE *in;
  FILE *out;
  Word rcvrCtrl;
  Word rcvrData;
  int rcvrIRQ;
  Word xmtrCtrl;
  Word xmtrData;
  int xmtrIRQ;
} Serial;


static Serial serials[MAX_NSERIALS];
static int nSerials;


/**************************************************************/


static void rcvrCallback(int dev) {
  int c;

  if (debug) {
    cPrintf("\n**** SERIAL RCVR CALLBACK ****\n");
  }
  timerStart(SERIAL_RCVR_USEC, rcvrCallback, dev);
  c = fgetc(serials[dev].in);
  if (c == EOF) {
    /* no character typed */
    return;
  }
  /* any character typed */
  serials[dev].rcvrData = c & 0xFF;
  serials[dev].rcvrCtrl |= SERIAL_RCVR_RDY;
  if (serials[dev].rcvrCtrl & SERIAL_RCVR_IEN) {
    /* raise serial line rcvr interrupt */
    cpuSetInterrupt(serials[dev].rcvrIRQ);
  }
}


static void xmtrCallback(int dev) {
  if (debug) {
    cPrintf("\n**** SERIAL XMTR CALLBACK ****\n");
  }
  fputc(serials[dev].xmtrData & 0xFF, serials[dev].out);
  serials[dev].xmtrCtrl |= SERIAL_XMTR_RDY;
  if (serials[dev].xmtrCtrl & SERIAL_XMTR_IEN) {
    /* raise serial line xmtr interrupt */
    cpuSetInterrupt(serials[dev].xmtrIRQ);
  }
}


/**************************************************************/


Word serialRead(Word addr) {
  int dev, reg;
  Word data;

  if (debug) {
    cPrintf("\n**** SERIAL READ from 0x%08X", addr);
  }
  dev = addr >> 12;
  if (dev >= nSerials) {
    /* illegal device */
    throwException(EXC_BUS_TIMEOUT);
  }
  reg = addr & 0x0FFF;
  if (reg == SERIAL_RCVR_CTRL) {
    data = serials[dev].rcvrCtrl;
  } else
  if (reg == SERIAL_RCVR_DATA) {
    serials[dev].rcvrCtrl &= ~SERIAL_RCVR_RDY;
    if (serials[dev].rcvrCtrl & SERIAL_RCVR_IEN) {
      /* lower serial line rcvr interrupt */
      cpuResetInterrupt(serials[dev].rcvrIRQ);
    }
    data = serials[dev].rcvrData;
  } else
  if (reg == SERIAL_XMTR_CTRL) {
    data = serials[dev].xmtrCtrl;
  } else
  if (reg == SERIAL_XMTR_DATA) {
    /* this register is write-only */
    throwException(EXC_BUS_TIMEOUT);
  } else {
    /* illegal register */
    throwException(EXC_BUS_TIMEOUT);
  }
  if (debug) {
    cPrintf(", data = 0x%08X ****\n", data);
  }
  return data;
}


void serialWrite(Word addr, Word data) {
  int dev, reg;

  if (debug) {
    cPrintf("\n**** SERIAL WRITE to 0x%08X, data = 0x%08X ****\n",
            addr, data);
  }
  dev = addr >> 12;
  if (dev >= nSerials) {
    /* illegal device */
    throwException(EXC_BUS_TIMEOUT);
  }
  reg = addr & 0x0FFF;
  if (reg == SERIAL_RCVR_CTRL) {
    if (data & SERIAL_RCVR_IEN) {
      serials[dev].rcvrCtrl |= SERIAL_RCVR_IEN;
    } else {
      serials[dev].rcvrCtrl &= ~SERIAL_RCVR_IEN;
    }
    if (data & SERIAL_RCVR_RDY) {
      serials[dev].rcvrCtrl |= SERIAL_RCVR_RDY;
    } else {
      serials[dev].rcvrCtrl &= ~SERIAL_RCVR_RDY;
    }
    if ((serials[dev].rcvrCtrl & SERIAL_RCVR_IEN) != 0 &&
        (serials[dev].rcvrCtrl & SERIAL_RCVR_RDY) != 0) {
      /* raise serial line rcvr interrupt */
      cpuSetInterrupt(serials[dev].rcvrIRQ);
    } else {
      /* lower serial line rcvr interrupt */
      cpuResetInterrupt(serials[dev].rcvrIRQ);
    }
  } else
  if (reg == SERIAL_RCVR_DATA) {
    /* this register is read-only */
    throwException(EXC_BUS_TIMEOUT);
  } else
  if (reg == SERIAL_XMTR_CTRL) {
    if (data & SERIAL_XMTR_IEN) {
      serials[dev].xmtrCtrl |= SERIAL_XMTR_IEN;
    } else {
      serials[dev].xmtrCtrl &= ~SERIAL_XMTR_IEN;
    }
    if (data & SERIAL_XMTR_RDY) {
      serials[dev].xmtrCtrl |= SERIAL_XMTR_RDY;
    } else {
      serials[dev].xmtrCtrl &= ~SERIAL_XMTR_RDY;
    }
    if ((serials[dev].xmtrCtrl & SERIAL_XMTR_IEN) != 0 &&
        (serials[dev].xmtrCtrl & SERIAL_XMTR_RDY) != 0) {
      /* raise serial line xmtr interrupt */
      cpuSetInterrupt(serials[dev].xmtrIRQ);
    } else {
      /* lower serial line xmtr interrupt */
      cpuResetInterrupt(serials[dev].xmtrIRQ);
    }
  } else
  if (reg == SERIAL_XMTR_DATA) {
    serials[dev].xmtrData = data & 0xFF;
    serials[dev].xmtrCtrl &= ~SERIAL_XMTR_RDY;
    if (serials[dev].xmtrCtrl & SERIAL_XMTR_IEN) {
      /* lower serial line xmtr interrupt */
      cpuResetInterrupt(serials[dev].xmtrIRQ);
    }
    timerStart(SERIAL_XMTR_USEC, xmtrCallback, dev);
  } else {
    /* illegal register */
    throwException(EXC_BUS_TIMEOUT);
  }
}


/**************************************************************/


void serialReset(void) {
  int i;

  cPrintf("Resetting Serial Lines...\n");
  for (i = 0; i < nSerials; i++) {
    serials[i].rcvrCtrl = 0;
    serials[i].rcvrData = 0;
    serials[i].rcvrIRQ = IRQ_SERIAL_0_RCVR + 2 * i;
    timerStart(SERIAL_RCVR_USEC, rcvrCallback, i);
    serials[i].xmtrCtrl = SERIAL_XMTR_RDY;
    serials[i].xmtrData = 0;
    serials[i].xmtrIRQ = IRQ_SERIAL_0_XMTR + 2 * i;
  }
}


static void makeRaw(int fd) {
  struct termios t;

  tcgetattr(fd, &t);
  t.c_iflag &= ~(IGNBRK|BRKINT|PARMRK|ISTRIP|INLCR|IGNCR|ICRNL|IXON);
  t.c_oflag &= ~OPOST;
  t.c_lflag &= ~(ECHO|ECHONL|ICANON|ISIG|IEXTEN);
  t.c_cflag &= ~(CSIZE|PARENB);
  t.c_cflag |= CS8;
  tcsetattr(fd, TCSANOW, &t);
}


void serialInit(int numSerials, Bool connectTerminals[]) {
  int i;
  int master;
  char slavePath[100];
  int slave;
  char termTitle[100];
  char termSlave[100];

  nSerials = numSerials;
  for (i = 0; i < nSerials; i++) {
    /* open pseudo terminal */
    master = open("/dev/ptmx", O_RDWR | O_NONBLOCK);
    if (master < 0) {
      error("cannot open pseudo terminal master for serial line %d", i);
    }
    grantpt(master);
    unlockpt(master);
    strcpy(slavePath, ptsname(master));
    if (debug) {
      cPrintf("pseudo terminal %d: master fd = %d, slave path = '%s'\n",
              i, master, slavePath);
    }
    if (connectTerminals[i]) {
      /* connect a terminal to the serial line */
      /* i.e., fork and exec a new xterm process */
      serials[i].pid = fork();
      if (serials[i].pid < 0) {
        error("cannot fork xterm process for serial line %d", i);
      }
      if (serials[i].pid == 0) {
        /* terminal process */
        setpgid(0, 0);
        close(master);
        /* open and configure pseudo terminal slave */
        slave = open(slavePath, O_RDWR | O_NONBLOCK);
        if (slave < 0) {
          error("cannot open pseudo terminal slave '%s'\n", slavePath);
        }
        makeRaw(slave);
        /* exec xterm */
        sprintf(termTitle, "ECO32 Terminal %d", i);
        sprintf(termSlave, "-Sab%d", slave);
        execlp("xterm", "xterm", "-title", termTitle, termSlave, NULL);
        error("cannot exec xterm process for serial line %d", i);
      }
    } else {
      /* leave serial line unconnected */
      serials[i].pid = 0;
      cPrintf("Serial line %d can be accessed by opening device '%s'.\n",
              i, slavePath);
    }
    fcntl(master, F_SETFL, O_NONBLOCK);
    serials[i].in = fdopen(master, "r");
    setvbuf(serials[i].in, NULL, _IONBF, 0);
    serials[i].out = fdopen(master, "w");
    setvbuf(serials[i].out, NULL, _IONBF, 0);
    if (connectTerminals[i]) {
      /* skip the window id written by xterm */
      while (fgetc(serials[i].in) != '\n') ;
    }
  }
  serialReset();
}


void serialExit(void) {
  int i;

  /* kill and wait for all xterm processes */
  for (i = 0; i < nSerials; i++) {
    if (serials[i].pid > 0) {
      kill(serials[i].pid, SIGKILL);
      waitpid(serials[i].pid, NULL, 0);
    }
  }
}
