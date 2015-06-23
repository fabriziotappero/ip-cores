/*
 * lfsr128.c -- a linear feedback shift register with 128 bits
 *              (actually constructed from 4 instances of a 32-bit lfsr)
 */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>


int main(void) {
  unsigned int startState[4] = {
    0xC70337DB,
    0x7F4D514F,
    0x75377599,
    0x7D5937A3
  };
  /* taps at 32 31 29 1 */
  unsigned int taps = 0xD0000001;
  unsigned int lfsr[4];
  int i, n;

  for (i = 0; i < 4; i++) {
    lfsr[i] = startState[i];
  }
  for (n = 0; n < 530; n++) {
    /*
     * The trigger condition in the actual hardware test will be set
     * to lfsr[0]==0x7119C0CD, which is reached at n==10. Therefore
     * we print out n-10 instead of n to get identical index numbers.
     */
    printf("%03d:  ", n - 10);
    for (i = 0; i < 4; i++) {
      printf("%02X  ", (lfsr[i] >> 24) & 0xFF);
      printf("%02X  ", (lfsr[i] >> 16) & 0xFF);
      printf("%02X  ", (lfsr[i] >>  8) & 0xFF);
      printf("%02X  ", (lfsr[i] >>  0) & 0xFF);
    }
    printf("\n");
    for (i = 0; i < 4; i++) {
      if ((lfsr[i] & 1) == 0) {
        lfsr[i] = lfsr[i] >> 1;
      } else {
        lfsr[i] = (lfsr[i] >> 1) ^ taps;
      }
    }
  }
  return 0;
}
