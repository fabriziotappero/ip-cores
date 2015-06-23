/* ********************************************************************************* */
/*                      Bi-quad IIR filter section                                   */
/*                                                                                   */
/*  Author:  Chuck Cox (chuck100@home.com)                                           */
/*                                                                                   */
/*  This module implements an IIR filter section with 2 poles and                    */
/*  2 zeros.  The filter coefficients are inputs to this module.                     */
/*  Multiple bi-quad filter sections can be connected together to                    */
/*  create higher order filters.  The filter uses a signed fractional                */
/*  2's complement binary numbering system.  For example with 3 bits:                */
/*                                                                                   */
/*  000 = 0     001 = 0.25     010 = 0.5     011 = 0.75                              */
/*  100 = 0     101 = -.75     110 = -.5     111 = -.25                              */
/*                                                                                   */
/*  The equation for the filter implemented with this module is                      */
/*  y[n] = b10 * x[n] + b11 * x[n-1] + b12 * x[n-2] + a11 * y[n-1] + a12 * y[n-2]    */
/*                                                                                   */
/*  Multipliers are implemented as calls to seperate modules to allow easy           */
/*  conversion to hard or firm macros.  Multicycle multipliers can be used           */
/*  by not making input data valid on every clock.  For a 4 clock multiplier         */
/*  data will need to be valid only once every 4 clocks.                             */
/*                                                                                   */
/*                                                                                   */
/* ********************************************************************************* */


module biquad
	(
	clk,				/* clock */
	nreset,			/* active low reset */
	x,				/* data input */
	valid,			/* input data valid */
	a11,				/* filter pole coefficient */
	a12,				/* filter pole coefficient */
	b10,				/* filter zero coefficient */
	b11,				/* filter zero coefficient */
	b12,				/* filter zero coefficient */
	yout				/* filter output */
	);

parameter	DATAWIDTH = 8;
parameter	COEFWIDTH = 8;
// Acumulator width is (DATAWIDTH + ACCUM) bits.
parameter	ACCUM = 2;  // Must be less than or equal to COEFWIDTH-2

input 								clk;
input 								nreset;
input	[DATAWIDTH-1:0]				x;
input								valid;
input	[COEFWIDTH-1:0]				a11;
input	[COEFWIDTH-1:0]				a12;
input	[COEFWIDTH-1:0]				b10;
input	[COEFWIDTH-1:0]				b11;
input	[COEFWIDTH-1:0]				b12;
output	[DATAWIDTH-1:0]				yout;

reg		[DATAWIDTH-1:0]				xvalid;
reg		[DATAWIDTH-1:0]				xm1;
reg		[DATAWIDTH-1:0]				xm2;
reg		[DATAWIDTH-1:0]				xm3;
reg		[DATAWIDTH-1:0]				xm4;
reg		[DATAWIDTH-1:0]				xm5;
reg		[DATAWIDTH+3+ACCUM:0]			sumb10reg;
reg		[DATAWIDTH+3+ACCUM:0]			sumb11reg;
reg		[DATAWIDTH+3+ACCUM:0]			sumb12reg;
reg		[DATAWIDTH+3+ACCUM:0]			suma12reg;
reg		[DATAWIDTH+3:0]				y;
reg		[DATAWIDTH-1:0]				yout;

wire		[COEFWIDTH-1:0]				sa11;
wire		[COEFWIDTH-1:0]				sa12;
wire		[COEFWIDTH-1:0]				sb10;
wire		[COEFWIDTH-1:0]				sb11;
wire		[COEFWIDTH-1:0]				sb12;
wire		[DATAWIDTH-2:0]				tempsum;
wire		[DATAWIDTH+3+ACCUM:0]			tempsum2;
wire		[DATAWIDTH + COEFWIDTH - 3:0]		mb10out;
wire		[DATAWIDTH+3+ACCUM:0]			sumb10;
wire		[DATAWIDTH + COEFWIDTH - 3:0]		mb11out;
wire		[DATAWIDTH+3+ACCUM:0]			sumb11;
wire		[DATAWIDTH + COEFWIDTH - 3:0]		mb12out;
wire		[DATAWIDTH+3+ACCUM:0]			sumb12;
wire		[DATAWIDTH + COEFWIDTH + 1:0] 	ma12out;
wire		[DATAWIDTH+3+ACCUM:0]			suma12;
wire		[DATAWIDTH + COEFWIDTH + 1:0] 	ma11out;
wire		[DATAWIDTH+3+ACCUM:0]			suma11;
wire		[DATAWIDTH+3:0]				sy;
wire		[DATAWIDTH-1:0]				olimit;


/* Two's complement of coefficients */
assign sa11 = a11[COEFWIDTH-1] ? (~a11 + 1) : a11;
assign sa12 = a12[COEFWIDTH-1] ? (~a12 + 1) : a12;
assign sb10 = b10[COEFWIDTH-1] ? (~b10 + 1) : b10;
assign sb11 = b11[COEFWIDTH-1] ? (~b11 + 1) : b11;
assign sb12 = b12[COEFWIDTH-1] ? (~b12 + 1) : b12;

