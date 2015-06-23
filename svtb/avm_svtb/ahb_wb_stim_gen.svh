//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************************************************
// Copyright (c) 2007 TooMuch Semiconductor Solutions Pvt Ltd.
//
//File name		:	ahb_wb_stim_gen.svh	
//Designer		: 	Sanjay kumar	
//Date			: 	3rd Aug'2007		
//Description		: 	ahb_wb_stim_gen:Class to generata write and read packet with wait state by master.	
//Revision		:	1.0
//*****************************************************************************************************************
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

import avm_pkg::*;
import global::*;

class ahb_wb_stim_gen extends avm_named_component;

// communication port
avm_blocking_put_port#( ahb_req_pkt) initiator_port;
tlm_fifo #(ahb_req_pkt) fifo;

	function new(string name ,avm_named_component parent);
		super.new(name,parent);
		initiator_port=new("initiatot_port",this);
		fifo =new("fifo",this);
	endfunction

task stimulus(input int count= 45);
	ahb_req_pkt p;
	//(write operation) write data and addr. to fifo 
		for(int i=0; i<count ;i++)
		begin
			if(i>15 && i<21)// busy  mode
				begin
				p.mode='b01;
				p.wr='b1;
				end
			else if(i>26 && i<31) // idle mode
				begin
				p.mode='b00;
				p.wr='b1;
				end
			else if(i>30 && i<36) // Sequential mode
				begin
				p.mode='b11;
				p.wr='b1;
				end
			else	// Non sequential mode
				begin
				p.mode='b10;
				p.adr=$random;	
				p.dat=$random;
				p.wr='b1;
				end
		write_to_pipe(p);
		end
	//(read operation) write address to fifo for read 
		for(int i=0; i<count ;i++)
		begin
			if(i>10 && i<16) // busy mode
				begin
				p.mode='b01;
				p.wr='b0;
				end
			else if(i>20 && i<26) // idle mode
				begin
				p.mode='b00;
				p.wr='b0;
				end
			else if(i>25 && i<31) // Sequential mode
				begin
				p.mode='b11;
				p.wr='b0;
				end
			else //Non Sequential mode
				begin 
				p.mode='b10;
				p.adr=$random;	
				p.wr='b0;
				end
		write_to_pipe(p);
		end
	// write operation
		for(int i=0; i<(count-30) ;i++)
		begin
			if(i>=0 && i<(count-30))
				begin
				p.mode='b10;
				p.adr=$random;	
				p.dat=$random;	
				p.wr='b1;
				end
		write_to_pipe(p);
		end
endtask

// task to push transaction in the fifo
task write_to_pipe(ahb_req_pkt p);
		initiator_port.put(p);
               //avm_report_message("Stim_gen: Packet pushed into fifo",global::convert2string(p));
		
endtask
	
  
endclass 
