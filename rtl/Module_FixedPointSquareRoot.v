`timescale 1ns / 1ps
`include "aDefinitions.v"

//Square Root State Machine Constants
`define SQUARE_ROOT_LOOP					1
`define WRITE_SQUARE_ROOT_RESULT			2


`define SR_AFTER_RESET_STATE 0
//-----------------------------------------------------------------
/*

	Calcualtes the SquareRoot of a Fixed Point Number
	Input:  Q32.32
	Output: Q16.16
	Notice that the result has half the precicion as the operands!!
*/	
module FixedPointSquareRoot
(
	input wire							Clock,
	input wire							Reset,
	input wire[`LONG_WIDTH-1:0] 	Operand,			
	input wire							iInputReady,					
	output	reg 						OutputReady,				
	output  reg [`WIDTH-1:0]		Result
);

reg[63:0]			x;
reg[0:`WIDTH-1] 	group,sum,diff;
reg[0:`WIDTH-1]	 	temp1,temp2;
reg	[5:0]			CurrentState, NextState;

reg myInputReady;
 
//----------------------------------------
always @(posedge Clock)
begin
	myInputReady = iInputReady;
end 
//----------------------------------------
//Next states logic
always @(negedge Clock)
begin
        if( Reset!=1 )
           CurrentState = NextState;
			 else 
				CurrentState = `SR_AFTER_RESET_STATE;
end
//----------------------------------------

always @ (posedge Clock)
begin
	case (CurrentState)
	//----------------------------------------
	`SR_AFTER_RESET_STATE:
	begin
		OutputReady = 0;
		Result		= 0;
		sum			= 0;
		diff			= 0;
		group=32;				//WAS 16
		x = 0;
		if ( myInputReady == 1  )
		begin
		  // x[31:0] = Operand;
		  x = Operand;
			x = x << `SCALE;
			NextState = `SQUARE_ROOT_LOOP;
		end else
			NextState = `SR_AFTER_RESET_STATE;
			
	end
	//----------------------------------------
	`SQUARE_ROOT_LOOP:
	begin
		
		
		
		sum = sum << 1;
		sum = sum +  1;
		temp1 = diff << 2;
		//diff = diff + (x>>(group*2)) &3;
		temp2 = group << 1;				//group * 2 ??
		diff = temp1 + ((x >> temp2) &3); 
		
		if (sum > diff)
		begin
			sum = sum -1;
		end
		else
		begin
			Result = Result + (1<<group);
			diff = diff - sum;
			sum = sum + 1;
		end//if
		
		
		if ( group != 0 )
		begin
			group = group - 1;
			NextState = `SQUARE_ROOT_LOOP;
		end	
		else
		begin	 
			NextState 	= `WRITE_SQUARE_ROOT_RESULT;
			
		end	 
	end
	//----------------------------------------
	`WRITE_SQUARE_ROOT_RESULT:
	begin
		OutputReady = 1;
		NextState = (iInputReady == 0) ?
		 `SR_AFTER_RESET_STATE : `WRITE_SQUARE_ROOT_RESULT;
	end
	//----------------------------------------
endcase	
end //always
endmodule
//-----------------------------------------------------------------