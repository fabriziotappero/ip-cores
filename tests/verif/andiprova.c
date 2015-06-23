int main() {
  int a = -5;     //r3
  int b = 7;
  int d=0;
  int c = a+b;  //r2= 2
	if(c<a) 
		d=0;
	else
		d=1;    
  //asm("ANDI $5 , $3 , 5");
  return 0;
}
