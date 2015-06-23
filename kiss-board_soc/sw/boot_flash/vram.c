
#include "vram.h"

void vram_init(VRAM *vram,DMA *dma,unsigned long int dma_ch){
	vram->base	= (void *)VRAM_BASE;
	vram->size	= VRAM_SIZE;
	vram->value	= VRAM_VALUE;
	vram->dma	= dma;
	vram->dma_ch	= dma_ch;
//	vram_clear(vram);
	return;
}
void vram_clear(VRAM *vram){
	unsigned long int *head;
	unsigned long int *tail;
	head = (unsigned long int *)vram->base;
	tail = (unsigned long int *)( (unsigned long int)vram->base + (unsigned long int)vram->size );
	while (head!=tail) {
		*head = vram->value;
		head++;
	}
	return;
}
void vram_image_paste(VRAM *vram,IMAGE *img,unsigned long int x,unsigned long int y){
	unsigned short int *s,*d;
	unsigned long int i,j;
	unsigned long int height;
	unsigned long int width;
	height	= img->height;
	width	= img->width;
	s = (unsigned short int *)img->src;
	for (i=0;i<height;i++){
		d = (unsigned short int *)( (unsigned long int)vram->base + (x*2) + ((y+i)*(1024*2)) );
		for (j=0;j<width;j++) {
			*d = *s;
			s++;
			d++;
		}
		// only odd pixel,so dma supported 32bit transfer
		//if (NULL==vram->dma) {
		//	for (j=0;j<width;j++) {
		//		*d = *s;
		//		s++;
		//		d++;
		//	}
		//}
		//else {
		//	dma_add(vram->dma,vram->dma_ch,(void *)s,(void *)d,img->width/2);
		//	s = s + img->width;
		//}
	}
	return;
}
void vram_image_paste_filter(VRAM *vram,IMAGE *img,unsigned long int x,unsigned long int y){
	unsigned short int *s,*d;
	unsigned long int i,j;
	unsigned long int height;
	unsigned long int width;
	unsigned long int x2y2;
	height	= img->height;
	width	= img->width;
	x2y2	= (img->height>>1)*(img->height>>1) + (img->width>>1)*(img->width>>1);
	s = (unsigned short int *)img->src;
	for (i=0;i<height;i++){
		d = (unsigned short int *)( (unsigned long int)vram->base + (x*2) + ((y+i)*(1024*2)) );
		for (j=0;j<width;j++) {
			unsigned short int ss;
			signed long int r,g,b;
			signed long int y,u,v;
			unsigned short int rgb565;
			ss = *s;
			{
				r = (0x0000f800&(ss))>>8 | 0x00000007; // R:5bit+LSB MASK
				g = (0x000007e0&(ss))>>3 | 0x00000003; // G:6bit+LSB MASK
				b = (0x0000001f&(ss))<<3 | 0x00000007; // B:5bit+LSB MASK
			}
			{
				// rgb -> yuv
				y = ( ( 38 * r) + ( 75 * g) + ( 15 * b) ) >> 7; // gcc is supported shift-arithmetic
				u = ( (-22 * r) + (-42 * g) + ( 64 * b) ) >> 7; // gcc is supported shift-arithmetic
				v = ( ( 64 * r) + (-54 * g) + (-10 * b) ) >> 7; // gcc is supported shift-arithmetic
			}
			{
				// clip
				y = ((y<0   ) ?    0: (y>255) ? 255: y); // y is unsigned
				u = ((u<-128) ? -128: (u>127) ? 127: u); 
				v = ((v<-128) ? -128: (v>127) ? 127: v);			
			}
			{
				// y modulation
				//signed long int half1;
			//	signed long int half2;
				unsigned long int rr;
				unsigned long int xx,yy;
				unsigned long int xx2,yy2;
				//half1 = y >> 1;
			//	half2 = y >> 2;
			//	y = y + half2;	// x1.25
				//y = y * 1.25;		// is float its slow!
				//y = y * 0.55;		// is float its slow!
				//
				xx2 = width>>1;
				yy2 = height>>1;
				xx = (j>xx2) ? j-xx2: xx2-j;
				yy = (i>yy2) ? i-yy2: yy2-i;
				//
				rr = (xx * xx) + (yy * yy);						// (20^2+25^2)=1025 (30^2+40^2)
				//y  = (y * (x2y2-rr)) >> 11;						//
				y  = (y * ((x2y2-rr)*(x2y2-rr))) >> 22;					//
				//y  = (y * ((rr)*(rr))) >> 20;						//
			}
			{
				// yuv -> rgb
				r = ( ( 128 * y) + (    0 * u) + ( 178 * v) ) >> 7;
				g = ( ( 128 * y) + (-  44 * u) + (- 91 * v) ) >> 7;
				b = ( ( 128 * y) + (  227 * u) + (   0 * v) ) >> 7;
			}
			{
				// clip
				r = ((r<0) ? 0: (r>255) ? 255: r);
				g = ((g<0) ? 0: (g>255) ? 255: g);
				b = ((b<0) ? 0: (b>255) ? 255: b);				
			}
			{
				rgb565 = (0x0000f800&(r<<8)) | (0x000007e0&(g<<3)) | (0x0000001f&(b>>3));
			}
			*d = rgb565;
			s++;
			d++;
		}
	}
	return;
}
void vram_image_clear(VRAM *vram,IMAGE *img,unsigned long int x,unsigned long int y){
	unsigned short int *d;
	unsigned long int i,j;
	unsigned long int height;
	unsigned long int width;
	unsigned long int value;
	height	= img->height;
	width	= img->width;
	value	= 0x0000;
	for (i=0;i<height;i++){
		d = (unsigned short int *)( (unsigned long int)vram->base + (x*2) + ((y+i)*(1024*2)) );
		for (j=0;j<width;j++) {
			*d = value;
			d++;
		}
	}
	return;
}

