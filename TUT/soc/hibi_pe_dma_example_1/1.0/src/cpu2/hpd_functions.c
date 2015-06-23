/*
 * @file   hpd_functions.c
 * @author Lasse Lehtonen
 * @date   2012-02-27
 *
 * @brief Implements platform independent functions for HIBI_PE_DMA.
 *
 */

#include "hpd_macros.h"
#include "hpd_config.h"
#include "hpd_functions.h"

#include <string.h>


void hpd_initialize()
{
  int i;
  int base;
  int tx_base;
  int tx_size;
  int tx_haddr;
  int tx_cmd;
  int rx_base;
  int rx_words;
  int rx_haddr;
  int n_streams;
  int n_packets;
  int c;
  for(i = 0; i < NUM_OF_HIBI_PE_DMAS; ++i) {
    base       = hpd_ifaces[i].base_address;
    tx_base    = hpd_ifaces[i].tx_base_address;
    tx_size    = hpd_ifaces[i].tx_buffer_bytes;
    tx_haddr   = hpd_ifaces[i].tx_hibi_address;
    tx_cmd     = hpd_ifaces[i].tx_hibi_command;
    n_streams  = hpd_ifaces[i].n_stream_channels;
    n_packets  = hpd_ifaces[i].n_packet_channels;

    // Set tx_buffer start address
    HPD_TX_MEM_ADDR(tx_base, base);

    // Set amount to send
    HPD_TX_WORDS(((tx_size+3) >> 2), base);

    // Set target hibi command
    HPD_TX_CMD(tx_cmd, base);
  
    // Set target hibi address
    HPD_TX_HIBI_ADDR(tx_haddr, base);
    
    for(c = 0; c < n_streams; ++c) {
      rx_base  = hpd_ifaces[i].rx_streams[c].rx_base_address;
      rx_words = (hpd_ifaces[i].rx_streams[c].rx_buffer_bytes+3) >> 2;
      rx_haddr = hpd_ifaces[i].rx_streams[c].rx_hibi_address;
      hpd_ifaces[i].rx_streams[c].rx_read_words = 0;
      // Set receive mem address for incoming data
      HPD_RX_MEM_ADDR(c, rx_base, base);
      // Set amount to receive
      HPD_RX_WORDS(c, rx_words, base);
      // Set hibi address to receive data
      HPD_RX_HIBI_ADDR(c, rx_haddr, base);
    }

    for(c = 0; c < n_packets; ++c) {
      rx_base  = hpd_ifaces[i].rx_packets[c].rx_base_address;
      rx_words = (hpd_ifaces[i].rx_packets[c].rx_buffer_bytes+3) >> 2;
      rx_haddr = hpd_ifaces[i].rx_packets[c].rx_hibi_address;
      // Set receive mem address for incoming data
      HPD_RX_MEM_ADDR(c+n_streams, rx_base, base);
      // Set amount to receive
      HPD_RX_WORDS(c+n_streams, rx_words, base);
      // Set hibi address to receive data
      HPD_RX_HIBI_ADDR(c+n_streams, rx_haddr, base);
    }
  }
}


void hpd_tx_base_conf_gen(int base, int words, int iface)
{
  hpd_ifaces[iface].tx_base_address = base;
  hpd_ifaces[iface].tx_buffer_bytes = words << 2;
  int hpd_base = hpd_ifaces[iface].base_address;

  // Set tx_buffer start address
  HPD_TX_MEM_ADDR(base, hpd_base);

  // Set amount to send
  HPD_TX_WORDS(words, hpd_base);
}


void hpd_tx_base_conf(int base, int words)
{
  hpd_tx_base_conf_gen(base, words, 0);
}


void hpd_tx_send_gen(int daddr, int words, int haddr, int iface)
{
  int tx_done = 0;    
  int base     = hpd_ifaces[iface].base_address;
  int tx_base  = hpd_ifaces[iface].tx_base_address;
  int tx_haddr = hpd_ifaces[iface].tx_hibi_address;
  int tx_cmd   = hpd_ifaces[iface].tx_hibi_command;

  // Poll HPD until it's not sending previous tx anymore
  for(; !tx_done;) {
    HPD_TX_GET_DONE(tx_done, base);
  }

  // Set tx_buffer start address
  if(tx_base != daddr) {
    HPD_TX_MEM_ADDR(daddr, base);
  }

  // Set target hibi command WRITE
  if(tx_cmd != 2) {
    HPD_TX_CMD(2, base);
    hpd_ifaces[iface].tx_hibi_command = 2;
  }
  
  // Set target hibi address
  if(tx_haddr != haddr) {
    HPD_TX_HIBI_ADDR(haddr, base);
    hpd_ifaces[iface].tx_hibi_address = haddr;
  }  

  // Set amount to send
  HPD_TX_WORDS(words, base);

  // Start the transfer
  HPD_TX_START(base);
}

