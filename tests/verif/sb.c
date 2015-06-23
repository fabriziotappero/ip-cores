int main() {
  int a = 5;
  int b = 7;
  int c = a+b;
  asm("SB $3 , 7($30)");
  return 0;
}
