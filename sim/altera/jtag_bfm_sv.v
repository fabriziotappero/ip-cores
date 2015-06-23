//**************************************************************
// Module             : jtag_bfm_sv.v
// Platform           : Windows xp sp2
// Simulator          : Modelsim 6.5b
// Synthesizer        : 
// Place and Route    : 
// Targets device     : 
// Author             : Bibo Yang  (ash_riple@hotmail.com)
// Organization       : www.opencores.org
// Revision           : 2.2 
// Date               : 2012/03/28
// Description        : JTAG Stimulus monitor
//**************************************************************

`timescale 1ns/1ns
`include "jtag_sim_define.h"

module jtag_bfm_sv (
);

reg jtag_sim_done;
initial begin
	jtag_sim_done = 0;
	fork
		@(posedge up_monitor_tb.MON_LO.inst.u_virtual_jtag_adda_fifo.sld_virtual_jtag_component.user_input.vj_sim_done);
		@(posedge up_monitor_tb.MON_LO.inst.u_virtual_jtag_addr_mask.sld_virtual_jtag_component.user_input.vj_sim_done);
		@(posedge up_monitor_tb.MON_LO.inst.u_virtual_jtag_adda_trig.sld_virtual_jtag_component.user_input.vj_sim_done);
	join
	$display("All JTAG stimulus excercised");
	jtag_sim_done = 1;
end

endmodule
