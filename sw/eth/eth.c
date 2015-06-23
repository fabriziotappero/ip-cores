#include <interconnect.h>
#include <support.h>
#include <or1200.h>
#include <int.h>

#include <uart.h>
#include <eth.h>


extern int eth_rx_len;
extern int eth_rx_done, eth_tx_done;
extern unsigned char * eth_rx_data;
extern unsigned char * eth_tx_data;

void eth_receive()
{
	int i;
	uart_print_str("Length: \n");
	uart_print_long(eth_rx_len);
	uart_print_str("\n");
	uart_print_str("Data: \n");
	for ( i = 0; i < eth_rx_len; i++ )
	{
		uart_print_short(eth_rx_data[i]);
		uart_print_str("\n");
	}
	eth_recv_ack();
}

int main()
{
	uart_init(UART_BASE);

	int_init();
	eth_init();
	int_add(UART_IRQ, &uart_interrupt, NULL);
	int_add(ETH_IRQ, &eth_interrupt, NULL);

	/* We can't use printf because in this simple example
	   we don't link C library. */
	uart_print_str("Hello World.\n");

	eth_tx_data[0] = 0xFF;
	eth_tx_data[1] = 0x2B;
	eth_tx_data[2] = 0x40;
	eth_tx_data[3] = 0x50;

	eth_send(4);

	while(1)
	{
		if (eth_rx_done)
		{
			eth_receive();
		}
	}

	report(0xdeaddead);
	or32_exit(0);
}

