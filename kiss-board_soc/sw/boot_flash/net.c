
#include "support.h"
#include "net.h"
#include "debug.h"

void net_init(void){

// software reset
	REG8(NET_BASE+NET_RESET)	= REG8(NET_BASE+NET_RESET);

// page0
	REG8(NET_BASE+NET_CR)		= NET_CR_PAGE_0 | NET_CR_DMA_ABORT | NET_CR_STOP;
	REG8(NET_BASE+NET_P0_DCR)	= NET_DCR_FIFO_8;
	REG8(NET_BASE+NET_P0_RBCR0)	= 0x00;
	REG8(NET_BASE+NET_P0_RBCR1)	= 0x00;
	REG8(NET_BASE+NET_P0_RCR)	= NET_RCR_MONITOR;
	REG8(NET_BASE+NET_P0_TCR)	= NET_TCR_LOOPBACK_INTERNAL;
	REG8(NET_BASE+NET_P0_TPSR)	= 0x40;
	REG8(NET_BASE+NET_P0_PSTART)	= 0x46;
	REG8(NET_BASE+NET_P0_BNRY)	= 0x46;
	REG8(NET_BASE+NET_P0_PSTOP)	= 0x60;
	REG8(NET_BASE+NET_P0_IMR)	= 0x00; // interrupt all disable
	REG8(NET_BASE+NET_P0_ISR)	= 0xff; // interrupt status all clear
	
// page1
	REG8(NET_BASE+NET_CR)		= NET_CR_PAGE_1 | NET_CR_DMA_ABORT | NET_CR_STOP;
	REG8(NET_BASE+NET_P1_PAR0)	= 0x00; // mac
	REG8(NET_BASE+NET_P1_PAR1)	= 0x22;
	REG8(NET_BASE+NET_P1_PAR2)	= 0x33;
	REG8(NET_BASE+NET_P1_PAR3)	= 0x44;
	REG8(NET_BASE+NET_P1_PAR4)	= 0x55;
	REG8(NET_BASE+NET_P1_PAR5)	= 0x00;
	REG8(NET_BASE+NET_P1_CURR)	= 0x47;
	REG8(NET_BASE+NET_P1_MAR0)	= 0x00; // multi-cast
	REG8(NET_BASE+NET_P1_MAR1)	= 0x00;
	REG8(NET_BASE+NET_P1_MAR2)	= 0x00;
	REG8(NET_BASE+NET_P1_MAR3)	= 0x00;
	REG8(NET_BASE+NET_P1_MAR4)	= 0x00;
	REG8(NET_BASE+NET_P1_MAR5)	= 0x00;
	REG8(NET_BASE+NET_P1_MAR6)	= 0x00;
	REG8(NET_BASE+NET_P1_MAR7)	= 0x00;
	
// page0
	REG8(NET_BASE+NET_CR)		= NET_CR_PAGE_0 | NET_CR_DMA_ABORT | NET_CR_STOP;
	REG8(NET_BASE+NET_P0_RCR)	= 0x00; //NET_RCR_BOARDCAST;

// page0
	REG8(NET_BASE+NET_CR)		= NET_CR_PAGE_0 | NET_CR_DMA_ABORT | NET_CR_START;
	REG8(NET_BASE+NET_P0_TCR)	= NET_TCR_LOOPBACK_NORMAL;

// end
	return;
}

void net_send(void){

// wait ok
	while ( 0x00 != ( REG8(NET_BASE+NET_CR)&NET_CR_SEND ) ){};

// page0 DMA setup
	REG8(NET_BASE+NET_CR)		= NET_CR_PAGE_0 | NET_CR_DMA_ABORT | NET_CR_START;
	REG8(NET_BASE+NET_P0_ISR)	= 0xff;
	REG8(NET_BASE+NET_P0_RSAR0)	= 0x00;
	REG8(NET_BASE+NET_P0_RSAR1)	= 0x40; // 0x4000 REMOTE-DMA ADDRESS
	REG8(NET_BASE+NET_P0_RBCR0)	= 0x0e;
	REG8(NET_BASE+NET_P0_RBCR1)	= 0x01; // 0x010e REMOTE-DMA SIZE(256+14)

// page0 DMA do
	REG8(NET_BASE+NET_CR)		= NET_CR_PAGE_0 | NET_CR_DMA_WRITE | NET_CR_START;
	//
	REG8(NET_BASE+NET_DMA)		= 0xff; // dst0
	REG8(NET_BASE+NET_DMA)		= 0xff; // dst1
	REG8(NET_BASE+NET_DMA)		= 0xff; // dst2
	REG8(NET_BASE+NET_DMA)		= 0xff; // dst3
	REG8(NET_BASE+NET_DMA)		= 0xff; // dst4
	REG8(NET_BASE+NET_DMA)		= 0xff; // dst5
	//
	REG8(NET_BASE+NET_DMA)		= 0x00; // src0
	REG8(NET_BASE+NET_DMA)		= 0x22; // src1
	REG8(NET_BASE+NET_DMA)		= 0x33; // src2
	REG8(NET_BASE+NET_DMA)		= 0x44; // src3
	REG8(NET_BASE+NET_DMA)		= 0x55; // src4
	REG8(NET_BASE+NET_DMA)		= 0x00; // src5
	//
	REG8(NET_BASE+NET_DMA)		= 0x10; // type1
	REG8(NET_BASE+NET_DMA)		= 0x00; // type0 0x1000
	//
	{
		unsigned long int i;
		for (i=0;i<256;i++) REG8(NET_BASE+NET_DMA) = (unsigned char)i;
	}

// page0 TX setup
	REG8(NET_BASE+NET_CR)		= NET_CR_PAGE_0 | NET_CR_DMA_ABORT | NET_CR_START;
	REG8(NET_BASE+NET_P0_TBCR0)	= 0x0e;
	REG8(NET_BASE+NET_P0_TBCR1)	= 0x01; // 0x010e TX SIZE(256+14)

// page0 TX do
	REG8(NET_BASE+NET_CR)		= NET_CR_PAGE_0 | NET_CR_DMA_ABORT | NET_CR_SEND | NET_CR_START;

// end
	return;
}

