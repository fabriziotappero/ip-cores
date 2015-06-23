#ifndef _BOARD_H_
#define _BOARD_H_

#define MC_ENABLED	    0

#define IC_ENABLE 	    0
#define IC_SIZE         8192
#define DC_ENABLE 	    0
#define DC_SIZE         8192


#define IN_CLK  	      50000000

#define TICKS_PER_SEC   100

#define STACK_SIZE	    0x01000

#define UART_BAUD_RATE 	115200

//#define UART_BASE  	    0xB0000000
#define UART_BASE  	    0x9E000000
//#define UART_IRQ        6
#define UART_IRQ        2
#define ETH_BASE        0x92000000
#define ETH_IRQ         4
#define MC_BASE_ADDR    0x60000000
#define SPI_BASE        0xa0000000

#define ETH_DATA_BASE  0xa8000000 /*  Address for ETH_DATA */

#define BOARD_DEF_IP	  0x0a010185
#define BOARD_DEF_MASK	0xff000000
#define BOARD_DEF_GW  	0x0a010101

#define ETH_MACADDR0	  0x00
#define ETH_MACADDR1	  0x12
#define ETH_MACADDR2  	0x34
#define ETH_MACADDR3	  0x56
#define ETH_MACADDR4  	0x78
#define ETH_MACADDR5	  0x9a


/* Whether online help is available -- saves space */
#define HELP_ENABLED	 1

/* Whether self check is enabled */
#define SELF_CHECK     1

#endif