void hpd_tx_send(int daddr, int words, int haddr)
{
  hpd_tx_send_gen(daddr, words, haddr, 0);
}

void hpd_tx_send_copy_gen(int daddr, int words, int haddr, int iface)
{
  int tx_done  = 0;  
  int base     = hpd_ifaces[iface].base_address;
  int tx_base  = hpd_ifaces[iface].tx_base_address;
  int tx_size  = hpd_ifaces[iface].tx_buffer_bytes;
  int tx_haddr = hpd_ifaces[iface].tx_hibi_address;
  int tx_cmd   = hpd_ifaces[iface].tx_hibi_command;
  
  // Set tx_buffer start address
  HPD_TX_MEM_ADDR(tx_base, base);

  // Set target hibi command WRITE
  if(tx_cmd != 2) {
    HPD_TX_CMD(2, base);
    hpd_ifaces[iface].tx_hibi_command = 2;
  }

  // Set target hibi address
  if(tx_haddr != haddr) {
    HPD_TX_HIBI_ADDR(haddr, base);
    hpd_ifaces[iface].tx_hibi_address = haddr;
  }  

  while(words > 0)
    {
      // Poll HPD until it's not sending previous tx anymore
      for(; !tx_done;) {
	HPD_TX_GET_DONE(tx_done, base);
      }
      tx_done = 0;

      // Copy data in pieces if there's more than tx_buffer's size
      if(words > (tx_size >> 2)) {
	memcpy((void*)tx_base, (void*)daddr, tx_size);
	daddr += tx_size;
	words -= (tx_size >> 2);
	// Set how many words to send
	HPD_TX_WORDS((tx_size >> 2), base);
      } else {
	memcpy((void*)tx_base, (void*)daddr, (words << 2));	
	// Set how many words to send
	HPD_TX_WORDS(words, base);
	words = 0;
      }
      
      // Start the transfer
      HPD_TX_START(base);
    }
}

void hpd_tx_send_copy(int daddr, int words, int haddr)
{
  hpd_tx_send_copy_gen(daddr, words, haddr, 0);
}


void hpd_rx_packet_init_gen(int chan, int daddr, 
			    int words, int haddr, int iface)
{
  int base      = hpd_ifaces[iface].base_address;
  int rx_base   = hpd_ifaces[iface].rx_packets[chan].rx_base_address;
  int rx_size   = hpd_ifaces[iface].rx_packets[chan].rx_buffer_bytes;
  int rx_haddr  = hpd_ifaces[iface].rx_packets[chan].rx_hibi_address;
  int n_streams = hpd_ifaces[iface].n_stream_channels;

  // Set receive mem address for incoming data
  if(rx_base != daddr) {
    HPD_RX_MEM_ADDR(chan+n_streams, daddr, base);
    hpd_ifaces[iface].rx_packets[chan].rx_base_address = daddr;
  }

  // Set amount to receive
  if((rx_size >> 2) != words) {
    HPD_RX_WORDS(chan+n_streams, words, base);
    hpd_ifaces[iface].rx_packets[chan].rx_buffer_bytes = (words << 2);
  }

  // Set hibi address to receive data
  if(rx_haddr != haddr) {
    HPD_RX_HIBI_ADDR(chan+n_streams, haddr, base);
    hpd_ifaces[iface].rx_packets[chan].rx_hibi_address = haddr;
  }

  // Initialize receiving
  HPD_RX_INIT(chan+n_streams, base);
}

void hpd_rx_packet_init(int chan, int daddr, int words, int haddr)
{
  hpd_rx_packet_init_gen(chan, daddr, words, haddr, 0);
}


