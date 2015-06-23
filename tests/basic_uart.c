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

sfr at 0x18 uart_dm0;
sfr at 0x19 uart_dm1;
sfr at 0x1a uart_iir;
sfr at 0x1b uart_lcr;
sfr at 0x1c uart_mcr;
sfr at 0x1d uart_lsr;
sfr at 0x1e uart_msr;
sfr at 0x1f uart_scr;

sfr at 0x80 sim_ctl_port;
sfr at 0x81 msg_port;
sfr at 0x82 timeout_port;

// THR (transmit holding register) is DM0
// RBR (receive buffer register) is also DM0

void print (char *string)
{
  char *iter;

  iter = string;
  while (*iter != 0) {
    msg_port = *iter++;
  }
}

char rxbuf[128];

void test_byte (unsigned char pattern) {
  unsigned char status, data;

  // send a byte through the UART
  uart_dm0 = pattern;

  // wait for byte to be received
  do {
    status = uart_lsr;
  } while ((status & 0x01) == 0);

  // fail if status byte indicates anything other
  // than data ready and transmitter empty
  if (status != 0x61) {
    print ("Incorrect status byte\n");
    sim_ctl_port = 0x02;
  }

  // read the sent byte and fail if it's not what we sent
  data = uart_dm0;
  if (data != pattern) {
    print ("Data miscompare\n");
    sim_ctl_port = 0x02;
  }
}

int main ()
{
  //print ("Hello, world!\n");

  int i, rx_count;

  // set divisor to 100
  uart_lcr = 0x8b;
  uart_dm0 = 0x02;
  uart_dm1 = 0x00;

  // line settings:
  // 8 bits, 1 stop bit, even parity
  uart_lcr = 0x0b;

  // turn on internal loopback in UART
  uart_mcr = 0x10;
  test_byte (0x55);
  test_byte (0x1F);

  // turn off loopback and use external loop
  uart_mcr = 0x00;
  test_byte (0xAA);
  test_byte (0xBD);

  // maybe do a checksum here
  sim_ctl_port = 0x01;

  return 0;
}

