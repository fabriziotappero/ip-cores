#include "openfire.h"

/* havebyte() -- poll if a byte is available in the serial port */
int havebyte(void)
{
  return (*(volatile unsigned char *)UARTS_STATUS_REGISTER) & UART1_DATA_PRESENT;
}

