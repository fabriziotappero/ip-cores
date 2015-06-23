/*********************************************************
 MODULE:		Sub Level Bus Arbiter Block

 FILE NAME:	bus_arbiter.v
 VERSION:	1.0
 DATE:		May 7th, 2002
 AUTHOR:		Hossein Amidi
 COMPANY:	
 CODE TYPE:	Register Transfer Level

 DESCRIPTION:	This module is the top level RTL code of Bus Arbiter verilog code.
 
 It will instantiate the following blocks in the ASIC:


 Hossein Amidi
 (C) April 2002

*********************************************************/

// DEFINES
`timescale 1ns / 10ps
 
// TOP MODULE
module bus_arbiter(// Inputs
						reset,
						clk0,
						bus_request,
						dma_dataout,
						dma_addr,
						dma_cmd,
						dcache_dataout,
						dcache_addr,
						dcache_cmd,
						icache_dataout,
						icache_addr,
						icache_cmd,
						sdram_dataout,
						// Outputs
						bus_grant,
						dma_datain,
						dcache_datain,
						icache_datain,
						sdram_addr,
						sdram_cmd,
						sdram_datain
						);


// Parameter
`include        "parameter.v"

// FSM States
parameter 	s_idle  = 8'b0000_0001,
				s_tap1  = 8'b0000_0010,
				s_tap2  = 8'b0000_0100,
				s_tap3  = 8'b0000_1000,
				s_tap4  = 8'b0001_0000,
				s_tap5  = 8'b0010_0000,
				s_tap6  = 8'b0100_0000,
				s_tap7  = 8'b1000_0000;


// Inputs
input reset;
input clk0;
input [arbiter_bus_size - 1 : 0]bus_request;
input [fifo_size - 1 : 0]dma_dataout;
input [padd_size - 1 : 0]dma_addr;
input [cmd_size  - 1 : 0]dma_cmd;
input [data_size - 1 : 0]dcache_dataout;
input [padd_size - 1 : 0]dcache_addr;
input [cmd_size  - 1 : 0]dcache_cmd;
input [data_size - 1 : 0]icache_dataout;
input [padd_size - 1 : 0]icache_addr;
input [cmd_size  - 1 : 0]icache_cmd;
input [data_size - 1 : 0]sdram_dataout;

// Outputs
output [arbiter_bus_size - 1 : 0]bus_grant;
output [fifo_size - 1 : 0]dma_datain;
output [data_size - 1 : 0]dcache_datain;
output [data_size - 1 : 0]icache_datain;
output [padd_size - 1 : 0]sdram_addr;
output [cmd_size - 1 : 0]sdram_cmd;
output [data_size - 1 : 0]sdram_datain;

// Signal Declarations
wire reset;
wire clk0;
wire [arbiter_bus_size - 1 : 0]bus_request;
wire [fifo_size - 1 : 0]dma_dataout;
wire [padd_size - 1 : 0]dma_addr;
wire [cmd_size  - 1 : 0]dma_cmd;
wire [data_size - 1 : 0]dcache_dataout;
wire [padd_size - 1 : 0]dcache_addr;
wire [cmd_size  - 1 : 0]dcache_cmd;
wire [data_size - 1 : 0]icache_dataout;
wire [padd_size - 1 : 0]icache_addr;
wire [cmd_size  - 1 : 0]icache_cmd;
wire [data_size - 1 : 0]sdram_dataout;

wire [arbiter_bus_size - 1 : 0]bus_grant;
wire [fifo_size - 1 : 0]dma_datain;
wire [data_size - 1 : 0]dcache_datain;
wire [data_size - 1 : 0]icache_datain;
wire [padd_size - 1 : 0]sdram_addr;
wire [cmd_size - 1 : 0]sdram_cmd;
wire [data_size - 1 : 0]sdram_datain;

reg [arbiter_bus_size - 1 : 0]rbus_grant;
reg [fifo_size - 1 : 0]rdma_datain;
reg [data_size - 1 : 0]rdcache_datain;
reg [data_size - 1 : 0]ricache_datain;
reg [padd_size - 1 : 0]rsdram_addr;
reg [cmd_size - 1 : 0]rsdram_cmd;
reg [data_size - 1 : 0]rsdram_datain;


// State Registers
reg [7:0]state;

 
// Assignment statments


assign bus_grant = rbus_grant;
assign dma_datain = rdma_datain;
assign dcache_datain = rdcache_datain;
assign icache_datain = ricache_datain;
assign sdram_addr = rsdram_addr;
assign sdram_cmd = rsdram_cmd;
assign sdram_datain = rsdram_datain;



