//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************************************************
// Copyright (c) 2007 TooMuch Semiconductor Solutions Pvt Ltd.
//
//File name		:	ahb_wb_responder.svh	
//Designer		: 	Sanjay kumar	
//Date			: 	3rd Aug'2007		
//Description		: 	ahb_wb_responder:Class to respond for the request sent by AHB Master and to generate 
//                              wait state by Wishbone slave.	
//Revision		:	1.0
//*****************************************************************************************************************
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

import avm_pkg::*;
import global::*;

class ahb_wb_responder extends avm_threaded_component;

int cnt;
virtual ahb_wb_if pin_if;

	function new(string name ,avm_named_component parent);
		super.new(name,parent);
		pin_if   =null;
	endfunction


task run;
	forever		
		begin 
			@(pin_if.slave_bw.adr_o or pin_if.slave_bw.we_o);	
				if(!pin_if.master_ab.hresetn)	
					begin
					pin_if.slave_bw.ack_i='b0;
					pin_if.slave_bw.dat_i='bx;
					end
				else
					 if(! pin_if.slave_bw.we_o)
						pin_if.slave_bw.dat_i=pin_if.slave_bw.adr_o;	
		end
endtask

// wait state asserted by slave 
task wait_state_by_slave;
	pin_if.slave_bw.ack_i='b1;
	do
		begin
		@(posedge pin_if.master_ab.hclk);
		cnt++;
		end
	while (cnt <= 7);
		
	#2 pin_if.slave_bw.ack_i='b0; // 8 clock cycle asserted
	//avm_report_message("Responder: Wait state asserted in Write mode ","by slave");
	cnt=0;
	do
		begin
		@(posedge pin_if.master_ab.hclk);
		cnt++;
		end
	while (cnt <= 4);
	#2 pin_if.slave_bw.ack_i='b1; // 5 clock cycle deasserted
	//avm_report_message("Responder: Wait state deasserted in write mode ","by slave");
	cnt=0;
	do
		begin
		@(posedge pin_if.master_ab.hclk);
		cnt++;
		end
	while (cnt <= 44);
	 
	#2 pin_if.slave_bw.ack_i='b0; // 25 clock cycle asserted
	//avm_report_message("Responder: Wait state asserted in Read mode ","by slave");
	cnt=0;
	do
		begin
		@(posedge pin_if.master_ab.hclk);
		cnt++;
		end
	while (cnt <= 4);
	#2 pin_if.slave_bw.ack_i='b1; // 5 clock cycle  deasserted
	//avm_report_message("Responder: Wait state deasserted in Read mode ","by slave");
endtask 


endclass

		
	
