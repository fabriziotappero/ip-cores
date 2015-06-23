#include "orsocdef.h"
#include <stdlib.h>
#include "system.h"


void delay(unsigned int);


unsigned int buffer [32];


	


		
		


int main()
{
	int i;
	for (i=1;i<32;i++) buffer [i] = i;
	for (i=1;i<32;i++) {
		delay(5000000);
		send_pck (0,0,buffer,30,0x00);
		wait_for_sending_pck();
		delay(50000000);
		send_pck (0,0,buffer,31,0x00);
		wait_for_sending_pck();
	}
	while(1)
	{
		gpio_o_wr(0,1);
		delay(500000);
		
			

		gpio_o_wr(0,0);
		delay(500000);
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

