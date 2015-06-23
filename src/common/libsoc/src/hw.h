/**
    @file hw.h
    @brief Declarations for the hardware-dependent part of the library.

    The library is not meant to be ported across architectures; but it is 
    meant to be ported to different FPGA projects using the Ion CPU core.
*/

#ifndef HW_H_INCLUDED
#define HW_H_INCLUDED

/*-- Hardware configuration (other than memory map) --------------------------*/

#define UART_TX             (0x20000000)    /**< Addr of TX buffer */
#define UART_RX             (0x20000000)    /**< Addr of RX buffer */
#define UART_STATUS         (0x20000004)    /**< Addr of status register */
#define UART_RXRDY_MASK     (0x00000002)    /**< Flag mask for 'RX ready' */
#define UART_TXRDY_MASK     (0x00000001)    /**< Flag mask for 'TX ready' */

#define GPIO_P0             (0x20001000)    /**< P0 output register */
#define GPIO_P1             (0x20001004)    /**< P1 input register */

#define WRPORT(p,v)         *((volatile unsigned int *)(GPIO_P0+(p*4)))=v
#define RDPORT(p)           (*((volatile unsigned int *)(GPIO_P0+(p*4))))    

#endif // HW_H_INCLUDED
