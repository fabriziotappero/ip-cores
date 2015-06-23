int main() {
  int a = 5;     //r3
  int b = 7;
  int c = a+b;   //r2
  asm("ADDI $5 ,$3 , -5");
  return 0;
}
