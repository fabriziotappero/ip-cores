
#ifndef __VRAM_H
#define __VRAM_H

#include "image.h"
#include "dma.h"

//#define VRAM_BASE	0x02000000
#define VRAM_BASE	0x03000000

#define VRAM_SIZE	0x00100000
#define VRAM_VALUE	0xffffffff

struct vram {
	void *base;
	unsigned long int size;
	unsigned long int value;
	DMA *dma;
	unsigned long int dma_ch;
} typedef VRAM;

// public
void vram_init(VRAM *vram,DMA *dma,unsigned long int dma_ch)				__attribute__ ((section(".text")));
void vram_clear(VRAM *vram)								__attribute__ ((section(".icm")));
void vram_image_paste(VRAM *vram,IMAGE *img,unsigned long int x,unsigned long int y);		//__attribute__ ((section(".icm")));
void vram_image_paste_filter(VRAM *vram,IMAGE *img,unsigned long int x,unsigned long int y);	//__attribute__ ((section(".icm")));
void vram_image_clear(VRAM *vram,IMAGE *img,unsigned long int x,unsigned long int y);		//__attribute__ ((section(".icm")));

// priave

#endif

