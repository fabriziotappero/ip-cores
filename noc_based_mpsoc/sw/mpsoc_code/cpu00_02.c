#include "orsocdef.h"
#include <stdlib.h>
#include "system.h"


void delay(unsigned int);






int main()
{
	int blk,i,pass=1;
	unsigned int buffer[18];
	while(1)
	{
		//gpio_o_wr(0,1);
		//delay(1000000);
		//gpio_o_wr(0,0);
		//delay(1000000);
	for(blk=0; blk<4;blk++){
		for(i=0;i<16;i++){
			buffer[i+2]= (blk+1)*i;	
		}
		write_on_ram_with_ack(buffer,blk*16,16);

	}
	for(blk=0; blk<4;blk++){
		read_from_ram(buffer,blk*16,16);
		for(i=0;i<16;i++){
			if(buffer[i+1] != (blk+1)*i) pass=0;	
		}
	}	
	
	gpio_o_wr(0,pass);


	while(1);

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

