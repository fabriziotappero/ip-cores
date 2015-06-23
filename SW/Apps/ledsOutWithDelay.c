#include "Edge_Atlys_LEDS.h"

void main()
{
  int i;
  int x = 1;
  
  for(i=0; i<=10; i++)
  {
    led_8b_send((char) x << i);
    fsleep(1000);
  }
    
}
