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

#ifndef __DEV_UART_H__
#define __DEV_UART_H__

#include <sys/types.h>
#include "UART_cfg.h"

/* Macros for error codes. */
#define EFRAME  1   /* frame error */
#define EPARITY 2   /* parity error */
#define EOVFLOW 3   /* overflow error */

extern int  UART_close     (int file);
extern void UART_init      (UART_Cfg cfg);
extern int  UART_open      (const char *name, int flags, int mode);
extern int  UART_read      (int file, char *ptr, int len);
extern int  UART_read_line (int file, char *ptr, int len);
extern int  UART_write     (int file, char *ptr, int len);

#endif
