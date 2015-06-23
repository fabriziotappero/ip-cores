//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************************************************
// Copyright (c) 2007 TooMuch Semiconductor Solutions Pvt Ltd.
//
//File name		:	ahb_wb_coverage.svh	
//Designer		: 	Sanjay kumar	
//Date			: 	3rd Aug'2007		
//Description		: 	ahb_wb_coverage:Class to receive monitor packets from publisher(monitor) and check
//                              for Functional coverage.
//Revision		:	1.0
//*****************************************************************************************************************
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

import avm_pkg::*;
import global::*;

class ahb_wb_coverage extends avm_threaded_component;

analysis_fifo#(monitor_pkt) ap_fifo; // analysis port fifo 
analysis_if#(monitor_pkt) ap_if; // analysis port  interface

// local variables 
logic [AWIDTH-1:0]adr1; 
logic [AWIDTH-1:0]adr2; 
logic [DWIDTH-1:0]dat1; 
logic [DWIDTH-1:0]dat2; 
bit sel,wr;
bit [1:0]mode;
	
// monitor packet
monitor_pkt m_pkt;

// coverage group
covergroup cov_wr;
	 write_read: coverpoint wr; // cover read/write
	 wr_with_wait_mst: cross  wr,mode;// cover read/write on wait state by master
	 wr_with_wait_slv: cross  wr,sel;// cover read/write on wait state by slave	

endgroup

	function new(string name ,avm_named_component parent);
		super.new(name,parent);
		ap_fifo  =new("ap_fifo",this);
		ap_if =null;
		cov_wr=new;
	endfunction

// connecting analysis fifo  to the analysis interface
function void export_connections();
	ap_if = ap_fifo.analysis_export;
endfunction 



		
task run;
	forever
	begin	
		ap_fifo.get(m_pkt); // receiving monitor_pkt from monitor
		// sampling the values of pkt to local variables
		sel=m_pkt.sel; 
		wr=m_pkt.wr;
		mode=m_pkt.mode;
		// sample the coverpoints
		cov_wr.sample();	
		
	end
endtask

endclass

		
	
