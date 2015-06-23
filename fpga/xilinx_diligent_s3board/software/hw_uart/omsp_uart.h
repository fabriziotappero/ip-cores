#ifndef OMSP_UART_H
#define OMSP_UART_H

#include <io.h>
#include <signal.h>
#include <iomacros.h>

//--------------------------------------------------
// Hardware UART register address mapping
//--------------------------------------------------

#define UART_CTL_           0x0080  // UART Control register (8bit)
sfrb(UART_CTL,UART_CTL_);

#define UART_STAT_          0x0081  // UART Status register (8bit)
sfrb(UART_STAT,UART_STAT_);

#define UART_BAUD_          0x0082  // UART Baud rate configuration (16bit)
sfrw(UART_BAUD,UART_BAUD_);

#define UART_TXD_           0x0084  // UART Transmit data register (8bit)
sfrb(UART_TXD,UART_TXD_);

#define UART_RXD_           0x0085  // UART Receive data register (8bit)
sfrb(UART_RXD,UART_RXD_);


//--------------------------------------------------
// Hardware UART register field mapping
//--------------------------------------------------

// UART Control register fields
#define  UART_IEN_TX_EMPTY  0x80
#define  UART_IEN_TX        0x40
#define  UART_IEN_RX_OVFLW  0x20
#define  UART_IEN_RX        0x10
#define  UART_SMCLK_SEL     0x02
#define  UART_EN            0x01

// UART Status register fields
#define  UART_TX_EMPTY_PND  0x80
#define  UART_TX_PND        0x40
#define  UART_RX_OVFLW_PND  0x20
#define  UART_RX_PND        0x10
#define  UART_TX_FULL       0x08
#define  UART_TX_BUSY       0x04
#define  UART_RX_BUSY       0x01


//--------------------------------------------------
// Hardware UART interrupt mapping
//--------------------------------------------------

#define UART_TX_VECTOR      (6 *2) // Interrupt vector 6  (0xFFEC)
#define UART_RX_VECTOR      (7 *2) // Interrupt vector 7  (0xFFEE)


#endif