void net_recv(void){
	unsigned char bnry;
	unsigned char curr;
	unsigned char rsr;
	unsigned char next;
	unsigned char len0;
	unsigned char len1;
	unsigned long int temp;
	static unsigned long int count = 0;
	static unsigned long int done = 0;
	
	unsigned char head;
	
// page0 bnry
	REG8(NET_BASE+NET_CR)		= NET_CR_PAGE_0 | NET_CR_DMA_ABORT | NET_CR_START;
	bnry				= REG8(NET_BASE+NET_P0_BNRY);
// page1 curr
	REG8(NET_BASE+NET_CR)		= NET_CR_PAGE_1 | NET_CR_DMA_ABORT | NET_CR_START;
	curr				= REG8(NET_BASE+NET_P1_CURR);
// exist check
	head = (bnry==0x5f) ? 0x46: bnry + 0x01; 
	if(curr==head) {
		REG8(NET_BASE+NET_CR)		= NET_CR_PAGE_0 | NET_CR_DMA_ABORT | NET_CR_START;
		return;
	}
// page0 DMA setup
	REG8(NET_BASE+NET_CR)		= NET_CR_PAGE_0 | NET_CR_DMA_ABORT | NET_CR_START;
	REG8(NET_BASE+NET_P0_ISR)	= 0xff;
	REG8(NET_BASE+NET_P0_RSAR0)	= 0x00;
	REG8(NET_BASE+NET_P0_RSAR1)	= head;
	REG8(NET_BASE+NET_P0_RBCR0)	= 0x04;
	REG8(NET_BASE+NET_P0_RBCR1)	= 0x00;
// page0 DMA do
	REG8(NET_BASE+NET_CR)		= NET_CR_PAGE_0 | NET_CR_DMA_READ | NET_CR_START;
// byte access(its slow,so memory controler is poor,always sequence is long int...)
	rsr				= REG8(NET_BASE+NET_DMA);
	next				= REG8(NET_BASE+NET_DMA);
	len0				= REG8(NET_BASE+NET_DMA);
	len1				= REG8(NET_BASE+NET_DMA);
// long int access
	//temp				= REG32(NET_BASE+NET_DMA);
	//rsr				= (temp&0xff000000)>>24;
	//next				= (temp&0x00ff0000)>>16;
	//len0				= (temp&0x0000ff00)>> 8;
	//len1				= (temp&0x000000ff)>> 0;
// data check
	if(0x00==(rsr&0x01)) {
		REG8(NET_BASE+NET_CR)	= NET_CR_PAGE_0 | NET_CR_DMA_ABORT | NET_CR_START;
		REG8(NET_BASE+NET_P0_BNRY)	= (next==0x46) ? 0x5f: next-0x01;
		return;
	}
// data read(print header)
	if(done==0){
		long int x;
		long int y;
		unsigned char debug_text[DEBUG_TEXT_LEN+1];
		//
		x = syscall(SYS_SCREEN_GET_LOCATE_X);
		y = syscall(SYS_SCREEN_GET_LOCATE_Y);
		//
		syscall(SYS_SCREEN_LOCATE,0,480-12-12-12-12);
		syscall(SYS_SCREEN_PUT_STRING,"head,curr,rsr,next,len1,len0,count:");
		debug_convert( (unsigned long int)head , debug_text , 2 , 16 );
		syscall(SYS_SCREEN_PUT_STRING,debug_text);syscall(SYS_SCREEN_PUT_STRING," ");
		debug_convert( (unsigned long int)curr , debug_text , 2 , 16 );
		syscall(SYS_SCREEN_PUT_STRING,debug_text);syscall(SYS_SCREEN_PUT_STRING," ");
		debug_convert( (unsigned long int)rsr  , debug_text , 2 , 16 );
		syscall(SYS_SCREEN_PUT_STRING,debug_text);syscall(SYS_SCREEN_PUT_STRING," ");
		debug_convert( (unsigned long int)next , debug_text , 2 , 16 );
		syscall(SYS_SCREEN_PUT_STRING,debug_text);syscall(SYS_SCREEN_PUT_STRING," ");
		debug_convert( (unsigned long int)len0 , debug_text , 2 , 16 );
		syscall(SYS_SCREEN_PUT_STRING,debug_text);syscall(SYS_SCREEN_PUT_STRING," ");
		debug_convert( (unsigned long int)len1 , debug_text , 2 , 16 );
		syscall(SYS_SCREEN_PUT_STRING,debug_text);syscall(SYS_SCREEN_PUT_STRING," ");
		debug_convert( (unsigned long int)count, debug_text , DEBUG_TEXT_LEN , 10 );
		syscall(SYS_SCREEN_PUT_STRING,debug_text);syscall(SYS_SCREEN_PUT_STRING," ");
		//
		syscall(SYS_SCREEN_SET_LOCATE_X,x);
		syscall(SYS_SCREEN_SET_LOCATE_Y,y);
	}
	done=0;
// release
	REG8(NET_BASE+NET_CR)		= NET_CR_PAGE_0 | NET_CR_DMA_ABORT | NET_CR_START;
	REG8(NET_BASE+NET_P0_BNRY)	= (next==0x46) ? 0x5f: next-0x01;

	count++;
// end
	return;
}

