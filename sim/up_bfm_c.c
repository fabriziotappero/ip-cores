#include <stdio.h>

#include "svdpi.h"
#include "dpiheader.h"
int up_bfm_c(double fw_delay)
{
  int cpu_addr_i;
  int cpu_data_i;
  int cpu_data_o;

  int t;
  for (t=0; t<=4000; t=t+4) 
  {
    
      cpu_addr_i = 0x0000c0a0+t;
      cpu_data_i = t+0;
      cpu_wr(cpu_addr_i, cpu_data_i);

      cpu_hd(50);

      cpu_addr_i = 0x0000c0a0+t;
      cpu_rd(cpu_addr_i, &cpu_data_o);

      cpu_hd(100);
  }

  return(0); /* Return success (required by tasks) */
}
