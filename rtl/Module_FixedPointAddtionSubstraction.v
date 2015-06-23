`timescale 1ns / 1ps
`include "aDefinitions.v"


//-----------------------------------------------------------
module INCREMENT # ( parameter SIZE=`WIDTH )
(
input	 wire					Clock,
input  wire					Reset,
input  wire[SIZE-1:0]	A,
output reg [SIZE-1:0]	R
);
always @ (posedge Clock)
begin
	R = A + 1;
end


endmodule
//-----------------------------------------------------------
module FixedAddSub
(
input	 wire					Clock,
input  wire					Reset,
input  wire[`LONG_WIDTH-1:0]	A,
input  wire[`LONG_WIDTH-1:0]	B,
output reg[`LONG_WIDTH-1:0]	R,
input	wire						iOperation,
input	wire					iInputReady,		//Is the input data valid?
output wire					OutputReady		//Our output data is ready!
);

reg MyOutputReady = 0;

wire [`LONG_WIDTH-1:0] wB;

assign wB = ( iOperation ) ? ~B + 1'b1 : B;
   
//Output ready just take 1 cycle
//assign OutputReady = iInputReady;

FFD_POSEDGE_ASYNC_RESET #(1) FFOutputReadyDelay2
(
	.Clock( Clock ),
	.Clear( Reset ),
	.D( iInputReady ),
	.Q( OutputReady )
);	
	
	
//-------------------------------	
always @ (posedge Clock)
begin

if (iInputReady == 1)
begin
	  R = ( A + wB );
end	
else 
begin
		R = 64'hFFFFFFFF;

end

end // always

endmodule
