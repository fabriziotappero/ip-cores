
#include "uart.h"

#define UART_RX_BUFFER_EXIST (uart->rx.wp!=uart->rx.rp)
#define UART_TX_BUFFER_EXIST (uart->tx.wp!=uart->tx.rp)

#define UART_RX_BUFFER_EMPTY (uart->rx.wp==uart->rx.rp)
#define UART_TX_BUFFER_EMPTY (uart->tx.wp==uart->tx.rp)

#define UART_RX_BUFFER_CLEAR \
	uart->rx.wp=0; \
	uart->rx.rp=0;
#define UART_TX_BUFFER_CLEAR \
       	uart->tx.wp=0; \
       	uart->tx.rp=0;

#define UART_RX_BUFFER_FULL  ( ( ( uart->rx.buf_size - 1 == uart->rx.wp ) ? 0:  uart->rx.wp + 1) == uart->rx.rp )
#define UART_TX_BUFFER_FULL  ( ( ( uart->tx.buf_size - 1 == uart->tx.wp ) ? 0:  uart->tx.wp + 1) == uart->tx.rp )

#define UART_TX_BUFFER_WRITE \
	uart->tx.buf[ uart->tx.wp ].data = data; \
	uart->tx.wp = ( uart->tx.buf_size - 1 == uart->tx.wp ) ? 0: uart->tx.wp + 1;
#define UART_TX_BUFFER_READ \
	ret = uart->tx.buf[ uart->tx.rp ].data; \
	uart->tx.rp = ( uart->tx.buf_size - 1 == uart->tx.rp) ? 0: uart->tx.rp + 1;

#define UART_RX_BUFFER_WRITE \
	uart->rx.buf [ uart->rx.wp ].data = data; \
	uart->rx.wp = ( uart->rx.buf_size - 1 == uart->rx.wp ) ? 0: uart->rx.wp + 1;
#define UART_RX_BUFFER_READ \
	ret = uart->rx.buf[ uart->rx.rp ].data; \
	uart->rx.rp = ( uart->rx.buf_size - 1 == uart->rx.rp) ? 0: uart->rx.rp + 1;

void uart_init(UART *uart,unsigned long int base,unsigned long int irq){
        int devisor;

	/* new */
	/* init */
	uart->base		= base; /* not-use */
	uart->irq		= irq;
	uart->tx.wp		= 0;
	uart->tx.rp		= 0;
	uart->rx.wp		= 0;
	uart->rx.rp		= 0;
	uart->info_add_iir	= base + UART_IIR;
	uart->info_add_msr	= base + UART_MSR;
	uart->info_add_ier	= base + UART_IER;
	uart->info_add_lsr	= base + UART_LSR;
	uart->info_add_tx	= base + UART_TX;
	uart->info_add_rx	= base + UART_RX;
	uart->info_add_mcr	= base + UART_MCR;
	uart->modemstatus	= 0xffffffff;
	uart->linestatus	= 0xffffffff;

	/* Reset receiver and transmiter */
        REG8(base + UART_FCR) = UART_FCR_ENABLE_FIFO | UART_FCR_CLEAR_RCVR | UART_FCR_CLEAR_XMIT | UART_FCR_TRIGGER_14;
	/* enable rx interrupts */
	//REG8(base + UART_IER) = 0x01; // InterruptEnable:RxOnly(next)
	REG8(base + UART_IER) = 0x09; // InterruptEnable:RxOnly(next)&ModemStatus
	//REG8(base + UART_IER) = 0x0d; // InterruptEnable:RxOnly(next)&ModemStatus&linestatus

        REG8(base + UART_FCR) = 0x00;
	/* Set 8 bit char, 1 stop bit, no parity */
        REG8(uart->base + UART_LCR) = UART_LCR_WLEN8 & ~(UART_LCR_STOP | UART_LCR_PARITY);
	/* Set baud rate */
        devisor = UART_IN_CLK/(16 * UART_BAUD_RATE);
        REG8(base + UART_LCR) |= UART_LCR_DLAB;
        REG8(base + UART_DLL) = devisor & 0x000000ff;
        REG8(base + UART_DLM) = (devisor >> 8) & 0x000000ff;
        REG8(base + UART_LCR) &= ~(UART_LCR_DLAB);

	/* DTR RTS */
	REG8(base + UART_MCR) = 0x00000003; // (DTR RTS inactive)
	REG8(base + UART_MCR) = 0x00000001; // (only DTR inactive)

	/* add interrupt handler */
	int_add(irq,&uart_handler,(void *)uart);

	return;
}

