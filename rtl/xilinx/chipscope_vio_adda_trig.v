//**************************************************************
// Module             : chipscope_vio_adda_trig.v
// Platform           : Ubuntu pnum_width.04 
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

module chipscope_vio_adda_trig(trig_out, pnum_out, clk, icon_ctrl);

parameter trig_width  = 72;
parameter pnum_width  = 10;

output [trig_width-1:0] trig_out;
output [pnum_width-1:0] pnum_out;

input clk;
inout [35:0] icon_ctrl;

wire [pnum_width+trig_width-1:0] pnum_trig_vi;

reg [trig_width-1:0] trig_out;
reg [pnum_width-1:0] pnum_out;

always @(posedge clk) begin
  pnum_out <= pnum_trig_vi[pnum_width+trig_width-1:trig_width];
  trig_out <= pnum_trig_vi[           trig_width-1:         0];
end

chipscope_vio_trig VIO_inst (
  .CONTROL(icon_ctrl), // INOUT BUS [35:0]
  .CLK(clk), // IN
  .SYNC_OUT(pnum_trig_vi) // OUT BUS [81:0]
);

endmodule
