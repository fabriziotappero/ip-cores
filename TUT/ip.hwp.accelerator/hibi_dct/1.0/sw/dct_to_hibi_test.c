/*
 * file   dct__hibi_test.c
 * date	  2013-3-27 
 * author LM
 *      
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>


#include "hpd_functions.h"

#define MY_ADDR   0x01000000
#define DCT_ADDR  0x05000000
#define FOO_ADDR  0x09000000



int main() 
{

  int dct_data[192]  = {0};
  int result_data[193] = {0};    // one word for zero detection
  int ref_quant_data[192] = {0};
  int data = 0; 
  
  printf("CPU: starts\n");
  
  hpd_initialize();
  
  // reinit the channel 0
  hpd_rx_packet_reinit(0);

  // Send quant result address
  data = MY_ADDR;
  hpd_tx_send_copy((int)&data, 1, DCT_ADDR);
  
  // Send idct result address (NOT USED)
  data = FOO_ADDR;
  hpd_tx_send_copy((int)&data, 1, DCT_ADDR);
  
  // Send control
  data= 0x21;
  hpd_tx_send_copy((int)&data, 1, DCT_ADDR);

  // Send DCT DATA 
  hpd_tx_send_copy((int)dct_data, 192, DCT_ADDR);
  printf("DCT_data sent\n");

  // Waiting for data
  while(!(hpd_rx_packet_poll(0)));
  
  // Data received & read it to result table
  hpd_rx_packet_read(0, result_data);
  hpd_irq_packet_ack(0);
  hpd_rx_packet_reinit(0);
  printf("DATA received\n");

  // compare result data to reference quant results



  while(1); return 0;
}


