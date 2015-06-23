//**************************************************************
// Module             : chipscope_vio_adda_fifo.v
// Platform           : Ubuntu addr_width.04
// Simulator          : Modelsim 6.5b
// Synthesizer        : PlanAhead 14.2
// Place and Route    : PlanAhead 14.2
// Targets device     : Zynq-7000
// Author             : Bibo Yang  (ash_riple@hotmail.com)
// Organization       : www.opencores.org
// Revision           : 2.3 
// Date               : 2012/11/19
// Description        : addr/data capture output to debug host
//                      via Virtual JTAG.
//**************************************************************

`timescale 1ns/1ns

module chipscope_vio_adda_fifo(clk,wr_in,data_in,rd_in,icon_ctrl);

parameter data_width  = 98,
          addr_width  = 10,
          al_full_val = 511;

input clk;
input wr_in, rd_in;
input [data_width-1:0] data_in;
inout [35:0] icon_ctrl;

wire [2-1:0] ctrl_vi;
wire [addr_width+data_width-1:0] usedw_data_vo;

reg rst_d1, rst_d2;
reg rd_d1 , rd_d2;

always @(posedge clk) begin
  rst_d1 <= ctrl_vi[1];
  rst_d2 <= rst_d1;

  rd_d1 <= ctrl_vi[0];
  rd_d2 <= rd_d1;
end

wire rst_vi = rst_d1 & !rst_d2;
wire rd_vi  = rd_d1  & !rd_d2;

wire reset = rst_vi;
wire [addr_width-1:0] usedw;
wire [data_width-1:0] data_out;
wire al_full = (usedw==al_full_val)? 1'b1: 1'b0;
wire wr_en = wr_in & !al_full;
wire rd_en = rd_in | rd_vi;

assign usedw_data_vo = {usedw, data_out};

scfifo jtag_fifo(
  .clk(clk),
  .rst(reset),
  .din(data_in),
  .wr_en(wr_en),
  .rd_en(rd_en),
  .dout(data_out),
  .full(),
  .empty(),
  .data_count(usedw)
);

chipscope_vio_fifo VIO_inst (
  .CONTROL(icon_ctrl), // INOUT BUS [35:0]
  .CLK(clk), // IN
  .SYNC_OUT(ctrl_vi), // OUT BUS [1:0]
  .SYNC_IN(usedw_data_vo) // IN BUS [107:0]
);

endmodule
