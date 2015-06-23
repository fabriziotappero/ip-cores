`timescale 1ns / 1ns
package cmath;
    import "DPI-C" function real sin(input real x);
endpackage
module cic_d_tb
(
);
localparam R = 25;
localparam idw = 16;
localparam odw = 16;
localparam M = 4;
localparam G = 1;
/*************************************************************/
localparam real Fs = 100;//MHz
localparam real T_ns = 10**3/Fs;//ns
localparam time half_T = T_ns/2;
localparam real f = 0.5;//MHz
localparam real f_inc = f/Fs;
localparam bias = 5;
real f_n = 0.0;
/*************************************************************/
reg                     clk;
reg                     reset_n;
reg signed[idw-1:0]     filter_in;
wire                    filter_valid;
wire signed[odw-1:0]    filter_out;
/*************************************************************/
import cmath::*;
/*************************************************************/
initial begin : clk_gen
  clk <= 1'b0;
  #half_T forever #half_T clk = ~clk;
end
/*************************************************************/
initial begin : reset_gen
  $display($time, " << Starting the Simulation >>");
  reset_n = 1'b0;
  repeat (2) @(negedge clk);
  $display($time, " << Coming out of reset >>");
  reset_n = 1'b1;
  repeat (20) @(posedge clk);
  @(posedge clk);
end
/*************************************************************/
always @(posedge clk)
begin
    f_n = f_n + f_inc;
end
/*************************************************************/
assign filter_in = $rtoi((2**(idw-1)-1)*($sin(f_n)));
/*************************************************************/
cic_d #(idw,odw,R,M,G) dut1
(
    .clk(clk),
    .reset_n(reset_n),
    .data_in(filter_in),
    .data_out(filter_out),
    .out_dv(filter_valid)
);
/*************************************************************/
endmodule
 
