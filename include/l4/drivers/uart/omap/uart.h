/*
 * OMAP UART Generic driver implementation.
 *
 * Copyright (C) 2007 Bahadir Balban
 *
 * The particular intention of this code is that it has been carefully written
 * as decoupled from os-specific code and in a verbose way such that it clearly
 * demonstrates how the device operates, reducing the amount of time to be spent
 * for understanding the operational model and implementing a driver from
 * scratch. This is the very first to be such a driver so far, hopefully it will
 * turn out to be useful.
 */

#ifndef __OMAP_UART_H__
#define __OMAP_UART_H__

#include INC_PLAT(uart.h)
#include INC_ARCH(io.h)

/* Register offsets */
#define OMAP_UART_DLL		0x00
#define OMAP_UART_THR		0x00
#define OMAP_UART_RHR		0x00
#define OMAP_UART_DLH		0x04
#define OMAP_UART_IER		0x04
#define OMAP_UART_FCR		0x08
#define OMAP_UART_MCR		0x10
#define OMAP_UART_LSR		0x14
#define OMAP_UART_MDR1		0x20
#define	OMAP_UART_LCR		0x0C

/* Modes supported by OMAP UART/IRDA/CIR IP */
#define OMAP_UART_MODE_UART16X               0x0
#define OMAP_UART_MODE_SIR                   0x1
#define OMAP_UART_MODE_UART16X_AUTO_BAUD     0x2
#define OMAP_UART_MODE_UART13X               0x3
#define OMAP_UART_MODE_MIR                   0x4
#define OMAP_UART_MODE_FIR                   0x5
#define OMAP_UART_MODE_CIR                   0x6
#define OMAP_UART_MODE_DEFAULT               0x7 /* Disable */

/* Number of data bits for UART */
#define OMAP_UART_DATA_BITS_5           0x0
#define OMAP_UART_DATA_BITS_6           0x1
#define OMAP_UART_DATA_BITS_7           0x2
#define OMAP_UART_DATA_BITS_8           0x3

/* Stop bits to be used for UART data */
#define OMAP_UART_STOP_BITS_1           0x0
#define OMAP_UART_STOP_BITS_1_5         0x1

/* Banked Register modes- ConfigA, ConfigB, Operational */
#define OMAP_UART_BANKED_MODE_OPERATIONAL      0x00
#define OMAP_UART_BANKED_MODE_CONFIG_A         0x80
#define OMAP_UART_BANKED_MODE_CONFIG_B         0xBF

void uart_tx_char(unsigned long base, char c);
char uart_rx_char(unsigned long uart_base);
void uart_set_baudrate(unsigned long uart_base, u32 baudrate, u32 clkrate);
void uart_init(unsigned long uart_base);

#endif /* __OMAP_UART_H__ */
