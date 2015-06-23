int main() {
  int a = 0; //r3
  int b = 0;
  int c = a+b;	//r2
asm(" BEQ $3, $2, gravagno");
//asm(" BEQ $5, $6, gravagno");
asm("nop \n nop ");
asm("gravagno:");
asm("andi $5 , $2 , 0");
  return 0;
}
