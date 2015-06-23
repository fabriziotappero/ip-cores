#include "drivers/lcd.h"
#include "drivers/piezo.h"

void dead_loop(void)
{
	for (;;) {}
}

void mips32_handler_AdEL(void)
{
	LCD_clear();
	LCD_printString("AdEL");
	dead_loop();
}

void mips32_handler_AdES(void)
{
	LCD_clear();
	LCD_printString("AdES");
	dead_loop();
}

void mips32_handler_Bp(void)
{
	LCD_clear();
	LCD_printString("Bp");
	dead_loop();
}

void mips32_handler_CpU(void)
{
	LCD_clear();
	LCD_printString("CpU");
	dead_loop();
}

void mips32_handler_Ov(void)
{
	LCD_clear();
	LCD_printString("Ov");
	dead_loop();
}

void mips32_handler_RI(void)
{
	LCD_clear();
	LCD_printString("RI");
	dead_loop();
}

void mips32_handler_Sys(void)
{
	LCD_clear();
	LCD_printString("Sys");
	dead_loop();
}

void mips32_handler_Tr(void)
{
	LCD_clear();
	LCD_printString("Trap");
	dead_loop();
}

/* Timer */
void mips32_handler_HwInt5(void)
{
	static volatile char blink = 0;
	static volatile char wait = 0;

	if (blink == 0) {
		blink++;
		LCD_setPos(15);
		LCD_printByte(' ');
	}
	else {
		blink--;
		LCD_setPos(15);
		LCD_printByte('.');
	}

	if (wait == 1) {
		wait++;
		Piezo_set(0, 0);
	}
	else if (wait < 1) {
		wait++;
	}
}

void mips32_handler_HwInt4(void)
{
	static volatile char count = 0;

	LCD_printByte(count);
	count++;
}

void mips32_handler_HwInt3(void)
{
	static volatile char count = 0;

	LCD_printByte(count);
	count++;
}

void mips32_handler_HwInt2(void)
{
	static volatile char count = 0;

	LCD_printByte(count);
	count++;
}

void mips32_handler_HwInt1(void)
{
	static volatile char count = 0;

	LCD_printByte(count);
	count++;
}


void mips32_handler_HwInt0(void)
{
	static volatile char count = 0;

	LCD_printByte(count);
	count++;
}

void mips32_handler_SwInt1(void)
{
	static volatile char count = 0;

	LCD_printByte(count);
	count++;
}

void mips32_handler_SwInt0(void)
{
	static volatile char count = 0;

	LCD_printByte(count);
	count++;
}

