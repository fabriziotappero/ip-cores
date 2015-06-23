/*
	Fixed point Multiplication Module Qm.n
	C = (A << n) / B
	
*/


//Division State Machine Constants
`define INITIAL_DIVISION_STATE					6'd1
`define DIVISION_REVERSE_LAST_ITERATION		6'd2
`define PRE_CALCULATE_REMAINDER					6'd3
`define CALCULATE_REMAINDER						6'd4
`define WRITE_DIVISION_RESULT						6'd5


`timescale 1ns / 1ps
`include "aDefinitions.v"
`define FPS_AFTER_RESET_STATE 0
//-----------------------------------------------------------------
//This only works if you dividend is power of 2
//x % 2^n == x & (2^n - 1).
/*
module Modulus2N
(
input wire 						Clock,
input wire 						Reset,
input wire [`WIDTH-1:0] 	iDividend,iDivisor,
output reg  [`WIDTH-1:0] 	oQuotient,
input  wire						iInputReady,		//Is the input data valid?
output reg						oOutputReady		//Our output data is ready!
);



FF1_POSEDGE_SYNCRONOUS_RESET FFOutputReadyDelay2
(
	.Clock( Clock ),
	.Clear( Reset ),
	.D( iInputReady ),
	.Q( oOutputReady )
);	

assign oQuotient = (iDividend & (iDivisor-1'b1));


endmodule
*/
//-----------------------------------------------------------------
/*
Be aware that the unsgined division algorith doesn't know or care
about the sign bit of the Result (bit 31). So if you divisor is very
small there is a chance that the bit 31 from the usginned division is
one even thogh the result should be positive

*/
module SignedIntegerDivision
(
input	 wire			Clock,Reset,
input  wire [`WIDTH-1:0] iDividend,iDivisor,
output reg  [`WIDTH-1:0] xQuotient,
input  wire	iInputReady,		//Is the input data valid?
output reg	OutputReady		//Our output data is ready!
);


parameter SIGN = 31;
wire Sign;

wire [`WIDTH-1:0] wDividend,wDivisor;
wire wInputReady;
FFD_POSEDGE_SYNCRONOUS_RESET # ( `WIDTH ) FFD1
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( iInputReady ),
	.D( iDividend ),
	.Q( wDividend)
);
FFD_POSEDGE_SYNCRONOUS_RESET # ( `WIDTH ) FFD2
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( iInputReady ),
	.D( iDivisor ),
	.Q( wDivisor )
);

