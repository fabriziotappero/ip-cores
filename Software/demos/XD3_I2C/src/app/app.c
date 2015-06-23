#include "drivers/piezo.h"
#include "drivers/lcd.h"
#include "drivers/monitor.h"

int main(void)
{
	static volatile char count = 0;
	uint32_t temperature;

	Piezo_play(C5);
	Monitor_start();
	LCD_clear();
	LCD_setPos(16);
	LCD_printString("Temp:");

	while (1) {
		// Get Monitor temperature
		temperature = Monitor_readTemp(1);
		LCD_setPos(22);
		LCD_printByteDec((uint8_t)temperature);
		LCD_printByte('/');

		// Get CPU temperature
		temperature = Monitor_readTemp(0);
		LCD_printByteDec((uint8_t)temperature);
		LCD_printByte(0xdf);	// degree symbol
		LCD_printByte('C');
		LCD_printByte(' ');
		LCD_printByte(' ');

		// Display a rolling value so we know we're alive
		LCD_setPos(31);
		LCD_printByte(count);
		count++;
	}

	return 0;
}

