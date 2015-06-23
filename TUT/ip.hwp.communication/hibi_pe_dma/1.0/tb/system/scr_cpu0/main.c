/*
 * main.c
 *
 *  Created on: 21.2.2011
 *      Author: Lasse Lehtonen
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <io.h>
#include <unistd.h>
#include <sys/alt_irq.h>

#include "system.h"
#include "alt_types.h"

#include "hpd_registers_conf.h"
#include "hpd_macros.h"

#include "hpd_isr_fifo.h"

#include "support.h"


int main()
{
  int n_received = 0;
  int rx_data[20];

  int rx_amount = 8;
  int tx_amount = 8;
  int send      = 0;

  int channels[8] = {1, 0, 0, 0, 0, 0, 0, 0};

  Hpd_isr_fifo* hpd_isr_fifo = hpd_isr_fifo_create();
  
  // Init N2H interrupt
  hpd_isr_init(hpd_isr_fifo);
      
  // Initialize n2h rx_channel 0 to store 8 incoming words to 0x10 to 
  // rx buffer with offset 0
  hpd_init_rx(0, 8*0, 8, 0x10);

  printf("CPU0: starts\n");

  
  while(1)
    {
      if(hpd_isr_fifo_size(hpd_isr_fifo))
	{
	  Hpd_isr_info* info = hpd_isr_fifo_pop(hpd_isr_fifo);

	  switch(info->isr_type)
	    {
	    case RX_READY:
	      
	      printf("CPU0: received %ith packet to channel %i\n", 
		     ++n_received, info->rx_channel);

	      if(channels[info->rx_channel] == 2)
		{
		  channels[info->rx_channel] = 0;
		  break;
		}

	      memcpy((int*)rx_data, (int*)(HPD_REGISTERS_RX_BUFFER_START + 
					   info->rx_channel * rx_amount *
					   sizeof(int)), 
		     rx_amount*sizeof(int));
  
	      printf("CPU0: read data from channel %i : %X %X %X %X %X "
		     "%X %X %X\n", 
		     info->rx_channel, rx_data[0], rx_data[1], rx_data[2], 
		     rx_data[3], rx_data[4], rx_data[5], rx_data[6], 
		     rx_data[7]);	     
	      
	      channels[info->rx_channel] = 0;

	      // Init rx chan half the time
	      int src = (rand() % 2 == 0) ? 0x10 : 0x20;
	      if(rand() % 2 == 0)
		{
		  int i = 0;
		  
		  for(i = 0; i < 5; ++i)
		    {
		      if(channels[i] == 0)
			{
			  channels[i] = 1;
			  hpd_init_rx(i, 8*i*sizeof(int), 8, i+src);
			  break;
			}
		    }		  
		}

	      send++;

	      int fre = 0;
	      int x = 0;
	      for(; x < 8; ++x) {if(channels[x]== 0) fre++;}
	      printf("CPU0: %i to send, %i in FIFO, %i channels free\n", 
		     send, hpd_isr_fifo_size(hpd_isr_fifo), fre);

	      break;
		
	    case RX_UNKNOWN:
	      {
		int cha = 0;
		
		for(cha = 0; cha < 8; ++cha)
		  {
		    if(channels[cha] == 0)
		      {
			channels[cha] = (info->dst_address == 0x1FF) ? 2 : 1;

			printf("CPU0: received data to unconfigured "
			       "address 0x%X, assigning to channel %i\n",
			       info->dst_address, cha);
			
			if(!(0x00 <= info->dst_address &&
			     info->dst_address <= 0x1FF))
			  {
			    printf("CPU0: %i is invalid address, FAILURE\n", 
				   info->dst_address);
			  }
			
			// Initialize some channel to receive
			hpd_init_rx(cha, cha * rx_amount*sizeof(int), rx_amount,
				    info->dst_address);

			break;
		      }		    
		  }
		
		int fre = 0;
		int x = 0;
		for(; x < 8; ++x) {if(channels[x]== 0) fre++;}
		printf("CPU0: %i to send, %i in FIFO, %i channels free\n", 
		       send, hpd_isr_fifo_size(hpd_isr_fifo), fre);
				
	      }
	      break;
		
	    case TX_IGNORED:
	      {
		printf("CPU0: A transfer was ignored because it overlapped"
		       " previous one\n");
		int fre = 0;
		int x = 0;
		for(; x < 8; ++x) {if(channels[x]== 0) fre++;}
		printf("CPU0: %i to send, %i in FIFO, %i channels free\n", 
		       send, hpd_isr_fifo_size(hpd_isr_fifo), fre);
	      }
	      break;
	    }	    

	  // Free memory
	  free(info); info = NULL;
	}
      else if (send > 0 && (((IORD(HIBI_PE_DMA_BASE, 4) >> 16) & 0x1) == 1))
	{
	  // Sent packet to a random target's random address
	  int target_addr;
	  int tx_data[8];
	  int tx_slot = (rand() % 8);
	  int cha;
	  
	  if(rand() % 2 == 0)
	    {
	      target_addr = 0x200 + tx_slot;
	    }
	  else
	    {
	      target_addr = 0x400 + tx_slot;
	    }
	  
	  for(cha = 0; cha < 8; ++cha)
	    tx_data[cha] = 0x80000000 | ((cha+1) << 16) | target_addr;
	  
	  memcpy((int*)(HPD_REGISTERS_TX_BUFFER_START + 
			tx_slot*tx_amount*sizeof(int)), 
		 (int*)tx_data, tx_amount*sizeof(int));
	  
	  printf("CPU0: sending packet to 0x%X\n", target_addr);

	  hpd_send(HPD_REGISTERS_TX_BUFFER_START + 
		   tx_slot*tx_amount*sizeof(int), 
		   tx_amount, target_addr);

	  send--;

	  // Overlapping with previous one, 50% change
	  if((rand() % 100) < 50)
	    {	      
	      hpd_send(HPD_REGISTERS_TX_BUFFER_START + 
		       tx_slot*tx_amount*sizeof(int), 
		       tx_amount, 0x3FF);
	      printf("CPU0: sending hazard packet\n");
	    }
	  int fre = 0;
	  int x = 0;
	  for(; x < 8; ++x) {if(channels[x]== 0) fre++;}
	  printf("CPU0: %i to send, %i in FIFO, %i channels free\n", 
		 send, hpd_isr_fifo_size(hpd_isr_fifo), fre);
	}      
    }
  
  printf("CPU0: retires!\n");
  while(1); return 0;
}
