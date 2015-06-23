/*--------------------------------------------------------------------
 * TITLE: Plasma Hardware Defines
 * AUTHOR: Steve Rhoads (rhoadss@yahoo.com)
 * DATE CREATED: 12/17/05
 * FILENAME: plasma.h
 * PROJECT: Plasma CPU core
 * COPYRIGHT: Software placed into the public domain by the author.
 *    Software 'as is' without warranty.  Author liable for nothing.
 * DESCRIPTION:
 *    Plasma Hardware Defines
 *--------------------------------------------------------------------*/
#ifndef __PLASMA_H__
#define __PLASMA_H__

/*********** Hardware addresses ***********/
#define RAM_INTERNAL_BASE 0x00000000 //8KB
#define RAM_EXTERNAL_BASE 0x10000000 //1MB or 64MB
#define RAM_EXTERNAL_SIZE 0x00100000
#define ETHERNET_RECEIVE  0x13ff0000
#define ETHERNET_TRANSMIT 0x13fe0000
#define MISC_BASE         0x20000000
#define UART_WRITE        0x20000000
#define UART_READ         0x20000000
#define IRQ_MASK          0x20000010
#define IRQ_STATUS        0x20000020
#define GPIO0_SET         0x20000030
#define GPIO0_CLEAR       0x20000040
#define GPIOA_IN          0x20000050
#define COUNTER_REG       0x20000060
#define ETHERNET_REG      0x20000070
#define FLASH_BASE        0x30000000

/*********** GPIO out bits ***************/
#define ETHERNET_MDIO     0x00200000
#define ETHERNET_MDIO_WE  0x00400000
#define ETHERNET_MDC      0x00800000
#define ETHERNET_ENABLE   0x01000000

/*********** Interrupt bits **************/
#define IRQ_UART_READ_AVAILABLE  0x01
#define IRQ_UART_WRITE_AVAILABLE 0x02
#define IRQ_COUNTER18_NOT        0x04
#define IRQ_COUNTER18            0x08
#define IRQ_ETHERNET_RECEIVE     0x10
#define IRQ_ETHERNET_TRANSMIT    0x20
#define IRQ_GPIO31_NOT           0x40
#define IRQ_GPIO31               0x80

#endif //__PLASMA_H__

