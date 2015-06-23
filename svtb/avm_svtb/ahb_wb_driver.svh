//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************************************************
// Copyright (c) 2007 TooMuch Semiconductor Solutions Pvt Ltd.
//
//File name		:	ahb_wb_driver.svh	
//Designer		: 	Sanjay kumar	
//Date			: 	3rd Aug'2007		
//Description		: 	ahb_wb_driver:Class to receive packets from the tlm fifo and passed it to the 
//				interface of the AHB to Wishbone bridge.		
//Revision		:	1.0
//*****************************************************************************************************************
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

import avm_pkg::*;
import global::*;

class ahb_wb_driver extends avm_threaded_component;

// communication ports
avm_nonblocking_get_port #(ahb_req_pkt) request_port;
tlm_fifo #(ahb_req_pkt) fifo;

virtual ahb_wb_if pin_if;

	function new(string name ,avm_named_component parent);
		super.new(name,parent);
		request_port =new("request_port",this);
		fifo =new("fifo",this);	
		pin_if   =null;
	endfunction

task run;
	ahb_req_pkt req;
	ahb_res_pkt res;
	forever		
		begin
			@(posedge pin_if.master_ab.hclk);
					if(pin_if.master_ab.hready && pin_if.master_ab.hresetn)
						begin
							if(request_port.try_get(req))
							write_to_bus(req);
						end
		end
endtask


// write data to bus
virtual task write_to_bus(input ahb_req_pkt req);
		#2	pin_if.master_ab.htrans=req.mode;
	            	pin_if.master_ab.hwrite=req.wr;
			pin_if.master_ab.haddr =req.adr;
			pin_if.master_ab.hwdata=req.dat;
			//avm_report_message("Driver:Packet on interface",global::convert2string(req));
endtask 

endclass

		
	