FFD_POSEDGE_SYNCRONOUS_RESET # ( 1 ) FFD3
(
	.Clock( Clock ),
	.Reset( Reset),
	.Enable( 1'b1 ),
	.D( iInputReady ),
	.Q( wInputReady )
);


//wire [7:0] wExitStatus;
wire [`WIDTH-1:0] wAbsDividend,wAbsDivisor;
wire [`WIDTH-1:0] wQuottientTemp;
wire  [`WIDTH-1:0] wAbsQuotient;

assign Sign = wDividend[SIGN] ^ wDivisor[SIGN];

assign wAbsDividend = ( wDividend[SIGN] == 1 )?
			~wDividend + 1'b1 : wDividend;
		
assign wAbsDivisor = ( wDivisor[SIGN] == 1 )?
		~wDivisor + 1'b1 : wDivisor;		

wire DivReady;


UnsignedIntegerDivision UDIV 
(
		.Clock(Clock),
		.Reset( Reset ),
		.iDividend( wAbsDividend),
		.iDivisor( wAbsDivisor ),
		.xQuotient(wQuottientTemp),
		.iInputReady( wInputReady ),
		.OutputReady( DivReady )
		
	);

//Make sure the output from the 'unsigned' operation is really posity
assign wAbsQuotient = wQuottientTemp & 32'h7FFFFFFF;

//assign Quotient = wAbsQuotient;
	
	//-----------------------------------------------
	always @ ( posedge Clock )
	begin
			
		if ( DivReady )
		begin
			if ( Sign == 1 )
				xQuotient = ~wAbsQuotient + 1'b1;
			else
				xQuotient = wAbsQuotient;
						
		end		
		
		OutputReady = DivReady;
		
		if (Reset == 1)
			OutputReady = 0;
			
		
	end
	//-----------------------------------------------

endmodule
//-----------------------------------------------------------------
/*
	
	Returns the integer part (Quotient) of a division.
	
	Division is the process of repeated subtraction. 
	Like the long division we learned in grade school, 
	a binary division algorithm works from the high 
	order digits to the low order digits and generates 
	a quotient (division result) with each step. 
	The division algorithm is divided into two steps:
   * Shift the upper bits of the dividend (the number 
   we are dividing into) into the remainder.
   * Subtract the divisor from the value in the remainder. 
   The high order bit of the result become a bit of 
   the quotient (division result).
	
*/

//-----------------------------------------------------------------
/*
Try to implemet the division as a FSM,
this basically because the behavioral Division has a for loop,
with a variable loop limit counter which I think is not friendly
to the synthetiser (dumb dumb synthetizer :) )
*/
module UnsignedIntegerDivision(
input	wire				Clock,Reset,
input	wire [`WIDTH-1:0]	iDividend,iDivisor,
//output reg	[`WIDTH-1:0]	Quotient,Remainder,

output reg	[`WIDTH-1:0]	xQuotient,

input  wire	iInputReady,		//Is the input data valid?
output reg	OutputReady	//Our output data is ready!
//output reg  [7:0]			ExitStatus
);

//reg		[`WIDTH-1:0] Dividend, Divisor;

reg [63:0] Dividend,Divisor;

//reg 	[`WIDTH-1:0] t, q, d, i,Bit,  num_bits;	
reg 	[`WIDTH-1:0]  i,num_bits;	
reg [63:0] t, q, d, Bit;
reg	[63:0]	Quotient,Remainder; 

reg	[5:0]	CurrentState, NextState;
//----------------------------------------
//Next states logic and Reset sequence
always @(negedge Clock)
begin
        if( Reset!=1 )
           CurrentState = NextState;
		  else
			  CurrentState = `FPS_AFTER_RESET_STATE;
end
//----------------------------------------

always @ (posedge Clock)
begin
case (CurrentState)
	//----------------------------------------
	`FPS_AFTER_RESET_STATE:
	begin
		OutputReady = 0;
		NextState = ( iInputReady == 1 ) ?
			`INITIAL_DIVISION_STATE : `FPS_AFTER_RESET_STATE;
	end
	//----------------------------------------
	`INITIAL_DIVISION_STATE:
	begin
		Dividend = iDividend;
		Dividend =  Dividend << `SCALE;
		
		Divisor	 = iDivisor;
		Remainder = 0;
  		Quotient = 0;
	
 		if (Divisor == 0) 
 		begin
				Quotient[31:0] = 32'h0FFF_FFFF;
   		//	ExitStatus = `DIVISION_BY_ZERO; 
				NextState = `WRITE_DIVISION_RESULT; 
 		end   
 		else if (Divisor > Dividend) 
 		begin
 	    	Remainder 	= Dividend;
			//ExitStatus 	= `NORMAL_EXIT; 
			NextState = `WRITE_DIVISION_RESULT; 
     	end
 		else if (Divisor == Dividend) 
 		begin
 	    	Quotient = 1;
    	//	ExitStatus 	= `NORMAL_EXIT; 
			NextState = `WRITE_DIVISION_RESULT;
      end
		else
		begin
         NextState = `PRE_CALCULATE_REMAINDER;
		end  
		  //num_bits = 32;
		  num_bits = 64;
	end 
	
	//----------------------------------------
	`PRE_CALCULATE_REMAINDER:
	begin
		
		//Bit = (Dividend & 32'h80000000) >> 31;
		Bit = (Dividend & 64'h8000000000000000 ) >> 63;
    	Remainder = (Remainder << 1) | Bit;
    	d = Dividend;
    	Dividend = Dividend << 1;
    	num_bits = num_bits - 1;
  		
		
//		$display("num_bits %d Remainder %d Divisor %d\n",num_bits,Remainder,Divisor);
  		NextState = (Remainder < Divisor) ? 
  			`PRE_CALCULATE_REMAINDER : `DIVISION_REVERSE_LAST_ITERATION;
	end
	//----------------------------------------
	/* 
  		The loop, above, always goes one iteration too far.
     	To avoid inserting an "if" statement inside the loop
     	the last iteration is simply reversed. 
     */
	`DIVISION_REVERSE_LAST_ITERATION:
	begin
		Dividend = d;
  		Remainder = Remainder >> 1;
  		num_bits = num_bits + 1;
		i = 0;
		
		NextState = `CALCULATE_REMAINDER;
	end
	//----------------------------------------
	`CALCULATE_REMAINDER:
	begin
			//Bit = (Dividend & 32'h80000000) >> 31;
			Bit = (Dividend & 64'h8000000000000000 ) >> 63;
    		Remainder = (Remainder << 1) | Bit;
    		t = Remainder - Divisor;
    		//q = !((t & 32'h80000000) >> 31);
			q = !((t & 64'h8000000000000000 ) >> 63);
    		Dividend = Dividend << 1;
    		Quotient = (Quotient << 1) | q;
    		if ( q != 0 ) 
       			Remainder = t;
       		i = i + 1;	
       		
       		if (i < num_bits)
       			NextState = `CALCULATE_REMAINDER;
       		else
       			NextState = `WRITE_DIVISION_RESULT;	
	end
	//----------------------------------------
	//Will go to the IDLE leaving the Result Registers
	//with the current results until next stuff comes
	//So, stay in this state until our client sets iInputReady
	//to 0 telling us he read the result
	`WRITE_DIVISION_RESULT:
	begin
		xQuotient = Quotient[32:0];	//Simply chop to round
		OutputReady = 1;
//		$display("Quotient = %h - %b \n", Quotient, Quotient);

		NextState = (iInputReady == 0) ?
		 `FPS_AFTER_RESET_STATE : `WRITE_DIVISION_RESULT;
	end
endcase	

end //always
endmodule
//-----------------------------------------------------------------
