#include "storm_core.h"

/*----------------------------------------
  STORM Core Demo SoC Program
  by Stephan Nolting

  This program outputs the first 30
  Fibonacci numbers on the IO.O port.
  Afterwards it restarts.

  The program is allready loaded
  into the MEMORY.vhd test component.
----------------------------------------*/


/* ---- IO Device Locations ---- */
#define REG32 (volatile unsigned int*)
#define GPIO_OUT (*(REG32 (0xFFFFFE020)))
#define GPIO_IN  (*(REG32 (0xFFFFFE024)))


int main(void)
{
  int i, num_a, num_b, tmp = 0;

  GPIO_OUT = 0; // clear output

  while(1)
  {
	num_a = 0;
	num_b = 1;

    for(i=0; i<31; i++)
    {
	  GPIO_OUT = num_a;
	  tmp = num_a + num_b;
	  num_a = num_b;
	  num_b = tmp;
	}
  }

}
