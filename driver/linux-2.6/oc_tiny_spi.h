#ifndef _LINUX_SPI_OC_TINY_SPI_H
#define _LINUX_SPI_OC_TINY_SPI_H

/**
 * struct tiny_spi_platform_data - platform data of the OpenCores tiny SPI
 * @freq:	input clock freq to the core.
 * @baudwidth:	baud rate divider width of the core.
 * @interrupt:	use intrrupt driven data transfer.
 */
struct tiny_spi_platform_data {
	uint freq;
	uint baudwidth;
	int interrupt;
};

#endif /* _LINUX_SPI_OC_TINY_SPI_H */