// FSM Sequential Section ( One-Hot encoding )
always @(posedge reset or posedge clk0)
begin
	if(reset == 1'b1)
		state = s_idle;
	else
	begin
		casex({bus_request,state})

			11'b000_0000_0001:
					state = s_idle;
			11'b001_0000_0001:
					state = s_tap1;
			11'b010_0000_0001:
					state = s_tap2;
			11'b011_0000_0001:
					state = s_tap3;
			11'b100_0000_0001:
					state = s_tap4;
			11'b101_0000_0001:
					state = s_tap5;
			11'b110_0000_0001:
					state = s_tap6;
			11'b111_0000_0001:
					state = s_tap7;
			11'b000_0000_0010:
					state = s_idle;
			11'b001_0000_0010:
					state = s_tap1;
			11'b000_0000_0100:
					state = s_idle;
			11'b010_0000_0100:
					state = s_tap2;
			11'b001_0000_1000:
					state = s_tap1;
			11'b011_0000_1000:
					state = s_tap3;
			11'b000_0001_0000:
					state = s_idle;
			11'b100_0001_0000:
					state = s_tap4;
			11'b101_0010_0000:
					state = s_tap5;
			11'b001_0010_0000:
					state = s_tap1;
			11'b110_0100_0000:
					state = s_tap6;
			11'b010_0100_0000:
					state = s_tap2;
			11'b111_1000_0000:
					state = s_tap7;
			11'b011_1000_0000:
					state = s_tap3;
			default:
					state = s_idle;
		endcase
	end
end


// FSM Presets State Task Call
always @(reset or state)
	state_task(	// Input
					state,
					reset,
					// Outuput
					rbus_grant,
					rdma_datain,
					rdcache_datain,
					ricache_datain,
					rsdram_addr,
					rsdram_cmd,
					rsdram_datain
					);


// FSM Task ( Combinatorial Section )
task state_task;

//INPUTS
input [7:0]state;
input reset;

//OUTPUTS
output [arbiter_bus_size - 1 : 0]rbus_grant;
output [fifo_size - 1 : 0]rdma_datain;
output [data_size - 1 : 0]rdcache_datain;
output [data_size - 1 : 0]ricache_datain;
output [padd_size - 1 : 0]rsdram_addr;
output [cmd_size - 1 : 0]rsdram_cmd;
output [data_size - 1 : 0]rsdram_datain;

// Signal Declaration
reg [arbiter_bus_size - 1 : 0]rbus_grant;
reg [fifo_size - 1 : 0]rdma_datain;
reg [data_size - 1 : 0]rdcache_datain;
reg [data_size - 1 : 0]ricache_datain;
reg [padd_size - 1 : 0]rsdram_addr;
reg [cmd_size - 1 : 0]rsdram_cmd;
reg [data_size - 1 : 0]rsdram_datain;


// Parameter
parameter 	s_idle  = 8'b0000_0001,
				s_tap1  = 8'b0000_0010,
				s_tap2  = 8'b0000_0100,
				s_tap3  = 8'b0000_1000,
				s_tap4  = 8'b0001_0000,
				s_tap5  = 8'b0010_0000,
				s_tap6  = 8'b0100_0000,
				s_tap7  = 8'b1000_0000;

begin

	if(reset == 1'b1)
	begin
		rbus_grant <= 3'h0;
		rdma_datain <= 8'h0;
		rdcache_datain <= 32'h0;
		ricache_datain <= 32'h0;
		rsdram_addr <= 24'h0;
		rsdram_cmd <= 3'h0;
		rsdram_datain <= 32'h0;
	end
	else
	begin
		case(state)

			s_idle:
			begin
				rbus_grant    <= 3'b000;
				rdma_datain   <= 8'h0;
				rdcache_datain <= 32'h0;
				ricache_datain <= 32'h0;
				rsdram_addr   <= 24'h0;
				rsdram_cmd    <= 3'h0;
				rsdram_datain <= 32'h0;
			end

			s_tap1:
			begin
				rbus_grant    <= 3'b001;
				rdma_datain   <= sdram_dataout;
				rdcache_datain <= 32'h0;
				ricache_datain <= 32'h0;
				rsdram_addr   <= dma_addr;
				rsdram_cmd    <= dma_cmd;
				rsdram_datain <= dma_dataout;
			end

			s_tap2:
			begin
				rbus_grant    <= 3'b010;
				rdma_datain   <= 8'h0;
				rdcache_datain <= sdram_dataout;
				ricache_datain <= sdram_dataout;
				rsdram_addr   <= dcache_addr | icache_addr;
				rsdram_cmd    <= dcache_cmd | icache_cmd;
				rsdram_datain <= dcache_dataout;
			end

			s_tap3:
			begin
				rbus_grant    <= 3'b100;
				rdma_datain   <= 8'h0;
				rdcache_datain <= 32'h0;
				ricache_datain <= 32'h0;
				rsdram_addr   <= 24'h0;
				rsdram_cmd    <= 3'h0;
				rsdram_datain <= dcache_dataout;
			end

			s_tap4:
			begin
				rbus_grant    <= 3'b100;
				rdma_datain   <= 8'h0;
				rdcache_datain <= 32'h0;
				ricache_datain <= 32'h0;
				rsdram_addr   <= 24'h0;
				rsdram_cmd    <= 3'h0;
				rsdram_datain <= icache_dataout;
			end

			s_tap5:
			begin
				rbus_grant    <= 3'b100;
				rdma_datain   <= 8'h0;
				rdcache_datain <= 32'h0;
				ricache_datain <= 32'h0;
				rsdram_addr   <= 24'h0;
				rsdram_cmd    <= 3'h0;
				rsdram_datain <= dcache_dataout;
			end

			s_tap6:
			begin
				rbus_grant    <= 3'b100;
				rdma_datain   <= 8'h0;
				rdcache_datain <= 32'h0;
				ricache_datain <= 32'h0;
				rsdram_addr   <= 24'h0;
				rsdram_cmd    <= 3'h0;
				rsdram_datain <= icache_dataout;
			end

			s_tap7:
			begin
				rbus_grant    <= 3'b100;
				rdma_datain   <= 8'h0;
				rdcache_datain <= 32'h0;
				ricache_datain <= 32'h0;
				rsdram_addr   <= 24'h0;
				rsdram_cmd    <= 3'h0;
				rsdram_datain <= dma_dataout;
			end

			default:
			begin
				rbus_grant    <= 3'b100;
				rdma_datain   <= 8'h0;
				rdcache_datain <= 32'h0;
				ricache_datain <= 32'h0;
				rsdram_addr   <= 24'h0;
				rsdram_cmd    <= 3'h0;
				rsdram_datain <= dcache_dataout;
			end
		 endcase
	end
end
endtask


endmodule
