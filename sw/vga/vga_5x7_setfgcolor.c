#include "vga.h"

void vga_setfgcolor5x7(unsigned short color)
{
  foreground_5x7 = colores_5x7[color];
}
