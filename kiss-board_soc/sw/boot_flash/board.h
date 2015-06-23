#ifndef _BOARD_H_
#define _BOARD_H_

#ifdef XESS
#define MC_ENABLED	    0
#else
#define MC_ENABLED	    1
#endif

#define IC_ENABLE 	    0
#define IC_SIZE         8192
#define DC_ENABLE 	    0
#define DC_SIZE         8192

#define MC_CSR_VAL      0x0B000300
#define MC_MASK_VAL     0x000003ff
#define FLASH_BASE_ADDR 0x04000000
#define FLASH_SIZE      0x02000000
#define FLASH_BLOCK_SIZE 0x20000
#define FLASH_TMS_VAL   0x19220057
#define SDRAM_BASE_ADDR 0x00000000
#define SDRAM_TMS_VAL   0x00000103

//#ifdef XESS
//#define IN_CLK		10000000
//#else
//#define IN_CLK		25000000
//#endif
#define IN_CLK 20000000

#define TICKS_PER_SEC   100

#define STACK_SIZE	    0x10000

//#ifdef XESS
//#define UART_BAUD_RATE 	19200
//#else
//#define UART_BAUD_RATE	57600
//#endif
#define UART_BAUD_RATE  192000

#define UART_BASE  	    0x90000000
//#define UART_IRQ        19
#ifdef XESS
#define ETH_BASE       	0x92000000
#else
#define ETH_BASE        0xD0000000
#endif
#define ETH_IRQ         15
#define MC_BASE_ADDR    0x60000000
#define SPI_BASE        0xa0000000

#ifdef XESS
 #define ETH_DATA_BASE  0x00100000 /*  Address for ETH_DATA */
#else
 #define ETH_DATA_BASE  0xa8000000 /*  Address for ETH_DATA */
#endif

#define BOARD_DEF_IP	  0x0a010185
#define BOARD_DEF_MASK	0xff000000
#define BOARD_DEF_GW  	0x0a010101

#define ETH_MACADDR0	  0x00
#define ETH_MACADDR1	  0x12
#define ETH_MACADDR2  	0x34
#define ETH_MACADDR3	  0x56
#define ETH_MACADDR4  	0x78
#define ETH_MACADDR5	  0x9a

#define CRT_ENABLED	    1
#define CRT_BASE_ADDR  	0xc0000000
#define FB_BASE_ADDR	  0xa8000000

/* Whether online help is available -- saves space */
#define HELP_ENABLED	 1

/* Whether self check is enabled */
#define SELF_CHECK     1

/* Whether we have keyboard suppport */
#define KBD_ENABLED    1

/* Keyboard base address */
#define KBD_BASE_ADD   0x98000000

#define KBD_IRQ        12

/* Keyboard buffer size */
#define KBDBUF_SIZE    256

/* Which console is used (CT_NONE, CT_SIM, CT_UART, CT_CRT) */
#define CONSOLE_TYPE   CT_UART

#endif
