#include "vga.h"

void vga_drawpixel(unsigned short x, unsigned short y, unsigned short color)
{
  unsigned ptr = (unsigned) &_VIDEO_RAM_ADDR;
  
  unsigned short pixel, mascara = 0x7;
  unsigned short w = x / 5;			/* word donde esta el pixel */
  unsigned short p = 12 - (x % 5) * 3;	/* obtenemos el # de pixel dentro del grupo */
  
  ptr += y * 256 + w * 2;
    
  pixel = *(unsigned short *) ptr;	/* obtenemos el valor del grupo de 5 pixels */  
  mascara = ~(0x7 << p);		/* mascara para el pixel */
  color <<= p;				/* ponemos el pixel en su sitio */
  
  pixel &= mascara;	/* aplicamos la mascara en el pixel actual */
  pixel |= color;	/* dibujamos el pixel en el hueco de la mascara */  
  
  *(unsigned short *) ptr = pixel;
}
