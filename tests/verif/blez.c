int main() {
  int a = -7;
  int b = 7;
  int c = a+b;	
//asm("nop \n nop \n BLEZ $3 , vari");
//asm("NOP \n NOP \n NOP \n NOP \n BLEZ $3 , vari ");       //caso funzionante
asm("BLEZ $3 , vari ");
asm("nop \n nop ");
asm("vari:");
asm("andi $5 , $2 , 0");
  return 0;
}
