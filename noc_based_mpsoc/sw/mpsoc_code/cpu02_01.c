#include "orsocdef.h"
#include <stdlib.h>
#include "system.h"

#define BUFFER_SIZE				31

void delay(unsigned int);

unsigned int buffer [BUFFER_SIZE];




int main(void){
	

	unsigned int status=0;
	

 while(1){	
	wait_for_getting_pck();
	save_pck (buffer,BUFFER_SIZE);
	 
	}
	return 0;
}




void delay ( unsigned int num ){
	
	while (num>0){ 
		num--;
		asm volatile ("nop");
	}
	return;

}

