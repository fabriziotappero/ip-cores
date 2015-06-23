/**********************************************************
 MODULE:		Sub Level Least Recently Used Instruction Cache

 FILE NAME:	lru_instruction_cache.v
 VERSION:	1.0
 DATE:		May 7th, 2002
 AUTHOR:		Hossein Amidi
 COMPANY:	
 CODE TYPE:	Register Transfer Level

 DESCRIPTION:	This module is the top level RTL code of LRU
 instruction Cache verilog code.
 
 It will instantiate the following blocks in the ASIC:

 1)	Instruction Cache Way 0
 2)	Instruction Cache Way 1
 3)	Instruction Cache Way 2
 4)	Instruction Cache Way 3


 Hossein Amidi
 (C) April 2002

*********************************************************/

// DEFINES
`timescale 1ns / 10ps
 
// TOP MODULE
module lru_instruction_cache(// Inputs
						reset,
						clk0,
						cache_host_addr,
						cache_host_cmd,
						cache_request,
						cache_host_datain,
						cache_bus_grant,
						cache_datain,
						// Outputs
						cache_host_dataout,
						cache_hit,
						cache_miss,
						cache_bus_request,
						cache_addr,
						cache_cmd,
						cache_dataout
						);


// Parameter
`include        "parameter.v"

// Inputs
input reset;
input clk0;
input [padd_size - 1 : 0]cache_host_addr;
input [cmd_size  - 1 : 0]cache_host_cmd;
input cache_request;
input [data_size - 1 : 0]cache_host_datain;
input cache_bus_grant;
input [data_size - 1 : 0]cache_datain;

// Outputs
output [data_size - 1 : 0]cache_host_dataout;
output cache_hit;
output cache_miss;
output cache_bus_request;
output [padd_size - 1 : 0]cache_addr;
output [cmd_size  - 1 : 0]cache_cmd;
output [data_size - 1 : 0]cache_dataout;

// Signal Declarations
wire reset;
wire clk0;
wire [padd_size - 1 : 0]cache_host_addr;
wire [cmd_size  - 1 : 0]cache_host_cmd;
wire cache_request;
wire [data_size - 1 : 0]cache_host_datain;
wire cache_bus_grant;
wire [data_size - 1 : 0]cache_datain;

reg [data_size - 1 : 0]cache_host_dataout;
reg cache_hit;
reg cache_miss;
wire cache_bus_request;
reg [padd_size - 1 : 0]cache_addr;
reg [cmd_size  - 1 : 0]cache_cmd;
reg [data_size - 1 : 0]cache_dataout;

wire [cache_line_size - 1 : 0]instruction_cache_datain_way0;
wire [cache_line_size - 1 : 0]instruction_cache_datain_way1;
wire [cache_line_size - 1 : 0]instruction_cache_datain_way2;
wire [cache_line_size - 1 : 0]instruction_cache_datain_way3;
wire [cache_line_size - 1 : 0]instruction_cache_dataout_way0;
wire [cache_line_size - 1 : 0]instruction_cache_dataout_way1;
wire [cache_line_size - 1 : 0]instruction_cache_dataout_way2;
wire [cache_line_size - 1 : 0]instruction_cache_dataout_way3;

wire cache_wr;
reg  [cache_valid - 1 : 0]valid0;
reg  [cache_valid - 1 : 0]valid1;
reg  [cache_valid - 1 : 0]valid2;
reg  [cache_valid - 1 : 0]valid3;
wire [cache_tag - 1 : 0]tag;
wire [cache_tag - 1 : 0]read_tag0;
wire [cache_tag - 1 : 0]read_tag1;
wire [cache_tag - 1 : 0]read_tag2;
wire [cache_tag - 1 : 0]read_tag3;

wire [cache_valid - 1 : 0]wvalid0;
wire [cache_valid - 1 : 0]wvalid1;
wire [cache_valid - 1 : 0]wvalid2;
wire [cache_valid - 1 : 0]wvalid3;


/********* Internal Register of Instruction cache configuration *********/
reg [cache_reg_width - 1 : 0] cache_register [cache_reg_depth - 1 : 0];



// Assignment statments
assign cache_bus_request = cache_miss;
assign cache_wr = (cache_host_cmd == 010) ? 1'b1 : 1'b0;

assign tag = cache_host_addr[23:5];
assign read_tag0 = instruction_cache_dataout_way0[50:32];
assign read_tag1 = instruction_cache_dataout_way1[50:32];
assign read_tag2 = instruction_cache_dataout_way2[50:32];
assign read_tag3 = instruction_cache_dataout_way3[50:32];
assign instruction_cache_datain_way0 = ({wvalid0,tag,cache_datain});
assign instruction_cache_datain_way1 = ({wvalid1,tag,cache_datain});
assign instruction_cache_datain_way2 = ({wvalid2,tag,cache_datain});
assign instruction_cache_datain_way3 = ({wvalid3,tag,cache_datain});

assign wvalid0 = valid0;
assign wvalid1 = valid1;
assign wvalid2 = valid2;
assign wvalid3 = valid3;

/********************************** Sub Level Instantiation *********************************/


instruction_cache_way0 instruction_cache_way0_0 (// Input
																.A(cache_host_addr[4:0]),
																.CLK(clk0),
																.D(instruction_cache_datain_way0),
																.WE(cache_wr),
																.SPO(instruction_cache_dataout_way0));


instruction_cache_way1 instruction_cache_way1_0 (// Input
																.A(cache_host_addr[4:0]),
																.CLK(clk0),
																.D(instruction_cache_datain_way1),
																.WE(cache_wr),
																.SPO(instruction_cache_dataout_way1));


