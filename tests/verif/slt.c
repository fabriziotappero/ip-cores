int main() {
  int a = -2;       //r3
  int b = 6;     
  int c = a+b;   //r2
  asm("SLT $5, $3 , $2");
  return 0;
}
