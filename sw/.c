#include "../support/support.h"
#include "../support/board.h"
#include "../support/uart.h"

#include "../support/spr_defs.h"

#include "eth.h"

void uart_print_str(char *);
void uart_print_long(unsigned long);

// Dummy or32 except vectors
void buserr_except(){}
void dpf_except(){}
void ipf_except(){}
void lpint_except(){}
void align_except(){}
void illegal_except(){}
/*void hpint_except(){

}*/
void dtlbmiss_except(){}
void itlbmiss_except(){}
void range_except(){}
void syscall_except(){}
void res1_except(){}
void trap_except(){}
void res2_except(){}


void uart_interrupt()
{
    char lala;
    unsigned char interrupt_id;
    interrupt_id = REG8(UART_BASE + UART_IIR);
    if ( interrupt_id & UART_IIR_RDI )
    {
        lala = uart_getc();
        uart_putc(lala+1);
    }

}


void uart_print_str(char *p)
{
        while(*p != 0) {
                uart_putc(*p);
                p++;
        }
}

void uart_print_long(unsigned long ul)
{
  int i;
  char c;

  
  uart_print_str("0x");
  for(i=0; i<8; i++) {

  c = (char) (ul>>((7-i)*4)) & 0xf;
  if(c >= 0x0 && c<=0x9)
    c += '0';
  else
    c += 'a' - 10;
  uart_putc(c);
  }

}

void uart_print_short(unsigned long ul)
{
  int i;
  char c;
  char flag=0;

  
  uart_print_str("0x");
  for(i=0; i<8; i++) {

  c = (char) (ul>>((7-i)*4)) & 0xf;
  if(c >= 0x0 && c<=0x9)
    c += '0';
  else
    c += 'a' - 10;
  if ((c != '0') || (i==7))
    flag=1;
  if(flag)
    uart_putc(c);
  }

}

int tx_done;
int rx_done;
int rx_len;
char tx_data[1536];     //max length
char rx_data[1536];

void eth_init()
{
	//TXEN & RXEN = 1; PAD & CRC = 1; FULLD = 1
	REG32(ETH_BASE + ETH_MODER) = ETH_TXEN | ETH_RXEN | ETH_PAD | ETH_CRCEN | ETH_FULLD;
	//PHY Address = 0x001
	REG32(ETH_BASE + ETH_MIIADDRESS) = 0x00000001;

	//enable all interrupts
	REG32(ETH_BASE + ETH_INT_MASK) = ETH_RXC | ETH_TXC | ETH_BUSY | ETH_RXE | ETH_RXB | ETH_TXE | ETH_TXB;

	//set MAC ADDRESS
	REG32(ETH_BASE + ETH_MAC_ADDR1) = OWN_MAC_ADDRESS >> 32;	//low word = mac address high word
	REG32(ETH_BASE + ETH_MAC_ADDR0) = OWN_MAC_ADDRESS;		//mac address rest

	//configure TXBD0
	REG32(ETH_BASE + ETH_TXBD0H) = tx_data;		//address used for tx_data
	REG32(ETH_BASE + ETH_TXBD0L) = TX_READY;	//length = 0 | PAD & CRC = 1 | IRQ & WR = 1

	//configure RXBD0
	REG32(ETH_BASE + ETH_RXBD0H) = rx_data;		//address used for tx_data
	REG32(ETH_BASE + ETH_RXBD0L) = RX_READY;	//len = 0 | IRQ & WR = 1 | EMPTY = 1

	//set txdata
	tx_data[0] = BROADCAST_ADDRESS >> 40;
	tx_data[1] = BROADCAST_ADDRESS >> 32;
	tx_data[2] = BROADCAST_ADDRESS >> 24;
	tx_data[3] = BROADCAST_ADDRESS >> 16;
	tx_data[4] = BROADCAST_ADDRESS >> 8;
	tx_data[5] = BROADCAST_ADDRESS;

	tx_data[6] = OWN_MAC_ADDRESS >> 40;
	tx_data[7] = OWN_MAC_ADDRESS >> 32;
	tx_data[8] = OWN_MAC_ADDRESS >> 24;
	tx_data[9] = OWN_MAC_ADDRESS >> 16;
	tx_data[10] = OWN_MAC_ADDRESS >> 8;
	tx_data[11] = OWN_MAC_ADDRESS;

	//erase interrupts
	REG32(ETH_BASE + ETH_INT_SOURCE) = ETH_RXC | ETH_TXC | ETH_BUSY | ETH_RXE | ETH_RXB | ETH_TXE | ETH_TXB;

    tx_done = 1;
    rx_done = 0;
    rx_len = 0;
}

void eth_send(int length)
{
    if (!tx_done)
        return;

    tx_done = 0;
	tx_data[12] = length >> 8;
	tx_data[13] = length;

	REG32(ETH_BASE + ETH_TXBD0L) = (( 0x0000FFFF & ( length + HDR_LEN ) ) << 16) | BD_SND;
}

void eth_receive()
{
    int i;
    uart_print_str("Length: \n");
    uart_print_long(rx_len - HDR_LEN - CRC_LEN);
    uart_print_str("\n");
    uart_print_str("Data: \n");
    for ( i = 0; i < rx_len - HDR_LEN - CRC_LEN; i++ )
    {
        uart_print_short(rx_data[i+HDR_LEN]);
//        uart_print_str("\n");
    }

    rx_done = 0;
    rx_len = 0;
}

void eth_interrupt()
{
    unsigned long source = REG32(ETH_BASE + ETH_INT_SOURCE);
    switch (source)
    {
        case ETH_TXB:
            tx_done = 1;
            //erase interrupt
            REG32(ETH_BASE + ETH_INT_SOURCE) |= ETH_TXB;
            break;

        case ETH_RXB:
            rx_done = 1;
            //erase interrupt
            REG32(ETH_BASE + ETH_INT_SOURCE) |= ETH_RXB;
            //accept further data (reset RXBD to empty)
            rx_len = (REG32(ETH_BASE + ETH_RXBD0L) >> 16);
            REG32(ETH_BASE + ETH_RXBD0L) = RX_READY;	//len = 0 | IRQ & WR = 1 | EMPTY = 1
            break;

        default:
            break;
    }
}

int main()
{
    unsigned long lalala;
	uart_init();

	int_init();
	int_add(UART_IRQ, &uart_interrupt);
	int_add(ETH_IRQ, &eth_interrupt);
	
	/* We can't use printf because in this simple example
	   we don't link C library. */
	uart_print_str("Hello World.\n\r");

	eth_init();

	tx_data[14] = 0xFF;
	tx_data[15] = 0x2B;
	tx_data[16] = 0x40;
	tx_data[17] = 0x50;

	eth_send(4);

    while(1)
    {
        if (rx_done)
        {
            eth_receive();
        }
    }
	
	report(0xdeaddead);
	or32_exit(0);
}

