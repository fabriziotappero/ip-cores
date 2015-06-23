//******************************************************************************************************
// Copyright (c) 2007 TooMuch Semiconductor Solutions Pvt Ltd.


//File name             :       wb_ahb_responder.svh
//Designer		:	Ravi S Gupta
//Date                  :       4 Sept, 2007
//Description   	:       Response from AHB to the Inputs from Wishbone
//Revision              :       1.0

//******************************************************************************************************


// responder class
import avm_pkg::*;
import global::*;
class wb_ahb_responder extends avm_threaded_component;

int cnt;
// local memory in AHB slave model
logic [DWIDTH-1 : 0] ahb_mem [AWIDTH-1 : 0]; 

logic [AWIDTH-1:0] haddr_temp;
logic [DWIDTH-1 :0] hrdata_temp;
logic hwrite_temp;

virtual wb_ahb_if pin_if;

	function new(string name ,avm_named_component parent);
		super.new(name,parent);
		pin_if   =null;
	endfunction

// task to sample address
task samp_addr;
	forever 
		begin
		@(posedge pin_if.master_wb.clk_i);
				if(pin_if.master_wb.rst_i)	
					begin
					pin_if.slave_ba.hready='b0;
					pin_if.slave_ba.hwdata='bx;
					pin_if.slave_ba.hresp='b00;

					end
				else if(!pin_if.slave_ba.hwrite)
					begin
					pin_if.slave_ba.hrdata= #2 pin_if.slave_ba.haddr+1;
					end
		end
endtask

	
task response;
	forever
	begin
	@(posedge pin_if.master_wb.clk_i);
	end
endtask	

//*****************************************
//Write operations with no wait states
//*****************************************
task wait_state_by_slave;
	pin_if.slave_ba.hready='b1;
		do
			begin
			@(posedge pin_if.master_wb.clk_i);
			cnt++;
			end
		while (cnt <= 9);//Write operations with no wait states for 10 clk cycles
//************************************************
//Write operations with wait states from AHB Slave
//************************************************
	#2 pin_if.slave_ba.hready='b0; 
	cnt=0;
		do
			begin
			@(posedge pin_if.master_wb.clk_i);
			++cnt;
			end
		while (cnt <= 4);// 5 clock cycle asserted AHB Master is in Wait State
//*****************************************
//Write operations with no wait states
//*****************************************
	#2 pin_if.slave_ba.hready='b1;
	cnt=0;
		do
			begin
			@(posedge pin_if.master_wb.clk_i);
			cnt++;
			end
		while (cnt <= 4);//Write operations with no wait states for 5 clk cycles
//***********************************************
//Write operations with wait states from WB Master
//***********************************************
	 #2 pin_if.slave_ba.hready='b1; 
	cnt=0;
		do
			begin
			@(posedge pin_if.master_wb.clk_i);
			++cnt;
			end
		while (cnt <= 4);// 5 clock cycle deasserted WB Master is in Wait State
//*****************************************
//Write operations with no wait states
//*****************************************
	#2 pin_if.slave_ba.hready='b1;
	cnt=0;
		do
			begin
			@(posedge pin_if.master_wb.clk_i);
			cnt++;
			end
		while (cnt <= 4);//Write operations with no wait states for 5 clk cycles

//*************************************
//Read operations without wait states
//*************************************
	#2 pin_if.slave_ba.hready='b1; 
	cnt=0;
		do
			begin
				@(posedge pin_if.master_wb.clk_i);
			cnt++;
			end
	while (cnt <= 9);// Read operations with no wait states for 10 clk cycles

//**********************************************
//Read operations with wait states from AHB Slave
//**********************************************
	#2 pin_if.slave_ba.hready='b0; 
	cnt=0;
		do
			begin
				@(posedge pin_if.master_wb.clk_i);
			++cnt;
			end
	while (cnt <= 9);// 10 clock cycle asserted AHB Master is in Wait State

//*************************************
//Read operations without wait states
//*************************************
	#2 pin_if.slave_ba.hready='b1; 
	cnt=0;
		do
			begin
				@(posedge pin_if.master_wb.clk_i);
			cnt++;
			end
	while (cnt <= 9);// Read operations with no wait states for 10 clk cycles
//**********************************************
//Read operations with wait states from WB Master
//**********************************************
	#2 pin_if.slave_ba.hready='b1; 
	cnt=0;
		do
			begin
				@(posedge pin_if.master_wb.clk_i);
			++cnt;
			end
		while (cnt <= 9);// 10 clock cycle  asserted WB Master in in Wait state

endtask 
// run all task
task run;
	fork
	samp_addr;
	response;
	join
endtask 

endclass
