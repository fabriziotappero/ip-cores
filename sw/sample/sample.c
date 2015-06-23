#include <stdio.h>
#include <string.h>

char buffer[256];

void main(void)
{
  xil_printf("como te llamas? ");
  fgets(buffer, 255, stdin);
  xil_printf("\r\nhola: %s\r\n", buffer);

}
