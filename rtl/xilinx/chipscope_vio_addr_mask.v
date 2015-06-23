//**************************************************************
// Module             : chipscope_vio_addr_mask.v
// Platform           : Ubuntu 10.04
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

module chipscope_vio_addr_mask(mask_out0 ,mask_out1 ,mask_out2 ,mask_out3 ,
                               mask_out4 ,mask_out5 ,mask_out6 ,mask_out7 ,
                               mask_out8 ,mask_out9 ,mask_out10,mask_out11,
                               mask_out12,mask_out13,mask_out14,mask_out15,
                               clk, icon_ctrl
                              );

parameter mask_index  = 4, //2**mask_index=mask_num
          mask_enabl  = 4,
          addr_width  = 32;

output [mask_enabl+addr_width-1:0] mask_out0;
output [mask_enabl+addr_width-1:0] mask_out1;
output [mask_enabl+addr_width-1:0] mask_out2;
output [mask_enabl+addr_width-1:0] mask_out3;
output [mask_enabl+addr_width-1:0] mask_out4;
output [mask_enabl+addr_width-1:0] mask_out5;
output [mask_enabl+addr_width-1:0] mask_out6;
output [mask_enabl+addr_width-1:0] mask_out7;
output [mask_enabl+addr_width-1:0] mask_out8;
output [mask_enabl+addr_width-1:0] mask_out9;
output [mask_enabl+addr_width-1:0] mask_out10;
output [mask_enabl+addr_width-1:0] mask_out11;
output [mask_enabl+addr_width-1:0] mask_out12;
output [mask_enabl+addr_width-1:0] mask_out13;
output [mask_enabl+addr_width-1:0] mask_out14;
output [mask_enabl+addr_width-1:0] mask_out15;

input clk;
inout [35:0] icon_ctrl;

reg [mask_enabl+addr_width-1:0] mask_out0;
reg [mask_enabl+addr_width-1:0] mask_out1;
reg [mask_enabl+addr_width-1:0] mask_out2;
reg [mask_enabl+addr_width-1:0] mask_out3;
reg [mask_enabl+addr_width-1:0] mask_out4;
reg [mask_enabl+addr_width-1:0] mask_out5;
reg [mask_enabl+addr_width-1:0] mask_out6;
reg [mask_enabl+addr_width-1:0] mask_out7;
reg [mask_enabl+addr_width-1:0] mask_out8;
reg [mask_enabl+addr_width-1:0] mask_out9;
reg [mask_enabl+addr_width-1:0] mask_out10;
reg [mask_enabl+addr_width-1:0] mask_out11;
reg [mask_enabl+addr_width-1:0] mask_out12;
reg [mask_enabl+addr_width-1:0] mask_out13;
reg [mask_enabl+addr_width-1:0] mask_out14;
reg [mask_enabl+addr_width-1:0] mask_out15;

wire [mask_index+mask_enabl+addr_width-1:0]           index_enabl_value_vi;
wire [mask_index-1                      :0] mask_id = index_enabl_value_vi[mask_index+mask_enabl+addr_width-1:mask_enabl+addr_width];
wire [           mask_enabl+addr_width-1:0] mask_is = index_enabl_value_vi[                                   mask_enabl+addr_width-1:0];

always @(posedge clk) begin
  case (mask_id)
    'd0  : mask_out0  <= mask_is;
    'd1  : mask_out1  <= mask_is;
    'd2  : mask_out2  <= mask_is;
    'd3  : mask_out3  <= mask_is;
    'd4  : mask_out4  <= mask_is;
    'd5  : mask_out5  <= mask_is;
    'd6  : mask_out6  <= mask_is;
    'd7  : mask_out7  <= mask_is;
    'd8  : mask_out8  <= mask_is;
    'd9  : mask_out9  <= mask_is;
    'd10 : mask_out10 <= mask_is;
    'd11 : mask_out11 <= mask_is;
    'd12 : mask_out12 <= mask_is;
    'd13 : mask_out13 <= mask_is;
    'd14 : mask_out14 <= mask_is;
    'd15 : mask_out15 <= mask_is;
  endcase
end

chipscope_vio_mask VIO_inst (
  .CONTROL(icon_ctrl), // INOUT BUS [35:0]
  .CLK(clk), // IN
  .SYNC_OUT(index_enabl_value_vi) // OUT BUS [39:0]
);

endmodule
