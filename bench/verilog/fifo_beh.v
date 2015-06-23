/******************************************************************************
  $Id: fifo_beh.v,v 1.1 2002-03-10 17:18:37 johnsonw10 Exp $
  
  Author(s): Johnsonw10@opencors.org
  
  Revision History:
  $Log: not supported by cvs2svn $

******************************************************************************/
`timescale 1 ns / 100 ps
module fifo_beh (
		 clk,
		 reset_n,
		 wr,
		 din,

		 rd,
		 dout,

		 empty,
		 full
);

parameter DATA_WIDTH   = 32;
parameter FIFO_SIZE    = 64;

input reset_n;
input clk;

input wr;
input [0:DATA_WIDTH-1] din;

input rd;
output [0:DATA_WIDTH-1] dout;
reg [0:DATA_WIDTH-1] dout;
output empty;
output full;

reg [0:DATA_WIDTH-1] mem[0:FIFO_SIZE-1];
integer rd_ptr, wr_ptr, dcnt;

wire empty_o, full_o;
wire rd_i = rd & (!empty_o);
wire wr_i = wr & (!full_o);

always @ (negedge reset_n or posedge clk) begin
    if (!reset_n) begin
	rd_ptr <= 0;
	wr_ptr <= 0;
	dcnt <= 0;
    end
    else begin
	if (rd_i) begin
	    dout <= mem[rd_ptr];
	    rd_ptr <= rd_ptr + 1;
	end

	if (wr_i) begin
	    mem[wr_ptr] <= din;
	    wr_ptr <= wr_ptr + 1;
	end

	if (rd_i && wr_i)
	    dcnt <= dcnt;
	else if (rd_i)
	    dcnt <= dcnt - 1;
	else if (wr_i)
	    dcnt <= dcnt + 1;
    end
end

assign empty_o = (dcnt == 0);
assign full_o  = (dcnt == FIFO_SIZE);

assign empty = empty_o;
assign full  = full_o;

endmodule