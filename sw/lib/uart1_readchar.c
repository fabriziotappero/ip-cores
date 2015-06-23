#include "openfire.h"

char uart1_readchar(void)
{
  while( ((*(volatile unsigned char *) UARTS_STATUS_REGISTER) & UART1_DATA_PRESENT) == 0 );	// wait a received char
  return *(char *) UART1_TXRX_DATA;
}
