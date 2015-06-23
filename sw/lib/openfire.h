/* peripherals address and configurations */
/* basic i/o */
/* openfire soc - 20070327 - a.anton */

#ifndef __OPENFIRE_H
#define __OPENFIRE_H

#define SP3SK_GPIO		0x08000000L

#define SP3SK_GPIO_SEGMENTS_N	0x000000FFL
#define SP3SK_GPIO_DRIVERS_N    0x00000F00L
#define SP3SK_GPIO_PUSHBUTTONS	0x0000F000L
#define SP3SK_GPIO_LEDS		0x00FF0000L
#define SP3SK_GPIO_SWITCHES	0xFF000000L

#define UARTS_STATUS_REGISTER   0x08000004L

#define UART1_DATA_PRESENT      0x00000001L
#define UART1_RX_HALF_FULL	0x00000002L
#define UART1_RX_FULL		0x00000004L
#define UART1_TX_HALF_FULL	0x00000008L
#define UART1_TX_BUFFER_FULL    0x00000010L

#define UART2_DATA_PRESENT	0x00010000L
#define UART2_RX_HALF_FULL	0x00020000L
#define UART2_RX_FULL		0x00040000L
#define UART2_TX_HALF_FULL	0x00080000L
#define UART2_TX_FULL		0x00100000L

#define UART1_TXRX_DATA         0x08000008L
#define UART2_TXRX_DATA		0x0800000CL

#define PROM_READER		0x08000010L
#define PROM_DATA		0x000000FFL
#define PROM_REQUEST_SYNC	0x00000100L
#define PROM_REQUEST_DATA	0x00000200L
#define PROM_SYNCED		0x00000400L
#define PROM_DATA_READY		0x00000800L

#define TIMER1_PORT		0x08000014L
#define TIMER1_VALUE		0x7FFFFFFFL
#define TIMER1_CONTROL		0x80000000L

#define INTERRUPT_ENABLE	0x08000018L
#define INTERRUPT_TIMER1	0x00000001L
#define INTERRUPT_UART1_RX	0x00000002L
#define INTERRUPT_UART2_RX	0x00000004L

unsigned char inbyte(void);
int outbyte( unsigned char c);
int havebyte(void);

char *gethexstring(char *string, unsigned *value, unsigned maxdigits);
void puthexstring(char *string, unsigned number, unsigned size);

void uart1_printchar(unsigned char c);
void uart1_printline(char *txt);
char uart1_readchar(void);
void uart1_readline(char *buffer);

int *__errno(void);

#endif