assign tempsum = ~xvalid[DATAWIDTH-2:0] + 1;
assign tempsum2 = ~{4'b0000,mb10out[COEFWIDTH+DATAWIDTH-3:COEFWIDTH-2-ACCUM]} + 1;

/* clock data into pipeline.  Divide by 8.  Convert to sign magnitude. */
always @(posedge clk or negedge nreset)
if ( ~nreset )
  begin
    xvalid <= 0;
    xm1 <= 0;
    xm2 <= 0;
    xm3 <= 0;
    xm4 <= 0;
    xm5 <= 0;
  end
else
  begin
    xvalid <= valid ? x : xvalid;
    xm1 <= valid ? (xvalid[DATAWIDTH-1] ? ({xvalid[DATAWIDTH-1],tempsum}) : {xvalid}) : xm1;
    xm2 <= valid ? xm1 : xm2;
    xm3 <= valid ? xm2 : xm3;
    xm4 <= valid ? xm3 : xm4;
    xm5 <= valid ? xm4 : xm5;
  end

/* Multiply input by filter coefficient b10 */
multb multb10(.clk(clk),.nreset(nreset),.a(sb10[COEFWIDTH-2:0]),.b(xm1[DATAWIDTH-2:0]),.r(mb10out));

assign sumb10 = (b10[COEFWIDTH-1] ^ xm1[DATAWIDTH-1]) ? (tempsum2) : ({4'b0000,mb10out[COEFWIDTH+DATAWIDTH-3:COEFWIDTH-2-ACCUM]});

/* Multiply input by filter coefficient b11 */
multb multb11(.clk(clk),.nreset(nreset),.a(sb11[COEFWIDTH-2:0]),.b(xm3[DATAWIDTH-2:0]),.r(mb11out));

/* Divide by two and add or subtract */
assign sumb11 = (b11[COEFWIDTH-1] ^ xm3[DATAWIDTH-1]) ? (sumb10reg - {4'b0000,mb11out[COEFWIDTH+DATAWIDTH-3:COEFWIDTH-2-ACCUM]}) : 
     (sumb10reg + {4'b0000,mb11out[COEFWIDTH+DATAWIDTH-3:COEFWIDTH-2-ACCUM]});

/* Multiply input by filter coefficient b12 */
multb multb12(.clk(clk),.nreset(nreset),.a(sb12[COEFWIDTH-2:0]),.b(xm5[DATAWIDTH-2:0]),.r(mb12out));

assign sumb12 = (b12[COEFWIDTH-1] ^ xm5[DATAWIDTH-1]) ? (sumb11reg - {4'b0000,mb12out[COEFWIDTH+DATAWIDTH-3:COEFWIDTH-2-ACCUM]}) : 
     (sumb11reg + {4'b0000,mb12out[COEFWIDTH+DATAWIDTH-3:COEFWIDTH-2-ACCUM]});

/* Twos complement of output for feedback */
assign sy = y[DATAWIDTH+3] ? (~y + 1) : y;

/* Multiply output by filter coefficient a12 */
multa multa12(.clk(clk),.nreset(nreset),.a(sa12[COEFWIDTH-2:0]),.b(sy[DATAWIDTH+2:0]),.r(ma12out));

assign suma12 = (a12[COEFWIDTH-1] ^ y[DATAWIDTH+3]) ? (sumb12reg - {1'b0,ma12out[COEFWIDTH+DATAWIDTH:COEFWIDTH-2-ACCUM]}) : 
     (sumb12reg + {1'b0,ma12out[COEFWIDTH+DATAWIDTH:COEFWIDTH-2-ACCUM]});

/* Multiply output by filter coefficient a11 */
multa multa11(.clk(clk),.nreset(nreset),.a(sa11[COEFWIDTH-2:0]),.b(sy[DATAWIDTH+2:0]),.r(ma11out));

assign suma11 = (a11[COEFWIDTH-1] ^ y[DATAWIDTH+3]) ? (suma12reg - {1'b0,ma11out[COEFWIDTH+DATAWIDTH:COEFWIDTH-2-ACCUM]}) : 
     (suma12reg + {1'b0,ma11out[COEFWIDTH+DATAWIDTH:COEFWIDTH-2-ACCUM]});

assign olimit = {y[DATAWIDTH+3],~y[DATAWIDTH+3],~y[DATAWIDTH+3],~y[DATAWIDTH+3],~y[DATAWIDTH+3],
				~y[DATAWIDTH+3],~y[DATAWIDTH+3],~y[DATAWIDTH+3]};

/* State registers */
always @(posedge clk or negedge nreset)
if ( ~nreset )
  begin
    sumb10reg <= 0;
    sumb11reg <= 0;
    sumb12reg <= 0;
    suma12reg <= 0;
    y <= 0;
    yout <= 0;
  end
else
  begin
    sumb10reg <= valid ? (sumb10) : (sumb10reg);
    sumb11reg <= valid ? (sumb11) : (sumb11reg);
    sumb12reg <= valid ? (sumb12) : (sumb12reg);
    suma12reg <= valid ? (suma12) : (suma12reg);
    y <= valid ? suma11[DATAWIDTH+3+ACCUM:ACCUM] : y;
    yout <= valid ? (( (&y[DATAWIDTH+3:DATAWIDTH-1]) | (~|y[DATAWIDTH+3:DATAWIDTH-1])  ) ? 
		(y[DATAWIDTH-1:0]) : (olimit)) : (yout);
  end


endmodule
