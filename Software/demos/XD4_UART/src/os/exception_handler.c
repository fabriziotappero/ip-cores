#include "drivers/lcd.h"
#include "drivers/piezo.h"
#include "drivers/monitor.h"
#include "drivers/uart.h"

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
	static volatile char wait = 0;
	static volatile uint8_t cursor = 0x20;

	if (wait == 1) {
		wait++;
		Piezo_set(0, 0);
	}
	else if (wait < 1) {
		wait++;
	}
	
	LCD_setAutoIncr(0);
	LCD_printByte(cursor);
	LCD_setAutoIncr(1);

	if (cursor == 0x20) {
		cursor = 0xff;
	}
	else {
		cursor = 0x20;
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


/* UART */
void mips32_handler_HwInt0(void)
{
	uint32_t recv_msg;
	uint32_t bytes_avail;
	uint8_t  read_byte;

	recv_msg = UART_readMessage();
	read_byte = (uint8_t)recv_msg;
	bytes_avail = (recv_msg >> 8);

	while (bytes_avail > 0) {
		if (read_byte == 0x7f) {  // delete
			LCD_setAutoIncr(0);
			LCD_printByte(0x20);
			LCD_setPos(LCD_getPos()-1);
			LCD_setAutoIncr(1);
		}
		else {
			LCD_printByte(read_byte);
		}
		bytes_avail--;
		read_byte = UART_readByte();
	}
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

