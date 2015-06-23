#include "drivers/piezo.h"
#include "drivers/lcd.h"


char *str_int = "Interrupt\x7e";
char *str_main = "Main\x7e";

int main(void)
{
	static volatile char disp = 0;

	Piezo_play(C5);
	LCD_clear();
	LCD_setAutoIncr(0);
	LCD_setPos(4);
	LCD_printString(str_int);
	LCD_setPos(25);
	LCD_printString(str_main);

	while (1) {
		LCD_setPos(31);
		LCD_printByte(disp);
		disp++;
	}
	
	return 0;
}