void uart_handler(void *argv){
	UART *uart;
	unsigned char iir;
	// handler pointer is uart.
	uart = (UART *)argv;
	// Interrupt status check
	iir = REG8(uart->info_add_iir);
	iir = (iir>>1) & 0x03; //mask
	switch (iir) {
		case 0x00: // ModemStatus(CTS,DSR,RI,DCD)
			uart->modemstatus = (unsigned long int)REG8(uart->info_add_msr); // read
		break;
		case 0x01: // TxReady
			if ( UART_TX_BUFFER_EXIST ) {
				unsigned char ret;
				UART_TX_BUFFER_READ
				REG8(uart->info_add_tx) = ret;
			}
			else {
				//REG8(uart->info_add_ier) = 0x01; // InterruptEnable:RxOnly(next)
				REG8(uart->info_add_ier) = 0x09; // InterruptEnable:RxOnly(next)&ModemStatus
				//REG8(uart->info_add_ier) = 0x0d; // InterruptEnable:RxOnly(next)&ModemStatus&linestatus
			}
		break;
		case 0x02: // RxReady
			if (0x01==0x01&REG8(uart->info_add_lsr)) {
				unsigned char data;
				data = REG8(uart->base + UART_RX);
				UART_RX_BUFFER_WRITE
			}
		break;
		case 0x03: // LineStatus(Parity,Overrun...)
			uart->linestatus = (unsigned long int)REG8(uart->info_add_lsr); // read
		break;
	}
	return;
}

//
// RX
//
unsigned char uart_get(UART *uart){
	unsigned char ret;
int_disable(uart->irq);
	UART_RX_BUFFER_READ
int_enable(uart->irq);
	return ret;
}
unsigned long int uart_get_exist(UART *uart){
	unsigned long int ret;
int_disable(uart->irq);
	ret = UART_RX_BUFFER_EXIST;
int_enable(uart->irq);
	return ret;
}
void uart_get_clear(UART *uart){
	unsigned long int ret;
int_disable(uart->irq);
	UART_RX_BUFFER_CLEAR;
int_enable(uart->irq);
	return;
}

//
// TX
//
void uart_put(UART *uart,unsigned char data){
	while (uart_put_full(uart)) {} // blocking
int_disable(uart->irq);
	UART_TX_BUFFER_WRITE
	//REG8(uart->info_add_ier) = 0x03; // InterruptEnable:Tx&Rx
	REG8(uart->info_add_ier) = 0x0b; // InterruptEnable:Tx&Rx&ModemStatus
	//REG8(uart->info_add_ier) = 0x0f; // InterruptEnable:Tx&Rx&ModemStatus&linestatus
int_enable(uart->irq);
	return;
}
unsigned long int uart_put_full(UART *uart){
	unsigned long int ret;
int_disable(uart->irq);
	ret = UART_TX_BUFFER_FULL;
int_enable(uart->irq);
	return ret;
}
void uart_put_clear(UART *uart){
	unsigned long int ret;
int_disable(uart->irq);
	UART_TX_BUFFER_CLEAR;
int_enable(uart->irq);
	return;
}
void uart_put_string(UART *uart,unsigned char *string){
	unsigned char *p;
	for (p=string;*p!='\0';p++) uart_put(uart,*p);
	return;
}

//
// STATUS
//
static unsigned long int uart_get_modemstatus(UART *uart){
	unsigned long int ret;
int_disable(uart->irq);
	ret = uart->modemstatus;
int_enable(uart->irq);
	return ret;
}
static unsigned long int uart_get_linestatus(UART *uart){
	unsigned long int ret;
int_disable(uart->irq);
	ret = uart->linestatus;
int_enable(uart->irq);
	return ret;
}
unsigned long int uart_is_cts(UART *uart){
	return !( uart_get_modemstatus(uart) & 0x00000010 );
}
unsigned long int uart_is_dsr(UART *uart){
	return !( uart_get_modemstatus(uart) & 0x00000020 );
}
unsigned long int uart_is_ri(UART *uart){
	return !( uart_get_modemstatus(uart) & 0x00000040 );
}
unsigned long int uart_is_dcd(UART *uart){
	return !( uart_get_modemstatus(uart) & 0x00000080 );
}

//
// MCR(DTR RTS)
//
static void uart_set_mcr(UART *uart,unsigned long int data){
int_disable(uart->irq);
	REG8(uart->info_add_mcr) = REG8(uart->info_add_mcr) | data;
int_enable(uart->irq);
	return;
}
static void uart_unset_mcr(UART *uart,unsigned long int data){
	unsigned long int ret;
int_disable(uart->irq);
	REG8(uart->info_add_mcr) = REG8(uart->info_add_mcr) & (~data);
int_enable(uart->irq);
	return;
}
void uart_dtr(UART *uart,unsigned long int data){
	if (!data)	uart_set_mcr(uart,0x00000001);
	else		uart_unset_mcr(uart,0x00000001);
	return;
}
void uart_rts(UART *uart,unsigned long int data){
	if (!data)	uart_set_mcr(uart,0x00000002);
	else		uart_unset_mcr(uart,0x00000002);
	return;
}


