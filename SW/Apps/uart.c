#include "uart.h"

void uart_send_byte(char byte)
{
  char *uart_byte_reg = UART_REG_BYTE;
  char *uart_byte_ctrl = UART_REG_CTRL;

  char isReady;
  
  for( ; ; )
  {
    isReady = *uart_byte_ctrl & 0x1;
    if(isReady)
    {
      *uart_byte_reg = byte;
      break;
    }
  }

}
