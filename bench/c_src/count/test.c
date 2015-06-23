//Apr.1.2005 for ram16k
//count_tak.c




#define print_port 0x3ff0
#define print_char_port 0x3ff1
#define print_int_port 0x3ff2
#define print_long_port 0x3ff4





#define uart_port		0x03ffc //for 16KRAM
#define uart_wport uart_port
#define uart_rport uart_port
#define int_set_address 0x03ff8 //for 16KRAM



char *name[]={
   "","one","two","three","four","five","six","seven","eight","nine",
   "ten","eleven","twelve","thirteen","fourteen","fifteen",
      "sixteen","seventeen","eighteen","nineteen",
   "","ten","twenty","thirty","forty","fifty","sixty","seventy",
      "eighty","ninety"
};
void print_uart(unsigned char* ptr)// 
{
	unsigned int uport;
	#define WRITE_BUSY 0x0100


	while (*ptr) {
	
		do {
		  uport=*(volatile unsigned*)	uart_port;
		} while (uport & WRITE_BUSY);
		*(volatile unsigned char*)uart_wport=*(ptr++);
	}
	//*(volatile unsigned char*)uart_wport=0x00;//Write Done
}	


void putc_uart(unsigned char c)// 
{
	unsigned int uport;
	

	do {
		  uport=*(volatile unsigned*)	uart_port;
	} while (uport & WRITE_BUSY);
	*(volatile unsigned char*)uart_wport=c;
	
}	

unsigned char read_uart()//Verilog Test Bench Use 
{
		unsigned uport;
		uport= *(volatile unsigned *)uart_rport;
		return uport;
}	

void print(unsigned char* ptr)//Verilog Test Bench Use 
{

	while (*ptr) {
	
		*(volatile unsigned char*)print_port=*(ptr++);
	}

	*(volatile unsigned char*)print_port=0x00;//Write Done

}
void print_char(unsigned char val)//Little Endian write out 16bit number 
{
	*(volatile unsigned char*)print_port=(unsigned char)val ;

}





char *itoa(unsigned long num)
{
   static char buf[12];
   int i;
   buf[10]=0;
   for(i=9;i>=0;--i) {
      buf[i]=(char)((num%10)+'0');
      num/=10;
   }
   return buf;
}

void number_text(unsigned long number)
{
   int digit;
   print(itoa(number));
   print(": ");
   if(number>=1000000000) {
      digit=number/1000000000;
      print(name[digit]);
      print(" billion ");
      number%=1000000000;
   }
   if(number>=100000000) {
      digit=number/100000000;
      print(name[digit]);
      print(" hundred ");
      number%=100000000;
      if(number<1000000) {
         print("million ");
      }
   }
   if(number>=20000000) {
      digit=number/10000000;
      print(name[digit+20]);
      print_char(' ');
      number%=10000000;
      if(number<1000000) {
         print("million ");
      }
   }
   if(number>=1000000) {
      digit=number/1000000;
      print(name[digit]);
      print(" million ");
      number%=1000000;
   }
   if(number>=100000) {
      digit=number/100000;
      print(name[digit]);
      print(" hundred ");
      number%=100000;
      if(number<1000) {
         print("thousand ");
      }
   }
   if(number>=20000) {
      digit=number/10000;
      print(name[digit+20]);
      print_char(' ');
      number%=10000;
      if(number<1000) {
         print("thousand ");
      }
   }
   if(number>=1000) {
      digit=number/1000;
      print(name[digit]);
      print(" thousand ");
      number%=1000;
   }
   if(number>=100) {
      digit=number/100;
      print(name[digit]);
      print(" hundred ");
      number%=100;
   }
   if(number>=20) {
      digit=number/10;
      print(name[digit+20]);
      print_char(' ');
      number%=10;
   }
   print(name[number]);
   print_char('\r');
   print_char('\n');
}

void main()
{
   unsigned mem [1000];
   unsigned long number,i;
	for (i=0;i<10000;i++) {
		read_uart();
		//print_uart(itoa(i));
	}	
}

