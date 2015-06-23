
#include "support.h"
#include "timer.h"
#include "dma.h"
#include "screen.h"
#include "vram.h"
#include "uart.h"
#include "debug.h"

#include "syscall.h"

//
// main object
//
static TIMER		timer					__attribute__ ((section(".bss")));

static DMA		dma					__attribute__ ((section(".bss")));
static DMA_BUFFER	dma_buffer_ch0[DMA_BUF_SIZE]		__attribute__ ((section(".bss")));
static DMA_CHANNEL	dma_channel[DMA_CH_SIZE]		__attribute__ ((section(".bss")));

static SCREEN		scr					__attribute__ ((section(".bss")));

static VRAM		vram					__attribute__ ((section(".bss")));

static UART		uart;
static UART_BUFFER	uart_buffer_tx[UART_TX_BUF_SIZE]	__attribute__ ((section(".bss")));
static UART_BUFFER	uart_buffer_rx[UART_RX_BUF_SIZE]	__attribute__ ((section(".bss")));

static int		dummy					__attribute__ ((section(".extbss")));

//
// syscall entry point
//
long int syscall(unsigned long int command,...){
	int ret;
	va_list  ap;
	ret = 0;
	va_start(ap,command);
	switch (command) {
	// SYS
		case SYS_INIT: {
			tick_init();			// raw-handler
			int_init();			// raw-handler
			syscall(SYS_TIMER_INIT);
			syscall(SYS_DMA_INIT);
			syscall(SYS_VRAM_INIT);
			syscall(SYS_SCREEN_INIT);
			syscall(SYS_UART_INIT);
			ret = 0;
		} break;
	// TIMER
		case SYS_TIMER_INIT: {
			timer_init(&timer);
			ret = 0;
		} break;
		case SYS_TIMER_GET_COUNT: {
			ret = timer_get_count(&timer);
		} break;
	// DMA
		case SYS_DMA_INIT: {
			unsigned long int base;
			unsigned long int irq;
			base	= va_arg(ap,unsigned long int);
			irq	= va_arg(ap,unsigned long int);
			dma.ch			= dma_channel;
			dma.ch_size		= DMA_CH_SIZE;
			dma.ch[0].buf		= dma_buffer_ch0;
			dma.ch[0].buf_size	= DMA_BUF_SIZE;
			dma_init(&dma,DMA_BASE,DMA_IRQ);
			ret = 0;
		} break;
		case SYS_DMA_ADD: {
			unsigned long int ch;
			void *src;
			void *dst;
			unsigned long int size;
			ch	= va_arg(ap,unsigned long int);
			src	= va_arg(ap,void *);
			dst	= va_arg(ap,void *);
			size	= va_arg(ap,unsigned long int);
			dma_add(&dma,ch,src,dst,size);
			ret = 0;
		} break;
		case SYS_DMA_ADD_FULL: {
			unsigned long int ch;
			ch	= va_arg(ap,unsigned long int);
			ret = (long int)dma_add_full(&dma,ch);
		} break;
		case SYS_DMA_GET_HANDLE: {
			ret = (long int)&dma;
		} break;
		case SYS_DMA_GET_CH: {
			ret = 0;
		} break;
	// VRAM
		case SYS_VRAM_INIT: {
			vram_init(&vram,&dma,0);
			ret = 0;
		} break;
		case SYS_VRAM_CLEAR: {
			vram_clear(&vram);
			ret = 0;
		} break;
		case SYS_VRAM_IMAGE_PASTE: {
			IMAGE *img;
			unsigned long int x;
			unsigned long int y;
			img	= va_arg(ap,IMAGE *);
			x	= va_arg(ap,unsigned long int);
			y	= va_arg(ap,unsigned long int);
			vram_image_paste(&vram,img,x,y);
			ret = 0;
		} break;
		case SYS_VRAM_IMAGE_PASTE_FILTER: {
			IMAGE *img;
			unsigned long int x;
			unsigned long int y;
			img	= va_arg(ap,IMAGE *);
			x	= va_arg(ap,unsigned long int);
			y	= va_arg(ap,unsigned long int);
			vram_image_paste_filter(&vram,img,x,y);
			ret = 0;
		} break;
		case SYS_VRAM_IMAGE_CLEAR: {
			IMAGE *img;
			unsigned long int x;
			unsigned long int y;
			img	= va_arg(ap,IMAGE *);
			x	= va_arg(ap,unsigned long int);
			y	= va_arg(ap,unsigned long int);
			vram_image_clear(&vram,img,x,y);
			ret = 0;
		} break;
	// SCREEN
		case SYS_SCREEN_INIT: {
			screen_init(&scr,&vram);
			ret = 0;
		} break;
		case SYS_SCREEN_CLEAR: {
			screen_clear(&scr);
			ret = 0;
		} break;
		case SYS_SCREEN_LOCATE: {
			unsigned long int x;
			unsigned long int y;
			x	= va_arg(ap,unsigned long int);
			y	= va_arg(ap,unsigned long int);
			screen_locate(&scr,x,y);
			ret = 0;
		} break;
		case SYS_SCREEN_SCROLL: {
			unsigned long int height;
			height	= va_arg(ap,unsigned long int);
			screen_scroll(&scr,height);
			ret = 0;
		} break;
		case SYS_SCREEN_PUT_STRING: {
			unsigned char *s;
			s	= va_arg(ap,unsigned char *);
			screen_put_string(&scr,s);
			ret = 0;
		} break;
		case SYS_SCREEN_PUT_CHAR: {
			unsigned char c;
			c	= va_arg(ap,unsigned int); // usigned char
			screen_put_char(&scr,c);
			ret = 0;
		} break;
		case SYS_SCREEN_PRINT: {
			unsigned char c;
			c	= va_arg(ap,unsigned int); // unsigned char
			screen_print(&scr,c);
			ret = 0;
		} break;
		//case SYS_SCREEN_IMAGE: {
		//	IMAGE *image;
		//	image	= va_arg(ap,IMAGE *);
		//	screen_image(&scr,image);
		//	ret = 0;
		//} break;
		case SYS_SCREEN_SET_LOCATE_X: {
			unsigned long int x;
			x	= va_arg(ap,unsigned long int);
			screen_set_locate_x(&scr,x);
			ret = 0;
		} break;
		case SYS_SCREEN_SET_LOCATE_Y: {
			unsigned long int y;
			y	= va_arg(ap,unsigned long int);
			screen_set_locate_y(&scr,y);
			ret = 0;
		} break;
		case SYS_SCREEN_GET_LOCATE_X: {
			ret = screen_get_locate_x(&scr);
		} break;
		case SYS_SCREEN_GET_LOCATE_Y: {
			ret = screen_get_locate_y(&scr);
		} break;
		case SYS_SCREEN_SET_COLOR_FG: {
			unsigned long int r,g,b;
			r	= va_arg(ap,unsigned long int);
			g	= va_arg(ap,unsigned long int);
			b	= va_arg(ap,unsigned long int);
			screen_set_color_fg(&scr,r,g,b);
			ret = 0;
		} break;
		case SYS_SCREEN_SET_COLOR_BG: {
			unsigned long int r,g,b;
			r	= va_arg(ap,unsigned long int);
			g	= va_arg(ap,unsigned long int);
			b	= va_arg(ap,unsigned long int);
			screen_set_color_bg(&scr,r,g,b);
			ret = 0;
		} break;
	// UART
		case SYS_UART_INIT: {
			unsigned long int base;
			unsigned long int irq;
			base	= va_arg(ap,unsigned long int);
			irq	= va_arg(ap,unsigned long int);
			uart.tx.buf		= uart_buffer_tx;
			uart.tx.buf_size	= UART_TX_BUF_SIZE;
			uart.rx.buf		= uart_buffer_rx;
			uart.rx.buf_size	= UART_RX_BUF_SIZE;
			uart_init(&uart,UART_BASE,UART_IRQ);
			ret = 0;
		} break;
		case SYS_UART_GET: {
			ret = (long int)uart_get(&uart);
		} break;
		case SYS_UART_GET_EXIST: {
			ret = (long int)uart_get_exist(&uart);
		} break;
		case SYS_UART_GET_CLEAR: {
			uart_get_clear(&uart);
			ret = 0;
		} break;
		case SYS_UART_PUT: {
			unsigned int data;
			data	= va_arg(ap,unsigned int);
			uart_put(&uart,(unsigned char)data);
			ret = 0;
		} break;
		case SYS_UART_PUT_FULL: {
			ret = uart_put_full(&uart);
		} break;
		case SYS_UART_PUT_CLEAR: {
			uart_put_clear(&uart);
			ret = 0;
		} break;
		case SYS_UART_PUT_STRING: {
			unsigned char *string;
			string	= va_arg(ap,unsigned char *);
			uart_put_string(&uart,string);
			ret = 0;
		} break;
		case SYS_UART_IS_CTS: {
			ret = uart_is_cts(&uart);
		} break;
		case SYS_UART_IS_DSR: {
			ret = uart_is_dsr(&uart);
		} break;
		case SYS_UART_IS_RI: {
			ret = uart_is_ri(&uart);
		} break;
		case SYS_UART_IS_DCD: {
			ret = uart_is_dcd(&uart);
		} break;
		case SYS_UART_DTR: {
			unsigned long int data;
			data = va_arg(ap,unsigned long int);
			uart_dtr(&uart,data);
			ret = 0;
		} break;
		case SYS_UART_RTS: {
			unsigned long int data;
			data = va_arg(ap,unsigned long int);
			uart_rts(&uart,data);
			ret = 0;
		} break;
	}
	va_end(ap);
	return ret;
}
