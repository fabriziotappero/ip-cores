#include "openfire.h"

// --------- uart #1 functions ----------
void uart1_printchar(unsigned char c)
{
  while( (*(volatile unsigned char *) UARTS_STATUS_REGISTER) & UART1_TX_BUFFER_FULL );	// wait empty buffer
  *(char *) UART1_TXRX_DATA = c;
}
