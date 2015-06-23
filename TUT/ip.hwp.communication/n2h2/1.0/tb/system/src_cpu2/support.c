/*
 *
 * Author            : Lasse Lehtonen
 * Last modification : 29.03.2011 
 *
 * N2H support functions
 *
 */

#include <stdio.h>
#include <string.h>
#include <io.h>
#include <unistd.h>
#include <sys/alt_irq.h>
#include <stdlib.h>

#include "support.h"


void n2h_send(int data_src_addr, int amount, int hibi_addr)
{
  // Poll N2H, until it's not sending previous tx anymore
  //while(((IORD(N2H2_CHAN_BASE, 4) >> 16) & 0x1) == 0) { }
  // Set data source address
  IOWR(N2H2_CHAN_BASE, 8, data_src_addr);
  // Set amount to send
  IOWR(N2H2_CHAN_BASE, 9, amount);
  // Set target hibi command
  IOWR(N2H2_CHAN_BASE, 10, 2);
  // Set target hibi address
  IOWR(N2H2_CHAN_BASE, 11, hibi_addr);
  // Start the transfer
  IOWR(N2H2_CHAN_BASE, 4, (0x1 | (IORD(N2H2_CHAN_BASE,4))));
}


void n2h_init_rx(int rx_channel, int rx_addr, int rx_amount, int hibi_addr)
{
  // Set receive mem address for incoming data
  IOWR(N2H2_CHAN_BASE, (rx_channel << 4), N2H_REGISTERS_RX_BUFFER_START +
       rx_addr);
  // Set amount to receive
  IOWR(N2H2_CHAN_BASE, (rx_channel << 4) + 2, rx_amount);
  // Set hibi address to receive data
  IOWR(N2H2_CHAN_BASE, (rx_channel << 4) + 1, hibi_addr);
  // Initialize receiving
  IOWR(N2H2_CHAN_BASE, 5 , 1 << rx_channel);
}



int onehot2int(int num)
{
  int i = 0;
  for(; i < 31; ++i)
    {
      if(num & (1 << i))
	{
	  return i;
	}
    }
  return -1;
}


void n2h2_isr(void* context)
{
  N2H_isr_fifo* fifo = (N2H_isr_fifo*) context;  

  // Read the cause of the interrupt
  int interrupter = IORD(N2H2_CHAN_BASE, 7);

  
  if((0x80000000 & interrupter) != 0)
    { 
      N2H_isr_info* info = (N2H_isr_info*) malloc(sizeof(N2H_isr_info));
      info->isr_type = RX_UNKNOWN;

      // Read in incoming hibi address
      info->dst_address = IORD(N2H2_CHAN_BASE, 12);      
      // Clear IRQ
      IOWR(N2H2_CHAN_BASE, 7, 0x80000000); 
      
      // Store interrupt information to fifo
      n2h_isr_fifo_push(fifo, info);    
    }
  
  if((0x40000000 & interrupter) != 0)
    {
      N2H_isr_info* info = (N2H_isr_info*) malloc(sizeof(N2H_isr_info));
      info->isr_type = TX_IGNORED;
      
      // Clear IRQ
      IOWR(N2H2_CHAN_BASE, 7, 0x40000000); 

      // Store interrupt information to fifo
      n2h_isr_fifo_push(fifo, info);    
    }
  
  while((0x3FFFFFFF & interrupter) != 0)
    {
      N2H_isr_info* info = (N2H_isr_info*) malloc(sizeof(N2H_isr_info));
      info->isr_type = RX_READY;
      
      // Store interrupted channel
      info->rx_channel = onehot2int(interrupter);
      // Clear IRQ
      IOWR(N2H2_CHAN_BASE, 7, (1 << info->rx_channel));

      interrupter = interrupter & ~(1 << info->rx_channel);

      // Store interrupt information to fifo
      n2h_isr_fifo_push(fifo, info);    
    }  
}



// Init interrupt
void n2h_isr_init(N2H_isr_fifo* n2h_isr_fifo)
{
  // Register N2H2 ISR
  if(alt_ic_isr_register(N2H2_CHAN_IRQ_INTERRUPT_CONTROLLER_ID,
			 N2H2_CHAN_IRQ, n2h2_isr, (void*)n2h_isr_fifo, 0) 
     != 0)
    {
      printf("CPU0: registering n2h2_isr failed!\n");
    }
  // Enable interrupt on CPU side     
  if(alt_ic_irq_enable(N2H2_CHAN_IRQ_INTERRUPT_CONTROLLER_ID,
		       N2H2_CHAN_IRQ) != 0)
    {
      printf("CPU0: enabling n2h2 interrupt failed!\n");
    }
  // Enable interrupts on N2H2 side
  IOWR(N2H2_CHAN_BASE, 4, (2 | (IORD(N2H2_CHAN_BASE,4))));
}

