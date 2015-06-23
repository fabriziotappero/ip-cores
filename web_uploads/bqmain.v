/* ********************************************************************************* */
/*										     */
/*        		Main module for biquad filter			             */
/*                                                                                   */
/*  Author:  Chuck Cox (chuck100@home.com)                                           */
/*                                                                                   */
/* This filter core uses a wishbone interface for compatibility with other cores:    */
/*										     */
/* Wishbone general description:  16x5 register file				     */
/* Supported cycles:  Slave Read/write, block read/write, RMW			     */
/* Data port size:  16 bit							     */
/* Data port granularity: 16 bit						     */
/* Data port maximum operand size:  16 bit					     */
/*                                                                                   */
/*      Addr	register							     */
/*      ----    --------							     */
/*	0x0	Filter coefficient a11						     */
/*	0x1	Filter coefficient a12						     */
/*      0x2	Filter coefficient b10						     */
/*	0x3	Filter coefficient b11						     */
/*	0x4	Filter coefficient b12						     */
/*                                                                                   */
/*  Filter coefficients need to be written as 16 bit twos complement fractional	     */
/*  numbers.  For example:  0100_0000_0000_0001 = 2^-1 + 2^-15 = .500030517578125    */
/*										     */
/*  The equation for the filter implemented with this core is                        */
/*  y[n] = b10 * x[n] + b11 * x[n-1] + b12 * x[n-2] + a11 * y[n-1] + a12 * y[n-2]    */
/* 										     */
/*  This biquad filter is parameterized.  If a filter with coefficients less than    */
/*  16 bits in length is selected via parameters then the most significant bits of   */
/*  the value written to the filter coefficient register shall be used (ie	     */
/*  coefficients shall be truncated as required by parameter value COEFWIDTH).	     */
/*										     */
/*  See comments in biquad module for more details on filtering algorthm.	     */
/* ********************************************************************************* */


module bqmain
	(
	clk_i,		/* Wishbone clk */
	rst_i,		/* Wishbone asynchronous active high reset */
	we_i,		/* Wishbone write enable */
	stb_i,		/* Wishbone strobe */
	ack_o,		/* Wishbone ack */
	dat_i,		/* Wishbone input data */
	dat_o,		/* Wishbone output data */
	adr_i,		/* Wishbone address bus */
	dspclk,		/* DSP processing clock */
	nreset,		/* active low asynchronous reset for filter block */
	x,		/* input data for filter */
	valid,		/* data valid input */
	y		/* filter output data */
	);

parameter	DATAWIDTH = 8;
parameter	COEFWIDTH = 8;

input			clk_i;
input			rst_i;
input			we_i;
input			stb_i;
output			ack_o;
input	[15:0]		dat_i;
output	[15:0]		dat_o;
input	[2:0]		adr_i;
input			dspclk;
input			nreset;
input	[DATAWIDTH-1:0]	x;
input			valid;
output	[DATAWIDTH-1:0]	y;


wire	[15:0]	a11;
wire	[15:0]	a12;
wire	[15:0]	b10;
wire	[15:0]	b11;
wire	[15:0]	b12;

/* Filter module */
biquad biquadi
	(
	.clk(dspclk),				/* clock */
	.nreset(nreset),			/* active low reset */
	.x(x),					/* data input */
	.valid(valid),				/* input data valid */
	.a11(a11[15:16-COEFWIDTH]),		/* filter pole coefficient */
	.a12(a12[15:16-COEFWIDTH]),		/* filter pole coefficient */
	.b10(b10[15:16-COEFWIDTH]),		/* filter zero coefficient */
	.b11(b11[15:16-COEFWIDTH]),		/* filter zero coefficient */
	.b12(b12[15:16-COEFWIDTH]),		/* filter zero coefficient */
	.yout(y)				/* filter output */
	);

/* Wishbone interface module */
coefio coefioi
	(
	.clk_i(clk_i),
	.rst_i(rst_i),
	.we_i(we_i),	
	.stb_i(stb_i),
	.ack_o(ack_o),
	.dat_i(dat_i),
	.dat_o(dat_o),
	.adr_i(adr_i),
	.a11(a11),
	.a12(a12),
	.b10(b10),
	.b11(b11),
	.b12(b12)
	);



endmodule
