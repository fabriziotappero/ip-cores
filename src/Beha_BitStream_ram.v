//--------------------------------------------------------------------------------------------------
// Design    : nova
// Author(s) : Ke Xu
// Email	   : eexuke@yahoo.com
// File      : Beha_BitStream_ram.v
// Generated : May 16,2005
// Copyright (C) 2008 Ke Xu                
//-------------------------------------------------------------------------------------------------
// Description 
// Behavior RAM for encoded bitstream storing, NOT synthesizable
//-------------------------------------------------------------------------------------------------

// synopsys translate_off
`include "timescale.v"
// synopsys translate_on
`include "nova_defines.v"

module Beha_BitStream_ram(clk,BitStream_ram_ren,BitStream_ram_addr,BitStream_ram_data);
	input clk;
	input BitStream_ram_ren;
	input [16:0] BitStream_ram_addr; 
	
	output [15:0] BitStream_ram_data;
	
	reg [15:0] BitStream_ram_data;
	reg [15:0] BitStream_ram[0:`Beha_Bitstream_ram_size];  
	
	initial	
		begin
			$readmemh("D:/nova_opencores/bin2hex/akiyo300_1ref.txt",BitStream_ram);
		end
		
	always @ (posedge clk)
		if (BitStream_ram_ren == 0)
			BitStream_ram_data <= #2 BitStream_ram[BitStream_ram_addr];	
			
endmodule
