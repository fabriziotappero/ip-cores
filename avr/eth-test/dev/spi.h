//Common settings for all SPI devices

#ifndef __SPI_H__
#define __SPI_H__

#define SPI_PORT	PORTB
#define SPI_DDR		DDRB

#define SPI_SCK		1
#define SPI_MOSI	2
#define SPI_MISO	3

#define SPI_SS_ETHERNET	4
#define SPI_SS_MMC	5

//Set up the SPI interface
void configure_spi(void);

#endif

