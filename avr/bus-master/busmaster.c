/* BUS Master version */
#include <avr/interrupt.h>
#include <avr/io.h>
#include <stdint.h>
#include "busmaster.h"

#define DEBUG 1

void write_bus_data(uint32_t data);
int32_t read_bus_data(void);
void tristate_data_bus(void);

void init_fpgabus(void) {
	// Tristate databus
	DATA0DDR  = 0x00;
	DATA0PORT = 0x00;
	DATA1DDR  = 0x00;
	DATA1PORT = 0x00;
	DATA2DDR  = 0x00;
	DATA2PORT = 0x00;
	DATA3DDR  = 0x00;
	DATA3PORT = 0x00;

	// Set addr as output
	ADDRLDDR  |= 0xF0;
	ADDRLPORT |= 0xF0;
	
	ADDRHDDR  |= 0xF0;
	ADDRHPORT |= 0xF0;
	
	// Set RDWR as output
	RDWRDDR	  |= (RD|WR);
	RDWRPORT  |= (RD|WR);

	// Set RDY as input
	RDYDDR    &= ~(1<<RDY);
	// Init high
	RDYPORT   &= ~(1<<RDY);

	/* Setup interrupt pin as input
	 * ISC11 = 1, ISC10 => Interrupt on falling edge on INT1
	 */
	INTDDR	|= (1<<INT1);
	INTPORT |= (1<<INT1);
	/*EICRA |= (1<<ISC11);
	EICRA &= ~(1<<ISC10);
	EIMSK |= (1<<INT1);*/
}



/* AVR-FGPA COM interrupt routine
 * TODO: ADD BURSTMODE operation
 */
uint32_t bus_read(uint8_t address) {

	uint32_t data;
	
	ADDRHPORT &= 0x0F;
	ADDRHPORT |= (address&0xF0);
	ADDRLPORT &= 0x0F;
	ADDRLPORT |= (address<<4);
	
	RDWRPORT &= ~RD;
	
	// send IRQ
	INTPORT &= ~(1<<INT1);
	
	// SPINLOCK on RDY high
	while ( (RDYPIN&(1<<RDY)) != 0 ) ;

	// Result is present
	data = read_bus_data();
	
	// Remove RD flag
	RDWRPORT |= RD;
	
	// Reset interrupt signal
	INTPORT |= (1<<INT1);

	// SPINLOCK on RDY low
	while ( (RDYPIN&(1<<RDY)) == 0 ) ;
	
	return data;
}

void bus_write ( uint8_t address, uint32_t data) {

	ADDRHPORT &= 0x0F;
	ADDRHPORT |= (address&0xF0);
	ADDRLPORT &= 0x0F;
	ADDRLPORT |= (address<<4);
	
	
	write_bus_data(data);
	
	RDWRPORT &= ~WR;
	
	// send IRQ
	INTPORT &= ~(1<<INT1);
	
	// SPINLOCK on RDY high
	while ( (RDYPIN&(1<<RDY)) != 0 ) ;

	// Remove RD flag
	RDWRPORT |= WR;

	tristate_data_bus();
	
	// Remove interrupt
	INTPORT |= (1<<INT);

	// SPINLOCK on RDY low
	while ( (RDYPIN&(1<<RDY)) == 0 ) ;	

	return;
}

void write_bus_data(uint32_t data) {
	// Set all dataports to output
	DATA0DDR  = 0xFF;
	DATA1DDR  = 0xFF;
	DATA2DDR  = 0xFF;
	DATA3DDR  = 0xFF;
	
	DATA0PORT = (char)(data);
	DATA1PORT = (char)(data>>8);
	DATA2PORT = (char)(data>>16);
	DATA3PORT = (char)(data>>24);

}


void tristate_data_bus() {
	// Tristate databus
	DATA0DDR  = 0x00;
	DATA0PORT = 0x00;
	DATA1DDR  = 0x00;
	DATA1PORT = 0x00;
	DATA2DDR  = 0x00;
	DATA2PORT = 0x00;
	DATA3DDR  = 0x00;
	DATA3PORT = 0x00;
	return;
}

int32_t read_bus_data() {
	return ((int32_t)DATA3PIN<<24)|((int32_t)DATA2PIN<<16)|((int32_t)DATA1PIN<<8)|(DATA0PIN);
}
