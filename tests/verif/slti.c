int main() {
  int a = -5;     //r3
  int b = 7;
  int c = a+b;   //r2
  asm("SLTI $5 ,$3 , -6");
  return 0;
}
