int main() {                 
  int a = 5;   //r3
  int b = 7;
  int c = a+b;	
  asm(".long 0x08000013 ");    // = j 4c ; 13 va shiftato a sinistra di 2 posizioni per ottenere 4c ; 0x08000013 = 0000_1000_0000_0000_0000_0000_0001_0011
  asm("nop");
  asm("MTHI $3");
  asm("NOR $5, $2 ,$3");
  asm("sotto:");
	return 0;
}
