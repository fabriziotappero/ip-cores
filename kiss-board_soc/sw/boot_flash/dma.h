
#ifndef __DMA_H
#define __DMA_H

#include "support.h"

//
// TSR1000x-board
//
#define DMA_IRQ			3
#define DMA_BASE		0x9f000000

//
// parameter
//
#define DMA_CH_SIZE		1
#define DMA_BUF_SIZE		4 //8192

//
// dma io
//
#define DMA_BASE_CSR		0x00000000
#define DMA_BASE_INT_MSK_A	0x00000004
#define DMA_BASE_INT_MSK_B	0x00000008
#define DMA_BASE_INT_SRC_A	0x0000000c
#define DMA_BASE_INT_SRC_B	0x00000010
#define DMA_CH_CSR		0x00000000
#define DMA_CH_SZ		0x00000004
#define DMA_CH_A0		0x00000008
#define DMA_CH_AM0		0x0000000c
#define DMA_CH_A1		0x00000010
#define DMA_CH_AM1		0x00000014
#define DMA_CH_DESC		0x00000018
#define DMA_CH_SWPTR		0x0000001c

struct dma_buffer {
	void *src;
	void *dst;
	unsigned long int size;
} typedef DMA_BUFFER;

struct dma_channel {
	unsigned long int wp;
	unsigned long int rp;
	unsigned long int busy;
	unsigned long int buf_size;
	unsigned long int info_add_a0;
	unsigned long int info_add_a1;
	unsigned long int info_add_sz;
	unsigned long int info_add_csr;
	DMA_BUFFER *buf;
} typedef DMA_CHANNEL;

struct dma {
	unsigned long int base;
	unsigned long int irq;
	unsigned long int ch_size;
	unsigned long int info_add_intsrca;
	DMA_CHANNEL *ch;
} typedef DMA;

// private
void				dma_handler(void *argv)									__attribute__ ((section(".icm")));

// public
void				dma_init(DMA *dma,unsigned long int base,unsigned long int irq)				__attribute__ ((section(".text")));
void				dma_add(DMA *dma,unsigned long int ch,void *src,void *dst,unsigned long int size)	__attribute__ ((section(".text")));
unsigned long int  		dma_add_full(DMA *dma,unsigned long int ch)						__attribute__ ((section(".text")));

#endif

