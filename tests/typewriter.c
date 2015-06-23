
int main() {
  unsigned long* text_vga_out = (unsigned long*)0xFA000000;
  unsigned long* ps2_keyboard_in = (unsigned long*)0xFB000000;
  unsigned long last_char;

  while(1) {
    last_char = (unsigned long)(*ps2_keyboard_in);
    asm("nop");
    if(last_char!=0) (*text_vga_out) = last_char;
    asm("nop");
  }
  return 0;
}
