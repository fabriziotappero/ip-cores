int main() {
  int a = 5;
  int b = 7;
  int c = a+b;
asm(".long 0x0C000015");
asm("ANDI $5 , $3 , 1");
asm("NOP \n NOP \n NOP");
asm("pesciolino:");
asm("nop");
asm("addi $6 , $3 , 2");
asm("nop ");
asm("jr $31");
  return 0;
}
