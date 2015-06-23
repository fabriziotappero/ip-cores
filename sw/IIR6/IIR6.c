#include "../support/support.h"
#include "../support/board.h"
#include "../support/uart.h"
#include "coefs_sos.h"

#include "../support/spr_defs.h"

#define IIR_BASE 0x9d000000
#define IIR_CONTROL 0
#define IIR_DATA 4
#define IIR_STATUS 8
#define IIR_NSECTT 12
#define IIR_GAIN 16
#define IIR_COEFF 20

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


//Nsections-1
		REG32(IIR_BASE+IIR_NSECTT)=NSECT-1;

//Gain
		REG32(IIR_BASE+IIR_GAIN)=(int)gk;

//Coef Write
    for (k=0;k<(6*NSECT);k++){
        	REG32(IIR_BASE+IIR_COEFF+(k*4))=(int)SOS[k];
		r_out=REG32(IIR_BASE+IIR_COEFF+(k*4));
int10_to_str(r_out,str,-10);
	   	uart_print_str(str);
			uart_putc(' ');


    }

uart_print_str("IIR filter impulse response :\n ");

                //Writes kronecker delta

       		REG32(IIR_BASE+IIR_DATA)=(int)(32767);
		REG32(IIR_BASE+IIR_CONTROL)=1;//Start
		while(REG32(IIR_BASE+IIR_STATUS)==0) ;
		REG32(IIR_BASE+IIR_STATUS)=1;


          
//Reads filter output
r_out=REG32(IIR_BASE+IIR_DATA);
		int10_to_str(r_out,str,-10);
	   	uart_print_str(str);
			uart_putc(' ');


     //Writes 999 zeros
    for (k=0;k<((1000)-1);k++){
		REG32(IIR_BASE+IIR_DATA)=0;
		REG32(IIR_BASE+IIR_CONTROL)=1;//Start

                //Waits for filtering 
		while(REG32(IIR_BASE+IIR_STATUS)==0) ;
		REG32(IIR_BASE+IIR_STATUS)=1;

//Reads filter output
r_out=REG32(IIR_BASE+IIR_DATA);
		int10_to_str(r_out,str,-10);
	   	uart_print_str(str);
			uart_putc(' ');

	}

	report(0xdeaddead);
	or32_exit(0);
}
