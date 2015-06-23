//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : ram_async_1r_sync_1w.v
// Generated : April 25,2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Synch Write, Asynch Read RAM, NOT synthesizable
// In real silicon, use register file (DFF) instead of RAM 
// legal range:data_width   [ 1 to 128 ]
// legal range:data_depth   [ 2 to 256 ]
// Input data :data_in[data_width-1:0]
// Output data:data_out[data_width-1:0]
// Read Address :rd_addr[addr_width-1:0]
// Write Address:wr_addr[addr_width-1:0]
// Write enable (active low): wr_n
// Chip select (active low): cs_n
// Reset (active low): rst_n
// Clock:clk
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"
module ram_async_1r_sync_1w (clk, rst_n, cs_n, wr_n, rd_addr, wr_addr, data_in, data_out);

  parameter data_width = 4;	//will be overrided during module instantiation
  parameter data_depth = 8; //will be overrided during module instantiation
  
  `define addr_width ((data_depth>16)?((data_depth>64)?((data_depth>128)?8:7):((data_depth>32)?6:5)):((data_depth>4)?((data_depth>8)?4:3):((data_depth>2)?2:1)))
  
  input clk;
  input rst_n;
  input cs_n;
  input wr_n; 
  input [data_width-1:0] data_in;
  input [`addr_width-1:0] rd_addr;
  input [`addr_width-1:0] wr_addr;
  output [data_width-1:0] data_out;
   
  reg [data_width-1:0] ram [data_depth-1:0];
  
  //data_width & data_depth check
  initial 
  	begin:parameter_check
    	integer param_error_flag;
    	param_error_flag = 0;
    
      if ( (data_width < 1) || (data_width > 128) ) 
    		begin
      		param_error_flag = 1;
      		$display("Error: %m :\n  Invalid value (%d) for parameter data_width (legal range: 1 to 128)",data_width );
    		end
  
    	if ( (data_depth < 2) || (data_depth > 256 ) ) 
    		begin
      		param_error_flag = 1;
      		$display("Error: %m :\n  Invalid value (%d) for parameter data_depth (legal range: 2 to 256 )",data_depth );
    		end
  
     	if ( param_error_flag == 1) 
     		begin
      		$display("%m :\n  Simulation aborted due to invalid parameter value(s)");
      		$finish;
    		end

  	end // end data_width & data_depth check
   
  //read
  assign data_out = ((rd_addr ^ rd_addr) !== {`addr_width{1'b0}})? {data_width{1'bx}} : ((rd_addr >= data_depth)? {data_width{1'b0}} : ram[rd_addr] );
    
	//write
	always @ (posedge clk)
		if (!cs_n && !wr_n)
			ram[wr_addr] <= data_in;
			
endmodule
		