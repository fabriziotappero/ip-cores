#ifndef _BOARD_H_
#define _BOARD_H_

#define MC_ENABLED		1
#define IC_ENABLE		0
#define IC_SIZE			8192
#define DC_ENABLE		0
#define DC_SIZE			8192

#define MC_CSR_VAL		0x0B000300
#define MC_MASK_VAL		0x000000e0
#define FLASH_BASE_ADDR		0x04000000
#define FLASH_SIZE		0x02000000
#define FLASH_BLOCK_SIZE	0x20000
#define FLASH_TMS_VAL		0x00102102
#define SDRAM_BASE_ADDR		0x00000000
#define SDRAM_TMS_VAL		0x07248230

#define IN_CLK			30000000
#define TICKS_PER_SEC		100
//#define STACK_SIZE		0x1000
#define STACK_SIZE		0x8000
#define UART_BAUD_RATE		115200

#define UART_BASE		0x90000000
#define UART_IRQ		19
#define ETH_BASE		0xD0000000
#define ETH_IRQ			15

#define MC_BASE_ADDR   0x60000000
#define SD_BASE        0x9e000000
#define USB_HOST_BASE  0x9d000000
#define USB_SLAVE_BASE 0x94000000

/* Register access macros */
#define REG8(add)		*((volatile unsigned char *)(add))
#define REG16(add)		*((volatile unsigned short *)(add))
#define REG32(add)		*((volatile unsigned long *)(add))

#endif
