// Sample program that writes some words at a predefined address

int main() {
  char Hello[] = "Hello";
  while(1) {
    puts(Hello);
  }
  return 0;
}

int puts(char* string) {
  unsigned long* TextOut = (unsigned long*)0xFA000000;
  int i;
  while(string[i]!=0) {
    (*TextOut) = string[i];
    i++;
  }
  return 0;
}
