//
//
//

#include "de1_or1200.h"
#include "serial.h"


//
// use 57600 baud

void init_serial( void )
{
 	REG8(0x50000003) = 0x83;
	REG8(0x50000001) = 0x00;
// 	REG8(0x50000000) = 0x06;
	REG8(0x50000000) = 0x1a;  // 57600 baud w/ clk=24MHz
// 	REG8(0x50000000) = 0x2b; // 57600 baud w/ clk=40MHz
	REG8(0x50000003) = 0x03;
	REG8(0x50000002) = 0x01;
 
}

void NS16550_putc( char c )
{
	while ( (LSR_BASE & LSR_THRE) == 0);
	THR_BASE = c;
}


int puts( char *s )
{
	while (*s) {
		NS16550_putc (*s++);
	}
}