void hpd_rx_stream_init_gen(int chan, int daddr, 
			    int words, int haddr, int iface)
{
  int base      = hpd_ifaces[iface].base_address;
  int rx_base   = hpd_ifaces[iface].rx_streams[chan].rx_base_address;
  int rx_size   = hpd_ifaces[iface].rx_streams[chan].rx_buffer_bytes;
  int rx_haddr  = hpd_ifaces[iface].rx_streams[chan].rx_hibi_address;
  hpd_ifaces[iface].rx_streams[chan].rx_read_words = 0;

  // Set receive mem address for incoming data
  if(rx_base != daddr) {
    HPD_RX_MEM_ADDR(chan, daddr, base);
    hpd_ifaces[iface].rx_streams[chan].rx_base_address = daddr;
  }

  // Set the length of the rx buffer in words
  if((rx_size >> 2) != words) {
    HPD_RX_WORDS(chan, words, base);
    hpd_ifaces[iface].rx_streams[chan].rx_buffer_bytes = (words << 2);
  }

  // Set hibi address to receive data
  if(rx_haddr != haddr) {
    HPD_RX_HIBI_ADDR(chan, haddr, base);
    hpd_ifaces[iface].rx_streams[chan].rx_hibi_address = haddr;
  }

  // Initialize receiving
  HPD_RX_INIT(chan, base);
}


void hpd_rx_stream_init(int chan, int daddr, int words, int haddr)
{
  hpd_rx_stream_init_gen(chan, daddr, words, haddr, 0);
}


void hpd_rx_packet_reinit_gen(int chan, int iface)
{
  int base      = hpd_ifaces[iface].base_address;
  int n_streams = hpd_ifaces[iface].n_stream_channels;
  // Initialize receiving
  HPD_RX_INIT(chan+n_streams, base);
}


void hpd_rx_packet_reinit(int chan)
{
  hpd_rx_packet_reinit_gen(chan, 0);
}


void hpd_rx_stream_reinit_gen(int chan, int iface)
{
  int base      = hpd_ifaces[iface].base_address;
  // Initialize receiving
  HPD_RX_INIT(chan, base);
}


void hpd_rx_stream_reinit(int chan)
{
  hpd_rx_stream_reinit_gen(chan, 0);
}


void hpd_rx_packet_read_gen(int chan, void* buffer, int iface)
{
  int rx_base = hpd_ifaces[iface].rx_packets[chan].rx_base_address;
  int rx_size = hpd_ifaces[iface].rx_packets[chan].rx_buffer_bytes;
  memcpy(buffer, (void*)rx_base, rx_size);
}


void hpd_rx_packet_read(int chan, void* buffer)
{
  hpd_rx_packet_read_gen(chan, buffer, 0);
}


void hpd_rx_packet_get_conf_gen(int chan, int* rx_base, int* rx_bytes,
				int* rx_haddr, int iface)
{
  if(rx_base) {
    *rx_base = hpd_ifaces[iface].rx_packets[chan].rx_base_address;
  }
  
  if(rx_bytes) {
    *rx_bytes = hpd_ifaces[iface].rx_packets[chan].rx_buffer_bytes;
  }

  if(rx_haddr) {
    *rx_haddr = hpd_ifaces[iface].rx_packets[chan].rx_hibi_address;
  }
}


void hpd_rx_packet_get_conf(int chan, int* rx_base, int* rx_bytes,
			    int* rx_haddr)
{
  hpd_rx_packet_get_conf_gen(chan, rx_base, rx_bytes, rx_haddr, 0);
}


void hpd_rx_stream_get_conf_gen(int chan, int* rx_base, int* rx_bytes,
				int* rx_haddr, int iface)
{
  if(rx_base) {
    *rx_base = hpd_ifaces[iface].rx_streams[chan].rx_base_address;
  }
  
  if(rx_bytes) {
    *rx_bytes = hpd_ifaces[iface].rx_streams[chan].rx_buffer_bytes;
  }

  if(rx_haddr) {
    *rx_haddr = hpd_ifaces[iface].rx_streams[chan].rx_hibi_address;
  }
}


void hpd_rx_stream_get_conf(int chan, int* rx_base, int* rx_bytes,
			    int* rx_haddr)
{
  hpd_rx_stream_get_conf_gen(chan, rx_base, rx_bytes, rx_haddr, 0);
}


