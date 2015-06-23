int main() {
  int a = 10;   //r3
  int b = 10;
  int c = a+b; //r2
//asm("jalr $6 , $2 ");	
asm("jalr  $2 ");  
return 0;
}
