#ifndef HARDWARE_H
#define HARDWARE_H


//--------------------------------------------------
// Hardware UART register address mapping
//--------------------------------------------------

#define UART_CTL          (*(volatile unsigned char *) 0x0080)  // UART Control register (8bit)
#define UART_STAT         (*(volatile unsigned char *) 0x0081)  // UART Status register (8bit)
#define UART_BAUD         (*(volatile unsigned int  *) 0x0082)  // UART Baud rate configuration (16bit)
#define UART_TXD          (*(volatile unsigned char *) 0x0084)  // UART Transmit data register (8bit)
#define UART_RXD          (*(volatile unsigned char *) 0x0085)  // UART Receive data register (8bit)


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


//--------------------------------------------------
// Diverse
//--------------------------------------------------

// BAUD = (mclk_freq/baudrate)-1

//#define BAUD           2083            //   9600  @20.0MHz
//#define BAUD           1042            //  19200  @20.0MHz
//#define BAUD            521            //  38400  @20.0MHz
//#define BAUD            347            //  57600  @20.0MHz
#define BAUD            174            // 115200  @20.0MHz
//#define BAUD             87            // 230400  @20.0MHz




#endif //HARDWARE_H
