int main() {
  int a = -7;
  int b = -10;   //r2
  int c = a+b;	
asm(" BLTZ $3 , ste");
//asm("NOP \n NOP \n NOP \n BLTZ $2 , ste");
asm("nop \n nop ");
asm("ste:");
asm("andi $5 , $2 , 0");
  return 0;
}
