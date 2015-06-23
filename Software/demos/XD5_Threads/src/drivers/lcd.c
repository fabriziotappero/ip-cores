#include <stdlib.h>	/* For definition of 'NULL' */
#include "lcd.h"
#include "os/lock.h"

static volatile int LCD_lock_var = 0;
static uint8_t LCD_position = 0;
static uint8_t LCD_autoIncr = 1;

static void LCD_incrPos(uint32_t amount)
{
	if (LCD_autoIncr == 0) {
		return;
	}
	while (amount > 32) {
		amount -= 32;
	}
	LCD_position += (uint8_t)amount;
	if (LCD_position >= 32) {
		LCD_position -= 32;
	}
}


void LCD_clear(void)
{
	volatile uint32_t *LCD;
	int i;

	LCD = (volatile uint32_t *)LCD_ADDRESS;

	for (i=0; i<8; i++) {
		LCD[i] = 0x20202020;
	}
	LCD_position = 0;
}

void LCD_setPos(uint8_t position)
{
	LCD_position = position;
}

uint8_t LCD_getPos(void)
{
	return LCD_position;
}

void LCD_setAutoIncr(uint8_t incr)
{
	LCD_autoIncr = incr;
}

void LCD_lock(void)
{
	Lock(&LCD_lock_var, NULL, NULL);
}

void LCD_unlock(void)
{
	Unlock(&LCD_lock_var);
}

void LCD_printByte(uint8_t byte)
{
	volatile uint8_t *LCD;

	LCD = (volatile uint8_t *)(LCD_ADDRESS + LCD_position);
	*LCD = byte;
	LCD_incrPos(1);
}

void LCD_printByteHex(uint8_t byte)
{
	volatile uint8_t *LCD;
	uint8_t nibble_h, nibble_l;

	LCD = (volatile uint8_t *)(LCD_ADDRESS + LCD_position);
	nibble_h = byte >> 4;
	nibble_l = byte & 0x0f;

	if (nibble_h < 10) {
		nibble_h += 48;
	}
	else {
		nibble_h += 55;
	}
	if (nibble_l < 10) {
		nibble_l += 48;
	}
	else {
		nibble_h += 55;
	}
	*LCD = nibble_h;
	LCD++;
	*LCD = nibble_l;
	LCD_incrPos(2);
}

void LCD_printByteDec(uint8_t byte)
{
	volatile uint8_t *LCD;
	uint8_t hundreds, tens, ones;
	uint32_t n_printed = 1;

	LCD = (volatile uint8_t *)(LCD_ADDRESS + LCD_position);
	hundreds = tens = ones = 48;

	while (byte >= 100) {
		hundreds++;
		byte -= 100;
	}
	while (byte >= 10) {
		tens++;
		byte -= 10;
	}
	while (byte >= 1) {
		ones++;
		byte -= 1;
	}
	if (hundreds > 48) {
		*LCD = hundreds;
		LCD++;
		n_printed++;
	}
	if ((n_printed > 1) || (tens > 48)) {
		*LCD = tens;
		LCD++;
		n_printed++;
	}
	*LCD = ones;
	LCD_incrPos(n_printed);
}

void LCD_printWord(uint32_t word)
{
	volatile uint32_t *LCD;

	LCD = (volatile uint32_t *)(LCD_ADDRESS + LCD_position);
	*LCD = word;
	LCD_incrPos(4);
}

void LCD_printString(char *string)
{
	volatile char *LCD;
	int i = 0;

	LCD = (volatile char *)(LCD_ADDRESS + LCD_position);
	
	while (string[i] != '\0') {
		LCD[i] = string[i];
		i++;
	}
	LCD_incrPos(i);
}

