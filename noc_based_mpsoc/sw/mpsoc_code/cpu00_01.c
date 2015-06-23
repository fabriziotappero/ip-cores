#include "orsocdef.h"
#include <stdlib.h>
#include "system.h"

#define BUFFER_SIZE				31

unsigned int buffer [BUFFER_SIZE];

#define DES_X	2
#define DES_Y	1
	

void delay(unsigned int);






int main()
{
	unsigned int status=0;
	int i;
 
	while(1){
		for (i=1;i<BUFFER_SIZE;i++) buffer [i] = i;
		send_pck (DES_X,DES_Y,buffer,2,0x00);
		

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

