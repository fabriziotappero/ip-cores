#include "orsocdef.h"
#include <stdlib.h>

#include "system.h"




#define EXT_INT_1	(1<<0)
#define EXT_INT_2	(1<<1)
#define EXT_INT_3	(1<<2)



const unsigned int seven_seg_tab [16] = {0x3F,0x06,0x5B,0x4F,0x66,0x6D,0x7D,0x07,0x7F,0x6F,0x77,0x7C,0x39,0x5E, 0x79,0x71};

void delay(unsigned int);
void ni_ISR ( void );
void timer_ISR( void );
void ext_int_ISR( void );

/*!
* Assembly macro to enable MSR_IE
*/
void aemb_enable_interrupt ()
{
  int msr, tmp;
  asm volatile ("mfs %0, rmsr;"
		"ori %1, %0, 0x02;"
		"mts rmsr, %1;"
		: "=r"(msr)
		: "r" (tmp)
		);
}


void myISR( void ) __attribute__ ((interrupt_handler));


unsigned int i;

void myISR( void )
{
	if( INTC_IPR & NI_INT )		ni_ISR();
	if( INTC_IPR & TIMER_INT )	timer_ISR();
	if( INTC_IPR & EXT_INT)		ext_int_ISR(); 
	INTC_IAR = INTC_IPR;		// Acknowledge Interrupts
}


void timer_ISR( void )
{
// Do Stuff Here
	i++;
	TCSR0 = TCSR0;
// Acknogledge Interrupt In Timer (Clear pending bit)
}



void ext_int_ISR( void )
{
// Do Stuff Here
	if(EXT_INT_ISR  & EXT_INT_1)	i=0xDEADBEAF;	
	if(EXT_INT_ISR  & EXT_INT_2)	i=0x12345678;
	if(EXT_INT_ISR  & EXT_INT_3)	i=0xAAAAAAAA;
	EXT_INT_ISR 	= EXT_INT_ISR;
// Clear any pending button interrupts
}

unsigned int ni_buffer	[32];

void ni_ISR( void )
{
// Do Stuff Here
	 save_pck	(ni_buffer, 32);
	 NIC_ST 	= NIC_ST;
// Clear any pending button interrupts
}


int main()
{
	unsigned int j,hex_val;
	i=0;
 	 
		
	
	
	EXT_INT_IER_RISE=EXT_INT_1 | EXT_INT_2 | EXT_INT_3;
	EXT_INT_GER =	0x3;

	TCMP0	=	50000000;
	TCSR0   =	( TIMER_EN | TIMER_INT_EN | TIMER_RST_ON_CMP);

	INTC_IER=	EXT_INT | TIMER_INT;
	INTC_MER=	0x3;	

	
	
	aemb_enable_interrupt ();
	while(1)
	{
		for(j=0;j<8;j++)
		{
			hex_val = (i>>(j*4))&0xF;	
			gpio_o_wr(j,~seven_seg_tab[hex_val]);
		}	
		
		delay(50000);
	}//while
	 return 0;



}




void delay ( unsigned int num ){
	
	while (num>0){ 
		num--;
		asm volatile ("nop");
	}
	return;

}

