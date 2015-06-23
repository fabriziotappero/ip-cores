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

#ifndef __DEV_UART_CFG_H__
#define __DEV_UART_CFG_H__

#include <inttypes.h>

#define UART_CFG_FCLK_25MHZ 25000000
#define UART_CFG_FCLK_40MHZ 40000000

#define UART_CFG_BAUD_9600     9600
#define UART_CFG_BAUD_19200   19200
#define UART_CFG_BAUD_38400   38400
#define UART_CFG_BAUD_57600   57600
#define UART_CFG_BAUD_115200 115200
#define UART_CFG_BAUD_230400 230400
#define UART_CFG_BAUD_460800 460800
#define UART_CFG_BAUD_921600 921600

#define UART_CFG_MSG_LEN_1    0
#define UART_CFG_MSG_LEN_2    1
#define UART_CFG_MSG_LEN_3    2
#define UART_CFG_MSG_LEN_4    3
#define UART_CFG_MSG_LEN_5    4
#define UART_CFG_MSG_LEN_6    5
#define UART_CFG_MSG_LEN_7    6
#define UART_CFG_MSG_LEN_8    7
#define UART_CFG_MSG_LEN_9    8
#define UART_CFG_MSG_LEN_10   9
#define UART_CFG_MSG_LEN_11  10
#define UART_CFG_MSG_LEN_12  11
#define UART_CFG_MSG_LEN_13  12
#define UART_CFG_MSG_LEN_14  13
#define UART_CFG_MSG_LEN_15  14
#define UART_CFG_MSG_LEN_16  15
#define UART_CFG_PARITY_NONE  0
#define UART_CFG_PARITY_ODD   1
#define UART_CFG_PARITY_EVEN  2
#define UART_CFG_STOP_BITS_1  0
#define UART_CFG_STOP_BITS_2  1

typedef struct 
{
  unsigned int msg_len   : 4;
  unsigned int parity    : 2;
  unsigned int stop_bits : 1;
} UART_Frame;

typedef struct
{
  uint32_t fclk;
  uint32_t baud;
  UART_Frame frame;
} UART_Cfg;

#endif

