
#ifndef __NET_H
#define __NET_H

// BASE
#define NET_BASE			0x04400000
#define NET_CR				0x00000000
#define NET_DMA				0x00000010
#define NET_RESET			0x00000018

// PAGE0
#define NET_P0_PSTART			0x00000001
#define NET_P0_PSTOP			0x00000002
#define NET_P0_BNRY			0x00000003
#define NET_P0_TPSR			0x00000004
#define NET_P0_TBCR0			0x00000005
#define NET_P0_TBCR1			0x00000006
#define NET_P0_ISR			0x00000007
#define NET_P0_RSAR0			0x00000008
#define NET_P0_RSAR1			0x00000009
#define NET_P0_RBCR0			0x0000000a
#define NET_P0_RBCR1			0x0000000b
#define NET_P0_RCR			0x0000000c
#define NET_P0_TCR			0x0000000d
#define NET_P0_DCR			0x0000000e
#define NET_P0_IMR			0x0000000f

// PAGE1
#define NET_P1_PAR0			0x00000001
#define NET_P1_PAR1			0x00000002
#define NET_P1_PAR2			0x00000003
#define NET_P1_PAR3			0x00000004
#define NET_P1_PAR4			0x00000005
#define NET_P1_PAR5			0x00000006
#define NET_P1_CURR			0x00000007
#define NET_P1_MAR0			0x00000008
#define NET_P1_MAR1			0x00000009
#define NET_P1_MAR2			0x0000000a
#define NET_P1_MAR3			0x0000000b
#define NET_P1_MAR4			0x0000000c
#define NET_P1_MAR5			0x0000000d
#define NET_P1_MAR6			0x0000000e
#define NET_P1_MAR7			0x0000000f

// CR
#define NET_CR_PAGE_0			0x00<<6
#define NET_CR_PAGE_1			0x01<<6
#define NET_CR_PAGE_2			0x02<<6
#define NET_CR_PAGE_3			0x03<<6
#define NET_CR_DMA_DISABLE		0x00<<3
#define NET_CR_DMA_READ			0x01<<3
#define NET_CR_DMA_WRITE		0x02<<3
#define NET_CR_DMA_PACKET		0x03<<3
#define NET_CR_DMA_ABORT		0x04<<3
#define NET_CR_SEND			0x01<<2
#define NET_CR_START			0x01<<1
#define NET_CR_STOP			0x01<<0

// DCR
#define NET_DCR_FIFO_2			0x00<<5
#define NET_DCR_FIFO_4			0x01<<5
#define NET_DCR_FIFO_8			0x02<<5
#define NET_DCR_FIFO_12			0x03<<5
#define NET_DCR_AUTOINIT		0x01<<4
#define NET_DCR_LOOPBACK		0x01<<3
#define NET_DCR_LONG_32			0x01<<2
#define NET_DCR_ENDIAN_BIG		0x01<<1
#define NET_DCR_WORD			0x01<<0 
// RCR
#define NET_RCR_MONITOR			0x01<<5
#define NET_RCR_ALL			0x01<<4
#define NET_RCR_MULTICAST		0x01<<3
#define NET_RCR_BOARDCAST		0x01<<2
#define NET_RCR_SHORT			0x01<<1
#define NET_RCR_ERROR			0x01<<0
// TCR
#define NET_TCR_DOWN_PRIORITY		0x01<<4
#define NET_TCR_AUTOSEND_DISABLE	0x01<<3
#define NET_TCR_LOOPBACK_NORMAL		0x00<<1
#define NET_TCR_LOOPBACK_INTERNAL	0x01<<1
#define NET_TCR_LOOPBACK_ENCDEC		0x02<<1
#define NET_TCR_LOOPBACK_EXTERNAL	0x03<<1
#define NET_TCR_CRC_DISABLE		0x01<<0
// IMR
#define NET_IMR_DMA			0x01<<6
#define NET_IMR_COUNTEROF		0x01<<5
#define NET_IMR_RXOF			0x01<<4
#define NET_IMR_TXERR			0x01<<3
#define NET_IMR_RXERR			0x01<<2
#define NET_IMR_TX			0x01<<1
#define NET_IMR_RX			0x01<<0
// ISR
#define NET_ISR_DMA			0x01<<6
#define NET_ISR_COUNTEROF		0x01<<5
#define NET_ISR_RXOF			0x01<<4
#define NET_ISR_TXERR			0x01<<3
#define NET_ISR_RXERR			0x01<<2
#define NET_ISR_TX			0x01<<1
#define NET_ISR_RX			0x01<<0

// public
void net_init(void) __attribute__ ((section(".text")));
void net_send(void) __attribute__ ((section(".text")));
void net_recv(void) __attribute__ ((section(".text")));

// private

#endif

