//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************************************************
// Copyright (c) 2007 TooMuch Semiconductor Solutions Pvt Ltd.
//
//File name		:	ahb_wb_top.sv	
//Designer		: 	Sanjay kumar	
//Date			: 	3rd Aug'2007		
//Description		: 	ahb_wb_top:Top module instantiating all components and scheduling tasks
//Revision		:	1.0
//*****************************************************************************************************************
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
// top module
`include "../../src/ahb2wb.v"
`timescale 1ns/ 1ps

import ahb_wb_pkg::*;
import global::*;

module ahb_wb_top;

logic clk ='b0;
logic reset ='b1;

	ahb_wb_if inf1(); // interface instance from ahb to bridge 
	stimulus_gen TB_M(inf1.master_ab,clk,reset); // AHB master instance 
    
	ahb2wb DUT ( // interface connection from AHB(stimulus gen) to bridge
                   .hclk(inf1.slave_ab.hclk),
                   .hresetn(inf1.slave_ab.hresetn), 
                   .haddr(inf1.slave_ab.haddr),
                   .hwdata(inf1.slave_ab.hwdata), 
                   .htrans(inf1.slave_ab.htrans), 
                   .hburst(inf1.slave_ab.hburst), 
                   .hsize(inf1.slave_ab.hsize), 
                   .hwrite(inf1.slave_ab.hwrite), 
                   .hsel(inf1.slave_ab.hsel), 
                   .hready(inf1.slave_ab.hready), 
                   .hrdata(inf1.slave_ab.hrdata),
                   .hresp(inf1.slave_ab.hresp), 
                   // interface connection from bridge to wishbone(memory)
                   .cyc_o(inf1.master_bw.cyc_o), 
                   .stb_o(inf1.master_bw.stb_o),
                   .we_o(inf1.master_bw.we_o),
                   .dat_o(inf1.master_bw.dat_o), 
                   .adr_o(inf1.master_bw.adr_o),
                   .ack_i(inf1.master_bw.ack_i),
                   .dat_i(inf1.master_bw.dat_i),
                   .clk_i(inf1.master_bw.clk_i),
                   .rst_i(inf1.master_bw.rst_i));
 	ahb_wb_env env; // enviornment class                   

// reset generation
initial 
	begin
		env = new(inf1);
	        $display ("\n@%0d:Testcase begin",$time); 
		#13  reset='b0;
		#33 reset ='b1; 
	        $display ("\n@%0d:Reset done",$time); 
	 	TB_M.initial_setup();
	        $display ("\n@%0d:Initial setup done",$time); 
		env.do_test();
	        $display ("\n@%0d do_test over",$time); 
		$finish;	
		
	end  

//clock generation
initial  
	forever
		#(cyc_prd/2)  clk = ~clk;
endmodule
