#include "vga.h"

void vga_putline5x7(char *s, unsigned short x, unsigned short y)
{
  unsigned c;
  
  while( (c = *(s++)) != 0 )
  {    
    if(c == '\r') x = 0;
    else if(c == '\n') { x = 0; y++; }
    else
    {
      if(c < 0x20 || c > 0x7f) c = '?';      
      vga_putchar5x7(c, x, y);
      x++;
      if(x == 128) { x = 0; y++; }
      if(y == 68) y = 0;
    }
  }
}
