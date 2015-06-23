//Apr.4.2005 Rewritten for RAM16K and Engilish
//RTL Simulation use Only 
//By using uart echo technique, UART interrupt routine and h/w are checked.
//YACC Project on CYCLONE 4KRAM
//Jul.15.2004 Simple 32bit calculator
// 


#define print_port 0x3ff0
#define print_char_port 0x3ff1
#define print_int_port 0x3ff2
#define print_long_port 0x3ff4


#define uart_port		0x03ffc //for 16KRAM
#define uart_wport uart_port
#define uart_rport uart_port
#define int_set_address 0x03ff8 //for 16KRAM



#define BUFFER_SIZE 160
unsigned char * read_ptr;
char buffer[BUFFER_SIZE];//
char result_buffer[8];//8+1
unsigned char sym;
unsigned char* char_ptr;
long term(void);
long factor(void);
long expression(void);
void calculator();
int volatile int_flag=0;//volatile is must. Without it,No calculation will be done because of Compiler Optimization.
char buf[2];
//#define DEBUG //For RTL Simulation USE
void print_uart(unsigned char* ptr)// 
{
	#define WRITE_BUSY 0x0100
	unsigned uport;
	while (*ptr) {
		do {
		  uport=*(volatile unsigned*)	uart_port;
		} while (uport & WRITE_BUSY);
		*(volatile unsigned char*)uart_wport=*(ptr++);
	}
}	


void putc_uart(unsigned char c)// 
{
	unsigned uport;
	
	do {
		  uport=*(volatile unsigned*)	uart_port;
	} while (uport & WRITE_BUSY);
	
	*(volatile unsigned char*)uart_wport=c;
}	

void print_char(unsigned char val)// 
{
	#ifdef DOS
		printf("%x ",val);
	#else
	*(volatile unsigned char*)print_char_port=(unsigned char)val ;
	#endif

}
unsigned char read_uart()//Apr.4.2005 changed 32 bits port
{
	unsigned uport=*(volatile unsigned*)uart_port;
//	print_char(uport);
		return uport;
}	

void print(unsigned char* ptr)//Verilog Test Bench Use 
{
	#ifdef DOS
			printf("%s ",ptr); 
	#else
		
	while (*ptr) {
	
		*(volatile unsigned char*)print_port=*(ptr++);
	}

	*(volatile unsigned char*)print_port=0x00;//Write Done
	#endif
}

void print_short(short val)//Little Endian write out 16bit number 
{	
	#ifdef DOS
		printf("%x",val);
	#else
		*(volatile unsigned short*)print_int_port=val ;
	#endif
	

}

void print_long(unsigned long val)//Little Endian write out 32bit number 
{
	#ifdef DOS
			printf("%x",val);
	#else
			*(volatile unsigned long*)print_long_port=val;

	#endif

}


//Interrupt Service Routine.
//If 0D/0A comes then, 
//{write 0 at the end of buffer.
// Parse Analysis by hand,
//}else increment READ_PTR
//if Overflow MessageOUT
 void interrupt(void)
{
	char c;
#define SAVE_REGISTERS   (13*4)
	asm("addiu	$sp,$sp,-52 ;");//SAVE_REGISTERS

	asm("	sw	$a0,($sp)");//Save registers@
	asm("	sw  $v0,4($sp)");
	asm("	sw  $v1,8($sp)");
	asm("	sw  $a1,12($sp)");
	asm("	sw  $s0,16($sp)");
	asm("	sw  $s1,20($sp)");
	asm("	sw  $s2,24($sp)");

	asm("	sw  $a3,28($sp)");
	asm("	sw  $s4,32($sp)");
	asm("	sw  $s5,36($sp)");
	asm("	sw  $s6,40($sp)");
	asm("	sw  $s7,44($sp)");
	asm("	sw  $a2,48($sp)");



	c=read_uart();//read 1Byte from uart read port.


	if ( c == 0x0a || c==0x0d )
	{
			*read_ptr = 0;//string end
			read_ptr=buffer;//Initialization of read_ptr
			
	
				putc_uart(0x0a);	
				putc_uart(0x0d);
	
			if (int_flag) print("PError!\n");
			else		int_flag=1;
		
	}  else if ( c == '\b' && read_ptr > buffer ){//Backspace
			
				putc_uart('\b');
			
	
			read_ptr--;
	}else if ( read_ptr>= buffer+BUFFER_SIZE){// overflow
		//
	 		*read_ptr = 0;//string end
			read_ptr=buffer;//Initialization of read_ptr
			print_uart("Sorry Overflow..!\n");
	
	}else {//post increment
				  
				putc_uart(c);
	
			*(read_ptr++) = c;
	}

#ifdef DEBUG
//	print(buffer);
//	print("\n\n");
#endif	
	
//Restore Saved Registers.

	asm("	lw	$a0,($sp)");
	asm("	lw  $v0,4($sp)");
	asm("	lw  $v1,8($sp)");
	asm("	lw  $a1,12($sp)");
	asm("	lw  $s0,16($sp)");
	asm("	lw  $s1,20($sp)");
	asm("	lw  $s2,24($sp)");

	asm("	lw  $a3,28($sp)");
	asm("	lw  $s4,32($sp)");
	asm("	lw  $s5,36($sp)");
	asm("	lw  $s6,40($sp)");
	asm("	lw  $s7,44($sp)");
	asm("	lw  $a2,48($sp)");

	asm("addiu	$sp,$sp,52 ;");//SAVE_REGISTERS
							//Adjust! 
	asm("lw	$ra,20($sp);");//Adjust! See dis-assemble list
	asm("addiu	$sp,$sp,24 ;");//Adjust.
    asm("jr	$26");//Return Interrupt
	asm("nop");//Delayed Slot
//

}	

