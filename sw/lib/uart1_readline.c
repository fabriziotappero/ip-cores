#include "openfire.h"

void uart1_readline(char *buffer)
{
  char tmp;
  do
  {
    *(buffer++) = tmp = uart1_readchar();
    uart1_printchar(tmp);
  } while(tmp != 0x0 && tmp != '\n' && tmp != '\r');
}

