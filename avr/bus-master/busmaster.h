#ifndef _BUSMASTER_H_
#define _BUSMASTER_H_
#include <avr/io.h>
#include <stdint.h>

/* Read Write port and flags */
#define RDWRPORT	PORTF
#define RDWRPIN		PINF
#define RDWRDDR		DDRF
/* Pin values that indicate different operations
 * using (2**pinnumber) for easier code
 */
#define	RD	0x04
#define WR	0x08

#define RDYPORT		PORTF
#define RDYPIN		PINF
#define RDYDDR		DDRF
#define RDY	0

#define ADDRLPIN	PINF
#define ADDRLPORT	PORTF	
#define	ADDRLDDR	DDRF


#define ADDRHPIN	PINE
#define ADDRHPORT	PORTE
#define	ADDRHDDR	DDRE

#define DATA0PIN	PINA
#define DATA0PORT	PORTA
#define DATA0DDR	DDRA

#define DATA1PIN	PIND
#define DATA1PORT	PORTD
#define DATA1DDR	DDRD

#define DATA2PIN	PINB
#define DATA2PORT	PORTB
#define DATA2DDR	DDRB

#define DATA3PIN	PINC
#define DATA3PORT	PORTC
#define DATA3DDR	DDRC

#define INTDDR		DDRF
#define INTPORT		PORTF
#define INT			1

int32_t fpga_delayed_write(void);
void fpga_finish_read(uint32_t data);
void init_fpgabus(void);
uint32_t bus_read(uint8_t addr);
void bus_write(uint8_t addr, uint32_t data);
#endif /* !_BUSMASTER_H_ */
