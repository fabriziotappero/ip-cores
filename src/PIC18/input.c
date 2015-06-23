#include <system.h>
#include "input.h"


#pragma CLOCK_FREQ 50000000

char getinput()
{
	
	set_bit(portd, 5);
	delay_us(12);
	clear_bit(portd, 5);
	delay_us(6);
	
	set_bit(rcsta, SREN);		//Single reception
	
	if(pir1 & 0b00100000)
	{
		return rcreg;
	}

}

void setupinput(void)
{
	set_bit(trisc, 7);
	spbrg = 255;
	
	set_bit(txsta,SYNC);
	set_bit(rcsta,SPEN);
	set_bit(txsta,CSRC);
	clear_bit(rcsta, SREN);
	clear_bit(rcsta, CREN);

	clear_bit(portd, 5);		
}

char getlonginput(void)
{
	char Output = 00000000b;
	
	set_bit(portd, 5);
	delay_us(12);
	clear_bit(portd, 5);
	delay_us(6);
	
	if(portd | 01111111b)
	{
		Output = 00000001b;
	}

	set_bit(portd, 1);
	if(portd | 01111111b)
	{
		Output = 00000010b | Output;
	}
	
	clear_bit(portd, 1);
	delay_us(6);
	set_bit(portd, 1);	
	
	if(portd | 01111111b)
	{
		Output = 00000100b | Output;
	}
	
	clear_bit(portd, 1);
	delay_us(6);
	set_bit(portd, 1);	
	
	if(portd | 01111111b)
	{
		Output = 00001000b | Output;
	}
	
	clear_bit(portd, 1);
	delay_us(6);
	set_bit(portd, 1);	
	
	if(portd | 01111111b)
	{
		Output = 00010000b | Output;
	}
	
	clear_bit(portd, 1);
	delay_us(6);
	set_bit(portd, 1);	
	
	if(portd | 01111111b)
	{
		Output = 00100000b | Output;
	}
	
	clear_bit(portd, 1);
	delay_us(6);
	set_bit(portd, 1);	
	
	if(portd | 01111111b)
	{
		Output = 01000000b | Output;
	}
	
	clear_bit(portd, 1);
	delay_us(6);
	set_bit(portd, 1);	
	
	if(portd | 01111111b)
	{
		Output = 10000000b | Output;
	}	
	clear_bit(portd, 1);
	delay_us(6);
}
