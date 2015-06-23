// Sample program that writes two words at a predefined address

int main() {
  unsigned long* address;
  address = (unsigned long*)0x0000CAC0;
  (*address) = 0xC1A0C1A0;  // First store
  address = (unsigned long*)0x0000CAC0;
  (*address) = 0xFABA1210;  // Second store
  return 0;
}

