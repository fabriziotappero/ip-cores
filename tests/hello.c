// Sample program that writes some words at a predefined address

int main() {
  unsigned long* address = (unsigned long*)0xFABA1210;
  (*address) = (unsigned long)'H';
  (*address) = (unsigned long)'e';
  (*address) = (unsigned long)'l';
  (*address) = (unsigned long)'l';
  (*address) = (unsigned long)'o';
  (*address) = (unsigned long)'!';
  (*address) = (unsigned long)'\n';
  return 0;
}
