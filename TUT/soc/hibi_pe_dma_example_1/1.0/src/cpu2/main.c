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
  char str[] =
    "Lorem ipsum dolor sit amet, consectetur adipisicing elit,\n"
    "sed do eiusmod tempor incididunt ut labore et dolore magna\n"
    "aliqua. Ut enim ad minim veniam, quis nostrud exercitation\n"
    "ullamco laboris nisi ut aliquip ex ea commodo consequat.\n"
    "Duis aute irure dolor in reprehenderit in voluptate velit\n"
    "esse cillum dolore eu fugiat nulla pariatur. Excepteur sint\n"
    "occaecat cupidatat non proident, sunt in culpa qui officia\n"
    "deserunt mollit anim id est laborum.\n";


  hpd_initialize();
  hpd_rx_packet_reinit(2);
  my_hpd_isr_init();  
  

  printf("CPU2: starts\n");
  printf("Size of str: %lu\n", sizeof(str));
  
  hpd_tx_send_copy((int)str, (sizeof(str)+3) >> 2, 0x00000001);

  //printf("CPU2: retires!\n");
  while(1); return 0;

}


void my_hpd_isr()
{
  // This pe gets data only on packet channel 2.
  // Omitting others.
  char data[17]; data[16] = 0;
  if(hpd_rx_packet_poll(2)) {
    hpd_rx_packet_read(2, data);    
    printf("CPU2: \"%s\"\n", data);
    hpd_irq_packet_ack(2);
    hpd_rx_packet_reinit(2);
  } else {
    printf("CPU2: got unexpected interrupt!\n");
  }
}


void my_hpd_isr_init()
{
  int status;
  
  status = alt_ic_isr_register(HIBI_PE_DMA_2_IRQ_INTERRUPT_CONTROLLER_ID,
			       HIBI_PE_DMA_2_IRQ, my_hpd_isr, 
			       0, 0);

  if(status) {
    printf("CPU2: registering my_hpd_isr failed!\n");
  }

  status = alt_ic_irq_enable(HIBI_PE_DMA_2_IRQ_INTERRUPT_CONTROLLER_ID,
			     HIBI_PE_DMA_2_IRQ);

  if(status) {
    printf("CPU2: enabling hpd interrupt failed!\n");
  }

  hpd_irq_enable();
}
