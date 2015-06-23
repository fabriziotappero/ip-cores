//#include <stdio.h>

void __port_write(char port, char arg) { }
char __port_read(char port) { }
void __nop() { }

#define LED_wr(arg)  __port_write(0x80, (arg))

#define LCD_wr(arg)   __port_write(0x01, (arg))
#define LCD_rd()   __port_read(0x01)
#define LCD_busy()  (LCD_rd() & 0x80) == 0x80

void delay_ms(int ms)
{
 int i;
 for (i=0;i<ms;i++) {
   for (i=0; i < 10000; i++) __nop();
 }
}

void LCD_init()
{
  LCD_wr(0x42);
  while (LCD_rd()) { __nop();}
  LCD_wr(0x43);
 delay_ms(10);
  LCD_wr(0x44);
  LCD_wr(0x45);
}

void LCD_write(char ch)
{
  LCD_wr(0x46);
  LCD_wr(0x47);
}


int main(void) {
 char st = 0;

 while(1) {
   LED_wr(st);
   st ^= 1;
   delay_ms(1000);
 }
/*
 char ch = 0x31;
 LCD_init();
 while (1) {
   LCD_write(ch);
   delay_ms(1000);
 }
*/
}
