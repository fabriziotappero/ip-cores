int main() {                 
  int a = 21 ;   //r3
  int b = 7;
  int c = a+b;	 //r2
  asm("SRL $9 ,$3 , 2  ");      
  return 0;
}
