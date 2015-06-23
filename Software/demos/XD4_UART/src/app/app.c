#include "drivers/piezo.h"
#include "drivers/lcd.h"
#include "drivers/uart.h"


int main(void)
{
	Piezo_play(C5);
	LCD_clear();
	UART_disableBoot();

	while (1) {};
	
	return 0;
}