instruction_cache_way2 instruction_cache_way2_0 (// Input
																.A(cache_host_addr[4:0]),
																.CLK(clk0),
																.D(instruction_cache_datain_way2),
																.WE(cache_wr),
																.SPO(instruction_cache_dataout_way2));


instruction_cache_way3 instruction_cache_way3_0 (// Input
																.A(cache_host_addr[4:0]),
																.CLK(clk0),
																.D(instruction_cache_datain_way3),
																.WE(cache_wr),
																.SPO(instruction_cache_dataout_way3));



// Generate the LRU talbe
always @(posedge reset or posedge clk0)
begin
	if(reset == 1'b1)
	begin
		valid0 <= 2'b00;
		valid1 <= 2'b00;
		valid2 <= 2'b10;
		valid3 <= 2'b10;
	end
	else
	begin
		if((cache_wr == 1'b1) && (wvalid0 == 2'b00))
			valid0 <= 2'b01;
		else
		if((cache_wr == 1'b1) && (wvalid0 == 2'b01))
			valid0 <= 2'b00;
		else
		if((cache_wr == 1'b1) && (wvalid1 == 2'b00))
			valid1 <= 2'b01;
		else
		if((cache_wr == 1'b1) && (wvalid1 == 2'b01))
			valid1 <= 2'b00;
		else
		if((cache_wr == 1'b1) && (wvalid2 == 2'b10))
			valid2 <= 2'b11;
		else
		if((cache_wr == 1'b1) && (wvalid2 == 2'b11))
			valid2 <= 2'b10;
		else
		if((cache_wr == 1'b1) && (wvalid3 == 2'b10))
			valid3 <= 2'b11;
		else
		if((cache_wr == 1'b1) && (wvalid3 == 2'b11))
			valid3 <= 2'b10;
	end
end


// Check for cache way validity, if matches generate the cache hit signal
// else generate cache miss signal
always @(posedge reset or posedge clk0)
begin
	if(reset == 1'b1)
		cache_dataout <= 32'h0;
	else
	if((cache_request == 1'b1) && (cache_host_cmd == 001) && (read_tag0 == cache_host_addr[23:5]))
	begin
		cache_hit <= 1'b1;
		cache_dataout <= instruction_cache_dataout_way0[31:0];
	end
	else
	if((cache_request == 1'b1) && (cache_host_cmd == 001) && (read_tag1 == cache_host_addr[23:5]))
	begin
		cache_hit <= 1'b1;
		cache_dataout <= instruction_cache_dataout_way1[31:0];
	end
	else
	if((cache_request == 1'b1) && (cache_host_cmd == 001) && (read_tag2 == cache_host_addr[23:5]))
	begin
		cache_hit <= 1'b1;
		cache_dataout <= instruction_cache_dataout_way2[31:0];
	end
	else
	if((cache_request == 1'b1) && (cache_host_cmd == 001) && (read_tag3 == cache_host_addr[23:5]))
	begin
		cache_hit <= 1'b1;
		cache_dataout <= instruction_cache_dataout_way3[31:0];
	end
	else
	if((cache_request == 1'b1) && (cache_host_cmd == 001))
	begin
		cache_miss <= 1'b1;
		cache_hit  <= 1'b0;
		cache_dataout <= 32'h0;
	end
	else
	begin
		cache_miss <= 1'b0;
		cache_hit  <= 1'b0;
		cache_dataout <= 32'h0;
	end
end


// Access to internal register by CPU address and command signals (write/read)
always @(posedge reset or posedge clk0)
begin
	if(reset == 1'b1)
	begin
		cache_host_dataout <= 32'h0;
		cache_register[0] <= 32'h0;
		cache_register[1] <= 32'h0;
		cache_register[2] <= 32'h0;
		cache_register[3] <= 32'h0;
		cache_register[4] <= 32'h0;
		cache_register[5] <= 32'h0;
		cache_register[6] <= 32'h0;
		cache_register[7] <= 32'h0;
	end
	else
	begin
		if(cache_host_cmd == 3'b010)	// Write from Host to Cache internal Registers
		begin
			case (cache_host_addr)
			
				24'h080018:	cache_register[0] <= cache_host_datain;	// Status Register
				24'h080019:	cache_register[1] <= cache_host_datain;	// Read Master Start Address
				24'h08001A:	cache_register[2] <= cache_host_datain;	// Write Master Start Address
				24'h08001B:	cache_register[3] <= cache_host_datain;	// Length in Bytes
				24'h08001C:	cache_register[4] <= cache_host_datain;	// Reserved
				24'h08001D:	cache_register[5] <= cache_host_datain; 	// Reserved
				24'h08001E:	cache_register[6] <= cache_host_datain;	// Control
				24'h08001F:	cache_register[7] <= cache_host_datain; 	// Reserved
			endcase
		end
		else
		if(cache_host_cmd == 3'b001)	// Read from Cache internal Registers to Host
		begin
			case (cache_host_addr)
			
				24'h080018:	cache_host_dataout <= cache_register[0];
				24'h080019:	cache_host_dataout <= cache_register[1];
				24'h08001A:	cache_host_dataout <= cache_register[2];
				24'h08001B:	cache_host_dataout <= cache_register[3];
				24'h08001C:	cache_host_dataout <= cache_register[4];
				24'h08001D:	cache_host_dataout <= cache_register[5];
				24'h08001E:	cache_host_dataout <= cache_register[6];
				24'h08001F:	cache_host_dataout <= cache_register[7];
			endcase
		end
	end	
end


always @(posedge reset or posedge clk0)
begin
	if(reset == 1'b1)
	begin
		cache_addr <= 24'h0;
		cache_cmd <= 3'h0;
	end
	else
	begin
		cache_addr <= cache_bus_grant & cache_host_addr;
		cache_cmd <= cache_bus_grant & cache_host_cmd;
	end
end

endmodule
