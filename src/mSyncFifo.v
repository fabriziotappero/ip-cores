/*
Developed By Subtleware Corporation Pte Ltd 2011
File		:
Description	:	
Remarks		:	
Revision	:
	Date	Author		Description
02/09/12	Jefflieu
*/


module mSyncFifo #(parameter pDataWidth=8,pPtrWidth=2)
	(
	input 	[pDataWidth-1:00] iv_Din,
	input	i_Wr,
	output	o_Full,
	output	o_Empty,	
	output	[pDataWidth-1:00] ov_Q,
	input	i_Rd,
	input	i_Clk,
	input	i_ARst_L);
	

	localparam pMemSize=2**pPtrWidth;
	
	reg [pDataWidth-1:00] rv_Ram [0:pMemSize-1];
	
	reg [pPtrWidth-1:00] rv_RdPtr;
	reg [pPtrWidth-1:00] rv_WrPtr;
	reg [pPtrWidth:00] 	 rv_Cntr;
	
	wire w_WrValid;
	wire w_RdValid;
	
	assign o_Full = (rv_Cntr==pMemSize)?1'b1:1'b0;
	assign o_Empty = (rv_Cntr==0)?1'b1:1'b0;
	assign w_WrValid = (~o_Full) & i_Wr;
	assign w_RdValid = (~o_Empty) & i_Rd;
	//DualPortRam
	always@(posedge i_Clk or negedge i_ARst_L)
	if(i_ARst_L==1'b0) begin
			rv_RdPtr<={pPtrWidth{1'b0}};
			rv_WrPtr<={pPtrWidth{1'b0}};
			rv_Cntr <={(pPtrWidth+1){1'b0}};
	end else
	begin
			if(w_WrValid) 
				begin
					rv_WrPtr <= rv_WrPtr+1;
					rv_Ram[rv_WrPtr] <= iv_Din;
				end
			if(w_RdValid)
					rv_RdPtr <= rv_RdPtr+1;
			
			if(w_RdValid & (~w_WrValid)) 
					rv_Cntr <= rv_Cntr-1;
			else if(w_WrValid & (~w_RdValid))
					rv_Cntr <= rv_Cntr+1;
	end
	
	assign ov_Q = rv_Ram[rv_RdPtr];
	
	
	
endmodule
