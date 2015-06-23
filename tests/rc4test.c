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

#include "tv80_env.h"
#include "rc4.h"
#include "stdint.h"

#define BUFSIZE 128

int main ()
{
  struct rc4_state rs;
  uint8_t key[16];
  int i;
  uint8_t pass;
  uint8_t buf1[BUFSIZE], buf2[BUFSIZE], buf3[BUFSIZE];

  print ("Start\n");
  // initialize key
  for (i=0; i<16; i++)
    key[i] = i;

  // init buf1
  for (i=0; i<BUFSIZE; i++)
    buf1[i] = i;

  // encrypt buf1->buf2
  print ("EncInit\n");
  rc4_init (&rs, key, 16);
  print ("Encrypting\n");
  rc4_crypt (&rs, buf1, buf2, BUFSIZE);

  // decrypt buf2->buf3
  print ("DecInit\n");
  rc4_init (&rs, key, 16);
  print ("Decrypting\n");
  rc4_crypt (&rs, buf2, buf3, BUFSIZE);

  // compare buf1 == buf3
  print ("Comparing\n");
  pass = 1;
  for (i=0; i<BUFSIZE; i++)
    if (buf1[i] != buf3[i])
      pass = 0;

  if (pass)
    sim_ctl_port = SC_TEST_PASSED;
  else
    sim_ctl_port = SC_TEST_FAILED;

  return 0;
}
