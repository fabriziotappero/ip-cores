
#include "dma.h"

#define DMA_BUFFER_EXIST ( dma->ch[ch].wp != dma->ch[ch].rp )

#define DMA_BUFFER_EMPTY ( dma->ch[ch].wp == dma->ch[ch].rp )

#define DMA_BUFFER_FULL  ( ( ( dma->ch[ch].buf_size - 1 == dma->ch[ch].wp ) ? 0:  dma->ch[ch].wp + 1) == dma->ch[ch].rp )

#define DMA_BUFFER_WRITE \
	dma->ch[ch].buf[ dma->ch[ch].wp ].src  = src; \
	dma->ch[ch].buf[ dma->ch[ch].wp ].dst  = dst; \
	dma->ch[ch].buf[ dma->ch[ch].wp ].size = size; \
	dma->ch[ch].wp = ( dma->ch[ch].buf_size - 1 == dma->ch[ch].wp ) ? 0:  dma->ch[ch].wp + 1;

#define DMA_BUFFER_READ \
	src  = dma->ch[ch].buf[ dma->ch[ch].rp ].src; \
	dst  = dma->ch[ch].buf[ dma->ch[ch].rp ].dst; \
	size = dma->ch[ch].buf[ dma->ch[ch].rp ].size; \
	dma->ch[ch].rp = ( dma->ch[ch].buf_size - 1 == dma->ch[ch].rp ) ? 0:  dma->ch[ch].rp + 1;

void dma_init(DMA *dma,unsigned long int base,unsigned long int irq){
	unsigned long int i;
	unsigned long int offset;
	/* new */
	/* init dma */
	dma->base		= base; /* not-use */
	dma->irq		= irq;
	dma->info_add_intsrca	= base + DMA_BASE_INT_SRC_A; // dma control address info
	/* init ch */
	for (i=0,offset=0x00000020;i<dma->ch_size;i++,offset=offset+0x00000020) {
		dma->ch[i].wp		= 0;
		dma->ch[i].rp		= 0;
		dma->ch[i].busy		= 0;
		dma->ch[i].info_add_a0	= base + offset + DMA_CH_A0;	// ch src address info
		dma->ch[i].info_add_a1	= base + offset + DMA_CH_A1;	// ch dst address info
		dma->ch[i].info_add_sz	= base + offset + DMA_CH_SZ;	// ch size address info
		dma->ch[i].info_add_csr	= base + offset + DMA_CH_CSR;	// ch control address info
	}
	/* setup device */	
	REG32(base + DMA_BASE_INT_MSK_A)	= 0xffffffff;	// maskA is all_enable
	REG32(base + DMA_BASE_INT_MSK_B)	= 0x00000000;	// maskB (not-use,only A)
	REG32(base + DMA_BASE_CSR)		= 0x00000000;	// enable
	/* add interrupt handler */
	int_add(irq,&dma_handler,(void *)dma);
	return;
}

void dma_handler(void *argv){
	DMA *dma;
	unsigned long int ch;
	unsigned long int sta;
	unsigned long int mask;
	// handler pointer is dma.
	dma = (DMA *)argv;
	// Interrupt status check
	sta = REG32(dma->info_add_intsrca);
	// for chX
	for (ch=0,mask=0x00000001;ch<dma->ch_size;ch++,mask<<1) {
		if (0 != mask&sta) {
			REG32(dma->ch[ch].info_add_csr); // read to clear
			if (DMA_BUFFER_EXIST) {
				void *src;
				void *dst;
				unsigned long int size;
				DMA_BUFFER_READ
				REG32(dma->ch[ch].info_add_a0)	= (unsigned long int)src;
				REG32(dma->ch[ch].info_add_a1)	= (unsigned long int)dst;
				REG32(dma->ch[ch].info_add_sz)	= size & 0x00000fff;
				REG32(dma->ch[ch].info_add_csr)	= 0x00040019;
				dma->ch[ch].busy = 1;
			}
			else {
				dma->ch[ch].busy = 0;
			}
		}
	}
	return;
}
void dma_add(DMA *dma,unsigned long int ch,void *src,void *dst,unsigned long size){
	while (dma_add_full(dma,ch)) {} // blocking
int_disable(dma->irq);
	if ( 0 == dma->ch[ch].busy ) {
		REG32(dma->ch[ch].info_add_a0)	= (unsigned long int)src;
		REG32(dma->ch[ch].info_add_a1)	= (unsigned long int)dst;
		REG32(dma->ch[ch].info_add_sz)	= size & 0x00000fff;
		REG32(dma->ch[ch].info_add_csr)	= 0x00040019;
		dma->ch[ch].busy = 1;
	}
	else {
		DMA_BUFFER_WRITE
	}
int_enable(dma->irq);
	return;
}
unsigned long int dma_add_full(DMA *dma,unsigned long int ch){
	unsigned long int ret;
int_disable(dma->irq);
	ret = DMA_BUFFER_FULL;
int_enable(dma->irq);
	return ret;
}