inline void set_interrupt_address()
{
	*(volatile unsigned long*)int_set_address=(unsigned long)interrupt;
	read_ptr=buffer;	
}


void print_longlong(long long val)//Little Endian write out 32bit number 
{
	#ifdef DOS
			printf("%x",val);
	#else
			*(volatile unsigned long*)print_long_port=val>>32;
			*(volatile unsigned long*)print_long_port=val;

	#endif

}


 void getsym()
{


	while ( *char_ptr==' ' || 
			*char_ptr=='\n' ||
			*char_ptr=='\r' ) char_ptr++;
	if (*char_ptr ==0) {
		sym=0;	
	}else {
		sym=*(char_ptr++);
	
	}		
}
	
inline void init_parser()
{
	char_ptr=buffer;
	getsym();
	
}


long evaluate_number(void)
{
	
	long x ;

	x=sym-'0';
	while(*char_ptr >='0' && *char_ptr <='9') {
		x = x * 10 + *char_ptr - '0';
		char_ptr++;
	}
	getsym();

	return x;
}
long expression(void)
{
	long term1,term2;
	unsigned char op;
	
	op=sym;

	if (sym=='+' || sym=='-') getsym();
	term1=term();

	if (op=='-') term1=-term1;

	while (sym=='+' || sym=='-') {
		op=sym;
		getsym();
		term2=term();
		if (op=='+') term1= term1+term2;
		else 		  term1= term1-term2;
	}

	return term1;		
}
	
long term(void)
{
	unsigned char op;
	long factor1,factor2;

	factor1=factor();
	while ( sym=='*' || sym=='/' || sym=='%'){
		op=sym;
		getsym();
		factor2=factor();

		switch (op) {	
			case '*': factor1= factor1*factor2;
					  break;
			case '/': factor1= factor1/factor2;
					  break;
			case '%':   factor1= factor1%factor2;
					  break;
		}
	}

	return factor1;
}

inline long parse_error()
{
	print_uart("\n parse error occurred\n");
	return 0;	
}	
			
long factor(void)
{
	int i;

	if (sym>='0' && sym <='9')	 return evaluate_number();
	else if (sym=='('){

					getsym();
					i= expression();

					if (sym !=')'){
						parse_error();
					} 
					getsym();
					return i;	 
	}else  if (sym==0) return 0;
	else return parse_error();			 	
}
	




char *strrev(char *s) {
	char *ret = s;
	char *t = s;
	char c;

	while( *t != '\0' )t++;
	t--;

	while(t > s) {
		c = *s;
		*s = *t;
		*t = c;
		s++;
		t--;
	}

	return ret;
}


void itoa(int val, char *s) {
	char *t;
	int mod;

	if(val < 0) {
		*s++ = '-';
		val = -val;
	}
	t = s;
	
	while(val) {
		mod = val % 10;
		*t++ = (char)mod + '0';
		val /= 10;

	}

	if(s == t)
		*t++ = '0';

	*t = '\0';
	

	strrev(s);
}
void calculator()
{
	long result;

//Parser Initialization	
	init_parser();

//Calculation
	result=expression();
	
//	
	#ifdef DEBUG
	print("\n");
	print(buffer);
	print("=");
	print_long(result);
	print("[Hex]   ");
	itoa(result,result_buffer);
	print(result_buffer);
	print("[Dec]\n");

	#else
	print_uart(buffer);
	putc_uart('=');
	itoa(result,result_buffer);

	print_uart(result_buffer);
	putc_uart(0x0a);
	putc_uart(0x0a);	
	putc_uart(0x0d);	

	#endif	
	
	
}	

void strcpy(char* dest,char* source)
{

	char* dest_ptr;
	dest_ptr=dest;	

	while(*source) {
		
		*(dest++) =*(source++);	
	} ;

	*dest=0;//Write Done

	
}	
void calculator_test(char* ptr)
{
	strcpy(buffer,ptr);
	calculator();
	
}	

void main()
{
	set_interrupt_address();

	putc_uart(0x0a);	
	putc_uart(0x0d);
	print_uart("Welcome to YACC World.Apr.8.2005 www.sugawara-systems.com");
	putc_uart(0x0a);	
	putc_uart(0x0d);
	print_uart("YACC>");
	label:
	if (int_flag){
			int_flag=0;
			calculator();
			print_uart("YACC>");	
		
	}	
	goto label;
}	
