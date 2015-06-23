#include "hardware.h"
#include "7seg.h"
#include "gray.h"
#include "memtest.h"




volatile unsigned char upd_count=1;

wakeup interrupt (WDT_VECTOR) INT_Watchdog(void)
{
	static unsigned int count=0xFFFF;

	if( upd_count )
	{
		upd_count=0;
		count++;

		DispWord(count);
	}
}



volatile unsigned char tctr;

wakeup interrupt (TIMERA1_VECTOR) INT_Timer_overflow(void)
{
	static unsigned char gray=0;

	tctr++;
	if( tctr&0x40 )
	{
		tctr&=0x3F;

		P3OUT = gray;
		gray = bin2gray( 1 + gray2bin( gray ) );
	}

	TACTL &= ~TAIFG; // clear int flag
}




/**
Main function with some blinking leds
*/
int main(void) {




	static UBYTE array1[448];
	static UBYTE array2[448];



	int i;


    WDTCTL = WDTPW | WDTHOLD;          // Disable watchdog timer

    P1OUT  = 0x00;                     // Port data output
    P2OUT  = 0x00;

    P1DIR  = 0x00;                     // Port direction register
    P2DIR  = 0x00;
    P3DIR  = 0xff;

    P1IES  = 0x00;                     // Port interrupt enable (0=dis 1=enabled)
    P2IES  = 0x00;
    P1IE   = 0x00;                     // Port interrupt Edge Select (0=pos 1=neg)
    P2IE   = 0x00;

    WDTCTL = WDTPW | WDTTMSEL | WDTCNTCL;// | WDTIS1  | WDTIS0 ;          // Configure watchdog interrupt



	TAR = 0x0000;
	TACTL = TASSEL1 | MC1 | TAIE; // run on smclk, no div, count to ffff, interrupt




    IE1 |= 0x01;
    eint();                            //enable interrupts




	init_array(array1);
	copy_array(array1,array2);

	i=1000;
	do
	{
		rnd_array(array1);

	} while( --i );



	while (1)
	{
		i=1000;
		do rnd_array(array2); while( --i );

		if( cmp_array(array1,array2) )
		{
			upd_count++;
		}

		i=1000;
		do rnd_array(array1); while( --i );
	}
}

