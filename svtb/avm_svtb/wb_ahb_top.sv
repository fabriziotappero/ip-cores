//******************************************************************************************************
// Copyright (c) 2007 TooMuch Semiconductor Solutions Pvt Ltd.


//File name             :       wb_ahb_top.svh
//Designer		:	Ravi S Gupta
//Date                  :       4 Sept, 2007
//Description           :       Top for WISHBONE_AHB Bridge
//Revision              :       1.0

//******************************************************************************************************


// top module
`include "../../src/ahbmas_wbslv_top.v"

import wb_ahb_pkg::*;
import global::*;

module wb_ahb_top;

logic clk ='b0;
logic reset ='b0;

	wb_ahb_if inf1(); // interface instance from wb to bridge 
	stimulus_gen TB_M(inf1.master_wb,clk,reset); // WB master instance 
    
	AHBMAS_WBSLV_TOP DUT ( // interface connection from WB(stimulus gen) to bridge
                   .clk_i(inf1.slave_wb.clk_i),
		   .rst_i(inf1.slave_wb.rst_i),
		   .data_i(inf1.slave_wb.data_i),
		   .addr_i(inf1.slave_wb.addr_i),
		   .ack_o(inf1.slave_wb.ack_o),
		   .cyc_i(inf1.slave_wb.cyc_i),
		   .stb_i(inf1.slave_wb.stb_i),
		   .we_i(inf1.slave_wb.we_i),
		   .data_o(inf1.slave_wb.data_o),
		   .sel_i(inf1.slave_wb.sel_i),
                   // interface connection from bridge to wishbone(memory)
		   .hclk(inf1.master_ba.hclk),
                   .hresetn(inf1.master_ba.hresetn), 
		   .hwrite(inf1.master_ba.hwrite),
		   .haddr(inf1.master_ba.haddr),
                   .hwdata(inf1.master_ba.hwdata),
		   .hburst(inf1.master_ba.hburst), 
                   .hsize(inf1.master_ba.hsize), 
		   .htrans(inf1.master_ba.htrans), 
		   .hready(inf1.master_ba.hready), 
                   .hrdata(inf1.master_ba.hrdata),
                   .hresp(inf1.master_ba.hresp));               	   
 	wb_ahb_env env; // enviornment class                   
// reset generation
initial 
	begin
		env = new(inf1);
	        #2  reset='b1;
		#23 reset ='b0;
	        TB_M.initial_setup();
	        env.do_test();
	        $finish;	
		
	end  

//clock generation
initial  
	forever
		#(cyc_prd/2)  clk = ~clk;
endmodule
