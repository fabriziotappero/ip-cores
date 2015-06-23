#include "../support/support.h"
#include "../support/board.h"
#include "../support/uart.h"
#include "coefs.h"

#include "../support/spr_defs.h"

#define FIR_BASE 0x9f000000
#define FIR_CONTROL 4
#define FIR_DATA 8
#define FIR_STATUS 12
#define FIR_Q 16
#define FIR_COEFF 20

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


//        uart_putc('A');


//uart_print_short(lala);
 //       uart_putc('\n');
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
int c,k,j,r_in,r_out;
	uart_init();

	int_init();
	int_add(UART_IRQ,&uart_interrupt);
uart_print_str("OpenRISC Printing Data:\n ");


//Writes coeffcientes
		for (k=0;k<Nh;k++){
			REG32(FIR_BASE+FIR_COEFF+(k*4))=hn[k];

		};


//Writes Q
		REG32(FIR_BASE+FIR_Q)=Q;
	
//Writes kronecker delta
		REG32(FIR_BASE+FIR_DATA)=32767;
		REG32(FIR_BASE+FIR_CONTROL)=1;//Start
                //reads filter output
		r_out=REG32(FIR_BASE+FIR_DATA);
		int10_to_str(r_out,str,-10);
	   	uart_print_str(str);
		uart_putc(' ');
                /*Writes zeros*/
		for (k=1;k<Nh;k++){
			REG32(FIR_BASE+FIR_DATA)=0;
			REG32(FIR_BASE+FIR_CONTROL)=1;//Start
                 //reads filter output
			r_out=REG32(FIR_BASE+FIR_DATA);
			int10_to_str(r_out,str,-10);
	   		uart_print_str(str);
			uart_putc(' ');
		};


	report(0xdeaddead);
	or32_exit(0);
}
