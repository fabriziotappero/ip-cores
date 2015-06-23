#include "stdio.h"
#include "uart.h"

void putc(char c)
{
  uart_send_byte(c);  
}

void printf(char *string)
{
  int i;
  for (i=0; string[i] != '\0'; i++)
  {
    putc(string[i]); 
  }
}

void printInt(int num)
{
  int i = 0;
  // print first 3 digits.
  putc(((num%1000)/100) + 48);
  putc(((num % 100)/10) + 48);
  putc((num % 10) + 48);
  
}
