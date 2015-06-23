#include "led.h"

uint32_t LED_read(void)
{
	volatile uint32_t *LED = (volatile uint32_t *)LED_ADDRESS;
	uint32_t data;

	data = *LED;
	return data;
}

void LED_write(uint32_t value)
{
	volatile uint32_t *LED = (volatile uint32_t *)LED_ADDRESS;

	*LED = value;
}

void LED_setMode(uint32_t mode)
{
	volatile uint32_t *LED = (volatile uint32_t *)LED_ADDRESS;

	*LED = mode;
}
	
