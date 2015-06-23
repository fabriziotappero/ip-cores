
#ifndef __SCREEN_H
#define __SCREEN_H

#include "image.h"
#include "dma.h"
#include "vram.h"
#include "font.h"
#include "debug.h"

#define SCREEN_HEIGHT	480
#define SCREEN_WIDTH	640

struct screen {
	unsigned long int height;
	unsigned long int width;
	unsigned long int x;
	unsigned long int y;
	unsigned short int color_fg;
	unsigned short int color_bg;
	unsigned long int font_height;
	unsigned long int font_width;
//	DMA *dma;
//	unsigned long int dma_ch;
	VRAM *vram;
} typedef SCREEN;

// public
void				screen_init(SCREEN *screen,VRAM *vram)									__attribute__ ((section(".text")));
void				screen_clear(SCREEN *screen)										__attribute__ ((section(".text")));
void				screen_locate(SCREEN *screen,unsigned long int x,unsigned long int y)					__attribute__ ((section(".text")));
void				screen_scroll(SCREEN *screen,unsigned long int height)							__attribute__ ((section(".text")));
void				screen_put_string(SCREEN *screen,unsigned char *s)							__attribute__ ((section(".text")));
void				screen_put_char(SCREEN *screen,unsigned char c)								__attribute__ ((section(".text")));
void				screen_print(SCREEN *screen,unsigned char c)								__attribute__ ((section(".text")));
//void				screen_image(SCREEN *screen,IMAGE *image)								__attribute__ ((section(".text")));
void				screen_set_locate_x(SCREEN *screen,unsigned long int x)							__attribute__ ((section(".text")));
void				screen_set_locate_y(SCREEN *screen,unsigned long int y)							__attribute__ ((section(".text")));
unsigned long int		screen_get_locate_x(SCREEN *screen)									__attribute__ ((section(".text")));
unsigned long int		screen_get_locate_y(SCREEN *screen)									__attribute__ ((section(".text")));
void				screen_set_color_fg(SCREEN *screen,unsigned long int r,unsigned long int g,unsigned long int b)		__attribute__ ((section(".text")));
void				screen_set_color_bg(SCREEN *screen,unsigned long int r,unsigned long int g,unsigned long int b)		__attribute__ ((section(".text")));

#endif

