/* UART device driver for SCARTS.
 * Copyright (C) 2010, 2011 Embedded Computing Systems Group,
 * Department of Computer Engineering, Vienna University of Technology.
 * Contributed by Martin Walter <mwalter@opencores.org>
 *
 * The authors hereby grant permission to use, copy, modify, distribute,
 * and license this software and its documentation for any purpose, provided
 * that existing copyright notices are retained in all copies and that this
 * notice is included verbatim in any distributions. No written agreement,
 * license, or royalty fee is required for any of the authorized uses.
 * Modifications to this software may be copyrighted by their authors
 * and need not follow the licensing terms described here, provided that
 * the new terms are clearly indicated on the first page of each file where
 * they apply.
 */

#include "UART.h"
#include "modules.h"

static int  UART_getc (char *c);
static void UART_putc (const char c);

static int
UART_getc (char *c)
{
  int err = 0;
  uint16_t msg;

  /* Start the receiver. */
  MINI_UART_CMD = (1 << MINI_UART_CMD_AA_2);

  /* Wait until the receiver is ready. */
  while ((MINI_UART_STATUS_C & (1 << MINI_UART_STATUS_C_RBR)) == 0)
    asm ("nop");

  /* Check for errors from the receiver. */
  if ((MINI_UART_STATUS_C & (1 << MINI_UART_STATUS_C_FE)) != 0)
    err = EFRAME;

  if ((MINI_UART_STATUS_C & (1 << MINI_UART_STATUS_C_PE)) != 0)
    err = EPARITY;

  if ((MINI_UART_STATUS_C & (1 << MINI_UART_STATUS_C_OV)) != 0)
    err = EOVFLOW;

  msg = MINI_UART_MSG;

  /* Stop the receiver. */
  MINI_UART_CMD = (1 << MINI_UART_CMD_AA_2) | (1 << MINI_UART_CMD_AA_0);

  if (err == 0)
    *c = (char) msg;

  return err;
}

static void
UART_putc (const char c)
{
  /* Wait until transmitter is ready. */
  while ((MINI_UART_STATUS_C & (1 << MINI_UART_STATUS_C_TBR)) == 0)
    asm ("nop");

  MINI_UART_MSG = c;

  /* Start the transmitter. */
  MINI_UART_CMD = (1 << MINI_UART_CMD_AA_1) | (1 << MINI_UART_CMD_AA_0);

  while ((MINI_UART_STATUS_C & (1 << MINI_UART_STATUS_C_TBR)) == 0)
    asm ("nop");

  MINI_UART_CMD = 0;
}

int
UART_close (int file)
{
  return 0;
}

void
UART_init (UART_Cfg cfg)
{
  uint16_t ubrs;

  if (cfg.baud == 0)
    return;

  MINI_UART_CFG = 0;

  /* Set the parity bits. */
  if (cfg.frame.parity != UART_CFG_PARITY_NONE)
  {
    MINI_UART_CFG |= (1 << MINI_UART_CFG_PARENA);

    if (cfg.frame.parity == UART_CFG_PARITY_ODD)
      MINI_UART_CFG |= (1 << MINI_UART_CFG_ODD);
  }

  /* Set the stop bits. */
  if (cfg.frame.stop_bits == UART_CFG_STOP_BITS_2)
    MINI_UART_CFG |= (1 << MINI_UART_CFG_STOP);

  /* Set the message length. */
  if (cfg.frame.msg_len & 8)
    MINI_UART_CFG |= (1 << MINI_UART_CFG_MSGLEN_3);

  if (cfg.frame.msg_len & 4)
    MINI_UART_CFG |= (1 << MINI_UART_CFG_MSGLEN_2);

  if (cfg.frame.msg_len & 2)
    MINI_UART_CFG |= (1 << MINI_UART_CFG_MSGLEN_1);

  if (cfg.frame.msg_len & 1)
    MINI_UART_CFG |= (1 << MINI_UART_CFG_MSGLEN_0);

  /* Enable transmission control. */
  MINI_UART_CFG |= (1 << MINI_UART_CFG_TRCTRL);

  /* Set the baud rate. */
  ubrs = (uint16_t) (cfg.fclk / cfg.baud) << 4;
  MINI_UART_UBRS_H = (ubrs >> 8) & 0xFF;
  MINI_UART_UBRS_L = ubrs & 0xFF;
}

int
UART_open (const char *name, int flags, int mode)
{
  return 0;
}

int
UART_read (int file, char *ptr, int len)
{
  char c;
  int i;

  i = 0;

  if (len <= 0)
    return 0;

  do
  {
    if (UART_getc (&c) != 0)
      break;

    ptr[i++] = c;
  }
  while (i < len);

  return i;
}

int
UART_read_line (int file, char *ptr, int len)
{
  char c;
  int i;

  i = 0;

  if (len <= 0)
    return 0;

  do
  {
    if (UART_getc (&c) != 0)
      break;

    if (c == '\r')
      continue;

    if (c == '\n')
      break;

    ptr[i++] = c;
  }
  while (i < len);

  ptr[i] = '\0';
  return i;
}

int
UART_write (int file, char *ptr, int len)
{
  int i;

  if (len <= 0)
    return 0;

  for (i = 0; i < len; ++i)
    UART_putc (ptr[i]);

  return len;
}
