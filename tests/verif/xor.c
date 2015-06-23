int main() {
  int a = 1;
  int b = 1;
  int c = a+b;
  asm("XOR $5, $2 , $3");
  return 0;
}
