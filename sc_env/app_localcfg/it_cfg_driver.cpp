#include "it_cfg_driver.h"

void it_cfg_driver::add_queue (uint32_t d)
{
  send_queue.push (d);
}

void it_cfg_driver::event()
{
  if (reset_n == 0) {
    cfgi_irdy = 0;
    cfgi_addr = 0;
    cfgi_write = 0;
    cfgi_wr_data = 0;
  } else {
    if (cfgi_irdy == 0) {
      // check the send queue
      if (!send_queue.empty()) {
        cfgi_irdy = 1;
        cfgi_addr = addr++;
        cfgi_wr_data = send_queue.front();
        send_queue.pop();
        cfgi_write = 1;
      }
    } else {
      if (cfgi_trdy == 1) {
        // check the send queue and send data
        if (!send_queue.empty()) {
          cfgi_irdy = 1;
          cfgi_addr = addr++;
          cfgi_wr_data = send_queue.front();
          send_queue.pop();
          cfgi_write = 1;
        } else {
          cfgi_irdy = 0;
        }
      }
    }

    while (!send_queue.empty() && (send_queue.front() == 0)) {
      send_queue.pop();
      addr++;
    }
  }
}
