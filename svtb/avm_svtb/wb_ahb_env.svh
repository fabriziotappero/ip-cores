//******************************************************************************************************
// Copyright (c) 2007 TooMuch Semiconductor Solutions Pvt Ltd.


//File name             :       wb_ahb_env.svh
//Designer		:	Ravi S Gupta
//Date                  :       4 Sept, 2007
//Description   	:       Environment for WISHBONE_AHB Bridge
//Revision              :       1.0

//******************************************************************************************************

// env class
import avm_pkg::*;
import wb_ahb_pkg::*;
import global::*;

class wb_ahb_env extends avm_env;

virtual wb_ahb_if pin_if;// interface

// operational components
wb_ahb_stim_gen    stim_gen;
wb_ahb_driver      driver;
wb_ahb_responder   responder;

// analysis components
wb_ahb_monitor     monitor;
wb_ahb_coverage	   coverage;
wb_ahb_scoreboard  scoreboard;

tlm_fifo #(wb_req_pkt) fifo;

avm_analysis_port#(monitor_pkt) e_ap;
	
	function new (virtual wb_ahb_if pin);
		stim_gen   =new("stim_gen",this);
		driver     =new("driver",this);
		responder  =new("responder",this);
		monitor	   =new("monitor",this);
		coverage   =new("coverage", this);
		scoreboard =new("scoreboard", this);
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
			#700;
		join
	endtask
	
endclass

