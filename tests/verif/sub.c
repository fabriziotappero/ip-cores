int main() {
  int a = 5;
  int b = 6;
  int c= a - b ;
  asm("SUB $5, $2,$3");
  return 0;
}
