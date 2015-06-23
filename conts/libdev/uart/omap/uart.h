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

#include <l4/config.h> /* To get PLATFORM */
#include <l4lib/types.h>

#if defined(VARIANT_USERSPACE)
/* FIXME: Take this value in agreement from kernel, or from kernel only */
#include <l4/macros.h>
#include INC_ARCH(io.h)
#define OMAP_UART_BASE              USERSPACE_CONSOLE_VBASE
#endif

#if defined(VARIANT_BAREMETAL)
#if defined(CONFIG_PLATFORM_BEAGLE)
#define OMAP_UART_BASE		0x49020000
#endif
#endif

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

void uart_tx_char(unsigned long uart_base, char c);
char uart_rx_char(unsigned long uart_base);
void uart_set_baudrate(unsigned long uart_base, u32 baudrate);
void uart_init(unsigned long uart_base);


#define OMAP_UART_FIFO_ENABLE	(1 << 0)
#define OMAP_UART_RX_FIFO_CLR   (1 << 1)
#define OMAP_UART_TX_FIFO_CLR   (1 << 2)
static inline void uart_enable_fifo(unsigned long uart_base)
{
	volatile u32 reg = read(uart_base + OMAP_UART_FCR);
	reg |= (OMAP_UART_FIFO_ENABLE | OMAP_UART_RX_FIFO_CLR |
                OMAP_UART_TX_FIFO_CLR);
	write(reg, uart_base + OMAP_UART_FCR);
}

static inline void uart_disable_fifo(unsigned long uart_base)
{
	volatile u32 reg= read(uart_base + OMAP_UART_FCR);
	reg &= (~OMAP_UART_FIFO_ENABLE | OMAP_UART_RX_FIFO_CLR |
                 OMAP_UART_TX_FIFO_CLR);
	write(reg, uart_base + OMAP_UART_FCR);
}

#define OMAP_UART_TX_ENABLE	(1 << 0)
static inline void uart_enable_tx(unsigned long uart_base)
{
	volatile u32 reg = read(uart_base + OMAP_UART_MCR);
	reg |= OMAP_UART_TX_ENABLE;
	write(reg, uart_base + OMAP_UART_MCR);
}

static inline void uart_disable_tx(unsigned long uart_base)
{
	volatile u32 reg = read(uart_base + OMAP_UART_MCR);
	reg &= ~OMAP_UART_TX_ENABLE;
	write(reg, uart_base + OMAP_UART_MCR);

}

#define OMAP_UART_RX_ENABLE	(1 << 1)
static inline void uart_enable_rx(unsigned long uart_base)
{
	volatile u32 reg = read(uart_base + OMAP_UART_MCR);
	reg |= OMAP_UART_RX_ENABLE;
	write(reg, uart_base + OMAP_UART_MCR);
}

static inline void uart_disable_rx(unsigned long uart_base)
{
	volatile u32 reg = read(uart_base + OMAP_UART_MCR);
	reg &= ~OMAP_UART_RX_ENABLE;
	write(reg, uart_base + OMAP_UART_MCR);
}

#define OMAP_UART_STOP_BITS_MASK	(1 << 2)
static inline void uart_set_stop_bits(unsigned long uart_base, int bits)
{
	volatile u32 reg = read(uart_base + OMAP_UART_LCR);
	reg &= ~OMAP_UART_STOP_BITS_MASK;
	reg |= (bits << 2);
	write(reg, uart_base + OMAP_UART_LCR);
}

#define OMAP_UART_DATA_BITS_MASK	(0x3)
static inline void uart_set_data_bits(unsigned long uart_base, int bits)
{
	volatile u32 reg = read(uart_base + OMAP_UART_LCR);
	reg &= ~OMAP_UART_DATA_BITS_MASK;
	reg |= bits;
	write(reg, uart_base + OMAP_UART_LCR);
}

#define OMAP_UART_PARITY_ENABLE		(1 << 3)
static inline void uart_enable_parity(unsigned long uart_base)
{
	volatile u32 reg = read(uart_base + OMAP_UART_LCR);
	reg |= OMAP_UART_PARITY_ENABLE;
	write(reg, uart_base + OMAP_UART_LCR);
}

static inline void uart_disable_parity(unsigned long uart_base)
{
	volatile u32 reg = read(uart_base + OMAP_UART_LCR);
	reg &= ~OMAP_UART_PARITY_ENABLE;
	write(reg, uart_base + OMAP_UART_LCR);
}

#define OMAP_UART_PARITY_EVEN		(1 << 4)
static inline void uart_set_even_parity(unsigned long uart_base)
{
	volatile u32 reg = read(uart_base + OMAP_UART_LCR);
	reg |= OMAP_UART_PARITY_EVEN;
	write(reg, uart_base + OMAP_UART_LCR);
}

static inline void uart_set_odd_parity(unsigned long uart_base)
{
	volatile u32 reg = read(uart_base + OMAP_UART_LCR);
	reg &= ~OMAP_UART_PARITY_EVEN;
	write(reg, uart_base + OMAP_UART_LCR);
}

static inline void uart_select_mode(unsigned long uart_base, int mode)
{
	write(mode, uart_base + OMAP_UART_MDR1);
}

#define OMAP_UART_INTR_EN	1
static inline void uart_enable_interrupt(unsigned long uart_base)
{
	write(OMAP_UART_INTR_EN, uart_base + OMAP_UART_IER);
}

static inline void uart_disable_interrupt(unsigned long uart_base)
{
	write((~OMAP_UART_INTR_EN), uart_base + OMAP_UART_IER);
}

static inline void uart_set_link_control(unsigned long uart_base, int mode)
{
	write(mode, uart_base + OMAP_UART_LCR);
}

#endif /* __OMAP_UART_H__ */
