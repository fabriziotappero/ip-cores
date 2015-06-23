/* ********************************************************************************* */
/*                      multiplier place holder                                      */
/*                                                                                   */
/*  Author:  Chuck Cox (chuck100@home.com)                                           */
/*                                                                                   */
/*                                                                                   */
/*                                                                                   */
/* ********************************************************************************* */


module multa
	(
	clk,			/* clock */
	nreset,			/* active low reset */
	a,			/* data input */
	b,			/* input data valid */
	r			/* filter pole coefficient */
	);


parameter	DATAWIDTH = 8;
parameter	COEFWIDTH = 8;

input 					clk;
input 					nreset;
input	[COEFWIDTH-2:0]			a;
input	[DATAWIDTH+2:0]			b;
output	[DATAWIDTH + COEFWIDTH + 1:0]	r;


assign r = a*b;


endmodule
