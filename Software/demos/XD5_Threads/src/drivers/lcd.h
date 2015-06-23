#ifndef __LCD_H__
#define __LCD_H__

#include <stdint.h>

#define LCD_ADDRESS 0x80000000

void    LCD_clear(void);
void    LCD_setPos(uint8_t position);
uint8_t LCD_getPos(void);
void    LCD_setAutoIncr(uint8_t incr);
void    LCD_lock(void);
void    LCD_unlock(void);
void    LCD_printByte(uint8_t byte);
void    LCD_printByteHex(uint8_t byte);
void    LCD_printByteDec(uint8_t byte);
void    LCD_printWord(uint32_t word);
void    LCD_printString(char *string);

#endif

