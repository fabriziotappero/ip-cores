//******************************************************************************************************
// Copyright (c) 2007 TooMuch Semiconductor Solutions Pvt Ltd.


//File name             :       wb_ahb_monitor.svh
//Designer		:	Ravi S Gupta
//Date                  :       4 Sept, 2007
//Description           :       Monitor for WISHBONE_AHB Bridge
//Revision              :       1.0

//******************************************************************************************************

// monitor class
import avm_pkg::*;
import global::*;
class wb_ahb_monitor extends avm_threaded_component;

avm_analysis_port#(monitor_pkt) ap_sb; // analysis port for Score board
monitor_pkt m_pkt;  // instance of packet

local bit flag1;
local bit flag2;

virtual wb_ahb_if pin_if;

	function new(string name ,avm_named_component parent);
		super.new(name,parent);
		ap_sb = new("ap_sb",this);
		pin_if =null;
	endfunction
// task to monitor event on read/write signal
task rdwr;
	forever 
		begin
		@(pin_if.monitor.we_i);
		flag1='b1;
		end
endtask
// task to monitor event on ack_o or stb_i (wait state)
task wait_ms;
	forever 
		begin
		@(pin_if.monitor.stb_i or pin_if.monitor.ack_o);
		flag2='b1;
		end		
endtask

task main_run;
	forever	
	begin
		@(posedge pin_if.monitor.clk_i);	
		if(pin_if.monitor.stb_i)//No wait state
		   begin
		    if(pin_if.monitor.we_i) //write mode
			begin
				if(flag1) // first clock
				begin	
					m_pkt.adr1=pin_if.monitor.addr_i;// Get WB addr and Data along with AHB addr
					m_pkt.dat1=pin_if.monitor.data_i;
					m_pkt.adr2=pin_if.monitor.haddr;
					m_pkt.wr='b1;
					m_pkt.stb=pin_if.monitor.stb_i;
					m_pkt.ack=pin_if.monitor.ack_o;
					m_pkt.flag1='b1;
					// write packet to scoreboard
					ap_sb.write(m_pkt);
					flag1='b0;
				end
				else
				begin
					m_pkt.adr1=pin_if.monitor.addr_i;
					m_pkt.dat1=pin_if.monitor.data_i;
					m_pkt.adr2=pin_if.monitor.haddr;
					m_pkt.dat2=pin_if.monitor.hwdata;
					m_pkt.wr='b1;
					m_pkt.stb=pin_if.monitor.stb_i;
					m_pkt.ack=pin_if.monitor.ack_o;
					m_pkt.flag1='b0;
					m_pkt.flag2=flag2;
					ap_sb.write(m_pkt);
				end
			end
			else// read mode
			begin
				if(flag1) // first clock
				begin
					m_pkt.adr1=pin_if.monitor.addr_i;//Get addr from both WB and AHB
					m_pkt.adr2=pin_if.monitor.haddr;
					m_pkt.wr='b0;
					m_pkt.stb=pin_if.monitor.stb_i;
					m_pkt.ack=pin_if.monitor.ack_o;
					m_pkt.flag1='b1;
					//write packet to scoreboard
					ap_sb.write(m_pkt);	
					flag1='b0;
				end
				else
				begin
					m_pkt.adr1=pin_if.monitor.addr_i;
					m_pkt.dat1=pin_if.monitor.data_o;
					m_pkt.adr2=pin_if.monitor.haddr;
					m_pkt.dat2=pin_if.monitor.hrdata;
					m_pkt.wr='b0;
					m_pkt.stb=pin_if.monitor.stb_i;
					m_pkt.ack=pin_if.monitor.ack_o;
					m_pkt.flag1='b0;
					m_pkt.flag2=flag2;
					// write packet to scoreboard
					ap_sb.write(m_pkt);
				end
			end
		end
		else // wait state by slave or master
		begin
			if(pin_if.monitor.we_i) // write mode 
			begin
				if(flag2) // latch the value
				begin
					m_pkt.adr1=pin_if.monitor.addr_i;
					m_pkt.dat1=pin_if.monitor.data_i;
					m_pkt.adr2=pin_if.monitor.haddr;
					m_pkt.dat2=pin_if.monitor.hwdata;
					m_pkt.wr='b1;
					m_pkt.stb=pin_if.monitor.stb_i;
					m_pkt.ack=pin_if.monitor.ack_o;
					m_pkt.flag2='b1;
					ap_sb.write(m_pkt);
					flag2='b0;
				end
				else
				begin
					m_pkt.adr1=pin_if.monitor.addr_i;
					m_pkt.dat1=pin_if.monitor.data_i;
					m_pkt.adr2=pin_if.monitor.haddr;
					m_pkt.dat2=pin_if.monitor.hwdata;
					m_pkt.wr='b1;
					m_pkt.stb=pin_if.monitor.stb_i;
					m_pkt.ack=pin_if.monitor.ack_o;
					m_pkt.flag2='b0;
					ap_sb.write(m_pkt);
				end
			end
			else	
			begin
				if(flag2) // latch the value
				begin
					m_pkt.adr1=pin_if.monitor.addr_i;
					m_pkt.dat1=pin_if.monitor.data_o;
					m_pkt.adr2=pin_if.monitor.haddr;
					m_pkt.dat2=pin_if.monitor.hrdata;
					m_pkt.wr='b0;
					m_pkt.stb=pin_if.monitor.stb_i;
					m_pkt.ack=pin_if.monitor.ack_o;
					m_pkt.flag2='b1;
					ap_sb.write(m_pkt);
					flag2='b0;
				end
				else
				begin
					m_pkt.adr1=pin_if.monitor.addr_i;
					m_pkt.dat1=pin_if.monitor.data_o;
					m_pkt.adr2=pin_if.monitor.haddr;
					m_pkt.dat2=pin_if.monitor.hrdata;
					m_pkt.wr='b0;
					m_pkt.stb=pin_if.monitor.stb_i;
					m_pkt.ack=pin_if.monitor.ack_o;
					m_pkt.flag2='b0;
					ap_sb.write(m_pkt);
				end
			end
		end
	end	
endtask 

// run all task simultaneously 
task run;
	fork
	   	rdwr();
	   	wait_ms();
		main_run();
	join
endtask

endclass


