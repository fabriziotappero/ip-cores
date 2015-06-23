#include "Edge_Atlys_LEDS.h"

void led_8b_send(char pattern)
{
  *((char *)UART_REG_LED) = pattern;
}
