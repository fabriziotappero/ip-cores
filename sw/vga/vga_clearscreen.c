#include "vga.h"

void vga_clearscreen(void)
{
  unsigned *ptr = (unsigned *)&_VIDEO_RAM_ADDR, n;
  for(n = 0; n < 64 * 480; n++) *(ptr++) = background_5x7;
}  
