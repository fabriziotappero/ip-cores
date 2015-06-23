
// Set Base address
int *sui = (int *) 0x80000400;


void delay(n) {
  int i;
  for (i=0;i<n;i++) {
  }
}

// Character LCD
void display_update(data, mode)
char	data;
int	mode;
{
	int	lcd_control_data, extended_mode, extended_data, lcd_data_read;

	extended_mode = (mode << 12) & 0x00001000;
	extended_data = data & 0x000000ff;
	lcd_control_data = extended_mode | extended_data;

	sui[2] = lcd_control_data;
	sui[2] = lcd_control_data | 0x00000100; // EN=1
	delay(5000);
	sui[2] = lcd_control_data;
	delay(5000);
	return;
}

void lcd_init()
{
	int lcd_count;
	static char lcd_data_init[6] =	{0x38, 0x06, 0x0c, 0x01, 0x80};

	delay(150000);

	for (lcd_count = 0; lcd_count < 6; lcd_count++) {
		display_update( lcd_data_init[lcd_count], 0);
		delay(500000);
	}
	delay(500000);
	return;
}

void lcd_write(char *s) {
  while (*s)  {
    display_update(*s, 1);
    s++;
  }
  return;
}


void lcd_clear()
{
	display_update(0x01, 0);
	return;
}

// 7 Segment LED

void led7_write_int(int val) {
  static char led_seg[16] = {
//  0     1     2     3    
    0x3F, 0x06, 0x5B, 0x4F,
//  4     5     6     7
    0x66, 0x6D, 0x7C, 0x07,
//  8     9
    0x7F, 0x67, 0x00, 0x00,
    0x00, 0x00, 0x00, 0x00
  };
  unsigned int led_val; 
  led_val = led_seg[val & 0x000F] | (led_seg[val>>4 & 0x000F]<<8);
  led_val ^= 0xFFFFFFFF;

  sui[1] = led_val;

}



main() {
  int val;

  // Say hello on LCD
  lcd_init();
  lcd_write("Testing SPARC V8 LCD");

  // write something to 7 Segment LED's
  led7_write_int(0x1234);

  // Blink single LEDs
  while (1) {
	sui[0] = val;
 	val++;
	delay(100000);
  }
}
