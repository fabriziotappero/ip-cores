// Factorial

int main() {
  int num = 5;
  int fact = fact_f(num);
  return 0;
}

int fact_f(int n) {
  if(n==1) return 1;
  else return n*fact_f(n-1);
}

