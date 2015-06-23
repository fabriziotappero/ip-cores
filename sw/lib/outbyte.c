#include "openfire.h"

/* outbyte -- shove a byte out the serial port. We wait till the byte  */
int outbyte( unsigned char c)
{
  uart1_printchar(c);
}
