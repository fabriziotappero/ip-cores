/*
 * file   main.c
 * date   2012-02-21
 * author Lasse Lehtonen
 *      
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/alt_irq.h>


#include "hpd_functions.h"


void my_hpd_isr();
void my_hpd_isr_init();

int main()
{
  printf("CPU1: starts\n");

  hpd_initialize();
  hpd_rx_packet_reinit(3);
  my_hpd_isr_init();  

  //printf("CPU1: retires!\n");
  while(1); return 0;
}



void my_hpd_isr()
{
  // This pe gets data only on packet channel 3.
  // Omitting others.
  char data[17]; data[16] = 0;
  if(hpd_rx_packet_poll(3)) {
    hpd_rx_packet_read(3, data);    
    printf("CPU1: \"%s\"\n", data);
    hpd_tx_send_copy((int)data, 4, 0x406);
    hpd_irq_packet_ack(3);
    hpd_rx_packet_reinit(3);
  } else {
    printf("CPU1: got unexpected interrupt!\n");
  }
}


void my_hpd_isr_init()
{
  int status;
  
  status = alt_ic_isr_register(HIBI_PE_DMA_1_IRQ_INTERRUPT_CONTROLLER_ID,
			       HIBI_PE_DMA_1_IRQ, my_hpd_isr, 
			       0, 0);

  if(status) {
    printf("CPU1: registering my_hpd_isr failed!\n");
  }

  status = alt_ic_irq_enable(HIBI_PE_DMA_1_IRQ_INTERRUPT_CONTROLLER_ID,
			     HIBI_PE_DMA_1_IRQ);

  if(status) {
    printf("CPU1: enabling hpd interrupt failed!\n");
  }

  hpd_irq_enable();
}
