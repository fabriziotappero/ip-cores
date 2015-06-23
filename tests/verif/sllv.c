int main() {
  int a = 1;     //r3
  int b = 32;
  int c = a+b;   //r2
  asm("SLLV $5 ,$3 , $2");
  return 0;
}
