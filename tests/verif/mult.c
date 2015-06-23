int main() {
  int a = -5;
  int b = 7;
  int c = a+b;
asm("MULT $2 , $3 ");
  return 0;
}
