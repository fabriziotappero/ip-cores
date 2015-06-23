
#ifndef __FONT_H
#define __FONT_H

#define FONT_HEIGHT		12
#define FONT_WIDTH		8

#define FONT_COLOR_BLACK	0x0000
#define FONT_COLOR_RED		0xf800
#define FONT_COLOR_GREEN	0x07e0
#define FONT_COLOR_BLUE		0x001f
#define FONT_COLOR_WHITE	0xffff

struct font {
	unsigned long int height;
	unsigned long int width;
	unsigned short int image[256][FONT_HEIGHT*FONT_WIDTH];
} typedef FONT;

// public
extern	const unsigned char fonts[256][FONT_HEIGHT];
void	font_init(FONT *font,unsigned short int fg,unsigned short int bg);
void	font_gen(FONT *font,unsigned char c,unsigned short int fg,unsigned short int bg);

#endif
