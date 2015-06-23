//******************************************************************************************************
// Copyright (c) 2007 TooMuch Semiconductor Solutions Pvt Ltd.


//File name             :       wb_ahb_driver.svh
//Designer		:	Ravi S Gupta
//Date                  :       4 Sept, 2007
//Description   	:       Drivers for WISHBONE_AHB Bridge
//Revision              :       1.0

//******************************************************************************************************

// driver class
import avm_pkg::*;
import global::*;
class wb_ahb_driver extends avm_threaded_component;

avm_nonblocking_get_port #(wb_req_pkt) request_port;
tlm_fifo #(wb_req_pkt) fifo;

virtual wb_ahb_if pin_if;

	function new(string name ,avm_named_component parent);
		super.new(name,parent);
		request_port =new("request_port",this);
		fifo =new("fifo",this);	
		pin_if = null;
	endfunction

task run;
	wb_req_pkt req;
	wb_res_pkt res;
	forever		
		begin
			@(posedge pin_if.master_wb.clk_i);
					if(pin_if.master_wb.cyc_i && !pin_if.master_wb.rst_i)
						begin
							if(pin_if.master_wb.we_i)
						        	begin	
								if(request_port.try_get(req))
								write_to_bus(req);
								end
							else
						        	begin	
								@(posedge pin_if.master_wb.clk_i);
								if(request_port.try_get(req))
								write_to_bus(req);
								end
					
						end
		end
endtask

// write data to bus
virtual task write_to_bus(input wb_req_pkt req);
		#2	pin_if.master_wb.we_i=req.wr;
			pin_if.master_wb.addr_i =req.adr;
			pin_if.master_wb.data_i=req.dat;
			pin_if.master_wb.stb_i=req.stb;
			
endtask 

endclass

