#include "../lib/storm_core.h"
#include "../lib/storm_soc_basic.h"
#include "../lib/io_driver.c"
#include "../lib/utilities.c"
#include "../lib/uart.c"

// +------------------------------+
// |    Simple Program Demo       |
// +------------------------------+

// This program uses the system timer to toggle LED(0) of the System IO
// port every second. Also a demo output to the terminal is made.
// Received UART transmission are echoed.


/* ---- IRQ: Timer ISR ---- */
void __attribute__ ((interrupt("IRQ"))) timer0_isr(void)
{
	// toggle status led
	set_syscpreg((get_syscpreg(SYS_IO) ^ 0x01), SYS_IO);

	// acknowledge interrupt
	VICVectAddr = 0;
}


/* ---- Main function ---- */
int main(void)
{
	int temp;

	// timer init
	STME0_CNT  = 0;
	STME0_VAL  = 50000000; // threshold value for 1s ticks
	STME0_CONF = (1<<2) | (1<<1) | (1<<0); // interrupt en, auto reset, timer enable
	VICVectAddr0 = (unsigned long)timer0_isr;
	VICVectCntl0 = (1<<5) | 0; // enable and channel select = 0 (timer0)
	VICIntEnable = (1<<0); // enable channel 0 (timer0)
	io_enable_xint(); // enable IRQ

	// Intro
	uart0_printf("\r\n\r\nSTORM SoC Basic Configuration\r\n");
	uart0_printf("Demo program\r\n\r\n");

	uart0_printf("Press any key!\r\n");

	// echo received char
	while(1){
		temp = io_uart0_read_byte();
		if (temp != -1)
			io_uart0_send_byte(temp);
	}

}
