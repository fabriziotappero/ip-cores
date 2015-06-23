#include "openfire.h"

/* inbyte -- get a byte from the serial port with eco and translates \r --> \n */
unsigned char inbyte(void)
{
  unsigned char c = uart1_readchar();  
  if(c == '\r') c = '\n';
  outbyte(c);
  return c;
}
