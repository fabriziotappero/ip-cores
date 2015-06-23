//******************************************************************************************************
// Copyright (c) 2007 TooMuch Semiconductor Solutions Pvt Ltd.


//File name             :       wb_ahb_coverage.svh
//Designaer		:	Ravi S Gupta
//Date                  :       4 Sept, 2007
//Description           :       Coverage Status for WISHBONE_AHB Bridge
//Revision              :       1.0

//******************************************************************************************************

// coverage  class
import avm_pkg::*;
import global::*;
class wb_ahb_coverage extends avm_threaded_component;

analysis_fifo#(monitor_pkt) ap_fifo; // analysis port fifo 
analysis_if#(monitor_pkt) ap_if; // analysis port  interface

// local variables 
logic [AWIDTH-1:0]adr1; 
logic [AWIDTH-1:0]adr2; 
logic [DWIDTH-1:0]dat1; 
logic [DWIDTH-1:0]dat2; 
bit stb,wr,ack;

// monitor packet
monitor_pkt m_pkt;

// coverage group
covergroup cov_wr;
	 write_read: coverpoint wr; // cover read/write
	 wr_with_wait_mst: cross  wr,stb;// cover read/write on wait state by master
	 wr_with_wait_slv: cross  wr,ack;// cover read/write on wait state by slave	

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
		stb=m_pkt.stb; 
		wr=m_pkt.wr;
		ack=m_pkt.ack;
		// sample the coverpoints
		cov_wr.sample();	
		
	end
endtask

endclass

