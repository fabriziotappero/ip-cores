//SPOSTA IL RISULTATO DELL'ADDIZIONE CHE È SU R2 SUL REGISTRO HI
int main() {
  int a = 5;
  int b = 7;
  int c = a+b;
asm("MTHI $2");

  return 0;
}
