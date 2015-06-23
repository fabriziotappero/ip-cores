//////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************************************************
// Copyright (c) 2007 TooMuch Semiconductor Solutions Pvt Ltd.
//
//File name		:	ahb_wb_env.svh	
//Designer		: 	Sanjay kumar	
//Date			: 	3rd Aug'2007		
//Description		: 	ahb_wb_env:Enviornment class to connect all the analysis and operational components.
//Revision		:	1.0
//*****************************************************************************************************************
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// env class
import avm_pkg::*;
import ahb_wb_pkg::*;
import global::*;

class ahb_wb_env extends avm_env;

virtual ahb_wb_if pin_if;// interface

// operational components
ahb_wb_stim_gen    stim_gen;
ahb_wb_driver      driver;
ahb_wb_responder   responder;

// analysis components
ahb_wb_monitor     monitor;
ahb_wb_scoreboard  scoreboard;
ahb_wb_coverage   coverage;

// tlm fifo
tlm_fifo #(ahb_req_pkt) fifo;

avm_analysis_port#(monitor_pkt) e_ap;
	function new (virtual ahb_wb_if pin);
		stim_gen   =new("stim_gen",this);
		driver     =new("driver",this);
		responder  =new("responder",this);
		monitor    =new("monitor",this);
		scoreboard =new("scoreboard",this);
		coverage   =new("coverage",this);
		fifo       =new("fifo",this);
		e_ap       =new("e_ap",this);
		pin_if        =pin;
		monitor.ap_sb =e_ap;
	endfunction

	function void connect();
		stim_gen.initiator_port.connect(fifo.blocking_put_export);
		driver.request_port.connect(fifo.nonblocking_get_export);
		monitor.ap_sb.register(scoreboard.ap_if);	
		monitor.ap_sb.register(coverage.ap_if);	
	endfunction

	function void import_connections();
		driver.pin_if    = pin_if;
		responder.pin_if = pin_if;
		monitor.pin_if   = pin_if;
	endfunction
	
	
		task run;
			fork
			stim_gen.stimulus();
			responder.wait_state_by_slave();
			#625;
			join
		endtask

endclass



