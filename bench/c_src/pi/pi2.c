/*Calculate the value of PI.  Takes a long time!*/
void putchar(char); 

#define print_port 0x3ff0
#define print_char_port 0x3ff1
#define print_int_port 0x3ff2
#define print_long_port 0x3ff4





#define uart_port		0x03ffc //for 16KRAM
#define uart_wport uart_port
#define uart_rport uart_port
#define int_set_address 0x03ff8 //for 16KRAM

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
}	


void putc_uart(unsigned char c)// 
{
	unsigned int uport;
	

	do {
		  uport=*(volatile unsigned*)	uart_port;
	} while (uport & WRITE_BUSY);
	*(volatile unsigned char*)uart_wport=c;
	
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

void print_num(unsigned long num)
{
   unsigned long digit,offset;
   for(offset=1000;offset;offset/=10) {
      digit=num/offset;
      #ifdef RTL_SIM
        print_char(digit+'0');
      #else
      	putc_uart(digit+'0');
      #endif
      num-=digit*offset;
   }
}

long a=10000,b,c=56,d,e,f[57],g;
//long a=10000,b,c=2800,d,e,f[2801],g;
void main()
{
#ifdef RTL_SIM
	print("Calculating pi, it may take some minutes.\n");

#endif
	

for(;b-c;)f[b++]=a/5;for(;d=0,g=c*2;c-=14,print_num(e+d/a),e=d%a)for(b=c;d+=f[b]*a,f[b]=d%--g,d/=g--,--b;d*=b);



   print_char('\n');
   print("");
   
#ifdef RTL_SIM
	print("$finish");

#endif
   
   
   
}

