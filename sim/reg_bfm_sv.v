//**************************************************************
// Module             : reg_bfm_sv.v
// Platform           : Windows xp sp2
// Simulator          : Modelsim 6.5b
// Synthesizer        : 
// Place and Route    : 
// Targets device     : 
// Author             : Bibo Yang  (ash_riple@hotmail.com)
// Organization       : www.opencores.org
// Revision           : 2.2 
// Date               : 2012/03/28
// Description        : Register BFM
//**************************************************************

`timescale 1ns/1ns

module reg_bfm_sv (
  input        up_clk,
  input        up_wbe,up_csn,  // negative logic
  input [15:0] up_addr,
  inout [31:0] up_data_io
);

wire [31:0] up_data_i;
reg  [31:0] up_data_o;

assign #10 up_data_io = (up_wbe&&!up_csn)? up_data_o : 32'bzzzzzzzz;
assign up_data_i  = up_data_io;

reg [31:0] RAM [0:3];
always @(posedge up_clk) begin
  if (!up_wbe && !up_csn)
	  RAM[up_addr[3:2]] <= up_data_i;

  up_data_o <= RAM[up_addr[3:2]];
end

endmodule
