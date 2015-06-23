/*
 * it_cfg_monitor.cpp
 *
 *  Created on: Feb 15, 2011
 *      Author: hutch
 */

#include "it_cfg_monitor.h"

void it_cfg_monitor::event()
{
  if (reset_n == 0) {
    cfgo_trdy = 0;
    cfgo_rd_data = 0;
  } else {
    if (cfgo_irdy) {
      if (delay_cnt == -1)
        delay_cnt = rand() % 10 + 1;
      else delay_cnt--;

      if (delay_cnt == 0) {
        cfgo_trdy = 1;
        if (cfgo_write) {
          cfgo_rd_data = rand();
          printf ("itmon: read value %x\n", cfgo_rd_data.read());
        } else {
          printf ("itmon: wrote value %x\n", cfgo_wr_data.read());
        }
      } else
        cfgo_trdy = 0;
    }
  }
}
