#include "vga.h"

/* ---------------------------------------------- */
void vga_putchar5x7(char caracter, unsigned short pos_x, unsigned short pos_y)
{
  unsigned short y, scanline, row, scan;
  unsigned ptr = (unsigned)&_VIDEO_RAM_ADDR;

  scanline = (caracter - 0x20) * 7;		/* bitmap del caracter a mostrar */
  
  y = pos_y * 7;				/* 7 bits de alto por caracter */
  for(row = 0; row < 7; row++)			/* procesamos el caracter */
  {						/* pintamos la linea */
    scan = bitmap_font_5x7[scanline++];
    *(unsigned short *) (ptr + (y++ * 256) + pos_x * 2) = (scan & foreground_5x7) | (background_5x7 & ~scan);
  } 
}
