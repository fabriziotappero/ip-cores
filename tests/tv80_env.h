//
// Copyright (c) 2005 Guy Hutchison (ghutchis@opencores.org)
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

// Environment library
// Creates definitions of the special I/O ports used by the
// environment, as well as some utility functions to allow
// programs to print out strings in the test log.

#ifndef TV80_ENV_H
#define TV80_ENV_H

#include "tv80_scenv.h"

sfr at 0x80 sim_ctl_port;
sfr at 0x81 msg_port;
sfr at 0x82 timeout_port;
sfr at 0x83 max_timeout_low;
sfr at 0x84 max_timeout_high;
sfr at 0x90 intr_cntdwn;
sfr at 0x91 cksum_value;
sfr at 0x92 cksum_accum;
sfr at 0x93 inc_on_read;
sfr at 0x94 randval;
sfr at 0x95 nmi_cntdwn;
sfr at 0xA0 nmi_trig_opcode;

/* now included from scenv.h
#define SC_TEST_PASSED 0x01
#define SC_TEST_FAILED 0x02
#define SC_DUMPON      0x03
#define SC_DUMPOFF     0x04
*/

void print (char *string)
{
  char *iter;
  char timeout;

  timeout = timeout_port;
  timeout_port = 0x02;
  timeout_port = timeout;

  iter = string;
  while (*iter != 0) {
    msg_port = *iter++;
  }
}

void print_hex (unsigned int num)
{
  char i, digit;

  for (i=3; i>=0; i--) {
    digit = (num >> (i*4)) & 0xf;
    if (digit < 10) msg_port = digit + '0';
    else msg_port = digit + 'a' - 10;
  }
}

void print_num (int num)
{
  char cd = 0;
  int i;
  char digits[8];
  char timeout;

  timeout = timeout_port;
  timeout_port = 0x02;
  timeout_port = timeout;

  if (num == 0) { msg_port = '0'; return; }
  while (num > 0) {
    digits[cd++] = (num % 10) + '0';
    num /= 10;
  }
  for (i=cd; i>0; i--)
    msg_port = digits[i-1];
}

#define sim_ctl(code) sim_ctl_port = code

void set_timeout (unsigned int max_timeout)
{
  timeout_port = 0x02;

  max_timeout_low = (max_timeout & 0xFF);
  max_timeout_high = (max_timeout >> 8);

  timeout_port = 0x01;
}

#endif
