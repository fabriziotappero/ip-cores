int main() {                 
  int a = -5;   //r3
  int b = 7;
  int c = a+b;	 //r2
  asm("SLL $9 ,$3 , 2  ");          //	l'offset che si usa deve essere allineato ma può essere rappresentato in diverse notazioni(0x--> HEX 0b-->BIN ).In assenza di specificarzione il numero è inteso essere decimale
  return 0;
}
