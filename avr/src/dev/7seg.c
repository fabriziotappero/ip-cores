//7segment-display
//dmpro2008 

#include <avr/io.h>
#include "7seg.h"

void display_init()
{
	//portF, 0-3 ->input
	DDRF|=(1<<0)|(1<<1)|(1<<2)|(1<<3);
}


void display_char(uint8_t inputchar)
{
	// Clear bits
	PORTF &= ~0x0f;
	// Set bits
	PORTF |= (0x0f & inputchar);
}

