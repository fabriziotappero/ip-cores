/* datos para el vga 5x7 */
extern unsigned short bitmap_font_5x7[];
extern unsigned short background_5x7;
extern unsigned short foreground_5x7;
extern unsigned short colores_5x7[];
extern unsigned short xpos_5x7;
extern unsigned short ypos_5x7;
extern unsigned _VIDEO_RAM_ADDR;

void vga_putchar5x7(char caracter, unsigned short pos_x, unsigned short pos_y);
void vga_putline5x7(char *s, unsigned short x, unsigned short y);
void vga_setfgcolor5x7(unsigned short color);
void vga_setbgcolor5x7(unsigned short color);

/* funciones vga generales */
void vga_clearscreen(void);
void vga_drawpixel(unsigned short x, unsigned short y, unsigned short color);
