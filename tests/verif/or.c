int main() {
  int a = 11;
  int b = 6;
  int c = a+b;
  asm("OR $5, $2 , $3");
  return 0;
}
