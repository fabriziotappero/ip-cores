int main() {
  int a = -5;
  int b = 1;
  int c = a+b;
  asm("AND $5, $2 , $3");
  return 0;
}
