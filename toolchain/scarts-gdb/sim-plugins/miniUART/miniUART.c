/* SCARTS miniUART extension module code for the GNU simulator.
   Copyright 1996, 1997, 1998, 1999, 2000, 2001, 2002, 2003
   Free Software Foundation, Inc.
   Contributed by Martin Walter <mwalter@opencores.org>

   This file is part of the GNU simulators.

   This program is free software; you can redistribute it and/or modify
   it under the terms of the GNU General Public License as published by
   the Free Software Foundation; either version 3 of the License, or
   (at your option) any later version.

   This program is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
   GNU General Public License for more details.

   You should have received a copy of the GNU General Public License
   along with this program.  If not, see <http://www.gnu.org/licenses/>.  */


#define _XOPEN_SOURCE
#include <errno.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <strings.h>
#include <termios.h>
#include <unistd.h>
#include "miniUART.h"

/* Macros for machine type. */
#if defined __SCARTS_16__
  #define SCARTS_ADDR_CTYPE  uint16_t
#elif defined __SCARTS_32__
  #define SCARTS_ADDR_CTYPE  uint32_t
#else
  #error "Unsupported target machine type"
#endif

/* Macros for the assigned action (ASA) in the CMD register. */
#define UART_CMD_ASA_BITMASK	0x38
#define UART_CMD_ASA_TxStart	(0x3 << 3)
#define UART_CMD_ASA_RxEnable	(0x4 << 3)
#define UART_CMD_ASA_RxDisable	(0x5 << 3)

/* Macros for the event selector (ES) in the CMD register. */
#define UART_CMD_ES_MASK	0x06
#define UART_CMD_ES_NoEvent	0x00
#define UART_CMD_ES_StartBitRec	(0x1 << 1)
#define UART_CMD_ES_RxComplete	(0x2 << 1)
#define UART_CMD_ES_TxStarted	(0x3 << 1)

/* Macros for bit manipulations. */
#define read_bit(regfile, bitpos) (((regfile) >> (bitpos)) & 1)
#define write_bit(regfile, bitpos, value) (void)((value) ? ((regfile) |= (1 << (bitpos))) : ((regfile) &= ~(1 << (bitpos))))

static miniuart_mem_t mem;
static int fdm          = -1; /* File handle of pseudo TTY master. */
static int rxEnabled    =  0; /* Does the simulated serial port accept any incoming data? */
static int txCnt        =  1; /* Simulates time the data transmission takes (cpu cycles). */
static int txMsgChanged =  0; /* Did MSG register contents change since last transmission? */

static void set_event_flag (void);
static int  stty_raw       (int fd);

static void
set_event_flag (void)
{
  /* Set the MINI_UART_STATUS_C_EF flag. */
  write_bit (mem.regfile.STATUS_C, MINI_UART_STATUS_C_EF, 1);

  /* Check if the MINI_UART_CMD_EI flag is set. */
  if (read_bit (mem.regfile.CMD, MINI_UART_CMD_EI))
    /* Trigger an interrupt. */
    write_bit (mem.regfile.STATUS, MINI_UART_STATUS_INT, 1);
}

static int
stty_raw (int fd)
{
  struct termios tty_state;

  bzero (&tty_state, sizeof (tty_state));
  tty_state.c_cflag = B38400 | CS8 | CLOCAL | CREAD;
  tty_state.c_iflag = IGNPAR;
  tty_state.c_oflag = 0;

  /* Configure for blocking read until 1 chars received. */
  tty_state.c_cc[VMIN]  = 1;

  /* Configure for inter-character timer being unused. */
  tty_state.c_cc[VTIME] = 0;

  if (tcsetattr (fd, TCSAFLUSH, &tty_state) < 0)
    return (-1);

  return 0;
}

uint8_t*
get_mem (void)
{
  return mem.raw;
}

void
get_mem_map (SCARTS_ADDR_CTYPE* start, SCARTS_ADDR_CTYPE* size)
{
  *start = MINI_UART_BADDR;
  *size  = MINI_UART_SIZE;
}

uint8_t*
get_status (void)
{
  return &mem.regfile.STATUS;
}

int
mem_read (SCARTS_ADDR_CTYPE offset, uint8_t *value)
{
  if (offset >= MINI_UART_SIZE)
    return 0;

  switch (offset)
  {
    /* STATUS_C */
    case 0:
      /* Reading the STATUS_C register resets the MINI_UART_STATUS_C_EF flag. */
      write_bit (mem.regfile.STATUS_C, MINI_UART_STATUS_C_EF, 1);
      break;
    /* MSG_LO */
    case 6:
    /* MSG_HI */
    case 7:
      if (read_bit (mem.regfile.STATUS_C, MINI_UART_STATUS_C_RBR))
      {
        /* Reading a received message resets the following flags:
         * - MINI_UART_STATUS_C_FE
         * - MINI_UART_STATUS_C_PE
         * - MINI_UART_STATUS_C_OV
         * - MINI_UART_STATUS_C_RBR
         * - MINI_UART_STATUS_ERR
         */
        write_bit (mem.regfile.STATUS_C, MINI_UART_STATUS_C_FE, 0);
        write_bit (mem.regfile.STATUS_C, MINI_UART_STATUS_C_PE, 0);
        write_bit (mem.regfile.STATUS_C, MINI_UART_STATUS_C_OV, 0);
        write_bit (mem.regfile.STATUS_C, MINI_UART_STATUS_C_RBR, 0);
        write_bit (mem.regfile.STATUS, MINI_UART_STATUS_ERR, 0);
      }

      break;
  }

  *value = mem.raw[offset];
  return 1;
}

