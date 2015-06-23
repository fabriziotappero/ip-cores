/*
 *
 * Author            : Lasse Lehtonen
 * Last modification : 29.03.2011 
 *
 * HPD support functions
 *
 */

#include <stdio.h>
#include <string.h>
#include <io.h>
#include <unistd.h>
#include <sys/alt_irq.h>
#include <stdlib.h>

#include "support.h"


void hpd_send(int data_src_addr, int words, int hibi_addr)
{
  // Poll HPD, until it's not sending previous tx anymore
  //while(((IORD(hpd_CHAN_BASE, 4) >> 16) & 0x1) == 0) { }

  // Set data source address
  HPD_TX_MEM_ADDR(data_src_addr, HIBI_PE_DMA_BASE);
  //IOWR(HPD_CHAN_BASE, 8, data_src_addr);

  // Set how many words to send
  HPD_TX_WORDS(words, HIBI_PE_DMA_BASE);
  //IOWR(HPD_CHAN_BASE, 9, words);

  // Set target hibi command
  HPD_TX_CMD_WRITE(HIBI_PE_DMA_BASE);
  //IOWR(HPD_CHAN_BASE, 10, 2);

  // Set target hibi address
  HPD_TX_HIBI_ADDR(hibi_addr, HIBI_PE_DMA_BASE);
  //IOWR(HPD_CHAN_BASE, 11, hibi_addr);

  // Start the transfer
  HPD_TX_START(HIBI_PE_DMA_BASE);
  //IOWR(HPD_CHAN_BASE, 4, (0x1 | (IORD(HPD_CHAN_BASE,4))));
}


void hpd_init_rx(int rx_channel, int rx_addr, int rx_words, int hibi_addr)
{
  // Set receive mem address for incoming data
  IOWR(HIBI_PE_DMA_BASE, (rx_channel << 4), HPD_REGISTERS_RX_BUFFER_START +
       rx_addr);
  // Set amount to receive
  IOWR(HIBI_PE_DMA_BASE, (rx_channel << 4) + 2, rx_words);
  // Set hibi address to receive data
  IOWR(HIBI_PE_DMA_BASE, (rx_channel << 4) + 1, hibi_addr);
  // Initialize receiving
  IOWR(HIBI_PE_DMA_BASE, 5 , 1 << rx_channel);
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


void hpd_isr(void* context)
{
  Hpd_isr_fifo* fifo = (Hpd_isr_fifo*) context;

  // Read the cause of the interrupt
  int interrupter = IORD(HIBI_PE_DMA_BASE, 7);

  
  if((0x80000000 & interrupter) != 0)
    { 
      Hpd_isr_info* info = (Hpd_isr_info*) malloc(sizeof(Hpd_isr_info));
      info->isr_type = RX_UNKNOWN;

      // Read in incoming hibi address
      info->dst_address = IORD(HIBI_PE_DMA_BASE, 12);
      // Clear IRQ
      IOWR(HIBI_PE_DMA_BASE, 7, 0x80000000);
      
      // Store interrupt information to fifo
      hpd_isr_fifo_push(fifo, info);    
    }
  
  if((0x40000000 & interrupter) != 0)
    {
      Hpd_isr_info* info = (Hpd_isr_info*) malloc(sizeof(Hpd_isr_info));
      info->isr_type = TX_IGNORED;
      
      // Clear IRQ
      IOWR(HIBI_PE_DMA_BASE, 7, 0x40000000);

      // Store interrupt information to fifo
      hpd_isr_fifo_push(fifo, info);    
    }
  
  while((0x3FFFFFFF & interrupter) != 0)
    {
      Hpd_isr_info* info = (Hpd_isr_info*) malloc(sizeof(Hpd_isr_info));
      info->isr_type = RX_READY;
      
      // Store interrupted channel
      info->rx_channel = onehot2int(interrupter);
      // Clear IRQ
      IOWR(HIBI_PE_DMA_BASE, 7, (1 << info->rx_channel));

      interrupter = interrupter & ~(1 << info->rx_channel);

      // Store interrupt information to fifo
      hpd_isr_fifo_push(fifo, info);    
    }  
}


// Init interrupt
void hpd_isr_init(Hpd_isr_fifo* hpd_isr_fifo)
{
  // Register hpd ISR
  if(alt_ic_isr_register(HIBI_PE_DMA_IRQ_INTERRUPT_CONTROLLER_ID,
		  HIBI_PE_DMA_IRQ, hpd_isr, (void*)hpd_isr_fifo, 0)
     != 0)
    {
      printf("CPU0: registering n2h2_isr failed!\n");
    }
  // Enable interrupt on CPU side     
  if(alt_ic_irq_enable(HIBI_PE_DMA_IRQ_INTERRUPT_CONTROLLER_ID,
		  HIBI_PE_DMA_IRQ) != 0)
    {
      printf("CPU0: enabling n2h2 interrupt failed!\n");
    }
  // Enable interrupts on hpd side
  IOWR(HIBI_PE_DMA_BASE, 4, (2 | (IORD(HIBI_PE_DMA_BASE,4))));
}

