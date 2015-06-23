
#include "screen.h"

// public
void screen_init(SCREEN *screen,VRAM *vram){
	screen->height		= SCREEN_HEIGHT;
	screen->width		= SCREEN_WIDTH;
	screen->x		= 0;
	screen->y		= 0;
	screen->color_fg	= FONT_COLOR_BLUE;
	screen->color_bg	= FONT_COLOR_WHITE;
	screen->font_height	= FONT_HEIGHT;
	screen->font_width	= FONT_WIDTH;
	//screen->dma		= dma;
	//screen->dma_ch	= dma_ch;
	screen->vram		= vram;
	return;
}
void screen_clear(SCREEN *screen){
	return;
}
void screen_locate(SCREEN *screen,unsigned long int x,unsigned long int y){
	screen->x = x;
	screen->y = y;
	return;
}
void screen_put_string(SCREEN *screen,unsigned char *s){
	unsigned char *p;
	for (p=s;*p!='\0';p++) screen_put_char(screen,*p);
	return;
}
void screen_put_char(SCREEN *screen,unsigned char c){
	// do scroll to current draw(draw-font)
	screen_scroll(screen,screen->font_height);
	//
	switch(c){
		case '\n': {
			screen_print(screen,c);
			screen->x = 0;
			screen->y += screen->font_height;
		} break;
		case '\r': {
			screen_print(screen,c);
			screen->x = 0;
		} break;
		case '\t': {
			screen_put_string(screen,"        ");
		} break;
		default: {
			screen_print(screen,c);
			screen->x += screen->font_width;
		} break;
	}
	// do scroll to next draw(same font)
	screen_scroll(screen,screen->font_height);
	return;
}

// private
void screen_scroll(SCREEN *screen,unsigned long int height){
	unsigned long int pos;
	pos = screen->y + height;
	if (screen->height<=pos) { // need scrooll
		screen->y = screen->height - height;
		// add vga scroll(add pos%screen-height)
		// ...
	}
	return;
}
void screen_print(SCREEN *screen,unsigned char c){
	IMAGE image;
	int i,j;
	unsigned char t;
	unsigned short int *p;
	unsigned short int font_buffer[FONT_HEIGHT*FONT_WIDTH];
	image.height	= screen->font_height;
	image.width	= screen->font_width;
	image.src	= font_buffer;
	for (i=0,p=font_buffer;i<screen->font_height;i++) {
		t = fonts[c][i];
		for (j=0;j<screen->font_width;j++,p++,t>>=1) *p = (t&0x01) ? screen->color_fg: screen->color_bg;
	}
	//
	// paste
	//
	//image_paste(&image,NULL,0,screen->x,screen->y);
	vram_image_paste(screen->vram,&image,screen->x,screen->y);
	return;
}
//void screen_image(SCREEN *screen,IMAGE *image){
//	// use DMA
//	//image_paste(image,screen->dma,screen->dma_ch,screen->x,screen->y);
//	// not-use DMA
//	//image_paste(image,NULL,0,screen->x,screen->y);
//	vram_image_paste(screen->vram,&image,screen->x,screen->y);
//	return;
//}
void screen_set_locate_x(SCREEN *screen,unsigned long int x){
	screen->x = x;
}
void screen_set_locate_y(SCREEN *screen,unsigned long int y){
	screen->y = y;
}
unsigned long int screen_get_locate_x(SCREEN *screen){
	return screen->x;
}
unsigned long int screen_get_locate_y(SCREEN *screen){
	return screen->y;
}
void screen_set_color_fg(SCREEN *screen,unsigned long int r,unsigned long int g,unsigned long int b){
	unsigned long int rr,gg,bb;
	rr = r & 0x0000001f;
	gg = g & 0x0000003f;
	bb = b & 0x0000001f;
	screen->color_fg = (rr<<11) | (gg<<5) | (bb<<0); // RGB565
	return;
}
void screen_set_color_bg(SCREEN *screen,unsigned long int r,unsigned long int g,unsigned long int b){
	unsigned long int rr,gg,bb;
	rr = r & 0x0000001f;
	gg = g & 0x0000003f;
	bb = b & 0x0000001f;
	screen->color_bg = (rr<<11) | (gg<<5) | (bb<<0); // RGB565
	return;
}

