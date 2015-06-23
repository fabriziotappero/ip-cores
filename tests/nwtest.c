//
// Copyright (c) 2004 Guy Hutchison (ghutchis@opencores.org)
//
// Permission is hereby granted, free of charge, to any person obtaining a 
// copy of this software and associated documentation files (the "Software"), 
// to deal in the Software without restriction, including without limitation 
// the rights to use, copy, modify, merge, publish, distribute, sublicense, 
// and/or sell copies of the Software, and to permit persons to whom the 
// Software is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included 
// in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, 
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF 
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. 
// IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY 
// CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, 
// TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE 
// SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
//
//
//  IO-interface:
//    R0  --  Status register
//    R1  --  Control register
//    R2  --  RX Length (low)
//    R3  --  RX Length (high)
//    R4  --  RX Data
//    R5  --  TX Data
//    R6  --  Configuration
//
sfr at 0x08 nw_status;
sfr at 0x09 nw_status_msk;
sfr at 0x0A nw_control;
sfr at 0x0B nw_rx_cnt_low;
sfr at 0x0C nw_rx_cnt_high;
sfr at 0x0D nw_rx_data;
sfr at 0x0E nw_tx_data;
sfr at 0x0F nw_config;

sfr at 0x80 sim_ctl_port;
sfr at 0x81 msg_port;
sfr at 0x82 timeout_port;

void print (char *string)
{
  char *iter;

  iter = string;
  while (*iter != 0) {
    msg_port = *iter++;
  }
}

char rxbuf[128];

int main ()
{
  //print ("Hello, world!\n");

  int i, rx_count;

  // configure nwintf to use preambles
  nw_config = 1;

  // send packet to buffer and trigger transmit
  for (i=0; i<64; i++)
    nw_tx_data = i;

  nw_control = 1;

  // wait for packet to be sent
  while ((nw_status & 0x02) != 2) ;

  // check and clear the TX status bit
  //if ((nw_status & 0x02) != 2)
  //sim_ctl_port = 0x02;
    //else
  nw_status = 0x02;

  // wait for packet to arrive on loopback
  while ((nw_status & 0x01) != 1)
    ;

  rx_count = nw_rx_cnt_low | (nw_rx_cnt_high << 8);

  if (rx_count != 64)
    sim_ctl_port = 0x02;

  // pull all the data from the interface into a buffer
  //for (i=0; i<rx_count; i++)
  //  rxbuf[i] = nw_rx_data;
  _asm
    in    a, (_nw_rx_cnt_low)
    ld    b, a
    ld    hl, #_rxbuf
    ld    c, #_nw_rx_data
    inir
  _endasm;

  // clear the RX status bit
  nw_status = 0x01;

  // check the status bit
  if (nw_status != 0)
    sim_ctl_port = 0x02;

  // maybe do a checksum here
  sim_ctl_port = 0x01;

  return 0;
}

