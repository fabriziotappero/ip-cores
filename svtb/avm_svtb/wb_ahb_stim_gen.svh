//******************************************************************************************************
// Copyright (c) 2007 TooMuch Semiconductor Solutions Pvt Ltd.


//File name             :       wb_ahb_stim_gen.svh
//Designaer		:	Ravi S Gupta
//Date                  :       4 Sept, 2007
//Description   	:       Stimulus Generation for WISHBONE_AHB Bridge
//Revision              :       1.0

//******************************************************************************************************

// class to generate write and read packet
import avm_pkg::*;
import global::*;
class wb_ahb_stim_gen extends avm_named_component;


avm_blocking_put_port#( wb_req_pkt) initiator_port;
tlm_fifo#(wb_req_pkt) fifo;

	function new(string name ,avm_named_component parent);
		super.new(name,parent);
		initiator_port=new("initiatot_port",this);
		fifo =new("fifo",this);
	endfunction

task stimulus(input int count = 41);

	wb_req_pkt p;
//*****************************************
//Write operations with no wait states
//*****************************************
		for(int i=0; i<11 ;i++)
		begin
				p.wr='b1;
				p.adr=i+1;	
				p.dat=i;	
				p.stb='b1;	
				write_to_pipe(p);
		end

//************************************************
//Write operations with wait states from AHB Slave
//************************************************
		for(int i=10;i<16;i++)
		begin
				p.wr='b1;//Wait state from AHB SLAVE
				p.stb='b1;
				write_to_pipe(p);
		end

//*****************************************
//Write operations with no wait states
//*****************************************
		for(int i=15; i<21 ;i++)
		begin
				p.wr='b1;
				p.adr=i+1;	
				p.dat=i;
				p.stb='b1;
				write_to_pipe(p);
		end

//***********************************************
//Write operations with wait states from WB Master
//***********************************************
		for(int i=20;i<26;i++)
		begin
				p.stb='b0;
				p.wr='b1;//Wait state from AHB SLAVE
		write_to_pipe(p);
		end

//*****************************************
//Write operations with no wait states
//*****************************************
		for(int i=25; i<31 ;i++)
		begin
				p.wr='b1;
				p.adr=i+1;	
				p.dat=i;
				p.stb='b1;	
				write_to_pipe(p);
		end

//*************************************
//Read operations without wait states
//*************************************
		for(int i=30; i<41 ;i++)
		begin
			
				p.wr='b0;
				p.adr=i+1;
				p.stb='b1;	
				write_to_pipe(p);
		end

//**********************************************
//Read operations with wait states from AHB Slave
//**********************************************
		for(int i=40; i<51 ;i++)
		begin
				p.wr='b0;
				p.stb='b1;	
				write_to_pipe(p);
		end
//*************************************
//Read operations without wait states
//*************************************
		for(int i=50; i<61 ;i++)
		begin
				p.wr='b0;
				p.stb='b1;	
				p.adr=i+1;	
				write_to_pipe(p);
		end
//**********************************************
//Read operations with wait states from WB Master
//**********************************************
		for(int i=60; i<71 ;i++)
		begin
				p.wr='b0;
				p.stb='b0;
				write_to_pipe(p);
		end
//*************************************
//Read operations without wait states
//*************************************
		for(int i=70; i<81 ;i++)
		begin
				p.wr='b0;
				p.stb='b1;	
				p.adr=i+1;	
				write_to_pipe(p);
		end
//*****************************************
//Write operations with no wait states
//*****************************************
		for(int i=80; i<91 ;i++)
		begin
				p.wr='b1;
				p.stb='b1;	
				p.adr=i+1;	
				p.dat=i;	
				write_to_pipe(p);
		end 

endtask

// task to push transaction in the fifo
task write_to_pipe(wb_req_pkt p);
		initiator_port.put(p);
endtask

endclass 
