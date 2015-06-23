int main() {
  int a = 7;  //r3
  int b = -42;
  int c = a+b;  //r2
asm("DIVU $2, $3");
  return 0;
}