int hpd_rx_packet_poll_gen(int chan, int iface)
{
  int rx_words  = hpd_ifaces[iface].rx_packets[chan].rx_buffer_bytes >> 2;
  int base      = hpd_ifaces[iface].base_address;
  int n_streams = hpd_ifaces[iface].n_stream_channels;
  int received;
  HPD_RX_GET_WORDS(received, chan+n_streams, base);
  if(rx_words == received)
    return 1;
  return 0;
}


int hpd_rx_packet_poll(int chan)
{
  return hpd_rx_packet_poll_gen(chan, 0);
}


int hpd_rx_stream_poll_gen(int chan, int iface)
{
  int base     = hpd_ifaces[iface].base_address;
  int received;
  HPD_RX_GET_WORDS(received, chan, base);
  return received;
}


int hpd_rx_stream_poll(int chan)
{
  return hpd_rx_stream_poll_gen(chan, 0);
}


void hpd_rx_stream_read_gen(int chan, int words, int* buffer, int iface)
{
  int base          = hpd_ifaces[iface].base_address;
  int rx_base       = hpd_ifaces[iface].rx_streams[chan].rx_base_address;
  int rx_size       = hpd_ifaces[iface].rx_streams[chan].rx_buffer_bytes;
  int rx_read_words = hpd_ifaces[iface].rx_streams[chan].rx_read_words;
  
  if(words > (rx_size >> 2) - rx_read_words) {
    memcpy((void*)buffer, (void*)rx_base + (rx_read_words << 2), 
	   rx_size - (rx_read_words << 2));
    memcpy((void*)buffer + (rx_size - (rx_read_words << 2)),
	   (void*)rx_base, (words << 2) - (rx_size - (rx_read_words << 2)));
    hpd_ifaces[iface].rx_streams[chan].rx_read_words =
      words - (rx_size << 2) + rx_read_words;
  }
  else {
    memcpy((void*)buffer, (void*)rx_base + (rx_read_words << 2), (words << 2));
    hpd_ifaces[iface].rx_streams[chan].rx_read_words = 
      (rx_read_words + words) %  (rx_size >> 2);
  }
  HPD_RX_WORDS(chan, words, base);
}


void hpd_rx_stream_read(int chan, int words, int* buffer)
{
  hpd_rx_stream_read_gen(chan, words, buffer, 0);
}


void hpd_rx_stream_ack_gen(int chan, int words, int iface)
{
  int base = hpd_ifaces[iface].base_address;
  HPD_RX_WORDS(chan, words, base);
}


void hpd_rx_stream_ack(int chan, int words)
{
  hpd_rx_stream_ack_gen(chan, words, 0);
}


void hpd_irq_enable_gen(int iface)
{
  int base = hpd_ifaces[iface].base_address;
  HPD_IRQ_ENA(base);
}


void hpd_irq_enable()
{
  hpd_irq_enable_gen(0);
}


void hpd_irq_disable_gen(int iface)
{
  int base = hpd_ifaces[iface].base_address;
  HPD_IRQ_DIS(base);
}


void hpd_irq_disable()
{
  hpd_irq_disable_gen(0);
}


void hpd_irq_packet_ack_gen(int chan, int iface)
{
  int base      = hpd_ifaces[iface].base_address;
  int n_streams = hpd_ifaces[iface].n_stream_channels;
  HPD_CLEAR_IRQ_REG(chan+n_streams, base);
}


void hpd_irq_packet_ack(int chan)
{
  hpd_irq_packet_ack_gen(chan, 0);
}


void hpd_irq_stream_ack_gen(int chan, int iface)
{
  int base = hpd_ifaces[iface].base_address;
  HPD_CLEAR_IRQ_CHAN(chan, base);
}


void hpd_irq_stream_ack(int chan)
{
  hpd_irq_stream_ack_gen(chan, 0);
}


int hpd_irq_get_vector_gen(int iface)
{
  int base = hpd_ifaces[iface].base_address;
  int vector;
  HPD_GET_IRQ_REG(vector, base);
  return vector;
}


int hpd_irq_get_vector()
{
  return hpd_irq_get_vector_gen(0);
}


void hpd_irq_clear_vector_gen(int mask, int iface)
{
  int base = hpd_ifaces[iface].base_address;
  HPD_CLEAR_IRQ_REG(mask, base);
}


void hpd_irq_clear_vector(int mask)
{
  hpd_irq_clear_vector_gen(mask, 0);
}
