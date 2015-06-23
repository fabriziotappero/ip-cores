int main() {
  int a = -5;   //r3
  int b = 7;
  int c = a+b;	
  asm("XORI $7 , $3 , 6");
  return 0;
}
