int main() {
  int a = -4;       //r3
  int b = 6;     
  int c = a+b;   //r2
  asm("SLTU $5, $3 , $2");
  return 0;
}
