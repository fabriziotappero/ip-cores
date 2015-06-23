#ifndef __DEVOPS_VEC_H__
#define __DEVOPS_VEC_H__

#include "devops.h"
#include "UART.h"

static const devops_t devops_UART = {"UART", UART_open, UART_close, UART_write, UART_read_line};

const devops_t *devops_vec[] =
{
  /* O: stdin */
  &devops_UART,
  /* 1: stdout */
  &devops_UART,
  /* 2: stderr */
  &devops_UART,
  0
};

#endif
