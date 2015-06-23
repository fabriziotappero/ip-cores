int main() {
  int a = 7;  //r3
  int b =15;
  int c = a+b;  //r2
//asm("nop \n nop");
//asm("nop");
//asm("nop");
//asm("nop");
  asm("BNE $6, $3 , gian");
 // asm(".long 0x08000008");
asm("NOR $2, $2, $3");
  asm("AND $7 , $2,  $3");
asm("nop \n nop");
asm("gian:");
asm("ADDI $5 , $2 , 1");
return 0;
}
