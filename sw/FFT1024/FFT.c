/*FFT-Core test*/

#include "../support/support.h"
#include "../support/board.h"
#include "../support/uart.h"

#include "../support/spr_defs.h"

#define FFT_BASE 0x94000000
#define FFT_CONTROL 0
#define FFT_DATA 4
#define FFT_STATUS 8
#define FFT_MEMORY 12


void uart_print_str(char *);
void uart_print_long(unsigned long);

// Dummy or32 except vectors
void buserr_except(){}
void dpf_except(){}
void ipf_except(){}
void lpint_except(){}
void align_except(){}
void illegal_except(){}
/*void hpint_except(){

}*/
void dtlbmiss_except(){}
void itlbmiss_except(){}
void range_except(){}
void syscall_except(){}
void res1_except(){}
void trap_except(){}
void res2_except(){}


void uart_interrupt()
{
    char lala;
    unsigned char interrupt_id;
    interrupt_id = REG8(UART_BASE + UART_IIR);
    if ( interrupt_id & UART_IIR_RDI )
    {
        lala = uart_getc();
        uart_putc((lala>>1)&0xff);


 }
}


void uart_print_str(char *p)
{
        while(*p != 0) {
                uart_putc(*p);
                p++;
        }
}

void uart_print_long(unsigned long ul)
{
  int i;
  char c;


  uart_print_str("0x");
  for(i=0; i<8; i++) {

  c = (char) (ul>>((7-i)*4)) & 0xf;
  if(c >= 0x0 && c<=0x9)
    c += '0';
  else
    c += 'a' - 10;
  uart_putc(c);
  }

}

void uart_print_short(unsigned long ul)
{
  int i;
  char c;
  char flag=0;


  uart_print_str("0x");
  for(i=0; i<8; i++) {

  c = (char) (ul>>((7-i)*4)) & 0xf;
  if(c >= 0x0 && c<=0x9)
    c += '0';
  else
    c += 'a' - 10;
  if ((c != '0') || (i==7))
    flag=1;
  if(flag)
    uart_putc(c);
  }

}



char str[100];


int main()
{
int c,k,j,r_in,r_out,DAT0,DAT1,DAT2;
	uart_init();

	int_init();
	int_add(UART_IRQ,&uart_interrupt);

	uart_print_str("FFT-Test\n");


         /*clears status register and FFT-core*/
	REG32(FFT_BASE+FFT_CONTROL)=1;

        /*Test data for FFT*/
	/*MATLAB command: int16((fft([-1100 1024 zeros(1,1022)])/16)).' */
	DAT0=-1100;  DAT1=1024; DAT2=0;

        /*real part in MSW, imaginary part (zero) in LSW*/
	REG32(FFT_BASE+FFT_DATA)=(DAT0)<<16;
        REG32(FFT_BASE+FFT_DATA)=(DAT1)<<16;
        
        /*Pipeline fill*/  
	for(k=1;k<=2046;k=k+1) {

	REG32(FFT_BASE+FFT_DATA)=(DAT2);
	};


	/*Waits for FFT core*/
	while(REG32(FFT_BASE+FFT_STATUS)==0) ;


	/*reads FFT results */
        for(k=0;k<=(1023);k++) {
            r_out=REG32(FFT_BASE+FFT_MEMORY+4*k);
           
           /*prints real part*/
	   int10_to_str(r_out>>16,str,-10);
	   uart_print_str(str);
     

           /*prints imaginary part*/
           uart_putc('+');
           int10_to_str((r_out<<16)>>16,str,-10);
           uart_print_str(str);
           uart_print_str("*j");

           uart_putc(' ');

        };



	report(0xdeaddead);
	or32_exit(0);
}
