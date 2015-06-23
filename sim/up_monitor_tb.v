//**************************************************************
// Module             : up_monitor_tb.v
// Platform           : Windows xp sp2
// Simulator          : Modelsim 6.5b
// Synthesizer        : 
// Place and Route    : 
// Targets device     : 
// Author             : Bibo Yang  (ash_riple@hotmail.com)
// Organization       : www.opencores.org
// Revision           : 2.2 
// Date               : 2012/03/28
// Description        : up_monitor testbench at both pin level 
//                      and transaction level
//**************************************************************

`timescale 1ns/1ns

module up_monitor_tb ();

reg cpu_start;
reg up_clk;
wire up_wbe, up_csn;
wire [15:2] up_addr;
wire [31:0] up_data_io;
initial begin
             up_clk = 1'b0;
  forever #5 up_clk = !up_clk;
end

// pin level DUT
up_monitor_wrapper MON_LO (
  .up_clk(up_clk),
  .up_wbe(),  // negative logic
  .up_csn(),  // negative logic
  .up_addr(),
  .up_data_io()
);

up_bfm_sv CPU (
  .up_clk(up_clk),
  .up_wbe(up_wbe),  // negative logic
  .up_csn(up_csn),  // negative logic
  .up_addr(up_addr),
  .up_data_io(up_data_io)
);

reg_bfm_sv REG (
  .up_clk(up_clk),
  .up_wbe(up_wbe),  // negative logic
  .up_csn(up_csn),  // negative logic
  .up_addr({up_addr,2'b00}),
  .up_data_io(up_data_io)
);

jtag_bfm_sv JTAG (
);

assign MON_LO.up_wbe     = up_wbe;
assign MON_LO.up_csn     = up_csn;
assign MON_LO.up_addr    = up_addr;
assign MON_LO.up_data_io = up_data_io;

initial begin
	up_monitor_tb.CPU.up_start = 0;
	@(posedge up_monitor_tb.JTAG.jtag_sim_done);
	up_monitor_tb.CPU.up_start = 1;
	#100000000 $stop;
end

endmodule
