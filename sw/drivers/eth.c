#include <support.h>
#include "interconnect.h"
#include "eth.h"

int eth_tx_done;
int eth_rx_done;
int eth_rx_len;
unsigned char eth_tx_packet[1536];     //max length
unsigned char eth_rx_packet[1536];
unsigned char * eth_tx_data;
unsigned char * eth_rx_data;

void eth_recv_ack(void)
{
	eth_rx_done = 0;
	eth_rx_len = 0;
	//accept further data (reset RXBD to empty)
	REG32(ETH_BASE + ETH_RXBD0L) = RX_READY;	//len = 0 | IRQ & WR = 1 | EMPTY = 1    
}

void eth_init()
{
	//TXEN & RXEN = 1; PAD & CRC = 1; FULLD = 1
	REG32(ETH_BASE + ETH_MODER) = ETH_TXEN | ETH_RXEN | ETH_PAD | ETH_CRCEN | ETH_FULLD;
	//PHY Address = 0x001
	REG32(ETH_BASE + ETH_MIIADDRESS) = 0x00000001;

	//enable all interrupts
	REG32(ETH_BASE + ETH_INT_MASK) = ETH_RXB | ETH_TXB;

	//set MAC ADDRESS
	REG32(ETH_BASE + ETH_MAC_ADDR1) = (OWN_MAC_ADDRESS_5 << 8) | OWN_MAC_ADDRESS_4;	//low word = mac address high word
	REG32(ETH_BASE + ETH_MAC_ADDR0) = (OWN_MAC_ADDRESS_3 << 24) | (OWN_MAC_ADDRESS_2 << 16)
		| (OWN_MAC_ADDRESS_1 << 8) | OWN_MAC_ADDRESS_0;		//mac address rest

	//configure TXBD0
	REG32(ETH_BASE + ETH_TXBD0H) = (unsigned long)eth_tx_packet;		//address used for tx_data
	REG32(ETH_BASE + ETH_TXBD0L) = TX_READY;	//length = 0 | PAD & CRC = 1 | IRQ & WR = 1

	//configure RXBD0
	REG32(ETH_BASE + ETH_RXBD0H) = (unsigned long)eth_rx_packet;		//address used for tx_data
	REG32(ETH_BASE + ETH_RXBD0L) = RX_READY;	//len = 0 | IRQ & WR = 1 | EMPTY = 1

	//set txdata
	eth_tx_packet[0] = BROADCAST_ADDRESS_5;
	eth_tx_packet[1] = BROADCAST_ADDRESS_4;
	eth_tx_packet[2] = BROADCAST_ADDRESS_3;
	eth_tx_packet[3] = BROADCAST_ADDRESS_2;
	eth_tx_packet[4] = BROADCAST_ADDRESS_1;
	eth_tx_packet[5] = BROADCAST_ADDRESS_0;

	eth_tx_packet[6] = OWN_MAC_ADDRESS_5;
	eth_tx_packet[7] = OWN_MAC_ADDRESS_4;
	eth_tx_packet[8] = OWN_MAC_ADDRESS_3;
	eth_tx_packet[9] = OWN_MAC_ADDRESS_2;
	eth_tx_packet[10] = OWN_MAC_ADDRESS_1;
	eth_tx_packet[11] = OWN_MAC_ADDRESS_0;

	//erase interrupts
	REG32(ETH_BASE + ETH_INT_SOURCE) = ETH_RXC | ETH_TXC | ETH_BUSY | ETH_RXE | ETH_RXB | ETH_TXE | ETH_TXB;

	eth_tx_done = 1;
	eth_rx_done = 0;
	eth_rx_len = 0;
	eth_tx_data = &eth_tx_packet[HDR_LEN];
	eth_rx_data = &eth_rx_packet[HDR_LEN];
}

int eth_send(int length)
{
	if (!eth_tx_done)       //if previous command not fully processed, bail out
		return -1;

	eth_tx_done = 0;
	eth_tx_packet[12] = length >> 8;
	eth_tx_packet[13] = length;

	REG32(ETH_BASE + ETH_TXBD0L) = (( 0x0000FFFF & ( length + HDR_LEN ) ) << 16) | BD_SND;

	return length;
}

void eth_interrupt()
{
	unsigned long source = REG32(ETH_BASE + ETH_INT_SOURCE);
	if ( source & ETH_TXB )
	{
		eth_tx_done = 1;
		//erase interrupt
		REG32(ETH_BASE + ETH_INT_SOURCE) |= ETH_TXB;
	}
	if ( source & ETH_RXB )
	{
		eth_rx_done = 1;
		eth_rx_len = (REG32(ETH_BASE + ETH_RXBD0L) >> 16) - HDR_LEN - CRC_LEN;
		//erase interrupt
		REG32(ETH_BASE + ETH_INT_SOURCE) |= ETH_RXB;        
	}
}
