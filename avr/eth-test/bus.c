#include <avr/interrupt.h>
#include <avr/io.h>
#include <stdint.h>

#include "bus.h"
#include "global.h"
#include "dispatch.h"
#include "dev/7seg.h"


uint32_t read_bus_data(void);
void fpga_finish_write(void);
void tristate_data_bus(void);

void init_fpgabus(void) {
	// Setup the boot port
	BOOTEDDDR |= (1<<BOOTED);
	BOOTEDPORT &= ~(1<<BOOTED);

	// Tristate databus
	DATA0DDR  = 0x00;
	DATA0PORT = 0x00;
	DATA1DDR  = 0x00;
	DATA1PORT = 0x00;
	DATA2DDR  = 0x00;
	DATA2PORT = 0x00;
	DATA3DDR  = 0x00;
	DATA3PORT = 0x00;

	// Set addr as input
	ADDRLDDR  &= ~0xF0;
	ADDRLPORT &= ~0xF0;
	
	ADDRHDDR  &= ~0xF0;
	ADDRHPORT &= ~0xF0;
	
	// Set RDWR as input
	RDWRDDR	  &= ~(RD|WR);
	RDWRPORT  &= ~(RD|WR);

	// Set RDY as output
	RDYDDR    |= (1<<RDY);
	// Init high
	RDYPORT   |= (1<<RDY);

	/* Setup interrupt pin as input
	 * ISC11 = 1, ISC10 => Interrupt on falling edge on INT1
	 */
	INTDDR	&= ~(1<<INT1);
	INTPORT &= ~(1<<INT1);
	EICRA |= (1<<ISC11);
	EICRA &= ~(1<<ISC10);
	EIMSK |= (1<<INT1);
}



/* AVR-FGPA COM interrupt routine
 * TODO: ADD BURSTMODE operation
 */
ISR(SIG_INTERRUPT1) {

	uint8_t addr;
	uint8_t rdwr;
	uint32_t data;
	
	_delay_ms(0.1);
	addr = (ADDRHPIN&0xF0)|((ADDRLPIN>>4)&0x0F);

	rdwr = RDWRPIN&(WR|RD);
	
	if ( rdwr == (WR|RD)) {
		// Both flags a set.. invalid operation. Should probably panic here
		// BAEBU BAEBU!	
		display_char(16);
		while(1);
	} else if ( (rdwr&RD) == 0 ) {
		// We are reading data
		if (dispatch_request_read(addr, &data)) {
			// Failed
			// main should call finish_read when data is available
			return; 			
		} else {
			// The data was avaiable. Finish transfer
			fpga_finish_read(data);
		}
	} else if ( (rdwr&WR) == 0 ) {
		// We are writing data
		// XXX: Add writefunction here
		data = read_bus_data();
		if (dispatch_request_write(addr,data)) {
			// Failed
			//display_char(12);
			// main should call fpga_delayed_write when bufferspace is avaiable
			return;
		} else {
			fpga_finish_write();
			return;
		}
	} else {
		// No flags set.. thats odd
		display_char(15);
		
		while(1) ;
	}
	
}
/* Output the requested data on the bus 
 * And complete the transfer with a 4-way handshake
 */
void fpga_finish_read(uint32_t data) {
	// Intermediate stage as per datasheet
	DATA0PORT = 0xFF;
	DATA1PORT = 0xFF;
	DATA2PORT = 0xFF;
	DATA3PORT = 0xFF;

	// Set all dataports to output
	DATA0DDR  = 0xFF;
	DATA1DDR  = 0xFF;
	DATA2DDR  = 0xFF;
	DATA3DDR  = 0xFF;

	DATA0PORT = (char)(data);
	DATA1PORT = (char)(data>>8);
	DATA2PORT = (char)(data>>16);
	DATA3PORT = (char)(data>>24);


	// Assert RDY
	RDYPORT &= ~(1<<RDY);
	
	// Spinlock until WR/RD,CE has been deasserted
	while (!(RDWRPIN & WR) || !(RDWRPIN & RD) || !(INTPIN & (1<<INT1)));
	
	_delay_ms(0.1);
	// Release the databus
	tristate_data_bus();
	// Deassert RDY
	RDYPORT |= (1<<RDY);
	return;

}

uint32_t fpga_delayed_write() {
	int32_t data = read_bus_data();
	fpga_finish_write();
	return data;
}

/* Complete with a 4-way handshake */
void fpga_finish_write() {	
	// Assert RDY
	RDYPORT &= ~(1<<RDY);
	
	// Spinlock until WR/RD,CE has been deasserted
	while (!(RDWRPIN & WR) || !(RDWRPIN & RD) || !(INTPIN & (1<<INT1)));
	
	_delay_ms(0.1);
	// Deassert RDY
	RDYPORT |= (1<<RDY);
	return;
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

uint32_t read_bus_data() {
	return ((uint32_t)DATA3PIN<<24)|((uint32_t)DATA2PIN<<16)|((uint32_t)DATA1PIN<<8)|(DATA0PIN);
}

/* We use this to syncronize the avr and the FPGA on boot */
void avr_online() {
	BOOTEDPORT |= (1<<BOOTED);
	return;
}
