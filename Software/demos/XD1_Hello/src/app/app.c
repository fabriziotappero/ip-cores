#include "drivers/lcd.h"

char *message = "It works!";

int main(void)
{
	LCD_clear();
	LCD_setPos(19);
	LCD_printString(message);

	return 0;
}

