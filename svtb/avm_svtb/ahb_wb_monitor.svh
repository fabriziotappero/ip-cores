///////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//*****************************************************************************************************************
// Copyright (c) 2007 TooMuch Semiconductor Solutions Pvt Ltd.
//
//File name		:	ahb_wb_monitor.svh	
//Designer		: 	Sanjay kumar	
//Date			: 	3rd Aug'2007		
//Description		: 	ahb_wb_monitor:Class to monitor transaction on interface and send a copy of monitor 
//                              packets to each subscribers(scoreboard and coverage).
//Revision		:	1.0
//*****************************************************************************************************************
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////

import avm_pkg::*;
import global::*;

class ahb_wb_monitor extends avm_threaded_component;

avm_analysis_port#(monitor_pkt) ap_sb; // analysis port 
monitor_pkt m_pkt;  // instance of packet

local bit flag1;
local bit flag2;

virtual ahb_wb_if pin_if;

	function new(string name ,avm_named_component parent);
		super.new(name,parent);
		ap_sb = new("ap_sb",this);
		pin_if =null;
	endfunction
// task to monitor event on read/write signal
task rdwr;
	forever 
		begin
		@(pin_if.monitor.hwrite);
		flag1='b1;
		end
endtask
// task to monitor event on hready or htrans (wait state)
task wait_ms;
	forever 
		begin
		@(pin_if.monitor.hready or pin_if.monitor.htrans);
		flag2='b1;
		end		
endtask
		
task main_run;
	forever	
	begin
		@(posedge pin_if.monitor.hclk);	
		if((pin_if.monitor.hready) && (pin_if.monitor.htrans == 'b10)) //No wait state
		begin
			if(pin_if.monitor.hwrite) //write mode
			begin
				if(flag1) // first clock
				begin	
					m_pkt.adr1=pin_if.monitor.haddr;
					m_pkt.wr='b1;
					m_pkt.sel=pin_if.monitor.hready;
					m_pkt.mode=pin_if.monitor.htrans;
					m_pkt.flag1='b1;
					// write packet to scoreboard
					ap_sb.write(m_pkt);
					flag1='b0;
				end
				else
				begin
					m_pkt.adr1=pin_if.monitor.haddr;
					m_pkt.dat1=pin_if.monitor.hwdata;
					m_pkt.adr2=pin_if.monitor.adr_o;
					m_pkt.dat2=pin_if.monitor.dat_o;
					m_pkt.wr='b1;
					m_pkt.sel=pin_if.monitor.hready;
					m_pkt.mode=pin_if.monitor.htrans;
					m_pkt.flag1='b0;
					m_pkt.flag2=flag2;
					ap_sb.write(m_pkt);
				end
			end
			else// read mode
			begin
				if(flag1) // first clock
				begin
					m_pkt.adr1=pin_if.monitor.haddr;
					m_pkt.wr='b0;
					m_pkt.sel=pin_if.monitor.hready;
					m_pkt.mode=pin_if.monitor.htrans;
					m_pkt.flag1='b1;
					//write packet to scoreboard
					ap_sb.write(m_pkt);	
					flag1='b0;
				end
				else
				begin
					m_pkt.adr1=pin_if.monitor.haddr;
					m_pkt.dat1=pin_if.monitor.hrdata;
					m_pkt.adr2=pin_if.monitor.adr_o;
					m_pkt.dat2=pin_if.monitor.dat_i;
					m_pkt.wr='b0;
					m_pkt.sel=pin_if.monitor.hready;
					m_pkt.mode=pin_if.monitor.htrans;
					m_pkt.flag1='b0;
					m_pkt.flag2=flag2;
					// write packet to scoreboard
					ap_sb.write(m_pkt);
				end
			end
		end
		else // wait state by slave or master
		begin
			if(pin_if.monitor.hwrite) // write mode 
			begin
				if(flag2) // latch the value
				begin
					m_pkt.adr1=pin_if.monitor.haddr;
					m_pkt.dat1=pin_if.monitor.hwdata;
					m_pkt.adr2=pin_if.monitor.adr_o;
					m_pkt.dat2=pin_if.monitor.dat_o;
					m_pkt.wr='b1;
					m_pkt.sel=pin_if.monitor.hready;
					m_pkt.mode=pin_if.monitor.htrans;
					m_pkt.flag2='b1;
					ap_sb.write(m_pkt);
					flag2='b0;
				end
				else
				begin
					m_pkt.adr1=pin_if.monitor.haddr;
					m_pkt.dat1=pin_if.monitor.hwdata;
					m_pkt.adr2=pin_if.monitor.adr_o;
					m_pkt.dat2=pin_if.monitor.dat_o;
					m_pkt.wr='b1;
					m_pkt.sel=pin_if.monitor.hready;
					m_pkt.mode=pin_if.monitor.htrans;
					m_pkt.flag2='b0;
					ap_sb.write(m_pkt);
				end
			end
			else	
			begin
				if(flag2) // latch the value
				begin
					m_pkt.adr1=pin_if.monitor.haddr;
					m_pkt.dat1=pin_if.monitor.hrdata;
					m_pkt.adr2=pin_if.monitor.adr_o;
					m_pkt.dat2=pin_if.monitor.dat_i;
					m_pkt.wr='b0;
					m_pkt.sel=pin_if.monitor.hready;
					m_pkt.mode=pin_if.monitor.htrans;
					m_pkt.flag2='b1;
					ap_sb.write(m_pkt);
					flag2='b0;
				end
				else
				begin
					m_pkt.adr1=pin_if.monitor.haddr;
					m_pkt.dat1=pin_if.monitor.hrdata;
					m_pkt.adr2=pin_if.monitor.adr_o;
					m_pkt.dat2=pin_if.monitor.dat_i;
					m_pkt.wr='b0;
					m_pkt.sel=pin_if.monitor.hready;
					m_pkt.mode=pin_if.monitor.htrans;
					m_pkt.flag2='b0;
					ap_sb.write(m_pkt);
				end
			end
		end	
	end
endtask 

// run all task simultanoe task 
task run;
	fork
	   	rdwr();
	   	wait_ms();
		main_run();
	join
endtask

endclass

		
	