int
mem_write (SCARTS_ADDR_CTYPE offset, uint8_t value)
{
  if (offset >= MINI_UART_SIZE)
    return 0;

  switch (offset)
  {
    /* STATUS */
    case 0:
    /* STATUS_C */
    case 1:
      /* The STATUS and STATUS_C registers are read-only. */
      return 0;
    /* CONFIG */
    case 2:
      /* Write the MINI_UART_CONFIG_LOOW bit to MINI_UART_STATUS_LOOR. */
      write_bit (mem.regfile.STATUS, MINI_UART_STATUS_LOOR, read_bit (value, MINI_UART_CONFIG_LOOW));

      /* Check if an interrupt needs to be acknowledged. */
      if (read_bit (value, MINI_UART_CONFIG_INTA))
      { 
        write_bit (mem.regfile.STATUS, MINI_UART_STATUS_INT, 0);
        write_bit (value, MINI_UART_CONFIG_INTA, 0);
      }	
      break;	
    /* CMD */
    case 5:
      switch (value & UART_CMD_ASA_BITMASK)
      {
        /* Start the transmitter. */
        case UART_CMD_ASA_TxStart:
          /* Simulate some delay before starting the transmission. */
          txCnt = 1;
          break;
        /* Enable the receiver. */
        case UART_CMD_ASA_RxEnable:
          /* Reset all error flags. */
          write_bit (mem.regfile.STATUS_C, MINI_UART_STATUS_C_FE, 0);
          write_bit (mem.regfile.STATUS_C, MINI_UART_STATUS_C_PE, 0);
          write_bit (mem.regfile.STATUS_C, MINI_UART_STATUS_C_OV, 0);
          write_bit (mem.regfile.STATUS_C, MINI_UART_STATUS_C_RBR, 0);
          write_bit (mem.regfile.STATUS, MINI_UART_STATUS_ERR, 0);
          rxEnabled = 1;
          break;
        /* Stop the receiver. */
        case UART_CMD_ASA_RxDisable:
          rxEnabled = 0;
          break;
      }

      break;
    case 6:
      txMsgChanged = 1;
      break;
  }

  mem.raw[offset] = value;
  return 1;
}

void
reset (void)
{
  memset (mem.raw, 0, MINI_UART_SIZE);
}

void
tick (SCARTS_ADDR_CTYPE pc)
{
  char c;

  if (txMsgChanged && --txCnt == 0)
  {
    if (write (fdm, &mem.regfile.MSG_LO, 1) == -1)
      fprintf (stderr, "Error writing to pseudo-terminal master device: %s\n", strerror (errno));

    if ((mem.regfile.CMD & UART_CMD_ES_MASK) == UART_CMD_ES_TxStarted)
      set_event_flag ();

    /* The transmitter is ready to transmit data. */
    write_bit (mem.regfile.STATUS_C, MINI_UART_STATUS_C_TBR, 1);

    txCnt = 1;
    txMsgChanged = 0;
  }

  /* Check if there is something to receive. */
  if (rxEnabled && !read_bit (mem.regfile.STATUS_C, MINI_UART_STATUS_C_RBR) && read (fdm, &c, 1) > 0)
  {
    mem.regfile.MSG_HI = 0;
    mem.regfile.MSG_LO = c;

    write_bit (mem.regfile.STATUS_C, MINI_UART_STATUS_C_RBR, 1);

    if ((mem.regfile.CMD & UART_CMD_ES_MASK) == UART_CMD_ES_RxComplete
     || (mem.regfile.CMD & UART_CMD_ES_MASK) == UART_CMD_ES_StartBitRec)
      set_event_flag ();
  } 
}

void __attribute__ ((constructor))
miniuart_init (void)
{
  extern char *ptsname ();
  char *slavename;

  /* Get a handle to the pseudo TTY master at MINIUART_TTY_DEV. */
  fdm = open (MINIUART_TTY_DEV, O_RDWR | O_NOCTTY | O_NONBLOCK);
  if (fdm == -1)
    fprintf (stderr, "Error opening backend device: %s\n", strerror (errno));

  if (stty_raw (fdm) != 0)
    fprintf (stderr, "Error putting serial device in raw mode: %s\n", strerror (errno));

  /* Grant access to the pseudo-terminal slave device. */
  if (grantpt (fdm) == -1)
    fprintf (stderr, "Error granting access to pseudo-terminal slave device: %s\n", strerror (errno));

  /* Unlock the pseudo-terminal master/slave pair. */
  if (unlockpt (fdm) == -1)
    fprintf (stderr, "Error unlocking the pseudo-terminal master/slave pair: %s\n", strerror (errno));

  /* Get the name of the pseudo-terminal slave device. */
  slavename = ptsname (fdm);
  if (slavename == NULL)
    fprintf (stderr, "Error getting name of pseudo-terminal slave device.\n");

  /* The transmitter is ready to transmit data. */
  write_bit (mem.regfile.STATUS_C, MINI_UART_STATUS_C_TBR, 1);

  fprintf (stdout, "miniUART pseudo-terminal master device: %s\n", MINIUART_TTY_DEV);
  fprintf (stdout, "miniUART pseudo-terminal slave device: %s\n", slavename);
}

void __attribute__ ((destructor))
miniuart_finish (void)
{
  if (fdm != -1)
    close (fdm);
}

