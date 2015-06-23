int main() {
  int a = -6;     //r3
  int b = 7;
  int c = a+b;   //r2
  asm("SLTIU $5 ,$3 , -5");
  return 0;
}
