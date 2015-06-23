#include "Edge_Atlys_LEDS.h"

void main()
{
  int i = 0;
  
  for(i=0; i<=10; i++)
    led_8b_send((char) i);
    
}
