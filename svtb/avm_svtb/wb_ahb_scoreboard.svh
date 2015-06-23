//******************************************************************************************************
// Copyright (c) 2007 TooMuch Semiconductor Solutions Pvt Ltd.


//File name             :       wb_ahb_scoreboard.svh
//Designer		:	Ravi S Gupta
//Date                  :       4 Sept, 2007
//Description           :       Stimulus Generation for WISHBONE_AHB Bridge
//Revision              :       1.0

//******************************************************************************************************

// scoreboard class
import avm_pkg::*;
import global::*;

class wb_ahb_scoreboard extends avm_threaded_component;

analysis_fifo#(monitor_pkt) ap_fifo; // analysis port fifo 
analysis_if#(monitor_pkt) ap_if; // analysis port  interface
// local variables 

logic [AWIDTH-1:0]adr1; //WB ADDR
logic [DWIDTH-1:0]dat1; //WB DATA
logic [AWIDTH-1:0]adr2; //AHB ADDR
logic [DWIDTH-1:0]dat2; //WB DATA

// monitor packet
monitor_pkt m_pkt;	

virtual ahb_wb_if pin_if;

	function new(string name ,avm_named_component parent);
		super.new(name,parent);
		ap_fifo  =new("ap_fifo",this);
		ap_if =null;
		pin_if =null;
	endfunction

// connecting analysis fifo to the analysis interface
function void export_connections();
	ap_if = ap_fifo.analysis_export;
endfunction 

task run;
forever	
	begin
	ap_fifo.get(m_pkt);
		if(m_pkt.stb && m_pkt.ack)  //No wait state
			if(m_pkt.wr) //write mode
				if(m_pkt.flag1) // first clock comparison only between addresses
				begin
					adr1=m_pkt.adr1;
					dat1=m_pkt.dat1;
					adr2=m_pkt.adr2;
					if(m_pkt.flag2) // first clock after after wait state 
					begin
						if((( adr1==m_pkt.adr1) && (dat1==m_pkt.dat1)  && (adr2==m_pkt.adr2)  && (dat2==m_pkt.dat2))|| (( m_pkt.adr1 === m_pkt.adr2 ) && (m_pkt.dat1 === dat2)));
						
							//avm_report_message("Scoreboard: Write Passed","after wait state");
						else
							avm_report_warning("Scoreboard: Error in write after wait state",display_pkt(m_pkt));
						adr1=m_pkt.adr1; // Holding the previous WB address 
						dat1=m_pkt.dat1; // Holding the previous WB data
						adr2=m_pkt.adr2; // Holding the previous AHB Addr
							
					end
					else
						begin
						if(( m_pkt.adr1 === m_pkt.adr2 ) && (m_pkt.dat1 === dat2));
							//avm_report_message("Scoreboard: Write Passed","without wait state");
						else
							avm_report_warning("Scoreboard: Error in write without wait state",display_pkt(m_pkt));
						end
					end
			else //READ Mode
				if(m_pkt.flag1) // first clock comaprison between addresses
				begin
					adr1=m_pkt.adr1;// Holding the previous WB address
					adr2=m_pkt.adr2;// Holding the previous AHB Addr
					if(m_pkt.flag2) // first clock after after wait state
					begin
						if((( adr1==m_pkt.adr1) && (dat1==m_pkt.dat1)  && (adr2==m_pkt.adr2)  && (dat2==m_pkt.dat2))|| (( adr1 === m_pkt.adr2 ) && (m_pkt.dat1 === m_pkt.dat2)));
							//avm_report_message("Scoreboard: Read Passed","after wait state");
						else
						
							avm_report_warning("Scoreboard: Error in read after wait state",display_pkt(m_pkt));
						adr1=m_pkt.adr1;
						adr2=m_pkt.adr2;
					end
					else
					begin
						if(( adr1 === m_pkt.adr2 ) && (m_pkt.dat1 === m_pkt.dat2)); // comparing unknown values too
							//avm_report_message("Scoreboard: Read Passed","without wait state");
						else
							avm_report_warning("Scoreboard: Error in read without wait state",display_pkt(m_pkt));
						adr1=m_pkt.adr1;
						adr2=m_pkt.adr2;
					end
				end
		else // wait state by slave or master		
		begin
			if(m_pkt.flag2) // latch the value
			begin
				adr1=m_pkt.adr1;
				dat1=m_pkt.dat1;
				adr2=m_pkt.adr2;
				dat2=m_pkt.dat2;
			end
			else
			begin
				if(( adr1==m_pkt.adr1) && (dat1==m_pkt.dat1)  && (adr2==m_pkt.adr2)  && (dat2==m_pkt.dat2));
					//avm_report_message("Scoreboard: Passed","with wait state");
				else
					avm_report_warning("Scoreboard: Error in with wait state",display_pkt(m_pkt));
			end
		end
						
	end		
endtask


// function to display values at any instant 
function string display_pkt(input monitor_pkt m);
	string s;
		$sformat(s,"current_adr1=%0d,adr1=%0d,adr2=%0d,dat1=%0d,dat2=%0d,wr=%0b,stb=%0b,f1=%b,f2=%b",adr1,m.adr1,m.adr2,m.dat1,m.dat2,m.wr,m.stb,m.flag1,m.flag2);
		return s;
endfunction


endclass







