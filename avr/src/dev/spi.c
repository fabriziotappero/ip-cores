#include "spi.h"
#include <avr/io.h>

//Configure the SPI interface for use with SD/MMC and Ethernet
void configure_spi(void)
{
	//Set pins as output
	SPI_DDR |= (1<<SPI_SCK) | (1<<SPI_MOSI) | (1<<SPI_SS_MMC) | (1<<SPI_SS_ETHERNET);
	
	//Set pins as input
	SPI_DDR &= ~(1<<SPI_MISO);

	//Activate pull-up on MISO and set both SS lines high (deasserted)
	SPI_PORT |= (1<<SPI_MISO) | (1<<SPI_SS_MMC) | (1<<SPI_SS_ETHERNET);

	//Drive SCK and MOSI low
	SPI_PORT &= ~((1<<SPI_SCK) | (1<<SPI_MOSI));

	// Disable SPI powersaving
	PRR0 &= ~(1<<PRSPI);

	/*Configure SPI interface:
	* Disable SPI interrupts
	* Enable SPI
	* Set data order MSB first
	* Set SPI master mode
	* Set clock polarity idle low
	* Set clock phase to sample on rising edge
	* Set SPI speed to freq_cpu/4
	*/
	SPCR = (0<<SPIE)|(1<<SPE)|(0<<DORD)|(1<<MSTR)|(0<<CPOL)|(0<<CPHA)|(0<<SPR1)|(0<<SPR0);

	//Activate SPI2X, doubling the speed set in the previous register
	SPSR = (1<<SPI2X);
}
