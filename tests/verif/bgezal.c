int main() {
  int a = 7;
  int b = -10;   //r2
  int c = a+b;	
asm(" BGEZAL $3 , bravusi");
//asm("NOP \n NOP \n NOP \n BGEZAL $3 , ste");
asm("nop \n nop \n nop \n nop");
asm("bravusi:");
asm("andi $5 , $2 , 0");
  return 0;
}
