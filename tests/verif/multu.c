int main() {
  int a = 7;//r3
  int b = -12;
  int c= a+b;// r2
 asm("MULTU $3,$2 \n ADD $7,$2,$3 ");
  return 0;
}
