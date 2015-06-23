#include "vga.h"

void vga_setbgcolor5x7(unsigned short color)
{
  background_5x7 = colores_5x7[color];
}
