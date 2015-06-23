int main() {
  int a = 5;
  int b = 7;
  int c = a+b;
	asm("MTLO $2");
	asm("MTHI $3");
  return 0;
}
