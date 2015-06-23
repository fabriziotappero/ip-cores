int main() {
  int a = 7;
  int b = 0;
  int c = a+b;	
asm(" BGTZ $3 , ste");
//asm("NOP \n NOP \n NOP \n BGTZ $3 , ste");
asm("nop \n nop ");
asm("ste:");
asm("andi $5 , $2 , 0");
  return 0;
}
