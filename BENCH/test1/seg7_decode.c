unsigned char byte2seg7(unsigned char my_byte)
{unsigned char seg;
switch (my_byte){
               case 0: return 0xc0;//~8'b00111111;//b11111100;
              case   1: return 0xf6;//~8'b00000110;//01100000;
               case  2: return 0xa4;//~8'b01011011;//11011010;
               case  3: return 0xb0;//~8'b01001111;//11010010;
              case   4: return 0x99;//~8'b01100110;//1100110;
              case   5: return 0x92;//~8'b01101101;//10110110;
              case   6: return 0x82;//~8'b01111101;//10111110;
              case   7: return 0xf8;//~8'b00000111;//11100000;
              case   8: return 0x8f;//~8'b01111111;//11111110;
              case   9: return 0x90;//~8'b01101111;//11110110;
              case   10: return 0x88;//~8'b01110111;//11101110;
              case   11: return 0x83;//~8'b01111100;//00111110;
              case   12: return 0xa7;//~8'b01011000;//00011010;
              case   13: return 0xa1;//~8'b01011110;//01111010;
              case   14: return 0x86;//~8'b01111001;//10011110;
              case   15: return 0x8e;//~8'b01110001;//10001110;
              default : return 0xff;}
}
