#include "xparameters.h"

#define XSS_CR				(XPAR_OPB_SPI_SLAVE_0_BASEADDR + (4* 0x00))
#define XSS_SR   			(XPAR_OPB_SPI_SLAVE_0_BASEADDR + (4* 0x01))
#define XSS_TD   			(XPAR_OPB_SPI_SLAVE_0_BASEADDR + (4* 0x02))
#define XSS_RD   			(XPAR_OPB_SPI_SLAVE_0_BASEADDR + (4* 0x03))
#define XSS_TX_THRESH  	(XPAR_OPB_SPI_SLAVE_0_BASEADDR + (4* 0x04))
#define XSS_RX_THRESH  	(XPAR_OPB_SPI_SLAVE_0_BASEADDR + (4* 0x05))
#define XSS_TX_DMA_CTL  (XPAR_OPB_SPI_SLAVE_0_BASEADDR + (4* 0x06))
#define XSS_TX_DMA_ADR  (XPAR_OPB_SPI_SLAVE_0_BASEADDR + (4* 0x07))
#define XSS_TX_DMA_NUM  (XPAR_OPB_SPI_SLAVE_0_BASEADDR + (4* 0x08))
#define XSS_RX_DMA_CTL  (XPAR_OPB_SPI_SLAVE_0_BASEADDR + (4* 0x09))
#define XSS_RX_DMA_ADR  (XPAR_OPB_SPI_SLAVE_0_BASEADDR + (4* 0x0A))
#define XSS_RX_DMA_NUM  (XPAR_OPB_SPI_SLAVE_0_BASEADDR + (4* 0x0B))

#define XSS_DGIE			(XPAR_OPB_SPI_SLAVE_0_BASEADDR + (4* 0x10))
#define XSS_IPISR			(XPAR_OPB_SPI_SLAVE_0_BASEADDR + (4* 0x11))
#define XSS_IPIER			(XPAR_OPB_SPI_SLAVE_0_BASEADDR + (4* 0x12))

//XSS_SPI_CR
#define XSS_CR_SPE_MASK		(0x01)
#define XSS_CR_TX_EN_MASK	(0x02)
#define XSS_CR_RX_EN_MASK	(0x04)
#define XSS_CR_RESET_MASK	(0x08)

//XSS_SPI
// Transmit
#define XSS_SR_TX_PROG_FULL_MASK		0x0001
#define XSS_SR_TX_FULL_MASK			0x0002
#define XSS_SR_TX_OVERFLOW_MASK		0x0004
#define XSS_SR_TX_PROG_EMPTY_MASK	0x0008
#define XSS_SR_TX_EMPTY_MASK			0x0010
#define XSS_SR_TX_UNDERFLOW_MASK		0x0020
// Receive
#define XSS_SR_RX_PROG_FULL_MASK		0x0040
#define XSS_SR_RX_FULL_MASK			0x0080
#define XSS_SR_RX_OVERFLOW_MASK		0x0100
#define XSS_SR_RX_PROG_EMPTY_MASK	0x0200
#define XSS_SR_RX_EMPTY_MASK			0x0400
#define XSS_SR_RX_UNDERFLOW_MASK		0x0800
// Chip Select
#define XSS_SR_CHIP_SELECT_MASK		0x1000
// DMA
#define XSS_SR_TX_DMA_done				0x2000
#define XSS_SR_RX_DMA_done				0x4000


// Device Global Interrupt Enable
#define XSS_DGIE_Bit_Enable			0x0001

// Interrupt /Enable Status Register
#define XSS_ISR_Bit_TX_Prog_Empty 	0x0001
#define XSS_ISR_Bit_TX_Empty      	0x0002
#define XSS_ISR_Bit_TX_Underflow  	0x0004
#define XSS_ISR_Bit_RX_Prog_Full  	0x0008
#define XSS_ISR_Bit_RX_Full       	0x0010
#define XSS_ISR_Bit_RX_Overflow   	0x0020
#define XSS_ISR_Bit_SS_Fall       	0x0040
#define XSS_ISR_Bit_SS_Rise       	0x0080
#define XSS_ISR_Bit_TX_DMA_done		0x0100
#define XSS_ISR_Bit_RX_DMA_done		0x0200

// TX DMA Control Register
#define XSS_TX_DMA_CTL_EN				0x0001

// RX DMA Control Register
#define XSS_RX_DMA_CTL_EN				0x0001
