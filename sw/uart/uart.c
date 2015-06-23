#include "../support/support.h"
#include "../support/board.h"
#include "../support/uart.h"

#include "../support/spr_defs.h"

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



int main()
{
int c,k,j,r_in,r_out;
	uart_init();

	int_init();
	int_add(UART_IRQ,&uart_interrupt);
	
uart_print_str("Hola\n");

	//report(0xdeaddead);
	//or32_exit(0);


	k=0;r_in=15;
	while(1){
//	uart_print_str("OpenRISC Printing: ");
//		uart_print_short(k++);
//		uart_putc('\n');
		REG32(0x94000000)=r_in;
		r_out=REG32(0x94000000);
		uart_print_short(r_out);
		uart_putc('\n');	
        }

	
	report(0xdeaddead);
	or32_exit(0);
}
