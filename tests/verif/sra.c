int main() {                 
  int  a = 5 ;   //r3
  int b = 7;
  int c = a+b;	 //r2
  asm("li $3 , 0b10000000000000000000000000000011");
  asm("SRA $9 ,$3 , 7  ");      
  return 0;
}
