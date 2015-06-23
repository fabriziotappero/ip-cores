/*
 * file   main.c
 * date   2012-02-21
 * author Lasse Lehtonen
 *      
 */

#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "system.h"
#include "hpd_functions.h"

int main()
{
  int       n = 0;
  int       n_received  = 0;
  const int buf_size    = 500;  
  char      buffer[buf_size];

  memset((void*)buffer, 0, buf_size);

  printf("CPU0: starts\n");

  // Initialize with defaults from hpd_config.c
  hpd_initialize();

  // Start stream channel 1
  hpd_rx_stream_reinit(1);


  while(1) {
	// Check if stream channel 1 has received any words
    if((n = hpd_rx_stream_poll(1))) {

      // Read the words
      hpd_rx_stream_read(1, n, (void*)(0x80000000 | 
				       ((int)buffer + (n_received << 2))));

      n_received += n;
      printf("CPU0: \"%s\"\n", buffer);

      // Send something to CPU1
      hpd_tx_send_copy((int)buffer + (n_received - 4) * 4, 4, 0x207);
    }
    
  }

  printf("CPU0: retires!\n");
  while(1); return 0;
}
