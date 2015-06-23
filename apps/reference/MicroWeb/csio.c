// Copyright (C) 2002 Mason Kidd (mrkidd@nettaxi.com)
//
// This file is part of MicroWeb.
//
// MicroWeb is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 2 of the License, or
// (at your option) any later version.
//
// MicroWeb is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with MicroWeb; if not, write to the Free Software
// Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 USA

// csio.c: driver code for CS8900A chip

#include "csio.h"
#include "csioa.h"

void cs_init(unsigned char my_MAC_addr[])
{
	unsigned int nReturn = 0;
	
	// reset the chip
	write_word(IO_PPPointer, PP_SelfCTL);
	write_word(IO_PPData, RESET);

	// wait until chip is ready
	while (!(nReturn & INITD))
	{
		write_word(IO_PPPointer, PP_SelfST);
		nReturn = read_wordL(IO_PPData);
	}

	// setup RxCTL(0104h)
	write_word(IO_PPPointer, PP_RxCTL);
	write_word(IO_PPData, RX_OK_ACCEPT | RX_IA_ACCEPT | RX_BROADCAST_ACCEPT);
	nReturn = read_wordL(IO_PPData);
	
	// write the MAC address starting at 0158h
	write_word(IO_PPPointer, PP_IA);
	write_word(IO_PPData, (my_MAC_addr[1] << 8) | my_MAC_addr[0]);
	write_word(IO_PPPointer, PP_IA + 2);
	write_word(IO_PPData, (my_MAC_addr[3] << 8) | my_MAC_addr[2]);
	write_word(IO_PPPointer, PP_IA + 4);
	write_word(IO_PPData, (my_MAC_addr[5] << 8) | my_MAC_addr[4]);
	
	// enable receive and transmit
	write_word(IO_PPPointer, PP_LineCTL);
	write_word(IO_PPData, SERIAL_RX_ON | SERIAL_TX_ON);
}

unsigned char cs_test(void)
{
	unsigned int nReturn;
	
	// Read from PPData port, should get 0E63h
	nReturn = read_wordL(IO_PPData);
       
	if (nReturn != 0x630E)
		return 0;      
       	
	// Read from register RxCFG(0102h), should get 3h
	write_word(IO_PPPointer, PP_RxCFG);
	nReturn = read_wordL(IO_PPData);
	
	if (nReturn != 0x0003)
		return 0;       	
      
  // Display OK Here at Hyper Teminal or at LCD Monitor 	
	
	return 1;
}

unsigned char rx_event_poll(void)
{
	unsigned int nReturn = 0x0000;
	
	write_word(IO_PPPointer, PP_RxEvent);
	nReturn = read_wordL(IO_PPData);
	
	if ((nReturn & RX_OK) && !(nReturn & RX_HASH))
		return 1;

	return 0;
}

unsigned int rx_packet(unsigned char *rx_buffer)
{
	unsigned int data nReturn = 0x0000;
	unsigned int data nLength = 0x0000;
	unsigned int data nData = 0x0000;
	unsigned char i;
	
	write_word(IO_PPPointer, PP_RxStatus);
	nReturn = read_wordL(IO_PPData);

	write_word(IO_PPPointer, PP_RxLength);
	nLength = read_wordL(IO_PPData);
	
	for (i = 0; i < nLength; i += 2)
	{
		write_word(IO_PPPointer, PP_RxFrame + i);
		nData = read_wordL(IO_PPData);
		rx_buffer[i] = (unsigned char)(nData & 0xFF);
		rx_buffer[i + 1] = (unsigned char)((nData >> 8) & 0xFF);
	}
	
	return nLength;
}
  
void tx_packet(unsigned char *tx_buffer, unsigned int tx_buffer_len)
{
	unsigned int nReturn = 0;
	unsigned int i = 0;
	unsigned char *tx_send = (unsigned char *)tx_buffer;
	
	// write transmit command to TxCMD port
	write_word(IO_TxCMD, 0x00C0);
	// write transmit size to TxLength port
	write_word(IO_TxLength, tx_buffer_len);
	
	// wait until space is available
	while (!(nReturn & READY_FOR_TX_NOW))
	{
		write_word(IO_PPPointer, PP_BusST);
		nReturn = read_wordL(IO_PPData);
	}
    
	// round odd packets up and convert to words
	tx_buffer_len = (tx_buffer_len + 1) >> 1;
	for (i = 0; i < tx_buffer_len; i++)
	{
	    	write_word(IO_RxTxData, *(tx_send++));
  		tx_send += 2;
    }
}
      

