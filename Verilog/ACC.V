/****************************************************************************************
 MODULE:		Sub Level Accumulator Block

 FILE NAME:	acc.v
 VERSION:	1.0
 DATE:		September 28th, 2001
 AUTHOR:		Hossein Amidi
 COMPANY:	California Unique Electrical Co.
 CODE TYPE:	Register Transfer Level

 Instantiations:
 
 DESCRIPTION:
 Sub Level RTL Accumulator block, with zero & negetive flags

 Hossein Amidi
 (C) September 2001
 California Unique Electric

***************************************************************************************/
 
`timescale 1ns / 1ps

module	 ACC(	// Input
					clock,
					reset,
					ACCInEn,
					ACCDataIn,
					// Output
					ACCNeg,
					ACCZero,
					ACCDataOut
					);


// Parameter
parameter DataWidth = 32;

// Input
input  clock;
input  reset;
input	 ACCInEn;
input  [DataWidth - 1 : 0] ACCDataIn;

// Output
output  ACCNeg;
output  ACCZero;
output [DataWidth - 1 : 0] ACCDataOut;

// Signal Declerations
reg [DataWidth - 1 : 0]rACCDataOut;

// Assignments
assign ACCDataOut = rACCDataOut;
assign ACCNeg = rACCDataOut[31]; 
assign ACCZero = ~((((((((((((((((ACCDataOut[0]  | ACCDataOut[1])   |
										 (ACCDataOut[2]  | ACCDataOut[3]))  |
										 (ACCDataOut[4]  | ACCDataOut[5]))  |
								 		 (ACCDataOut[6]  | ACCDataOut[7]))  |
								 		 (ACCDataOut[8]  | ACCDataOut[9]))  |
								 		 (ACCDataOut[10] | ACCDataOut[11])) |
								 		 (ACCDataOut[12] | ACCDataOut[13])) |
								 		 (ACCDataOut[14] | ACCDataOut[15])) |
										 (ACCDataOut[16] | ACCDataOut[17])) |
										 (ACCDataOut[18] | ACCDataOut[19])) |
										 (ACCDataOut[20] | ACCDataOut[21])) |
										 (ACCDataOut[22] | ACCDataOut[23])) |
										 (ACCDataOut[24] | ACCDataOut[25])) |
										 (ACCDataOut[26] | ACCDataOut[27])) |
										 (ACCDataOut[28] | ACCDataOut[29])) |
										 (ACCDataOut[30] | ACCDataOut[31])) ;



always @(posedge reset or negedge clock)
begin
	if(reset == 1'b1)
		rACCDataOut <= 32'h0000;
	else
	if(ACCInEn == 1'b1)
		rACCDataOut <= ACCDataIn;
	else
		rACCDataOut <= rACCDataOut;
end
endmodule
