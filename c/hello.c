//---------------------------------------------------------------------------------------
//	Project:			light8080 SOC		WiCores Solutions 
//
//	File name:			hello.c 				(February 04, 2012)
//
//	Writer:				Moti Litochevski 
//
//	Description:
//		This file contains a simple program written in Small-C that sends a string to 
//		the UART and then switches to echo received bytes. 
//		This example also include a simple interrupt example which will work with the 
//		verilog testbench. the testbench 
//
//	Revision History:
//
//	Rev <revnumber>			<Date>			<owner> 
//		<comment>
//---------------------------------------------------------------------------------------

// define interrupt vectors 
// note that this file must be edited to enable interrupt used 
#include intr_vec.h 
// insert c80 assmbly library to the output file 
#include ..\tools\c80\c80.lib

// UART IO registers 
port (128) UDATA;		// uart data register used for both transmit and receive 
port (129) UBAUDL;		// low byte of baud rate register 
port (130) UBAUDH;		// low byte of baud rate register 
port (131) USTAT;		// uart status register 
// digital IO ports registers 
port (132) P1DATA;     	// port 1 data register 
port (133) P1DIR;		// port 1 direction register control 
port (134) P2DATA;		// port 2 data register 
port (135) P2DIR;		// port 2 direction register control 
// interrupt controller register 
port (136) INTRENA;		// interrupts enable register 
// simulation end register 
// writing any value to this port will end the verilog simulation when using tb_l80soc 
// test bench. 
port (255) SIMEND;

// registers bit fields definition 
// uart status register decoding 
#define UTXBUSY		1
#define URXFULL		16

// globals 
char rxbyte;		// byte received from the uart 
int tstary[2] = {1234, 5678};

//---------------------------------------------------------------------------------------
// send a single byte to the UART 
sendbyte(by) 
char by;
{
	while (USTAT & UTXBUSY);
	UDATA = by;
}

// check if a byte was received by the uart 
getbyte()
{
	if (USTAT & URXFULL) {
		rxbyte = UDATA;
		return 1;
	} 
	else 
		return 0;
}

// send new line to the UART 
nl()
{
	sendbyte(13);
	sendbyte(10);
}

// sends a string to the UART 
printstr(sptr)
char *sptr;
{
	while (*sptr != 0) 
		sendbyte(*sptr++);
}

// sends a decimal value to the UART 
printdec(dval) 
int dval;
{
	if (dval<0) {
		sendbyte('-');
		dval = -dval;
	}
	outint(dval);
}

// function copied from c80dos.c 
outint(n)	
int n;
{	
int q;

	q = n/10;
	if (q) outint(q);
	sendbyte('0'+(n-q*10));
}

// sends a hexadecimal value to the UART 
printhex(hval)	
int hval;
{	
int q;

	q = hval/16;
	if (q) printhex(q);
	q = hval-q*16;
	if (q > 9)
		sendbyte('A'+q-10);
	else 
		sendbyte('0'+q);
}

// external interrupt 0 service routine 
int0_isr()
{
	printstr("Interrupt 0 was asserted."); nl();
}

// program main routine 
main()
{
	// configure UART baud rate - set to 9600 for 30MHz clock 
	// BAUD = round(<clock>/<baud rate>/16) = round(30e6/9600/16) = 195 
	// Note: Usage of a minimum divider value of 1 will accelerate the RTL simulation. 
	UBAUDL = 195;
	UBAUDH = 0;

	// configure both ports to output and digital outputs as zeros 
	P1DATA = 0x00;
	P1DIR = 0xff;
	P2DATA = 0x00;
	P2DIR = 0xff;
	// enable interrupt 0 only 
	INTRENA = 0x01; 
	// enable CPU interrupt 
#asm 
	ei 
#endasm

	// print message 
	printstr("Hello World!!!"); nl();
	printstr("Dec value: "); printdec(tstary[1]); nl();
	printstr("Hex value: 0x"); printhex(tstary[0]); nl();

	// assert bit 0 of port 1 to test external interrupt 0 
	P1DATA = 0x01;
		
	printstr("Echoing received bytes: "); nl();
	// loop forever 
	while (1) {
		// check if a new byte was received 
		if (getbyte()) 
			// echo the received byte to the UART 
			sendbyte(rxbyte); 
	}
}
//---------------------------------------------------------------------------------------
//						Th.. Th.. Th.. Thats all folks !!!
//---------------------------------------------------------------------------------------

