#include "vga.h"
#include <stdio.h>
#include <math.h>

#define PI 3.14159265

char buffer[256];

void main(void)
{
   unsigned n, m, c = 0;
   vga_clearscreen();
   
   for(m = 0; m < 8; m++)
   {
     for(n = 0; n < 8; n++)
     {
       vga_setfgcolor5x7( n );
       vga_setbgcolor5x7( m );
       vga_putline5x7("HOLA", 10 + m * 4, 10 + n);
     }
   }
   vga_setfgcolor5x7(7);
   vga_setbgcolor5x7(1);
   
   for(n = 100; n < 540; n++)
   {
     vga_drawpixel(n, 100, 7);
     vga_drawpixel(n, 380, 7);
   }
   
   for(n = 100; n < 380; n++)
   {
     vga_drawpixel(100, n, 7);
     vga_drawpixel(540, n, 7);
   }
   
   for(n = 0; n < 360; n++)
   {     
     float x, y;
     x = 320 + 100 * cos(n * (2*PI) / 360.0);
     y = 240 + 100 * sin(n * (2*PI) / 360.0);
     
     //printf("n=%u, x=%f  y=%f\r\n", n, x, y);
     //vga_putline5x7(buffer, 5, 5);
     
     vga_drawpixel(x, y, 7);
   }
   
}
