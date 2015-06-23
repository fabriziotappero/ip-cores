int main () {
  return 1;
}


int func2 (int i) {
  return i + 1; 
}
 
int func1 () {
  
  int i,j,k;
  j = 0;
  for (i = 0; i < 100;i++) {
    j = func2 (j);
  }
  return j;
}
